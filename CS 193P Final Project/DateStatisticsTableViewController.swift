//
//  DateStatisticsTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/18/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import CoreData
import UIKit

class DateStatisticsTableViewController: UITableViewController {
    
    var date: Date? {
        didSet {
            if let context = container?.viewContext {
                let calendar = NSCalendar.current
                let year = calendar.component(.year, from: date!)
                let month = calendar.component(.month, from: date!)
                let day = calendar.component(.day, from: date!)
                self.title = "\(month)/\(day)/\(year)"
                let request: NSFetchRequest<SongPlayCount> = SongPlayCount.fetchRequest()
                let dayPredicate = NSPredicate(format: "day=%d", day)
                let monthPredicate = NSPredicate(format: "month=%d", month)
                let yearPredicate = NSPredicate(format: "year=%d", year)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, monthPredicate, yearPredicate])
                request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
                fetchedResultsController = NSFetchedResultsController<SongPlayCount>(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: nil,
                    cacheName: nil
                )
                do {
                    try fetchedResultsController?.performFetch()
                } catch {
                    print ("DateStatisticsTableViewController.Error: Perform fetch failed")
                }
                tableView.reloadData()
            }
            updateUI()
        }
    }

    private var fetchedResultsController: NSFetchedResultsController<SongPlayCount>?
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUI() {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCountCell", for: indexPath)
        if let songPlayCount = fetchedResultsController?.object(at: indexPath),
            let customCell = cell as? SongPlaycountCell {
            customCell.titleLabel.text = songPlayCount.title
            customCell.artistLabel.text = songPlayCount.artist!.name!
            customCell.countLabel.text = String(describing: songPlayCount.count)
        }
        return cell
    }
}
