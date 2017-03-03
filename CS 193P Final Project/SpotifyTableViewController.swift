//
//  SpotifyTableTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/1/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SpotifyTableViewController: UITableViewController {
    
    let clientId = "4275d7c3c3864d7988c42a7d282aaaa4"
    let callbackURL = "cponcede-cs193p-project-spotify://callback"
    let tokenSwapURL = ""
    let tokenRefreshServiceURL = ""
    
    let numSections = 2
    let numShortcuts = 4
    
    var spotifyPlaylists: SPTPlaylistList?
    
    var session : SPTSession!
    
    var authData = SpotifyAuthenticationData()
    
    func updateAfterLogin() {
        self.session = SPTAuth.defaultInstance().session
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spotify"
        print("IN VDL")
        authData.getNewSession()
        /*
        NotificationCenter.default.addObserver(self, selector: Selector.init("updateAfterLogin"), name: NSNotification.Name.init(rawValue: "spotifyLoginSuccessful") , object: nil)
        
        let userDefaults = UserDefaults.standard
        if let sessionObj = userDefaults.value(forKey: "spotifySession") {
            print("FOUND SAVED SESSION")
            let sessionDataObj = sessionObj as? Data
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj!) as! SPTSession
            if !session.isValid() {
                
                SPTAuth.defaultInstance().renewSession(session, callback: {
                    error, session in
                    if error == nil {
                        let sessionDataObj = NSKeyedArchiver.archivedData(withRootObject: session)
                        userDefaults.set(sessionDataObj, forKey: "spotifySession")
                        userDefaults.synchronize()
                        self.session = session
                        print("Refreshed Spotify auth token successfully")
                    } else {
                        print("Error refreshing Spotify auth token. Creating new one.")
                        SPTAuth.defaultInstance().clientID = self.clientId
                        SPTAuth.defaultInstance().redirectURL = URL.init(string: self.callbackURL)
                        SPTAuth.defaultInstance().requestedScopes = [SPTAuthUserLibraryReadScope]
                        let loginURL = SPTAuth.loginURL(forClientId: self.clientId, withRedirectURL: URL.init(string: self.callbackURL), scopes: [SPTAuthUserLibraryReadScope], responseType: "token")
                        UIApplication.shared.open(loginURL!)
                    }
                })
            } else {
                print("Session valid")
                // Display user's library
                self.session = session
            }
            return
        } else {
            print ("NO SAVED SESSION")
            SPTAuth.defaultInstance().clientID = clientId
            SPTAuth.defaultInstance().redirectURL = URL.init(string: callbackURL)
            SPTAuth.defaultInstance().requestedScopes = [SPTAuthUserLibraryReadScope]
            let loginURL = SPTAuth.loginURL(forClientId: clientId, withRedirectURL: URL.init(string: callbackURL), scopes: [SPTAuthUserLibraryReadScope], responseType: "token")
            UIApplication.shared.open(loginURL!)
        }
         */
    }
    
    func getMorePlaylists(sptPlaylists: SPTListPage, destinationViewController: SpotifyPlaylistsTableViewController) {
        if sptPlaylists.hasNextPage {
            sptPlaylists.requestNextPage(withAccessToken: self.authData.session.accessToken, callback: { (error, playlists) in
                if (error == nil) {
                    let newPlaylists = playlists as! SPTListPage
                    for playlist in newPlaylists.items {
                        let partialPlaylist = playlist as! SPTPartialPlaylist
                        let title = partialPlaylist.name
                        destinationViewController.numPlaylists += 1
                        if partialPlaylist.images.count > 0 {
                            if let artwork = partialPlaylist.images[0] as? SPTImage {
                                let artworkURL = artwork.imageURL
                                if let artworkData = try? Data.init(contentsOf: artworkURL!) {
                                    let artworkImage = UIImage(data: artworkData)
                                    destinationViewController.playlists.append(Playlist(artworkImage: artworkImage, title: title))
                                }
                            }
                        } else {
                            // Set default image
                            destinationViewController.playlists.append(Playlist(artworkImage: UIImage.init(contentsOfFile: "/Users/cponcede/Developer/CS 193P Final Project/CS 193P Final Project/Images/NoPhotoDefault.png"), title: title))
                            print("No playlist image, Skipping for now.")
                        }
                        
                    }
                    print("Adding \(sptPlaylists.items.count) playlists")
                    //destinationViewController.playlists.append(newPlaylists)
                    if newPlaylists.hasNextPage {
                        self.getMorePlaylists(sptPlaylists: newPlaylists, destinationViewController: destinationViewController)
                    } else {
                        destinationViewController.doneSettingPlaylists = true
                    }
                    } else {
                    print("Error retrieving spotify playlists")
                }
            })
        }
        
    }
    
    func getUserPlaylists(destinationViewController: SpotifyPlaylistsTableViewController) {
            SPTPlaylistList.playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken, callback: { (error, playlists) in
                if (error == nil) {
                    let sptPlaylists = playlists as! SPTListPage
                    print("Adding \(sptPlaylists.items.count) playlists")
                    for playlist in sptPlaylists.items {
                        let partialPlaylist = playlist as! SPTPartialPlaylist
                        let title = partialPlaylist.name
                        destinationViewController.numPlaylists += 1
                        if partialPlaylist.images.count > 0 {
                            if let artwork = partialPlaylist.images[0] as? SPTImage {
                                let artworkURL = artwork.imageURL
                                if let artworkData = try? Data.init(contentsOf: artworkURL!) {
                                    let artworkImage = UIImage(data: artworkData)
                                    destinationViewController.playlists.append(Playlist(artworkImage: artworkImage, title: title))
                                }
                            }
                        } else {
                            destinationViewController.playlists.append(Playlist(artworkImage: UIImage.init(contentsOfFile: "/Users/cponcede/Developer/CS 193P Final Project/CS 193P Final Project/Images/NoPhotoDefault.png"), title: title))
                            print("No playlist image, Skipping for now.")
                        }
                        
                    }
                    //destinationViewController.playlists.append(sptPlaylists)
                    if sptPlaylists.hasNextPage {
                        self.getMorePlaylists(sptPlaylists: sptPlaylists, destinationViewController: destinationViewController)
                    } else {
                        destinationViewController.doneSettingPlaylists = true
                    }
                    
                } else {
                    print("Error retrieving spotify playlists")
                }
            })
    }
    
    func getMoreSongs(currentPage: SPTListPage, destinationViewController: SpotifySongsTableViewController) {
        if currentPage.hasNextPage {
            currentPage.requestNextPage(withAccessToken: self.authData.session.accessToken, callback: {
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
                                
                                let spotifyURL = song.playableUri
                                destinationViewController.songs.append(Song(title: title, artist: artistString, albumTitle: album, spotifyURL: spotifyURL))
                            }
                        }
                        self.getMoreSongs(currentPage: songs, destinationViewController: destinationViewController)
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
    
    func retrieveUserLibrary(destinationViewController: SpotifySongsTableViewController) {
        print("IN RETRIVE USER LIBRARY")
        SPTYourMusic.savedTracksForUser(withAccessToken: self.authData.session.accessToken, callback: {
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
                            
                            let spotifyURL = song.playableUri
                            destinationViewController.songs.append(Song(title: title, artist: artistString, albumTitle: album, spotifyURL: spotifyURL))
                        }
                    }
                    self.getMoreSongs(currentPage: songs, destinationViewController: destinationViewController)
                }
            } else {
                print("Error retrieving saved tracks for user")
                return
            }
            
        })
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
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
            return numShortcuts
        } else if section == 1 {
            // TODO: Update with recents
            return 0
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
            case 2:
                return tableView.dequeueReusableCell(withIdentifier: "albums", for: indexPath)
            case 3:
                return tableView.dequeueReusableCell(withIdentifier: "artists", for: indexPath)
            default:
                return tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
            }
        }
        return tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let id = cell.reuseIdentifier
            if (id == "playlists") {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let playlistsTableViewController = destinationViewController as? SpotifyPlaylistsTableViewController {
                    //playlistsTableViewController.playlists = getUserPlaylists()
                    playlistsTableViewController.authData = self.authData
                    getUserPlaylists(destinationViewController: playlistsTableViewController)
                    print ("SEGUE WORKED!")
                }
                
            } else if (id == "songs") {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let songsTableViewController = destinationViewController as? SpotifySongsTableViewController {
                    //playlistsTableViewController.playlists = getUserPlaylists()
                    songsTableViewController.title = "Saved Tracks"
                    songsTableViewController.authData = self.authData
                    retrieveUserLibrary(destinationViewController: songsTableViewController)
                }
                
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
