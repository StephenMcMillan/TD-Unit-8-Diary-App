//
//  EntryListController+SearchDelegates.swift
//  Diary
//
//  Created by Stephen McMillan on 17/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

extension EntryListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // This is where the heavy work happens.
        
        // Without the results controller, it will be impossible to display the search results.
        guard let searchResultsController = searchController.searchResultsController as? SearchResultsController, let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        // Very very basic search based on string contents.
        let results = fetchedResultsController.fetchedObjects?.filter({ (entry) -> Bool in
            
            if entry.entryDescription.lowercased().contains(searchText) || (entry.creationDate as Date).longStringRepresentation.lowercased().contains(searchText) {
                return true
            } else {
                return false
            }
            
        })
        
        searchResultsController.filteredEntries = results ?? []
        searchResultsController.tableView.reloadData()
    }
}

extension EntryListController: UISearchControllerDelegate {}

extension EntryListController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
