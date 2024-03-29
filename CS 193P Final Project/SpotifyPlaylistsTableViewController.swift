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
    
    var numPlaylists = 0
    
    // Boolean used to indicate whether the playlists being displayed are actually albums
    var displayingAlbums : Bool = false
    
    var doneSettingPlaylists = false {
        didSet {
            self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
            self.tableView.tableHeaderView = self.tableView.tableHeaderView // necessary to really set the frame
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            print(playlists.count)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        print(tableView.center)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                    print("SpotifyPlaylistsTableViewController.Error: Getting more playlist songs")
                    return
                }
            })
            
            
        } else {
            destinationViewController.songsDoneLoading = true
        }
    }
    
    func getPlaylistSongs(destinationViewController : SpotifySongsTableViewController, row: Int) {
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
            }
        })
    }
    
    func getMoreAlbumSongs(destinationViewController : SpotifySongsTableViewController, currentPage : SPTListPage, albumName: String) {
        if currentPage.hasNextPage {
            currentPage.requestNextPage(withAccessToken: self.authData!.getAccessToken(), callback: {
                (error, data) in
                if (error == nil) {
                    if let songs = data as? SPTListPage {
                        if songs.items == nil {
                            return
                        }
                        for item in songs.items {
                            if let song = item as? SPTPartialTrack {
                                let title = song.name
                                let album = albumName
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
                        self.getMoreAlbumSongs(destinationViewController: destinationViewController, currentPage: songs, albumName: albumName)
                    }
                } else {
                    print("SpotifyPlaylistsTableViewController.Error: getting more album songs returned error.")
                }
            })
            
        } else {
            destinationViewController.songsDoneLoading = true
        }
    }
    
    func getAlbumSongs(destinationViewController : SpotifySongsTableViewController, row: Int) {
        let albumUri = playlists[row].spotifyUri
        SPTAlbum.album(withURI: URL(string: albumUri!), accessToken: self.authData!.getAccessToken(), market: "US", callback: {(error, data) in
            if error == nil {
                if let album = data as? SPTAlbum,
                    let firstPage = album.firstTrackPage {
                    if firstPage.items == nil {
                        return
                    }
                    for item in firstPage.items {
                        if let song = item as? SPTPartialTrack {
                            let title = song.name
                            let album = album.name
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
                    self.getMoreAlbumSongs(destinationViewController: destinationViewController, currentPage: firstPage, albumName: album.name)
                    
                }
            } else {
                print("SpotifyPlaylistsTableViewController.Error: album return error")
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
                    songsTableViewController.authData = self.authData
                    songsTableViewController.title = cell.textLabel?.text
                    songsTableViewController.songs = []
                    let row = tableView.indexPath(for: cell)!.row
                    if !self.displayingAlbums {
                        getPlaylistSongs(destinationViewController: songsTableViewController, row: row)
                    } else {
                        getAlbumSongs(destinationViewController: songsTableViewController, row: row)
                    }
                }
                
            }
        }
    }

}
