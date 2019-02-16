//
//  Entry+CoreDataProperties.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//

import UIKit
import CoreData
import MapKit

// Model of a Diary Entry
public class Entry: NSManagedObject {}

extension Entry {

    static var entityName: String {
        return String(describing: Entry.self)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var entryDescription: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var image: NSData?
    @NSManaged public var mood: Int32
    @NSManaged public var location: Location?
    
    // Need to expose creationMonth to objc runtime 
    @objc var creationMonth: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let result = dateFormatter.string(from: creationDate as Date)
            return result
        }
    }
    
    static func new(withDescription description: String, mood: Int, image: UIImage?, mapItem: MKMapItem?, inContext context: NSManagedObjectContext) {
        
        let newEntry = Entry(context: context)
        
        newEntry.entryDescription = description
        newEntry.mood = Int32(mood)
        
        // Get todays date.
        newEntry.creationDate = Date() as NSDate
        
        // Convert the data to its data representation so it can be stored by Core Data
        if let imageData = image?.jpegData(compressionQuality: 0.5) as NSData? {
            newEntry.image = imageData
        }
        
        // Create a location object using the MapItem that the user selected earlier
        if let mapItem = mapItem, let locationName = mapItem.name {
                    
            if let location = NSEntityDescription.insertNewObject(forEntityName: Location.entityName, into: context) as? Location {
                location.name = locationName
                location.longitude = mapItem.placemark.coordinate.longitude as NSNumber
                location.latitude = mapItem.placemark.coordinate.latitude as NSNumber
                
                newEntry.location = location
            }
        }
    }
}
