//
//  PlaySongViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/2/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class PlaySongViewController: UIViewController {
    
    var song: Song? {
        didSet {
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
