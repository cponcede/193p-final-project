//
//  SpotifyPlaylistsTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import UIKit

class SpotifyPlaylistsTableViewController: UITableViewController {
    
    var authData: SpotifyAuthenticationData!
    
    var playlists: [Playlist] = []
    
    var imageViewConstraints: [NSLayoutConstraint]?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var numPlaylists = 0
    
    var doneSettingPlaylists = false {
        didSet {
            self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
            self.tableView.tableHeaderView = self.tableView.tableHeaderView // necessary to really set the frame
            spinner.stopAnimating()
            spinner.isHidden = true
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        spinner.startAnimating()
        print(tableView.center)
        self.title = "Spotify Playlists"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning \(numPlaylists)")
        return numPlaylists
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Loading cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell")
        if let customCell = cell as? TitleAndImageTableViewCell {
            customCell.titleLabel.text = playlists[indexPath.row].title
            customCell.entityImageView.image = playlists[indexPath.row].artworkImage
            // customCell.setNeedsDisplay()
            /*
            print(customCell.entityImageView.constraints)
            if self.imageViewConstraints == nil && !customCell.entityImageView.constraints.isEmpty {
                print("Setting imageViewConstraints")
                self.imageViewConstraints = customCell.entityImageView.constraints
            } else {
                print(self.imageViewConstraints!)
                customCell.entityImageView.removeConstraints(customCell.entityImageView.constraints)
                customCell.entityImageView.addConstraints(self.imageViewConstraints!)
            }
 */
            return customCell
        }
        print("RETURNING WRONG CELL")
        return cell!
        
        /*
        if let partialPlaylist = self.playlists[pageIndex].items[rowIndex] as? SPTPartialPlaylist,
            let customCell = cell as? TitleAndImageTableViewCell {
            customCell.titleLabel.text = partialPlaylist.name
            if partialPlaylist.images.count > 0 {
                if let artwork = partialPlaylist.images[0] as? SPTImage {
                    let artworkURL = artwork.imageURL
                    if let artworkData = try? Data.init(contentsOf: artworkURL!) {
                        let artworkImage = UIImage(data: artworkData)
                        customCell.entityImageView.image = artworkImage
                    }
                }
            } else {
                // Set default image
                print("No playlist image")
            }
        } else {
            print("COULD NOT CONVERT")
        }
        // Configure the cell...

        return cell
         */
    }
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? TitleAndImageTableViewCell
        cell?.titleLabel.text = playlists[indexPath.row].title
        cell?.entityImageView?.image = playlists[indexPath.row].artwork
        cell?.setNeedsDisplay()
        cell?.isSelected = false
        return
    }
 */

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
    
    func getMorePlaylistSongs(destinationViewController : SpotifySongsTableViewController, currentPage : SPTListPage) {
        print("getMorePlaylistSongs")
        if currentPage.hasNextPage {
            currentPage.requestNextPage(withAccessToken: self.authData.session.accessToken, callback: {
                (error, data) in
                if (error == nil) {
                    if let playlistSnapshot = data as? SPTPlaylistSnapshot,
                    let songs = playlistSnapshot.firstTrackPage as? SPTListPage {
                        
                        for item in songs.items {
                            if let song = item as? SPTPartialTrack {
                                let title = song.name
                                let album = (song.album as! SPTPartialAlbum).name
                                var artists: [String] = []
                                for artist in song.artists {
                                    let artistName = (artist as! SPTPartialArtist).name
                                    artists.append(artistName!)
                                }
                                let artistString = artists.joined(separator: " + ")
                                
                                let spotifyURL = song.playableUri
                                destinationViewController.songs.append((Song(title: title, artist: artistString, albumTitle: album, spotifyURL: spotifyURL)))
                            }
                        }
                        self.getMorePlaylistSongs(destinationViewController: destinationViewController, currentPage: songs)
                    }
                } else {
                    print("Error retrieving saved tracks for user")
                    return
                }
            })
            
            
        } else {
            // Set flag to done
            destinationViewController.songsDoneLoading = true
        }
    }
    
    func getPlaylistSongs(destinationViewController : SpotifySongsTableViewController, row: Int) {
        print("getPlaylistSongs")
        let playlistUri = playlists[row].spotifyUri
        SPTPlaylistSnapshot.playlist(withURI: URL(string: playlistUri!), accessToken: self.authData.session.accessToken, callback: {
            (error, data) in
            if error == nil {
                if let playlistSnapshot = data as? SPTPlaylistSnapshot,
                    let songs = playlistSnapshot.firstTrackPage as? SPTListPage {
                    for item in songs.items {
                        if let song = item as? SPTPartialTrack {
                            let title = song.name
                            let album = (song.album as! SPTPartialAlbum).name
                            var artists: [String] = []
                            for artist in song.artists {
                                let artistName = (artist as! SPTPartialArtist).name
                                artists.append(artistName!)
                            }
                            let artistString = artists.joined(separator: " + ")
                            
                            let spotifyURL = song.playableUri
                            destinationViewController.songs.append(Song(title: title, artist: artistString, albumTitle: album, spotifyURL: spotifyURL))
                        }
                    }
                    self.getMorePlaylistSongs(destinationViewController: destinationViewController, currentPage: songs)
                } else {
                    print("Error converting data to SPTListPage")
                }
            } else {
                print("SpotifyPlaylistsTableViewController Error: playlist return error")
                print(error)
                return
            }
            
        })
        
        
        
        
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let id = cell.reuseIdentifier
            if (id == "playlistCell") {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let songsTableViewController = destinationViewController as? SpotifySongsTableViewController {
                    print("About to segue")
                    songsTableViewController.authData = self.authData
                    songsTableViewController.title = (cell as! TitleAndImageTableViewCell).titleLabel.text
                    songsTableViewController.songs = []
                    let row = tableView.indexPath(for: cell)!.row
                    getPlaylistSongs(destinationViewController: songsTableViewController, row: row)
                }
                
            }
        }
    }

}
