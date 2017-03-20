//  Base controller for navigating through Spotify.
//  SpotifyTableTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SpotifyTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let MAX_SEARCH_RESULTS = 5
    let NUM_SECTIONS = 2
    let NUM_SHORTCUTS = 2
    
    var authData = SpotifyAuthenticationData()
    
    var recents : [Song] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spotify"
        searchBar.delegate = self
        if let returnVal =  UserDefaults.standard.value(forKey: "recents") as? Data {
            if let decodedRecents = NSKeyedUnarchiver.unarchiveObject(with: returnVal) as? [Song] {
                self.recents = decodedRecents
            }
        }
        authData.getNewSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let returnVal =  UserDefaults.standard.value(forKey: "recents") as? Data {
            if let decodedRecents = NSKeyedUnarchiver.unarchiveObject(with: returnVal) as? [Song] {
                self.recents = decodedRecents
            }
        }
    }
    
    func getMorePlaylists(sptPlaylists: SPTListPage, destinationViewController: SpotifyPlaylistsTableViewController) {
        if sptPlaylists.hasNextPage {
            sptPlaylists.requestNextPage(withAccessToken: self.authData.getAccessToken(), callback: { (error, playlists) in
                if (error == nil) {
                    let newPlaylists = playlists as! SPTListPage
                    for playlist in newPlaylists.items {
                        let partialPlaylist = playlist as! SPTPartialPlaylist
                        let title = partialPlaylist.name
                        destinationViewController.numPlaylists += 1
                        destinationViewController.playlists.append(Playlist(title: title, spotifyUri: partialPlaylist.uri.absoluteString))
                    }
                    //destinationViewController.playlists.append(newPlaylists)
                    if newPlaylists.hasNextPage {
                        self.getMorePlaylists(sptPlaylists: newPlaylists, destinationViewController: destinationViewController)
                    } else {
                        destinationViewController.doneSettingPlaylists = true
                    }
                } else {
                    print("SpotifyTableViewController.Error: Retrieving more Spotify playlists")
                }
            })
        }
        
    }
    
    func getUserPlaylists(destinationViewController: SpotifyPlaylistsTableViewController) {
        SPTPlaylistList.playlists(forUser: authData.getCanonicalUsername(), withAccessToken: authData.getAccessToken(), callback: { (error, playlists) in
                if (error == nil) {
                    let sptPlaylists = playlists as! SPTListPage
                    for playlist in sptPlaylists.items {
                        let partialPlaylist = playlist as! SPTPartialPlaylist
                        let title = partialPlaylist.name
                        destinationViewController.numPlaylists += 1
                        destinationViewController.playlists.append(Playlist(title: title, spotifyUri: partialPlaylist.uri.absoluteString))
                        
                    }
                    if sptPlaylists.hasNextPage {
                        self.getMorePlaylists(sptPlaylists: sptPlaylists, destinationViewController: destinationViewController)
                    } else {
                        destinationViewController.doneSettingPlaylists = true
                    }
                    
                } else {
                    print("SpotifyTableViewController.Error: Retrieving Spotify playlists")
                }
            })
    }
    
    func getMoreSongs(currentPage: SPTListPage, destinationViewController: SpotifySongsTableViewController) {
        if currentPage.hasNextPage {
            currentPage.requestNextPage(withAccessToken: self.authData.getAccessToken(), callback: {
                (error, data) in
                if (error == nil) {
                    if let songs = data as? SPTListPage {
                        
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
                                let artistId = (song.artists[0] as! SPTPartialArtist).identifier
                                
                                let spotifyURL = song.playableUri
                                destinationViewController.songs.insert((Song.init(title: title, artist: artistString, artistId: artistId, albumTitle: album, spotifyURL: spotifyURL)), at: 0)
                            }
                        }
                        self.getMoreSongs(currentPage: songs, destinationViewController: destinationViewController)
                    }
                } else {
                    print("SpotifyTableViewController.Error: Retrieving more saved tracks for user")
                }
            })
            
            
        } else {
            // Set flag to done
            destinationViewController.songsDoneLoading = true
        }
    }
    
    func retrieveUserLibrary(destinationViewController: SpotifySongsTableViewController) {
        SPTYourMusic.savedTracksForUser(withAccessToken: self.authData.getAccessToken(), callback: {
            (error, data) in
            if (error == nil) {
                if let songs = data as? SPTListPage {
                    
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
                            let artistId = (song.artists[0] as! SPTPartialArtist).identifier
                            
                            let spotifyURL = song.playableUri
                            destinationViewController.songs.insert(Song.init(title: title, artist: artistString, artistId: artistId, albumTitle: album, spotifyURL: spotifyURL), at: 0)
                        }
                    }
                    self.getMoreSongs(currentPage: songs, destinationViewController: destinationViewController)
                }
            } else {
                print("SpotifyTableViewController.Error: Retrieving saved tracks for user")
            }
            
        })
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Shortcuts"
        } else if section == 1 {
            return "Recents"
        } else {
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return NUM_SHORTCUTS
        } else if section == 1 {
            return recents.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            switch (row) {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "playlists", for: indexPath)
            case 1:
                return tableView.dequeueReusableCell(withIdentifier: "songs", for: indexPath)
            default:
                return tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
            cell.textLabel?.text = recents[indexPath.row].title
            cell.detailTextLabel?.text = recents[indexPath.row].artist
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = StyleConstants.headerColor
            headerView.backgroundView?.backgroundColor = StyleConstants.headerBackgroundColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let id = cell.reuseIdentifier
            var destinationViewController = segue.destination
            if let navigationController = destinationViewController as? UINavigationController {
                destinationViewController = navigationController.visibleViewController ?? destinationViewController
            }
            if (id == "playlists") {
                if let playlistsTableViewController = destinationViewController as? SpotifyPlaylistsTableViewController {
                    //playlistsTableViewController.playlists = getUserPlaylists()
                    playlistsTableViewController.authData = self.authData
                    getUserPlaylists(destinationViewController: playlistsTableViewController)
                    destinationViewController.title = "Spotify Playlists"
                }
            } else if (id == "songs") {
                if let songsTableViewController = destinationViewController as? SpotifySongsTableViewController {
                    //playlistsTableViewController.playlists = getUserPlaylists()
                    songsTableViewController.title = "Saved Tracks"
                    songsTableViewController.authData = self.authData
                    retrieveUserLibrary(destinationViewController: songsTableViewController)
                }
            } else if (id == "recent") {
                if let playSongViewController = destinationViewController as? SpotifyPlaySongViewController {
                    playSongViewController.authData = self.authData
                    let row = tableView.indexPath(for: cell)!.row
                    playSongViewController.playlistIndex = row
                    playSongViewController.songs = self.recents
                    playSongViewController.title = "Recent songs"
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var songSearchResults : [Song] = []
        var numSongs = 0
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotifySearchTableViewController") as? SpotifySearchTableViewController {
            SPTSearch.perform(withQuery: searchBar.text!, queryType: SPTSearchQueryType.queryTypeTrack, accessToken: self.authData.getAccessToken(), callback: {
                (error, data) in
                if (error != nil) {
                    print("SpotifyTableViewController.Error: Searching for songs")
                } else {
                    let page = data as? SPTListPage
                    if page != nil && page!.items != nil {
                        for item in (data as! SPTListPage).items {
                            if numSongs > self.MAX_SEARCH_RESULTS {
                                break
                            }
                            if let song = item as? SPTPartialTrack {
                                let title = song.name
                                let album = (song.album as SPTPartialAlbum).name
                                var artists: [String] = []
                                for artist in song.artists {
                                    let artistName = (artist as! SPTPartialArtist).name
                                    artists.append(artistName!)
                                }
                                let artistString = artists.joined(separator: " + ")
                                let artistId = (song.artists[0] as! SPTPartialArtist).identifier
                                
                                let spotifyURL = song.playableUri
                                songSearchResults.append(Song.init(title: title, artist: artistString, artistId: artistId, albumTitle: album, spotifyURL: spotifyURL))
                                numSongs += 1
                            }
                        }
                    }
                    viewController.songs = songSearchResults
                }
            })
            var artistSearchResults : [ArtistData] = []
            var numArtists = 0
            SPTSearch.perform(withQuery: searchBar.text!, queryType: SPTSearchQueryType.queryTypeArtist, accessToken: self.authData.getAccessToken(), callback: {
                (error, data) in
                if (error != nil) {
                    print("SpotifyTableViewController.Error: Searching for artists")
                } else {
                    let page = data as? SPTListPage
                    if page != nil && page!.items != nil {
                        for item in (data as! SPTListPage).items {
                            if numArtists > self.MAX_SEARCH_RESULTS {
                                break
                            }
                            if let artist = item as? SPTPartialArtist {
                                artistSearchResults.append(ArtistData(name: artist.name, spotifyURL: artist.uri.absoluteString))
                                numArtists += 1
                            }
                        }
                    }
                    viewController.artists = artistSearchResults
                }
            })
            
            SPTSearch.perform(withQuery: searchBar.text!, queryType: SPTSearchQueryType.queryTypeAlbum, accessToken: self.authData.getAccessToken(), callback: {
                (error, data) in
                if (error != nil) {
                    print("SpotifyTableViewController.Error: Searching for albums")
                } else {
                    var albumSearchResults : [Playlist] = []
                    var numAlbums = 0
                    let page = data as? SPTListPage
                    if page != nil && page!.items != nil {
                        for item in (data as! SPTListPage).items {
                            if numAlbums > self.MAX_SEARCH_RESULTS {
                                break
                            }
                            if let album = item as? SPTPartialAlbum {
                                albumSearchResults.append(Playlist(title: album.name, spotifyUri: album.playableUri.absoluteString))
                                numAlbums += 1
                            }
                        }
                    }
                    viewController.albums = albumSearchResults
                }
            })
            if let navigator = navigationController {
                print("segue")
                viewController.authData = self.authData
                viewController.title = searchBar.text
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
}
