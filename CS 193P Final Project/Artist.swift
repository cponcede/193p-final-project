//
//  Artist.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

import CoreData
class Artist: NSManagedObject {
    class func addPlayedSongToCoreData(artistId: String, songPlayed : Song, day: Int, month: Int, year: Int, in context: NSManagedObjectContext) throws -> Artist {
        let request : NSFetchRequest<Artist> = Artist.fetchRequest()
        request.predicate = NSPredicate(format: "identifier==%@", artistId)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Artist.addPlayedSongToCoreData -- database inconsistency")
                let newSongData = try SongPlayCount.findOrCreateSongPlayCount(songPlayed, day: day, month: month, year: year, in: context)
                matches[0].addToSongs(newSongData)
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let artist = Artist(context: context)
        artist.identifier = artistId
        let newSongData = try SongPlayCount.findOrCreateSongPlayCount(songPlayed, day: day, month: month, year: year, in: context)
        artist.addToSongs(newSongData)
        return artist
    }

}
