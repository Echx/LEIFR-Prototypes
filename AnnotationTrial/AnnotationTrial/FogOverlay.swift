//
//  FogOverlay.swift
//  AnnotationTrial
//
//  Created by Lei Mingyu on 7/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class FogOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    override init() {
        let topLeft = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: 90, longitude: -180))
        let bottomRight = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: -90, longitude: 180))
        self.boundingMapRect = MKMapRectMake(topLeft.x, topLeft.y, fabs(topLeft.x - bottomRight.x), fabs(topLeft.y - bottomRight.y));
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}
