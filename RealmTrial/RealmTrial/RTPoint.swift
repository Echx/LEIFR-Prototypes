//
//  RTPoint.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 8/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class RTPoint: Object {
	var path = LinkingObjects(fromType: RTPath.self, property: "points")
	dynamic var sequence = 0
	dynamic var longitude = 0.0
	dynamic var latitude = 0.0
	dynamic var time = NSDate()
	private var tempMapPoint: MKMapPoint?
	
	override static func ignoredProperties() -> [String] {
		return [""]
	}
	
	func coordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2DMake(self.latitude, self.longitude)
	}
	
	func mapPoint() -> MKMapPoint {
		if self.tempMapPoint == nil {
			self.tempMapPoint = MKMapPointForCoordinate(self.coordinate())
		}
		
		return self.tempMapPoint!
	}
	
	func orthogonalDistanceFromLineSegmentWithEnds(startPoint: RTPoint, endPoint: RTPoint) -> Double {
		let p1 = self.mapPoint()
		let p2 = startPoint.mapPoint()
		let p3 = endPoint.mapPoint()
		
		// Goal: find the distance from p1 to line segment p2p3
		
		// Step 1: find area of triangle p1p2p3
		let area = abs(0.5 * (p1.x * p2.y + p2.x * p3.y + p3.x * p1.y - p1.x * p3.y - p2.x * p1.y - p3.x * p2.y))
		
		// Step 2: find the length of bottom p2p3
		let bottom = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
		
		// Step 3: find the height
		let height = area / bottom * 2.0
		
		return height
	} 
}
