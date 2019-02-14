//
//  ImagePickerManager.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ImagePickerManagerDelegate: class {
    /// Returns the image that the user picked from the image picker.
    func imagePickerManager(_ manager: ImagePickerManager, didSelectImage image: UIImage)
}

class ImagePickerManager: NSObject, UINavigationControllerDelegate {

    let imagePickerController: UIImagePickerController
    
    private let presentingController: UIViewController
    
    weak var delegate: ImagePickerManagerDelegate?
    
    init?(presentingController: UIViewController){
        
        // If we can't access the photo library then there is no reason to create / present an image picker controller.
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return nil
        }
        
        self.presentingController = presentingController
        
        // Setup the picker
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.mediaTypes = [kUTTypeImage as String]
        
        super.init()
        
        self.imagePickerController.delegate = self
    }
    
    func presentImagePicker() {
        presentingController.present(imagePickerController, animated: true, completion: nil)
    }
    
}

extension ImagePickerManager: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        // Hand the image of to the pickerManagerDelegate
        delegate?.imagePickerManager(self, didSelectImage: selectedImage)
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
