//
//  PlaySongViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/2/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import AVFoundation
import UIKit

class SpotifyPlaySongViewController: UIViewController, SPTAudioStreamingDelegate {
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    var songs: [Song]! {
        didSet {
            login()
        }
    }
    
    var player: SPTAudioStreamingController?
    
    var authData: SpotifyAuthenticationData!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func login() {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
        }
        player?.delegate = self
        if player?.initialized == false {
            try? player?.start(withClientId: authData.clientId)
        }
        
        player?.login(withAccessToken: authData.session.accessToken)
    }
    

    func queueNextSong(index: Int) {
        if index < songs.count {
            player?.queueSpotifyURI(songs[index].spotifyURL?.absoluteString, callback: { (error) in
                if error != nil {
                    print("Error queueing")
                    print (error.debugDescription)
                } else {
                    print("Song queued successfully")
                    self.queueNextSong(index: index+1)
                }
            })
        }
    }

    func playSong() {
        player?.playSpotifyURI(songs[0].spotifyURL?.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
            if error != nil {
                print("SpotifyPlaySongViewController: Error playing song.")
            }
        })
    }
    
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("login successful")
        playSong()
        self.queueNextSong(index: 1)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        //print(error)
        return
    }
    
    
    @IBAction func skipSong(_ sender: UIButton) {
        player?.skipNext({(error) in
            if error != nil {
                print("Error in SpotifyPlaySongViewController.skipSong")
                print(error)
            } else {
                print("SKIPPING")
            }
        })
    }
    
    @IBAction func previousSong(_ sender: UIButton) {
        player?.skipPrevious({(error) in
            if error != nil {
                print("Error in previousSong")
                print(error)
            } else {
                print("Prev")
            }
        })

    }
    
    @IBAction func pause(_ sender: UIButton) {
        player?.setIsPlaying(false, callback: {(error) in
            if error != nil {
                print("Error in pause")
                print(error)
            } else {
                self.pauseButton.isHidden = true
                self.playButton.isHidden = false
            }
        })
        

    }
    
    @IBAction func play(_ sender: UIButton) {
        player?.setIsPlaying(true, callback: {(error) in
            if error != nil {
                print("Error in pause")
                print(error)
            } else {
                self.pauseButton.isHidden = false
                self.playButton.isHidden = true
            }
        })
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
