//
//  EntryDetailController.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// Displays the details of a particular diary entry.
class EntryDetailController: UIViewController, ErrorAlertable {
    
    weak var entry: Entry?
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryDescriptionLabel: UILabel!
    @IBOutlet weak var entryLocationLabel: UILabel!
    @IBOutlet weak var entryLocationMapView: MKMapView!
    @IBOutlet weak var moodCircle: MoodCircleView!
    @IBOutlet weak var moodCircleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Having this loading code in the viewWillAppear ensures that the view is updated if an entry is updated. :D
        if let entry = entry {
            configure(with: EntryViewModel(entry: entry))
        }
    }
    
    func configure(with viewModel: EntryViewModel) {
        title = viewModel.creationDate
        
        if let entryImage = viewModel.image {
            entryImageView.image = entryImage
        }
        
        entryDescriptionLabel.text = viewModel.description
        entryLocationLabel.text = viewModel.locationName
        
        // Map View setup
        if let location = entry?.location {
            let mapAnnotation = LocationAnnotation(location: location)
            entryLocationMapView.addAnnotation(mapAnnotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: mapAnnotation.coordinate, span: span)
            entryLocationMapView.setRegion(region, animated: true)
        } else {
            entryLocationMapView.isHidden = true
        }
        
        // Mood Circle Setup
        moodCircle.moodLevel = viewModel.mood
        moodCircleLabel.text = viewModel.moodString
    }
    
    @IBAction func deleteEntry(_ sender: Any) {
        
        let deleteAlert = UIAlertController(title: "Delete Entry", message: "Are you sure you want to delete this diary entry. Once deleted, this entry can not be recovered.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: confirmDeleteEntry)
        
        deleteAlert.addActions([cancelAction, deleteAction])
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func confirmDeleteEntry(_ alertAction: UIAlertAction) {
        managedObjectContext?.delete(entry!)
        
        do {
            try managedObjectContext?.save()
            
            navigationController?.popViewController(animated: true)
        } catch {
            // Prsesent an alert because something went wrong whilst try to delete this entry.
            displayAlert(for: error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we are going to the edit view controller, pass through the entry we are working with.
        guard segue.identifier == "EditExistingEntry",
            let navigationController = segue.destination as? UINavigationController,
            let editEntyrViewController = navigationController.topViewController as? EditEntryController else { return }
        
        // Pass through the current entry and moc
        editEntyrViewController.entry = entry
        editEntyrViewController.managedObjectContext = managedObjectContext
    }
}

