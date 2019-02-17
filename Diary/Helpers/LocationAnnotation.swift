//
//  LocationAnnotation.swift
//  Diary
//
//  Created by Stephen McMillan on 15/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(location: Location) {
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude.doubleValue, longitude: location.longitude.doubleValue)
        self.title = location.name
        
        super.init()
    }
    
}
