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
    
    var isPlaying: Bool = false
    
    func loginToSpotify(authData: SpotifyAuthenticationData!) {
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
    
    func skipNext() {
        if spotifyPlaying {
            player?.skipNext({ (error) in
                if error != nil {
                    print("Erorr in skip next")
                }
            })
        }
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("in didStartPlayingTrack")
        recents.append(trackUri)
        player?.queueSpotifyURI(queue.remove(at: 0).spotifyURL!.absoluteString, callback: {(error) in
            if error != nil {
                print ("error while queueing")
            }
        })
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("In did Stop Playing Track")
        
    }
    
    
    func skipPrev() {
        if spotifyPlaying {
            let time = player?.playbackState.position
            if time != nil && time! < TimeInterval.init(2) && !recents.isEmpty {
                print("Skip to new song")
                queue.insert(Song(title: player!.metadata.currentTrack?.name,
                                  artist: player!.metadata.currentTrack?.artistName,
                                  albumTitle: player!.metadata.currentTrack?.albumName,
                                  spotifyURL: URL(string: player!.metadata.currentTrack!.uri)), at: 0)
                player?.playSpotifyURI(recents.removeLast(), startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
                    if error != nil {
                        print("Error in skip prev")
                    } else {
                        self.recents.append(self.queue[0].spotifyURL!.absoluteString)
                        self.queue.remove(at: 0)
                    }
                })

            } else {
                print("seek")
                player?.seek(to: TimeInterval.init(0), callback: { (error) in
                    if error != nil {
                        print("AudioPlayer: Error in skipPrev for Spotify song.")
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
                } else {
                    self.isPlaying = true
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
                } else {
                    self.isPlaying = false
                }
            })
        }
        
    }
    
    
    func playSpotifySong() {
        self.spotifyPlaying = true
        player?.playSpotifyURI(queue[0].spotifyURL?.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
            if error != nil {
                print("SpotifyPlaySongViewController: Error playing song.")
            } else {
                self.recents.append(self.queue[0].spotifyURL!.absoluteString)
                self.queue.remove(at: 0)
            }
        })
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("login successful")
        playSpotifySong()

    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Message: \(message)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Error: \(error)")
    }
}
