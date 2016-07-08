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
	dynamic var boundingMapRectString = ""
	dynamic var time = NSDate()
	
	let points = List<RTPoint>()
	
	func addPoint(newPoint: RTPoint) {
		self.updateBoundingMapRectForPoint(newPoint)
		self.points.append(newPoint)
	}
	
	private func updateBoundingMapRectForPoint(point: RTPoint) {
		let x = point.mapPoint().x
		let y = point.mapPoint().y
		let boundingMapRect = self.boundingMapRect()
		
		if MKMapRectIsNull(self.boundingMapRect()) {
			self.setBoundingMapRect(MKMapRectMake(x, y, 0, 0))
		} else {
			let minX = min(MKMapRectGetMinX(boundingMapRect), x)
			let maxX = max(MKMapRectGetMaxX(boundingMapRect), x)
			let minY = min(MKMapRectGetMinY(boundingMapRect), y)
			let maxY = max(MKMapRectGetMaxY(boundingMapRect), y)
			
			self.setBoundingMapRect(MKMapRectMake(minX, minY, maxX - x, maxY - minY))
		}
	}
	
	func boundingMapRect() -> MKMapRect {
		let string = self.boundingMapRectString
		
		let elements = string.componentsSeparatedByString(";")
		if elements.count == 4 {
			let x = Double(elements[0])!
			let y = Double(elements[1])!
			let width = Double(elements[2])!
			let height = Double(elements[3])!
			return MKMapRectMake(x, y, width, height)
		} else {
			return MKMapRectNull
		}
	}
	
	func setBoundingMapRect(rect: MKMapRect) {
		self.boundingMapRectString = "\(rect.origin.x);\(rect.origin.y);\(rect.size.width);\(rect.size.height)"
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
