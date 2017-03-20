//
//  SpotifySearchTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/19/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SpotifySearchTableViewController: UITableViewController {
    
    let NUM_SECTIONS = 3
    
    var authData: SpotifyAuthenticationData?
    
    var songs : [Song]? {
        didSet {
            print("songs set")
            updateUI()
        }
    }
    
    var artists : [ArtistData]? {
        didSet {
            print("artists set")
            updateUI()
        }
    }
    
    var albums : [Playlist]? {
        didSet {
            print("albums set")
            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        if artists != nil && songs != nil && albums != nil {
            tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Songs"
        } else if section == 1 {
            return "Artists"
        } else if section == 2 {
            return "Albums"
        } else {
            return "Unknown section"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return songs?.count ?? 0
        } else if section == 1 {
            return artists?.count ?? 0
        } else if section == 2 {
            return albums?.count ?? 0
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
            if section == 0 {
                cell.textLabel?.text = songs![indexPath.row].title
                cell.detailTextLabel?.text = songs![indexPath.row].artist
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            if section == 1 {
                cell.textLabel?.text = artists![indexPath.row].name
                return cell
            } else {
                cell.textLabel?.text = albums![indexPath.row].title
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = StyleConstants.headerColor
            headerView.backgroundView?.backgroundColor = StyleConstants.headerBackgroundColor
        }
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
            if id == "subtitleCell" {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let playSongViewController = destinationViewController as? SpotifyPlaySongViewController {
                    playSongViewController.authData = self.authData
                    let row = tableView.indexPath(for: cell)!.row
                    playSongViewController.playlistIndex = row
                    playSongViewController.songs = self.songs
                    playSongViewController.title = self.title! + " songs"
                }
            }
        }
    }

}
