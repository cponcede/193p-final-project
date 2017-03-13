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
    
    var numPlaylists = 0
    
    var doneSettingPlaylists = false {
        didSet {
            self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
            self.tableView.tableHeaderView = self.tableView.tableHeaderView // necessary to really set the frame
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
        cell?.textLabel?.text = playlists[indexPath.row].title
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = StyleConstants.headerColor
            headerView.backgroundView?.backgroundColor = StyleConstants.headerBackgroundColor
        }
    }
    
    
    func getMorePlaylistSongs(destinationViewController : SpotifySongsTableViewController, currentPage : SPTListPage) {
        print("getMorePlaylistSongs")
        if currentPage.hasNextPage {
            currentPage.requestNextPage(withAccessToken: self.authData.getAccessToken(), callback: {
                (error, data) in
                if (error == nil) {
                    if let songs = data as? SPTListPage {
                        if songs.items == nil {
                            return
                        }
                        for item in songs.items {
                            if let song = item as? SPTPartialTrack {
                                let title = song.name
                                let album = song.album.name
                                var artists: [String] = []
                                for artist in song.artists {
                                    let artistName = (artist as! SPTPartialArtist).name
                                    artists.append(artistName!)
                                }
                                let artistString = artists.joined(separator: " + ")
                                let artistId = (song.artists[0] as! SPTPartialArtist).identifier
                                
                                let spotifyURL = song.playableUri
                                destinationViewController.songs.append((Song.init(title: title, artist: artistString, artistId: artistId, albumTitle: album, spotifyURL: spotifyURL)))
                            }
                        }
                        self.getMorePlaylistSongs(destinationViewController: destinationViewController, currentPage: songs)
                    }
                } else {
                    print("Error retrieving saved tracks for user")
                    print(error)
                    return
                }
            })
            
            
        } else {
            // Set flag to done
            print("Done loading playlist songs")
            destinationViewController.songsDoneLoading = true
        }
    }
    
    func getPlaylistSongs(destinationViewController : SpotifySongsTableViewController, row: Int) {
        print("getPlaylistSongs")
        let playlistUri = playlists[row].spotifyUri
        SPTPlaylistSnapshot.playlist(withURI: URL(string: playlistUri!), accessToken: self.authData.getAccessToken(), callback: {
            (error, data) in
            if error == nil {
                if let playlistSnapshot = data as? SPTPlaylistSnapshot,
                    let firstPage = (playlistSnapshot.firstTrackPage as? SPTListPage) {
                    if firstPage.items == nil {
                        return
                    }
                    for item in firstPage.items {
                        if let song = item as? SPTPartialTrack {
                            let title = song.name
                            let album = (song.album as! SPTPartialAlbum).name
                            var artists: [String] = []
                            for artist in song.artists {
                                let artistName = (artist as! SPTPartialArtist).name
                                artists.append(artistName!)
                            }
                            let artistString = artists.joined(separator: " + ")
                            let artistId = (song.artists[0] as! SPTPartialArtist).identifier
                            
                            let spotifyURL = song.playableUri
                            destinationViewController.songs.append(Song.init(title: title, artist: artistString, artistId: artistId, albumTitle: album, spotifyURL: spotifyURL))
                        }
                    }
                    self.getMorePlaylistSongs(destinationViewController: destinationViewController, currentPage: firstPage)
                } else {
                    print("Error converting data to SPTListPage")
                }
            } else {
                print("SpotifyPlaylistsTableViewController Error: playlist return error")
                print(error)
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
                    songsTableViewController.title = cell.textLabel?.text
                    songsTableViewController.songs = []
                    let row = tableView.indexPath(for: cell)!.row
                    getPlaylistSongs(destinationViewController: songsTableViewController, row: row)
                }
                
            }
        }
    }

}
