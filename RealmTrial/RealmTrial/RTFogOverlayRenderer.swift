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
	
	var mapView: MKMapView!
	
	override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		
//		let region = MKCoordinateRegionForMapRect(mapRect)
		
		return true
	}
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
		
		let rect = rectForMapRect(mapRect)
		CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
		CGContextFillRect(context, rect)
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
		
		let threshold = 8192.0
		let lineWidth = CGFloat(max(MKMapRectGetWidth(self.mapView.visibleMapRect), threshold)/40)
		CGContextSetLineWidth(context, lineWidth)
		CGContextSetBlendMode(context, .Clear)
		CGContextSetLineCap(context, .Round)
		
		let realm = try!Realm()
		let paths = realm.objects(RTPath.self)
		
		let cgPath = CGPathCreateMutable()
		CGPathMoveToPoint(cgPath, nil, 0, 0)
		for path in paths {
			let pointsCount = path.points.count
			let firstValidIndex = 0
			if pointsCount > firstValidIndex {
				for i in firstValidIndex ..<  pointsCount {
					let point = path.points[i]
					let coordinate = point.coordinate()
					let mapPoint = MKMapPointForCoordinate(coordinate)
					let cgPoint = pointForMapPoint(mapPoint)
					
					if i == firstValidIndex {
						CGPathMoveToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
					} else if i < pointsCount {
						CGPathAddLineToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
					}
				}
			}
		}
		
		CGContextAddPath(context, cgPath)
		CGContextStrokePath(context)
	}
}
