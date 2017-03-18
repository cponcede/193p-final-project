//
//  StatisticsViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/18/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    @IBOutlet weak var dateSelector: UIDatePicker!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statistics"
        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "showArtistStats" {
                print("Segueing")
            } else if id == "showDateStats" {
                print("showDateStats")
                let date = dateSelector.date
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let dateViewController = destinationViewController as? DateStatisticsTableViewController {
                    print("About to segue")
                    dateViewController.date = date
                }
            }
        }
    }
}
