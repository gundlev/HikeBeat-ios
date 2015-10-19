//
//  BeatPin.swift
//  MapkitTest
//
//  Created by Niklas Gundlev on 09/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import MapKit

class BeatPin: NSObject, MKAnnotation, Comparable {
    
    var title: String?
    var timestamp: String
    var subtitle: String?
    let locationName: String
    let discipline: String
    var coordinate: CLLocationCoordinate2D
    var lastPin: Bool
    var image: UIImage?
    
    init(title: String, timestamp: String, subtitle: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, lastPin: Bool, image: UIImage?) {
        self.title = title
        self.timestamp = timestamp
        self.subtitle = subtitle
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.lastPin = lastPin
        self.image = image
        
        super.init()
    }

    
}

func <(lhs: BeatPin, rhs: BeatPin) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

func ==(lhs: BeatPin, rhs: BeatPin) -> Bool {
    return lhs.timestamp == rhs.timestamp
}
