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

}
