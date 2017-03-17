//
//  AudioPlayer.swift
//  CS 193P Final Project
//  Portions of the Spotify login code are taken from the Spotify ios sdk tutorial
//
//  Created by Christopher Ponce de Leon on 3/5/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import AVFoundation
import CoreData
import Foundation

private let sharedAudioPlayer = AudioPlayer()

class AudioPlayer : NSObject, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    class var sharedInstance : AudioPlayer {
        return sharedAudioPlayer
    }
    
    private let MAX_PREV_TIME = TimeInterval.init(3)
    private let MAX_NUM_RECENTS = 50
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var queue : [Song] = []
    var playlist : [Song] = []
    
    
    var currentlyPlaying : Song?
    var nextSongPlaying : Song?

    var playlistIndex : Int!
    var recents : [String] = []
    var spotifyPlaying : Bool = false
    var player: SPTAudioStreamingController?
    var authData: SpotifyAuthenticationData!
    var loggedIn = false
    var spotifyShouldStartPlaying = false
    
    var isPlaying : Bool? {
        get {
            if player == nil || player?.initialized == false || player?.playbackState == nil {
                return false
            }
            return player?.playbackState.isPlaying
        }
    }

    var songPosition : TimeInterval? {
        get {
            if player == nil {
                return nil
            } else {
                return player!.playbackState.position
            }
        }
    }
    
    func login(_ authData: SpotifyAuthenticationData!) {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
        }
        player?.delegate = self
        player?.playbackDelegate = self
        if player?.initialized == false {
            try? player?.start(withClientId: authData.clientId)
        }
        player?.login(withAccessToken: authData.getAccessToken())
    }
    
    func playSpotify(authData: SpotifyAuthenticationData!) {
        login(authData)
        spotifyShouldStartPlaying = true
    }
    
    private func updateRecents(_ song : Song?) {
        if song == nil {
            return
        }
        if let returnVal =  UserDefaults.standard.value(forKey: "recents") as? Data {
            if var decodedRecents = NSKeyedUnarchiver.unarchiveObject(with: returnVal) as? [Song] {
                // Ensure only one instance of each song appears in Recents
                for (index, item) in decodedRecents.enumerated() {
                    if index == decodedRecents.count {
                        break
                    }
                    if item.spotifyURL == song?.spotifyURL {
                        print("Removing")
                        decodedRecents.remove(at: index)
                        break
                    }
                }
                decodedRecents.insert(song!, at: 0)
                if (decodedRecents.count > MAX_NUM_RECENTS) {
                    decodedRecents.removeLast()
                }
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: decodedRecents)
                UserDefaults.standard.set(encodedData, forKey: "recents")
            }
        } else {
            var recentSearches = Array<Song>()
            recentSearches.append(song!)
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: recentSearches)
            UserDefaults.standard.set(encodedData, forKey: "recents")
        }
        UserDefaults.standard.synchronize()

    }
    
    // Function to get current date in Swift3 taken off of StackOverflow
    private func getCurrentDate() -> (Int, Int, Int) {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                print("STATS:")
                let request: NSFetchRequest<Artist> = Artist.fetchRequest()
                if let artistCount = (try? context.fetch(request))?.count {
                    print("\(artistCount) unique artists")
                }
                if let songCount = try? context.count(for: SongPlayCount.fetchRequest()) {
                    print ("\(songCount) unique SongPlayCount objects")
                }
            }
        }
    }
    
    private func savePlaybackData() {
        container?.performBackgroundTask {[weak self] context in
            let (day, month, year) = self!.getCurrentDate()
            _ = try? Artist.addPlayedSongToCoreData(artistName: self!.currentlyPlaying!.artist!, artistId: self!.currentlyPlaying!.artistId!, songPlayed: self!.currentlyPlaying!, day: day, month: month, year: year, in: context)
            try? context.save()
        }
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("in didStartPlayingTrack for track \(playlist[playlistIndex].title) and index \(playlistIndex)")
        if self.currentlyPlaying == nil {
            print ("currentlyPlaying is nil")
        }
        updateRecents(self.currentlyPlaying)
        savePlaybackData()
        if !queue.isEmpty {
            self.nextSongPlaying = queue[0]
            player?.queueSpotifyURI(queue.remove(at: 0).spotifyURL!.absoluteString, callback: {(error) in
                if error != nil {
                    print("Audio Player: Error while queueing")
                    print(error)
                    self.nextSongPlaying = nil
                }
            })
        } else {
            self.nextSongPlaying = playlist[(self.playlistIndex! + 1)%playlist.count]
            player?.queueSpotifyURI(playlist[(self.playlistIndex! + 1)%playlist.count].spotifyURL!.absoluteString, callback: {
                (error) in
                if error != nil {
                    print("Audio Player: Error while queueing from playlist")
                    print(error)
                    self.nextSongPlaying = nil
                }
            })
            self.playlistIndex = (self.playlistIndex! + 1)%playlist.count
        }
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        print("queue popped")
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("In did Stop Playing Track")
        self.currentlyPlaying = self.nextSongPlaying
        
    }
    
    func skipNext() {
        if spotifyPlaying {
            print("SKIP")
            self.currentlyPlaying = self.nextSongPlaying
            player?.skipNext({(error) in
                if error != nil {
                    print (error)
                } else {
                    self.printStats()
                }
            })
        }
        
    }
    
    
    func skipPrev() {
        if spotifyPlaying {
            let time = player?.playbackState.position
            if time != nil && time! < MAX_PREV_TIME {
                
                print("Skip to new song")
                self.playlistIndex = (self.playlistIndex - 2)
                if self.playlistIndex < 0 {
                    self.playlistIndex = self.playlist.count + self.playlistIndex
                }
                self.currentlyPlaying = self.playlist[playlistIndex]
                player?.playSpotifyURI(self.playlist[playlistIndex].spotifyURL!.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: {
                    (error) in
                    if error != nil {
                        print("Error in skip prev (prev song) for Spotify song")
                    } else {
                        //self.printStats()
                    }
                })

            } else {
                print("seek")
                player?.seek(to: TimeInterval.init(0), callback: { (error) in
                    if error != nil {
                        print("AudioPlayer: Error in skipPrev (seek) for Spotify song.")
                    } else {
                        //self.printStats()
                    }
                })
            }
        }
        
    }
    
    func pause() {
        if spotifyPlaying {
            player?.setIsPlaying(false, callback: {(error) in
                if error != nil {
                    print("Error in pause")
                    print(error)
                }
            })
        }
        
    }
    
    func play() {
        if spotifyPlaying {
            player?.setIsPlaying(true, callback: {(error) in
                if error != nil {
                    print("Error in pause")
                    print(error)
                }
            })
        }
        
    }
    
    func queueSong(_ song: Song) {
        if self.spotifyPlaying == true {
            self.queue.append(song)
            /*
            player?.queueSpotifyURI(queue.remove(at: 0).spotifyURL!.absoluteString, callback: {(error) in
                if error != nil {
                    print("Audio Player: Error while queueing")
                    print(error)
                }
            })
             */
        }
    }
    
    
    func playSpotifySong() {
        self.spotifyPlaying = true
        self.currentlyPlaying = playlist[playlistIndex]
        player?.playSpotifyURI(playlist[playlistIndex].spotifyURL?.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: {
            (error) in
            if error != nil {
                print("AudioPlayer: Error in playSpotifySong.")
            }
        })
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("login successful")
        self.loggedIn = true
        if self.spotifyShouldStartPlaying {
            playSpotifySong()
        }

    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Message: \(message)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Error: \(error)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            self.activateAudioSession()
        } else {
            self.deactivateAudioSession()
        }
    }
    
    func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func getSongProgress() -> (Double, Double)? {
        if spotifyPlaying,
            let position = player?.playbackState.position,
            let duration = player?.metadata.currentTrack?.duration {
                return ((position as Double)/(duration as Double), position as Double)
        } else {
            return nil
        }
    }
    
    func printStats() {
        if queue.isEmpty {
            print ("EMPTY QUEUE")
        } else {
            print("\(queue[0].title) is next")
        }
        print("\(recents.count) RECENTS")
    }
}
