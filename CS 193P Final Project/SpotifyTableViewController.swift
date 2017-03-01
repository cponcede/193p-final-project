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
    
    var session : SPTSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Spotify"
        print("IN VDL")
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
                        self.retrieveUserLibrary()
                    } else {
                        print("Error refreshing Spotify auth token")
                    }
                })
            } else {
                print("Session valid")
                // Display user's library
                self.session = session
                self.retrieveUserLibrary()
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
    }
    
    func updateAfterLogin() {
        self.session = SPTAuth.defaultInstance().session
        retrieveUserLibrary()
    }
    
    func retrieveUserLibrary() {
        print("IN RETRIVE USER LIBRARY")
        var request : URLRequest?
        do {
            request = try SPTYourMusic.createRequestForCurrentUsersSavedTracks(withAccessToken: session.accessToken)
            NSURLConnection.sendAsynchronousRequest(request!, queue: OperationQueue(), completionHandler: { (response: URLResponse?, data: Data?, error: Error?) in
                do {
                    // TODO: Debug this and get playlists appearing.
                    print("About to try to decode response")
                    if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) {
                        print(jsonResult)
                    }
                } catch let error as Error {
                    print(error.localizedDescription)
                }
                
            })
        } catch {
            print("Erorr generating library request")
            return
        }
        
        
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
