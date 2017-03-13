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
            tableView.reloadData()
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

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
