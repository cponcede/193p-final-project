//
//  PlaySongViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/2/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import AVFoundation
import UIKit

class SpotifyPlaySongViewController: UIViewController {
    
    var song: Song? {
        didSet {
            print("SONG SET")
            print(song)
            startPlayingSong()
        }
    }
    
    var player: SPTAudioStreamingController?
    
    var authData: SpotifyAuthenticationData!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func startPlayingSong() {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
            try? player?.start(withClientId: authData.clientId)
        }
        if player?.initialized == false {
            print("player not init")
        }

        print(authData.session.accessToken)
        if (player?.loggedIn)! {
            player?.playSpotifyURI(song?.spotifyURL?.absoluteString, startingWith: 0, startingWithPosition: TimeInterval.init(0), callback: { (error) in
                if error != nil {
                    print("SpotifyPlaySongViewController: Error playing song.")
                }
            })
        } else {
            print("SpotifyPlaySongViewController: Error while logging into player.")
        }
    
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
