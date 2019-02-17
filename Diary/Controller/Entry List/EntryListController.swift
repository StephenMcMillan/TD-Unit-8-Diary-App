//
//  EntryListController.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import CoreData

class EntryListController: BaseTableViewController, ErrorAlertable {
    
    // Creates a new core data stack to work with throughout the application.
    let coreDataStack: CoreDataStack = CoreDataStack()
    
    // Fetched results controller provides the entries for us to work with.
    lazy var fetchedResultsController: NSFetchedResultsController<Entry> = {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        let dateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [dateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.coreDataStack.managedObjectContext, sectionNameKeyPath: "creationMonth", cacheName: nil)
        fetchedResultsController.delegate = self
       return fetchedResultsController
    }()
    
    // Table View that will display searched entries
    private lazy var searchResultsController: SearchResultsController = {
        let searchResultsController = SearchResultsController()
        searchResultsController.tableView.delegate = self
        return searchResultsController
    }()
    
    // Search results controller that provides a search bar for searching entries
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchResultsController)
        searchController.searchResultsUpdater = self // This view controller will be alerted when the search bar changes text etc.
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.tintColor = .white
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    // MARK: View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set-up for search controller
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Try and fetch the data from the database...
        do {
            try fetchedResultsController.performFetch()
        } catch {
            displayAlert(for: error)
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
        
        // Fetch entry from fetchedResultsController, set-up cell using parent method.
        let entry = fetchedResultsController.object(at: indexPath)
        configureCell(cell, forEntry: entry)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Commit the deletion, because we only enable .delete there's no need to check what action is taken.
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        coreDataStack.managedObjectContext.delete(objectToDelete)
        
        do {
           try coreDataStack.managedObjectContext.save()
        } catch {
            displayAlert(for: error)
        }
    }
    
    // MARK: Table View Delegate method for deleting items
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // TODO: This may need adjusting
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Since the delegate of the searchResultsController is set to self, entryListController manages both its own delegate calls and the searchResultsControllers delegate calls.
        
        let selectedEntry: Entry
        
        if tableView == self.tableView {
            // The user tapped a regular entry in THIS view controller.
            selectedEntry = fetchedResultsController.object(at: indexPath)
        } else {
            // The user tapped an entry from the search results controller
            selectedEntry = searchResultsController.filteredEntries[indexPath.row]
        }
        
        // Create a detail view controller and push it to the navigation stack.
        guard let storyboard = storyboard, let detailViewController = storyboard.instantiateViewController(withIdentifier: EntryDetailController.storyboardIdentifier) as? EntryDetailController else {
            return
        }
        
        detailViewController.managedObjectContext = coreDataStack.managedObjectContext
        detailViewController.entry = selectedEntry
        
        navigationController?.pushViewController(detailViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false) // No need to animate as view will be off-screen.
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
