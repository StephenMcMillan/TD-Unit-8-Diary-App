//
//  Location+CoreDataProperties.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

public class Location: NSManagedObject {
    
}

extension Location {
    
    static var entityName: String {
        return String(describing: Location.self)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var name: String
    @NSManaged public var longitude: NSNumber
    @NSManaged public var latitude: NSNumber
    
    static func newLocation(withName name: String?, coordinate: CLLocationCoordinate2D, inContext context: NSManagedObjectContext) -> Location {
        let location = Location(context: context)
        location.name = name ?? "Unknown"
        location.longitude = NSNumber(value: coordinate.longitude)
        location.latitude = NSNumber(value: coordinate.latitude)
        return location
    }
}
