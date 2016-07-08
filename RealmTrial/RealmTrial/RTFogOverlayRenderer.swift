//
//  RTFogOverlayRenderer.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 8/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import RealmSwift

class RTFogOverlayRenderer: MKOverlayRenderer {
	
	override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		
//		let region = MKCoordinateRegionForMapRect(mapRect)
		
		return true
	}
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
		let realm = try!Realm()
		let paths = realm.objects(RTPath.self)
		
		let cgPath = CGPathCreateMutable()
		for path in paths {
			if let firstPoint = path.points.first {
				let coordinate = firstPoint.coordinate()
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let cgPoint = pointForMapPoint(mapPoint)
				CGPathMoveToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
			}
			
			print(path.points.count)
			
			for point in path.points {
				let coordinate = point.coordinate()
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let cgPoint = pointForMapPoint(mapPoint)
				CGPathAddLineToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
			}
		}
		
		let rect = rectForMapRect(mapRect)
		CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
		CGContextFillRect(context, rect)
		
		CGContextSetBlendMode(context, .Clear)
		CGContextSetLineCap(context, .Round)
		CGContextSetLineWidth(context, 1024)
		CGContextAddPath(context, cgPath)
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
		CGContextStrokePath(context)
	}
}
