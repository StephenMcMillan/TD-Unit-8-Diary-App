//
//  LocationAnnotation.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    let location: Location
    
    init(location: Location) {
        self.location = location
        
        super.init()
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude.doubleValue, longitude: location.longitude.doubleValue)
    }
    
    var title: String? {
        return location.name
    }
    
}
