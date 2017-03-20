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
    
    @IBOutlet weak var noSongPlayingView: UIView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var currTimeLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var positionView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // Songs to play
    var songs: [Song]? {
        didSet {
            login()
        }
    }
    
    var audioPlayer = AudioPlayer.sharedInstance
    
    var viewDisplayed = true
    
    var authData: SpotifyAuthenticationData!
    
    var playlistIndex : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        if audioPlayer.currentlyPlaying != nil{
            trackProgress()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.viewDisplayed = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDisplayed = true
        if (self.songs != nil && !self.songs!.isEmpty) || audioPlayer.currentlyPlaying != nil {
            noSongPlayingView.isHidden = true
            if audioPlayer.isPlaying != nil && audioPlayer.isPlaying! {
                self.pauseButton.isHidden = false
                self.playButton.isHidden = true
            } else {
                self.pauseButton.isHidden = true
                self.playButton.isHidden = false
            }
            
            trackProgress()
        } else {
            noSongPlayingView.isHidden = false
        }
    }
    
    func login() {
        audioPlayer.spotifyShouldStartPlaying = true
        audioPlayer.playlistIndex = self.playlistIndex
        audioPlayer.playlist = self.songs!
        audioPlayer.playSpotify(authData: self.authData)
        trackProgress()
    }
    
    func sanitizeTimeString(_ input : String) -> String {
        if input.characters.count == 1 {
            return "0\(input)"
        }
        return input
    }
    
    // Queries the AudioPlayer for song progress and updates UI accordingly.
    private func trackProgress() {
        DispatchQueue.global(qos: .background).async {
            while (true) {
                
                if !self.viewDisplayed || !self.isViewLoaded {
                    print("Leaving trackProgress")
                    return
                }
                if (self.audioPlayer.isPlaying != nil && self.audioPlayer.isPlaying == true) {
                    // In the following cases, do not track UI
                    if self.audioPlayer.player == nil ||
                        self.audioPlayer.player!.metadata.currentTrack == nil ||
                        self.isViewLoaded == false ||
                        self.view.window == nil {
                        usleep(1000)
                        continue
                    }
                    if let (songProgress, songTime) = self.audioPlayer.getSongProgress() {
                        if songProgress == nil || songTime == nil {
                            usleep(1000)
                            continue
                        }
                        if self.audioPlayer.player == nil || self.audioPlayer.player!.metadata.currentTrack == nil {
                            usleep(1000)
                            continue
                        }
                        let duration = (self.audioPlayer.player?.metadata.currentTrack?.duration)!
                        var minutes = self.sanitizeTimeString(String(Int(floor(duration/60))))
                        var seconds = self.sanitizeTimeString(String(Int(round(duration - Double(minutes)! * 60))))
                        let albumURL = self.audioPlayer.player?.metadata.currentTrack?.albumCoverArtURL
                        let artworkData = try? Data.init(contentsOf: URL.init(string: albumURL!)!)
                        let isPlaying = self.audioPlayer.isPlaying
                        
                        DispatchQueue.main.async {
                            if self.audioPlayer.player == nil || self.audioPlayer.player!.metadata.currentTrack == nil {
                                return
                            }
                            self.songTitleLabel.attributedText = NSAttributedString(string: self.audioPlayer.player!.metadata.currentTrack!.name, attributes: StyleConstants.labelStyleAttributes)
                            self.artistNameLabel.attributedText = NSAttributedString(string: self.audioPlayer.player!.metadata.currentTrack!.artistName, attributes: StyleConstants.labelStyleAttributes)
                            
                            self.maxTimeLabel.attributedText = NSAttributedString(string: "\(minutes):\(seconds)", attributes: StyleConstants.labelStyleAttributes)
                            self.positionView.setProgress(Float(songProgress), animated: true)
                            minutes = self.sanitizeTimeString(String(Int(floor(songTime/60))))
                            seconds = self.sanitizeTimeString(String(Int(floor(songTime - Double(minutes)!*60))))
                            self.currTimeLabel.attributedText = NSAttributedString(string: "\(minutes):\(seconds)", attributes: StyleConstants.labelStyleAttributes)
                            
                            if artworkData != nil {
                                self.albumImageView.image = UIImage(data: artworkData!)
                            } else {
                                self.albumImageView.image = UIImage.init(contentsOfFile: "/Users/cponcede/Developer/CS 193P Final Project/CS 193P Final Project/Images/NoPhotoDefault.png")
                            }
                            if isPlaying != nil && isPlaying! {
                                self.pauseButton.isHidden = false
                                self.playButton.isHidden = true
                            } else {
                                self.pauseButton.isHidden = true
                                self.playButton.isHidden = false
                            }
                        }
                        
                    } else {
                        print("SpotifyPlaySongViewController: Error getting song progress")
                    }
                    usleep(1000)
                }
            }
        }
        
    }
    
    @IBAction func skipSong(_ sender: UIButton) {
        audioPlayer.skipNext()
        // Sleep to avoid multiple accidental clicks
        usleep(200)
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

}
