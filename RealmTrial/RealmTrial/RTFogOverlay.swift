//
//  RTFogOverlay.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 8/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class RTFogOverlay: NSObject, MKOverlay {
	@objc var coordinate = CLLocationCoordinate2DMake(0, 0)
	@objc var boundingMapRect = MKMapRectWorld
}
