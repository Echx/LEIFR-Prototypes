//
//  MapPoint.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(MapPoint)
class MapPoint: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
	
	func mapPoint() -> MKMapPoint {
		return MKMapPointMake(self.longitude!.doubleValue, self.latitude!.doubleValue)
	}
}
