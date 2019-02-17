//
//  BaseTableViewController.swift
//  Diary
//
//  Created by Stephen McMillan on 17/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var filteredEntries: [Entry] = []
    
    private static let entryCellNibName = "EntryCell"
    static let entryCellReuseIdentifier = "EntryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads the entry cell from the nib file
        let nib = UINib(nibName: BaseTableViewController.entryCellNibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BaseTableViewController.entryCellReuseIdentifier)
    }
    
    func configureCell(_ cell: EntryCell, forEntry entry: Entry) {
        // Fetch entry from fetchedResultsController, create a view-model and use that view-model to configure the cell.
        let viewModel = EntryViewModel(entry: entry)
        cell.configure(with: viewModel)
    }
}

