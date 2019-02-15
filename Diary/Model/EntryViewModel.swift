//
//  EntryViewModel.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

struct EntryViewModel {
    
    // The entry model that the view-model is displaying
    let entry: Entry
    
    init(entry: Entry) {
        self.entry = entry
    }
    
    // The main things that need formatted are the mood, images and date.
    var description: String {
        return entry.entryDescription
    }
    
    // Format the Entry creation date to display in long format.
    var creationDate: String {
        
        let dateFormatter = DateFormatter()
        // eg. Friday 15 February
        dateFormatter.dateFormat = "EEEE dd MMMM"
        
        return dateFormatter.string(for: entry.creationDate) ?? "Date Unknown"
    }
    
    // Creates a small image from the iamge data and returns a placeholder if one wasnt found.
    var thumbnailImage: UIImage? {
        // TODO: Scale this or something.
        
        guard let image = self.image else {
            return nil
        }
        
        return image
    }
    
    // Returns the image saved to disk. If no image was added then returns nil.
    var image: UIImage? {
        
        guard let imageData = entry.image as Data?, let entryImage = UIImage(data: imageData) else {
            return nil
        }
        
        return entryImage
    }
    
    var mood: String {
        return "Fix this. what am i doing with the mood."
    }
    
    var locationName: String {
        guard let location = entry.location else {
            return "Unknown"
        }
        
        return location.name
    }
}
