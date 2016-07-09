//
//  RTPath.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 8/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class RTPath: Object {
	
	dynamic var id = ""
	dynamic var boundNorth = 0.0
	dynamic var boundSouth = 0.0
	dynamic var boundEast = 0.0
	dynamic var boundWest = 0.0
	dynamic var time = NSDate()
	
	let points = List<RTPoint>()
	
	func addPoint(newPoint: RTPoint) {
		self.updateBoundingMapRectForPoint(newPoint)
		self.points.append(newPoint)
	}
	
	private func updateBoundingMapRectForPoint(point: RTPoint) {
		let x = point.mapPoint().x
		let y = point.mapPoint().y
		
		if boundNorth == 0 && boundSouth == 0 && boundEast == 0 && boundWest == 0 {
			boundNorth = y
			boundSouth = y
			boundWest = x
			boundEast = x
		} else {
			boundWest = min(boundWest, x)
			boundEast = max(boundEast, x)
			boundSouth = max(boundSouth, y)
			boundNorth = min(boundNorth, y)
		}
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
