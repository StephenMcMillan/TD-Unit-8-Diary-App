//
//  EntryViewModel.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

struct EntryViewModel {
        
    var description: String
    var creationDate: String
    var image: UIImage?
    var mood: Int
    var moodString: String
    var locationName: String
    
    init(entry: Entry) {
        description = entry.entryDescription
        
        // Format the Entry creation date to display in long format.
        creationDate = (entry.creationDate as Date).longStringRepresentation
        
        // Returns the image saved to disk. If no image was added then returns nil.
        if let imageData = entry.image as Data?, let entryImage = UIImage(data: imageData) {
            image = entryImage
        }
        
        mood = Int(entry.mood)
        moodString = "\(entry.mood)/10"
        
        locationName = entry.location?.name ?? "Unknown"
    }
}
