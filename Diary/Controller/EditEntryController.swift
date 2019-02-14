//
//  EditEntryController
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
// This View Controller is responsible for creating or editing an entry.
// The behaviour is very similar.
// If the view controller is creating a new entry then an entry won't be injected otherwise an entry will be injected and the view controller can set itself up for this case.

import UIKit
import CoreData
import MapKit

class EditEntryController: UITableViewController {
    
    // Interface Builder Outlets
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryDescriptionTextView: UITextView!
    @IBOutlet weak var moodLevelSlider: UISlider!
    @IBOutlet weak var locationButton: UIButton!
    
    // Properties
    /// Represents the current entry. This will be nil when the viewLoads if the user is creating a new entry.
    var entry: Entry?
    
    var entryImage: UIImage? {
        didSet {
            entryImageView.image = entryImage
        }
    }
    
    var entryLocation: MKMapItem? {
        didSet {
            locationButton.setTitle(entryLocation?.name, for: .normal)
        }
    }
    
    lazy var imagePickerManager: ImagePickerManager? = {
        // If the available media type is not available then this initializer will fail.
        guard let pickerManager = ImagePickerManager(presentingController: self) else { return nil }
        pickerManager.delegate = self
        return pickerManager
    }()
    
    weak var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checks to see if an existing entry was set by another ViewController, if so setup with this entry.
        if let existingEntry = entry {
            setup(with: existingEntry)
        }
    }
    
    func setup(with entry: Entry) {
        // Use an existing entry to configure the view.
    }

    
    // MARK: Image Selection/Updating
    @IBAction func entryImageViewTapped(_ sender: UITapGestureRecognizer) {
        if entryImage == nil {
            // No image has been specified. Let's try and get one.
            imagePickerManager?.presentImagePicker()
        } else {
            // An image has already been selected. Show an action sheet.
            displayEditImageActionSheet()
        }
    }
    
    func displayEditImageActionSheet() {
        let editImageActionSheet = UIAlertController.actionSheet()
        
        let removeAction = UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
            self.entryImage = nil
        }
        
        let newImageAction = UIAlertAction(title: "Change Image", style: .default) { _ in
            self.imagePickerManager?.presentImagePicker()
        }

        editImageActionSheet.addActions([removeAction, newImageAction])
        
        present(editImageActionSheet, animated: true, completion: nil)
    }
    
    // MARK: Saving Entry
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        do {
            try saveEntry()
        } catch {
            print(error)
        }
    }
    
    func saveEntry() throws {
        
        guard let moc = managedObjectContext else { throw DiaryError.missingContextDuringSave }
        
        // The only requirement to save an entry is to have a valid description. Everything else will have a default value or be nil.
        guard let entryDescription = entryDescriptionTextView.text, entryDescription.count > 0 else {
            showAlert(for: .emptyDescription)
            return
        }
        
        let moodValue = Int(moodLevelSlider.value)
        
        guard let newEntry = Entry.newEntry(withDescription: entryDescription, mood: moodValue , image: entryImage, mapItem: entryLocation, inContext: moc) else {
            let alert = UIAlertController.alert(with: "Failed to create a new entry model.")
            present(alert, animated: true, completion: nil) // FIXME: Add error and present using error type instead
            return
        }
        
        try moc.save()
        
        dismiss()
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddLocation", let navigationController = segue.destination as? UINavigationController, let locationSearchController = navigationController.topViewController as? LocationSearchController {
            
            locationSearchController.delegate = self
        }
    }
    @IBAction func cancelEditTapped(_ sender: Any) {
        dismiss()
    }
    
    // Dismisses the nav controller that presented this edit view.
    func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Error Alert
    func showAlert(for error: DiaryError) {
        let alert = UIAlertController.alert(for: error, action: nil)
        present(alert, animated: true, completion: nil)
    }
}

// Allows the Edit Entry Controller to listen for a call from the Image Picker Manager
extension EditEntryController: ImagePickerManagerDelegate {
    func imagePickerManager(_ manager: ImagePickerManager, didSelectImage image: UIImage) {
        entryImage = image
    }
}

// Allow the edit entry controller to listen for a call from the Location search controller with a location selected by the user.
extension EditEntryController: LocationSearchControllerDelegate {
    func locationSearchController(_ controller: LocationSearchController, userSelectedMapItem mapItem: MKMapItem) {
        entryLocation = mapItem
    }
    
}

