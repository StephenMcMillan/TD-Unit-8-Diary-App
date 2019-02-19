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
    
    static let storyboardIdentifier: String = String(describing: EntryDetailController.self)
    
    weak var entry: Entry?
    weak var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var contentStackView: UIStackView!
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
        
        updateDisplayMode()
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
            entryLocationMapView.isHidden = false
            let mapAnnotation = LocationAnnotation(location: location)
            entryLocationMapView.addAnnotation(mapAnnotation)

            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: mapAnnotation.coordinate, span: span)
            entryLocationMapView.setRegion(region, animated: false)
        } else {
            entryLocationMapView.isHidden = true
        }
        
        moodCircleLabel.text = viewModel.moodString
        
        // This view is not drawn by the time this property is set, i think..
        moodCircle.moodLevel = Int(entry?.mood ?? 0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let moodValue = entry?.mood {
            moodCircle.setMood(Int(moodValue))
        }
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
        entry = nil
        
        do {
            try managedObjectContext?.save()
            
            navigationController?.popViewController(animated: true)
            updateDisplayMode()
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
    
    func updateDisplayMode() {
        // If the entry is nil, hide the content view.
        if entry == nil {
            navigationItem.rightBarButtonItem?.isEnabled = false
            contentStackView.isHidden = true
            title = "Select an Entry"
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            contentStackView.isHidden = false
        }
    }
    

}

