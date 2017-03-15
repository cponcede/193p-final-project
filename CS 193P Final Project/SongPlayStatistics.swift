//  Class used to store playback stats for a particular artist
//  SongPlayStatistics.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/14/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

class SongPlayStatistics {
    
    private var yearlyData = [Int: [Int: [Int: Int]]]()
    
    func setPlayCountForDate(year: Int, month: Int, day: Int, count: Int) {
        if yearlyData[year] == nil {
            yearlyData[year] = [Int: [Int: Int]]()
        }
        if yearlyData[year]![month] == nil {
            yearlyData[year]![month] = [Int: Int]()
        }
        yearlyData[year]![month]![day] = count
    }
    
    func getPlayCountForDate(year: Int, month: Int, day: Int) -> Int {
        if yearlyData[year]?[month]?[day] == nil {
            return 0
        } else {
            return yearlyData[year]![month]![day]!
        }
    }
    
    // TODO: Figure out best way to represent play counts to graph using custom view
    
    private func getDateString(day : Int, month : Int, year : Int) -> String {
        return "\(month)/\(day)/\(year)"
    }
    
    func printStats() {
        for year in yearlyData.keys.sorted() {
            for month in yearlyData[year]!.keys.sorted() {
                for day in yearlyData[year]![month]!.keys.sorted() {
                    let count = yearlyData[year]![month]![day]!
                    let dateString = getDateString(day: day, month: month, year: year)
                    print("\(dateString) - \(count)")
                }
            }
        }
    }
}
