//
//  ArtistsDataTableViewController.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/11/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import CoreData
import UIKit

class ArtistsDataTableViewController: UITableViewController {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private var fetchedResultsController: NSFetchedResultsController<Artist>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Listening statistics"
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Artist> = Artist.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
            fetchedResultsController = NSFetchedResultsController<Artist>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print ("ArtistsDataTableViewController.Error: Fetch request failed")
            }
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistDataCell", for: indexPath)
        if let artist = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = artist.name
            cell.detailTextLabel?.text = "\(artist.count) plays"
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
            let identifier = segue.identifier {
            if identifier == "showArtistGraph" {
                var destinationViewController = segue.destination
                if let navigationController = destinationViewController as? UINavigationController {
                    destinationViewController = navigationController.visibleViewController ?? destinationViewController
                }
                if let artistStatisticsViewController = destinationViewController as? ArtistStatisticsViewController {
                    let row = tableView.indexPath(for: cell)!.row
                    let artist = fetchedResultsController?.object(at: tableView.indexPath(for: cell)!)
                    artistStatisticsViewController.artist = artist!
                    artistStatisticsViewController.title = "\(artist!.name!)"
                }
            }
        }
    }

}
