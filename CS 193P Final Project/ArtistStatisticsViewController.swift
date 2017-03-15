//
//  ArtistStatisticsViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/12/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//
import Charts
import UIKit

class ArtistStatisticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dataTableView: UITableView!
    
    @IBOutlet weak var graphView: BarChartView? {
        didSet { updateUI() }
    }
    
    private var cachedPlaybackData : [String : Int]?
    
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
                    print("\(Int(songPlayCount.month))/\(Int(songPlayCount.day))/\(Int(songPlayCount.year)) - \(Int(songPlayCount.count))")
                    songPlayStatistics.setPlayCountForDate(year: Int(songPlayCount.year),
                                                           month: Int(songPlayCount.month),
                                                           day: Int(songPlayCount.day),
                                                           count: Int(songPlayCount.count))
                }
            }
            //songPlayStatistics.printStats()
            updateUI()            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTableView.dataSource = self
        dataTableView.delegate = self
    }
    
    private func updateUI() {
        if graphView != nil && artist != nil {
            let (_, yVals, dates) = songPlayStatistics.getGraphStats()
            var dataEntries : [BarChartDataEntry] = []
            for i in 0..<yVals.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yVals[i]))
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Plays per month")
            let chartData = BarChartData.init(dataSets: [chartDataSet])
            graphView!.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
            graphView!.xAxis.granularity = 1
            graphView!.data = chartData
            dataTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cachedPlaybackData == nil {
            cachedPlaybackData = songPlayStatistics.getAllData()
        }
        if section == 0  {
            return cachedPlaybackData!.keys.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCount", for: indexPath)
        let dateString = cachedPlaybackData!.keys.sorted()[indexPath.row]
        cell.textLabel?.text = dateString
        cell.detailTextLabel?.text = String(describing: cachedPlaybackData![dateString]!)
        return cell
    }


    

}
