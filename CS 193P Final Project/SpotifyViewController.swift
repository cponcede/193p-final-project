//
//  ViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 2/28/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class SpotifyViewController: UIViewController {
    
    let clientId = "4275d7c3c3864d7988c42a7d282aaaa4"
    let callbackURL = "cponcede-cs193p-project-spotify://callback"
    let tokenSwapURL = ""
    let tokenRefreshServiceURL = ""
    
    var session : SPTSession!

    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginWithSpotify(_ sender: UIButton) {
    }
    
    func updateAfterLogin() {
        loginButton.isHidden = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN VDL")
        loginButton.isHidden = true
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


}

