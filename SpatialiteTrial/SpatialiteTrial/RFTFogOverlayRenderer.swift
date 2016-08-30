//
//  RFTFogOverlayRenderer.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class RFTFogOverlayRenderer: MKOverlayRenderer {
	var mapView: MKMapView!
	
	private let maxTimeIntervalBetweenConsecutivePoints: Double = 0.2 //in seconds
	private let maxDistanceBetweenConsecutivePoints: Double = 1.0 //in meters
	private let cache: NSCache = NSCache()
	
	override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		let key: String = "\(mapRect.origin.x) \(mapRect.origin.y) \(mapRect.size.width) \(mapRect.size.height) | \(zoomScale)"
		if cache.objectForKey(key) != nil {
			return true
		}
		
		let region = MKCoordinateRegionForMapRect(mapRect)
		STDatabaseManager.sharedManager().getPathsInRegion(region, completion: {
			paths in
			let cgPath = CGPathCreateMutable()
			
			var lastPoint: WKBPoint!
			
			for path in paths {
				lastPoint = nil
				for geoPoint in path.points() {
					let point = geoPoint as! WKBPoint
					let coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
					let mapPoint = MKMapPointForCoordinate(coordinate)
					let cgPoint = self.pointForMapPoint(mapPoint)
					
					if lastPoint == nil {
						CGPathMoveToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
					} else {
						CGPathAddLineToPoint(cgPath, nil, cgPoint.x, cgPoint.y)
					}
					lastPoint = point
				}
			}
			
			self.cache.setObject(cgPath, forKey: key)
			
			self.setNeedsDisplayInMapRect(mapRect, zoomScale: zoomScale)
		})
		
		return false
	}
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
		
		let key: String = "\(mapRect.origin.x) \(mapRect.origin.y) \(mapRect.size.width) \(mapRect.size.height) | \(zoomScale)"
		
		let cgPath = self.cache.objectForKey(key)! as! CGPath
		
		self.cache.removeObjectForKey(key)
		
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
	}
}
