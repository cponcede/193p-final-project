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
    
    @IBOutlet weak var positionView: UIProgressView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    var songs: [Song]! {
        didSet {
            login()
        }
    }
    
    var audioPlayer = AudioPlayer()
    
    var authData: SpotifyAuthenticationData!
    
    var playlistIndex : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func login() {
        audioPlayer.spotifyShouldStartPlaying = true
        audioPlayer.playlistIndex = self.playlistIndex
        audioPlayer.playlist = self.songs
        audioPlayer.playSpotify(authData: self.authData)
        trackProgress()
    }
    
    private func trackProgress() {
        DispatchQueue.global(qos: .userInteractive).async {
            while (true) {
                if (self.audioPlayer.isPlaying != nil && self.audioPlayer.isPlaying == true) {
                    DispatchQueue.main.sync {
                        self.positionView.setProgress(Float(self.audioPlayer.getSongProgress()!), animated: true)
                    }
                    // TODO: figure out if this should be in a different queue
                    usleep(1000)
                }
            }
        }
        
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
