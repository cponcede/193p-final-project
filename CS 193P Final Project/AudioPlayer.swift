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
    var recents : [String] = []
    var spotifyPlaying : Bool = false
    var player: SPTAudioStreamingController?
    var authData: SpotifyAuthenticationData!
    var loggedIn = false
    var spotifyShouldStartPlaying = false
    
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
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("in didStartPlayingTrack")
        recents.append(trackUri)
        self.printStats()
        if !queue.isEmpty {
            player?.queueSpotifyURI(queue.remove(at: 0).spotifyURL!.absoluteString, callback: {(error) in
                if error != nil {
                    print ("error while queueing")
                }
            })
        }
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
        print("queue popped")
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("In did Stop Playing Track")
        
    }
    
    
    func skipPrev() {
        if spotifyPlaying {
            let time = player?.playbackState.position
            if time != nil && time! < TimeInterval.init(2) && recents.count > 1 {
                print("Skip to new song")
                // Update recents and queue
                recents.removeLast()
                print("recents = \(recents)")
                queue.insert(Song(title: player!.metadata.currentTrack?.name,
                                  artist: player!.metadata.currentTrack?.artistName,
                                  albumTitle: player!.metadata.currentTrack?.albumName,
                                  spotifyURL: URL(string: player!.metadata.currentTrack!.uri)), at: 0)
                
                player?.playSpotifyURI(recents.removeLast(), startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
                    if error != nil {
                        print("Error in skip prev")
                    } else {
                        self.printStats()
                    }
                })

            } else {
                print("seek")
                player?.seek(to: TimeInterval.init(0), callback: { (error) in
                    if error != nil {
                        print("AudioPlayer: Error in skipPrev for Spotify song.")
                    } else {
                        self.printStats()
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
        player?.playSpotifyURI(queue.remove(at: 0).spotifyURL?.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
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
    
    func printStats() {
        if queue.isEmpty {
            print ("EMPTY QUEUE")
        } else {
            print("\(queue[0].title) is next")
        }
        print("\(recents.count) RECENTS")
    }
}
