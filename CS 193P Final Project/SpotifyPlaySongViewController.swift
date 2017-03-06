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
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    var songs: [Song]! {
        didSet {
            login()
        }
    }
    
    var audioPlayer = AudioPlayer()
    
    var authData: SpotifyAuthenticationData!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func login() {
        audioPlayer.queue = []
        audioPlayer.recents = []
        audioPlayer.queue.append(contentsOf: songs)
        audioPlayer.spotifyShouldStartPlaying = true
        audioPlayer.playSpotify(authData: self.authData)
    }
    
    
    @IBAction func skipSong(_ sender: UIButton) {
        audioPlayer.skipNext()
    }
    
    
    @IBAction func previousSong(_ sender: UIButton) {
        audioPlayer.skipPrev()

    }
    
    @IBAction func pause(_ sender: UIButton) {
        audioPlayer.pause()
        self.pauseButton.isHidden = true
        self.playButton.isHidden = false
    }
    
    @IBAction func play(_ sender: UIButton) {
        audioPlayer.play()
        self.pauseButton.isHidden = false
        self.playButton.isHidden = true
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
