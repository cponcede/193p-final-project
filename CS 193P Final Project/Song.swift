//
//  Song.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/2/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import CoreData
import Foundation

class Song: NSObject, NSCoding {

    var title: String?
    var artist: String?
    var artistId : String?
    var albumTitle: String?
    var spotifyURL: URL?
    
    init(title: String?, artist: String?, artistId: String?, albumTitle: String?, spotifyURL: URL?) {
        super.init()
        self.title = title
        self.artist = artist
        self.artistId = artistId
        self.albumTitle = albumTitle
        self.spotifyURL = spotifyURL
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(artistId, forKey: "artistId")
        aCoder.encode(albumTitle, forKey: "albumTitle")
        aCoder.encode(spotifyURL, forKey: "spotifyURL")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let title = aDecoder.decodeObject(forKey: "title") as? String,
            let artist = aDecoder.decodeObject(forKey: "artist") as? String,
            let artistId = aDecoder.decodeObject(forKey: "artistId") as? String,
            let albumTitle = aDecoder.decodeObject(forKey: "albumTitle") as? String,
            let spotifyURL = aDecoder.decodeObject(forKey: "spotifyURL") as? URL {
            self.init(title: title, artist: artist, artistId: artistId, albumTitle: albumTitle, spotifyURL: spotifyURL)
        } else {
            print("Failure decoding")
            return nil
        }
    }
}
