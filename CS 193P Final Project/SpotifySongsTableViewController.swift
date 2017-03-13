//
//  SpotifySongsTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SpotifySongsTableViewController: UITableViewController, UIAlertViewDelegate {
    
    var authData: SpotifyAuthenticationData!
    
    var audioPlayer = AudioPlayer.sharedInstance
    
    var songs: [Song] = []
    
    var songToQueue : Song?
    
    var songsDoneLoading = false {
        didSet {
            print("In didSet of songsDoneLoading")
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            tableView.reloadData()
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            alertView.dismiss(withClickedButtonIndex: 0, animated: true)
            audioPlayer.queueSong(songToQueue!)
            print("QUEUE")
        } else {
            alertView.dismiss(withClickedButtonIndex: 1, animated: true)
            print("CANCEL")
            songToQueue = nil
        }
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        print("Queueing song")
        if let cell = recognizer.view as? UITableViewCell {
            songToQueue = songs[tableView.indexPath(for: cell)!.row]
            let alert = UIAlertView.init(title: "Queue song?", message: songToQueue!.title!, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
            alert.show()
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)

        cell.textLabel?.text = songs[indexPath.row].title
        cell.detailTextLabel?.text = songs[indexPath.row].artist
        let recognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipe(recognizer:)))
        recognizer.direction = UISwipeGestureRecognizerDirection.left
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = StyleConstants.headerColor
            headerView.backgroundView?.backgroundColor = StyleConstants.headerBackgroundColor
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let id = cell.reuseIdentifier
            if id == "songCell" && segue.identifier != "songOptionsSegue" {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let playSongViewController = destinationViewController as? SpotifyPlaySongViewController {
                    playSongViewController.authData = self.authData
                    let row = tableView.indexPath(for: cell)!.row
                    playSongViewController.playlistIndex = row
                    playSongViewController.songs = self.songs
                    playSongViewController.title = self.title
                }
            }
        }
    }

}
