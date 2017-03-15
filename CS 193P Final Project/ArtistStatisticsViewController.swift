//
//  ArtistStatisticsViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/12/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class ArtistStatisticsViewController: UIViewController {
    
    // Static dictionary for converting from int representation of month to the name of the month.
    static let intToMonth = [1: "January",
                     2: "February",
                     3: "March",
                     4: "April",
                     5: "May",
                     6: "June",
                     7: "July",
                     8: "August",
                     9: "September",
                     10: "October",
                     11: "November",
                     12: "December"]
    
    // Get American representatino of date as String
    private static func getDateString(day : Int, month : Int, year : Int) -> String {
        return "\(month)/\(day)/\(year)"
    }
    
    // Map from year -> (Map from month -> (Map from day -> play count))
    var songPlayStatistics = SongPlayStatistics()
    
    var artist : Artist? {
        didSet {
            print("Showing listening stats for \(artist!.name!)")
            for item in (artist?.songs)! {
                if let songPlayCount = item as? SongPlayCount {
                    songPlayStatistics.setPlayCountForDate(year: Int(songPlayCount.year),
                                                           month: Int(songPlayCount.month),
                                                           day: Int(songPlayCount.day),
                                                           count: Int(songPlayCount.count))
                }
            }
            songPlayStatistics.printStats()
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
