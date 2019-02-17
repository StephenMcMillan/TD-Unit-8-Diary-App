//
//  SearchResultsController.swift
//  Diary
//
//  Created by Stephen McMillan on 16/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

// To implement search controller functionality.
// Create a custom table view controller base class that loads the cell nib and has a config cell method.

// EntryList can be a sub-class with a search controller object.
// Search Resutls controller shouldn't be too difficult to implement.
class SearchResultsController: BaseTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BaseTableViewController.entryCellReuseIdentifier, for: indexPath) as! EntryCell
        
        // Setting up the cell using a method in the parent class 'BaseTableViewController'
        configureCell(cell, forEntry: filteredEntries[indexPath.row])
        
        return cell
        
    }
}
