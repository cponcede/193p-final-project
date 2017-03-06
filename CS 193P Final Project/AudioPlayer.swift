//
//  AudioPlayer.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/5/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

class AudioPlayer : NSObject, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var queue : [Song] = []
    var playlist : [Song] = []
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
        player?.login(withAccessToken: authData.session.accessToken)
    }
    
    func playSpotify(authData: SpotifyAuthenticationData!) {
        login(authData)
        spotifyShouldStartPlaying = true
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("in didStartPlayingTrack for track \(playlist[playlistIndex].title)")
        
        if !queue.isEmpty {
            player?.queueSpotifyURI(queue.remove(at: 0).spotifyURL!.absoluteString, callback: {(error) in
                if error != nil {
                    print("Audio Player: Error while queueing")
                    print(error)
                }
            })
        } else {
            player?.queueSpotifyURI(playlist[(self.playlistIndex! + 1)%playlist.count].spotifyURL!.absoluteString, callback: {
                (error) in
                if error != nil {
                    print("Audio Player: Error while queueing from playlist")
                    print(error)
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
        
    }
    
    func skipNext() {
        if spotifyPlaying {
            print("SKIP")
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
            if time != nil && time! < TimeInterval.init(2) {
                
                print("Skip to new song")
                self.playlistIndex = (self.playlistIndex - 2)
                if self.playlistIndex < 0 {
                    self.playlistIndex = self.playlist.count - 1
                }

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
    
    
    func playSpotifySong() {
        self.spotifyPlaying = true
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
    
    func getSongProgress() -> Double? {
        if spotifyPlaying,
            let position = player?.playbackState.position,
            let duration = player?.metadata.currentTrack?.duration {
                return (position as Double)/(duration as Double)
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
