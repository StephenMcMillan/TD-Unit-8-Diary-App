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
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, sectionNameKeyPath: "creationMonth", cacheName: nil)
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Gets the section name from the fetched results controller. These are categorised by month and year
        guard let section = fetchedResultsController.sections?[section] else { return nil }
        return section.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.reuseIdentifier, for: indexPath) as! EntryCell
        
        // Fetch entry from fetchedResultsController, create a view-model and use that view-model to configure the cell.
        let entry = fetchedResultsController.object(at: indexPath)
        let viewModel = EntryViewModel(entry: entry)
        cell.configure(with: viewModel)
        return cell
        
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        switch segue.identifier {
        case "AddNewEntry":
            
            guard let navigationController = segue.destination as? UINavigationController else { return }
            
            guard let addEntryView = navigationController.topViewController as? EditEntryController else {
                return
            }
            
            addEntryView.managedObjectContext = coreDataStack.managedObjectContext
            
        case "ViewEntry":
            
            guard let entryDetailView = segue.destination as? EntryDetailController else {
                return
            }
            
            // Gets the entry from the fetched results controller for the index path that was tapped and passes it through to the detail view.
            guard let selectedTableIndex = tableView.indexPathForSelectedRow else { return }
            entryDetailView.managedObjectContext = coreDataStack.managedObjectContext
            entryDetailView.entry = fetchedResultsController.object(at: selectedTableIndex)
            
        default:
            break
        }
    }
}

extension EntryListController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Handle the insertion/deletion of sections.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
    
    // Handle the insertion, deletion and updating of rows.
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
