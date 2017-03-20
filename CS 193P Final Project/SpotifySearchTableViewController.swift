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
    
    func getMoreAlbumSongs(destinationViewController : SpotifySongsTableViewController, currentPage : SPTListPage, albumName: String) {
        print("getMorePlaylistSongs")
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
    
    func getAlbumSongs(destinationViewController : SpotifySongsTableViewController, row: Int) {
        print("getPlaylistSongs")
        let albumUri = albums![row].spotifyUri
        SPTAlbum.album(withURI: URL(string: albumUri!), accessToken: self.authData!.getAccessToken(), market: "US", callback: {(error, data) in
            if error == nil {
                print(data)
                if let album = data as? SPTAlbum,
                    let firstPage = (album.firstTrackPage as? SPTListPage) {
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
                print("SpotifySearchTableViewController Error: album return error")
                print(error)
            }
        })
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let id = cell.reuseIdentifier
            var destinationViewController = segue.destination
            if let navigationController = destinationViewController as? UINavigationController {
                destinationViewController = navigationController.visibleViewController ?? destinationViewController
            }
            if id == "subtitleCell" {
                
                if let playSongViewController = destinationViewController as? SpotifyPlaySongViewController {
                    playSongViewController.authData = self.authData
                    let row = tableView.indexPath(for: cell)!.row
                    playSongViewController.playlistIndex = row
                    playSongViewController.songs = self.songs
                    playSongViewController.title = self.title! + " songs"
                }
            } else if id == "basicCell" {
                if tableView.indexPath(for: cell)!.section == 2 {
                    if let songsTableViewController = destinationViewController as? SpotifySongsTableViewController{
                        songsTableViewController.authData = self.authData
                        songsTableViewController.title = cell.textLabel?.text
                        songsTableViewController.songs = []
                        let row = tableView.indexPath(for: cell)!.row
                        getAlbumSongs(destinationViewController: songsTableViewController, row: row)
                    }
                }
            }
        }
    }

}
