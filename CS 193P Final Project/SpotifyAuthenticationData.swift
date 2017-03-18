//
//  SpotifyAuthenticationData.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/2/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

class SpotifyAuthenticationData {
    
    let clientId = "4275d7c3c3864d7988c42a7d282aaaa4"
    let callbackURL = "cponcede-cs193p-project-spotify://callback"
    let tokenSwapURL = ""
    let tokenRefreshServiceURL = ""
    
    var session : SPTSession?
    
    @objc public func updateAfterLogin() {
        self.session = SPTAuth.defaultInstance().session
    }
    
    func getAccessToken() -> String {
        if session != nil {
            return session!.accessToken
        } else {
            getNewSession()
            while self.session == nil {
                sleep(1)
            }
            return self.session!.accessToken
        }
    }
    
    func getCanonicalUsername() -> String {
        if session != nil {
            return session!.canonicalUsername
        } else {
            getNewSession()
            while self.session == nil {
                sleep(1)
            }
            return self.session!.canonicalUsername
        }
    }
    
    
    func getNewSession() {
        NotificationCenter.default.addObserver(self, selector: Selector("updateAfterLogin"), name: NSNotification.Name.init(rawValue: "spotifyLoginSuccessful") , object: nil)
        
        let userDefaults = UserDefaults.standard
        if let sessionObj = userDefaults.value(forKey: "spotifySession") {
            print("FOUND SAVED SESSION")
            let sessionDataObj = sessionObj as? Data
            let session = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj!) as! SPTSession
            // TODO: Have this no longer always get a new session
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

        
    }
}
