//  Class used to store playback stats for a particular artist
//  SongPlayStatistics.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/14/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

class SongPlayStatistics {
    
    private let daysInMonth = [1: 31,
                               2: 28,
                               3: 31,
                               4: 30,
                               5: 31,
                               6: 30,
                               7: 31,
                               8: 31,
                               9: 30,
                               10: 31,
                               11: 30,
                               12: 31]
    
    // Static dictionary for converting from int representation of month to the name of the month.
    static let intToMonth = [1: "Jan",
                             2: "Feb",
                             3: "Mar",
                             4: "Apr",
                             5: "May",
                             6: "Jun",
                             7: "Jul",
                             8: "Aug",
                             9: "Sep",
                             10: "Oct",
                             11: "Nov",
                             12: "Dec"]
    
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
    
    func getGraphStats() -> ([Int], [Int], [String]) {
        var xVals : [Int] = []
        var yVals : [Int] = []
        var dates : [String] = []
        let sortedYears = yearlyData.keys.sorted()
        let firstYear = sortedYears[0]
        let lastYear = sortedYears[sortedYears.count - 1]
        var monthCount = 0
        for year in firstYear...lastYear {
            for month in 1...12 {
                if yearlyData[year] == nil ||
                    yearlyData[year]![month] == nil {
                    xVals.append(monthCount)
                    yVals.append(0)
                    dates.append("\(month)/\(year)")
                } else {
                    var playbacks = 0
                    for day in yearlyData[year]![month]!.keys {
                        playbacks = yearlyData[year]![month]![day]! + playbacks
                    }
                    xVals.append(monthCount)
                    yVals.append(playbacks)
                    dates.append("\(month)/\(year)")
                }
                monthCount = monthCount + 1
            }
        }
        return (xVals, yVals, dates)
    }
    
    private func getDateString(day : Int, month : Int, year : Int) -> String {
        return "\(month)/\(day)/\(year)"
    }
    
    func getAllData() -> [String: Int]{
        var result = [String : Int]()
        for year in yearlyData.keys.sorted() {
            for month in yearlyData[year]!.keys.sorted() {
                for day in yearlyData[year]![month]!.keys.sorted() {
                    let count = yearlyData[year]![month]![day]!
                    let dateString = getDateString(day: day, month: month, year: year)
                    result[dateString] = count
                }
            }
        }
        return result
    }
}
