//
//  RFTFogOverlay.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class RFTFogOverlay: NSObject, MKOverlay {
	@objc var coordinate = CLLocationCoordinate2DMake(0, 0)
	@objc var boundingMapRect = MKMapRectWorld
}
