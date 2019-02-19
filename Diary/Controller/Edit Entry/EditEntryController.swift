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

class EditEntryController: UITableViewController, ErrorAlertable {
    
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
        
        configureKeyboardToolbar()
        
        // Checks to see if an existing entry was set by another ViewController, if so setup with this entry.
        if let existingEntry = entry {
            setup(with: existingEntry)
        } else {
            title = Date().longStringRepresentation
        }
    }
    
    // Set-up code if this view is given an existing entry.
    func setup(with entry: Entry) {
        // Use an existing entry to configure the view.
        // Kind of short circuiting of the logic for new entries.
        let entryViewModel = EntryViewModel(entry: entry)
        title = entryViewModel.creationDate
        entryImageView.image = entryViewModel.image
        entryDescriptionTextView.text = entryViewModel.description
        moodLevelSlider.value = Float(entryViewModel.mood)
        locationButton.setTitle(entryViewModel.locationName, for: .normal)
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
        
        // Special display case for iPads
        if let popoverController = editImageActionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: entryImageView.frame.midX, y: entryImageView.frame.midY, width: 0, height: 0)
        }
        
        present(editImageActionSheet, animated: true, completion: nil)
    }
    
    // MARK: Saving Entry
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        do {
            try saveEntry()
        } catch {
            displayAlert(for: error)
        }
    }
    
    func saveEntry() throws {
        
        // MOC Required to save.
        guard let moc = managedObjectContext else {
            throw DiaryError.missingContextDuringSave
        }
        
        // Must have populated description field.
        guard let entryDescription = entryDescriptionTextView.text, entryDescription.count > 0 else {
            throw DiaryError.emptyDescription
        }
        
        let moodValue = Int(moodLevelSlider.value)
        
        // One of two things can now happen:
        // ---------------------------------
        // 1) an existing entry is present, in which case we are editing and need to update that entry.
        // 2) no entry was present, in which case we are creating a new entry.

        if let entry = entry {
            
            if let entryImage = entryImage, let imageData = entryImage.jpegData(compressionQuality: 0.5) {
                // If there's a new entry image we need to convert and save it.
                entry.image = imageData as NSData
            }
            
            entry.entryDescription = entryDescription
            entry.mood = Int32(moodValue)
            
            // entryLocation will be non-nill if the user selects a location from the location modal.
            if let newEntryLocation = entryLocation {
                // If the user selected a new locatiom, update the entry with this new location.
                let newLocation = Location.newLocation(withName: newEntryLocation.name, coordinate: newEntryLocation.placemark.coordinate, inContext: moc)
                entry.location = newLocation
            }
            
            // Once we get here, any relevant sections should be up to date with the users choices.
            // Continue saving and dismiss.
            
        } else {
            // Create a new entry and add it to the managed object context
            Entry.new(withDescription: entryDescription, mood: moodValue, image: entryImage, mapItem: entryLocation, inContext: moc)
        }
        
        // Once there's either a new entry or an updated entry, save the changes and dismiss.
        try moc.save()
        dismiss() // The user will be returned to the detail view or the entry list depending on how they got here.
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
    
    func dismiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Keyboard toolbar helper for dismissing the keyboard in the text view.
    func configureKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 30.0)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditEntryController.keyboardDoneButtonAction))
        
        // Creates a tool bar with flexible space on the left so the done button is positioned to the right-hand side.
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        self.entryDescriptionTextView.inputAccessoryView = toolbar
    }
    
    @objc func keyboardDoneButtonAction() {
        entryDescriptionTextView.resignFirstResponder()
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
