//
//  SongPlayCount.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import CoreData
import UIKit

class SongPlayCount: NSManagedObject {
    
    class func findOrCreateSongPlayCount(_ songPlayed : Song, day: Int, month: Int, year: Int, in context: NSManagedObjectContext) throws -> SongPlayCount {
        let request : NSFetchRequest<SongPlayCount> = SongPlayCount.fetchRequest()
        let identifierPredicate = NSPredicate(format: "identifier==%@", songPlayed.spotifyURL!.absoluteString)
        let dayPredicate = NSPredicate(format: "day == %d", day)
        let monthPredicate = NSPredicate(format: "month == %d", month)
        let yearPredicate = NSPredicate(format: "year == %d", year)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [identifierPredicate, dayPredicate, monthPredicate, yearPredicate])
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "SongPlayCount -- database inconsistency")
                matches[0].count = matches[0].count + 1
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let songPlayCount = SongPlayCount(context: context)
        songPlayCount.identifier = songPlayed.spotifyURL!.absoluteString
        songPlayCount.month = Int64(month)
        songPlayCount.day = Int64(day)
        songPlayCount.year = Int64(year)
        songPlayCount.count = 1
        return songPlayCount
    }
    
    
}
