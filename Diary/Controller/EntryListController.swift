//
//  EntryListController.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import CoreData

class EntryListController: UITableViewController {
    
    let coreDataStack: CoreDataStack = CoreDataStack()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
       return fetchedResultsController
    }()
    
    // MARK: View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Try and fetch the data from the database...
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print("Something went wrong when fetching the objets.")
        }
    }
    
    // MARK: Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.reuseIdentifier, for: indexPath) as! EntryCell
        
        let entry = fetchedResultsController.object(at: indexPath)
        
        cell.dateLabel.text = "\(entry.creationDate)"
        cell.descriptionLabel.text = entry.entryDescription
        
        if let entryLocation = entry.location {
            cell.locationLabel.text = entryLocation.name
        }
        
        return cell
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let navigationController = segue.destination as? UINavigationController else { return }
        
        switch segue.identifier {
        case "AddNewEntry":
            
            
            guard let addEntryView = navigationController.topViewController as? EditEntryController else {
                return
            }
            
            addEntryView.managedObjectContext = coreDataStack.managedObjectContext
            
        case "ViewEntry":
            print("Viewing entry")
        default:
            break
        }
    }
}

extension EntryListController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
