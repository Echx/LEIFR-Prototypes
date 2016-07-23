//
//  RFTFogOverlayRenderer.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import RealmSwift

class RFTFogOverlayRenderer: MKOverlayRenderer {
	var mapView: MKMapView!
	
	private let maxTimeIntervalBetweenConsecutivePoints = 0.2 //in seconds
	private let maxDistanceBetweenConsecutivePoints = 1.0 //in meters
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
		
		let startTime = NSDate()
		
		let region = MKCoordinateRegionForMapRect(mapRect)
		let minLon = region.center.longitude - region.span.longitudeDelta / 2
		let minLat = region.center.latitude - region.span.latitudeDelta / 2
		let maxLon = region.center.longitude + region.span.longitudeDelta / 2
		let maxLat = region.center.latitude + region.span.latitudeDelta / 2
		let zoom = Int(log2(zoomScale) + 20)
		
		let factor = max(Double(1 << (21 - zoom)), 1)
		let maxDistance = maxDistanceBetweenConsecutivePoints * factor
		let maxTime = maxTimeIntervalBetweenConsecutivePoints * factor
		
		let deltaLon = maxLon - minLon
		let deltaLat = maxLat - minLat
		
		let boundaryLon = max(0.5 * deltaLon, 0.005)
		let boundaryLat = max(0.5 * deltaLat, 0.005)
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoomLevel < %ld", minLon - boundaryLon, maxLon + boundaryLon, minLat - boundaryLat, maxLat + boundaryLat, zoom)
		
		let realm = try!Realm()
		let points = realm.objects(RFTPoint.self).filter(predicate).sorted("time")

		
		let cgPath = CGPathCreateMutable()
		var lastPoint: RFTPoint!
		
		for point in points {
			let coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
			let mapPoint = MKMapPointForCoordinate(coordinate)
			let cgPoint = self.pointForMapPoint(mapPoint)
			
			if lastPoint == nil {
				CGPathMoveToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
			} else {
				let lastLocation = CLLocation(latitude: lastPoint.latitude, longitude: lastPoint.longitude)
				let currentLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
				if point.time.timeIntervalSince1970 - lastPoint.time.timeIntervalSince1970 < maxTime && lastLocation.distanceFromLocation(currentLocation) < maxDistance
					{
					CGPathAddLineToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
				} else {
					CGPathMoveToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
				}
			}
			lastPoint = point
		}
		
		let rect = rectForMapRect(mapRect)
		CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
		CGContextFillRect(context, rect)
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
		
		let threshold = 8192.0
		let lineWidth = CGFloat(max(MKMapRectGetWidth(self.mapView.visibleMapRect), threshold)/40)
		CGContextSetLineWidth(context, lineWidth)
		CGContextSetBlendMode(context, .Clear)
		CGContextSetLineCap(context, .Round)
		CGContextSetLineJoin(context, .Round)
		
		
		CGContextAddPath(context, cgPath)
		CGContextSetLineWidth(context, lineWidth)
//		CGContextSetShadowWithColor(context, CGSizeZero, lineWidth, UIColor.whiteColor().CGColor)
		CGContextStrokePath(context)
		
		let endTime = NSDate()
		print("Zoom: \(zoom), Time: \(endTime.timeIntervalSinceDate(startTime) * 1000)ms")
	}
}
