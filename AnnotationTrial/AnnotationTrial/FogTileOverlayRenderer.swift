//
//  FogTileOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 29/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class FogTileOverlayRenderer: MKTileOverlayRenderer {
	
	let cache: NSCache = NSCache()
	
	func setNeedsDisplayTileAtPath(tilePath: MKTileOverlayPath) {
		let mapRect = FogOverlayRendererTools.mapRectForTilePath(tilePath)
		self.cache.removeObjectForKey(FogOverlayRendererTools.stringForTilePath(tilePath))
		self.setNeedsDisplayInMapRect(mapRect)
	}
	
	override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		
		let tilePath = self.tilePathForMapRect(mapRect, andZoomScale: zoomScale)
		let tilePathString = FogOverlayRendererTools.stringForTilePath(tilePath)
		if let _ = self.cache.objectForKey(tilePathString) {
			return true
		} else {
			CoreDataManager.pointsForTileAtPath(tilePath, andHandler: {
				points in
				let coordinates: [NSValue] = points.map({
					flatPoint in
					let coordinate = CLLocationCoordinate2DMake(flatPoint.latitude!.doubleValue, flatPoint.longitude!.doubleValue)
					return NSValue(MKCoordinate: coordinate)
				})
				
				self.cache.setObject(coordinates, forKey: tilePathString)
				self.setNeedsDisplayInMapRect(mapRect, zoomScale: zoomScale)
			})
			
			return false
		}
	}
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
//		CGContextSetRGBFillColor(context, 0, 0, 0, 0.5);
		let rect = rectForMapRect(mapRect)
//		CGContextFillRect(context, rect)
//		CGContextSetBlendMode(context, .Clear)
		
		let tilePath = self.tilePathForMapRect(mapRect, andZoomScale: zoomScale)
		let tilePathString = FogOverlayRendererTools.stringForTilePath(tilePath)
		
		if let points = self.cache.objectForKey(tilePathString) as? [NSValue] {
			let points: [CGPoint] = points.map({
				value in
				
				let coordinate = value.MKCoordinateValue
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let point = pointForMapPoint(mapPoint)
				
				return point
			})
			
			for point in points {
				let radius: CGFloat = rect.size.height * 0.04
				let pointBoundingRect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2)
				CGContextSetRGBFillColor(context, 0, 0, 0, 0.2);
				CGContextFillEllipseInRect(context, pointBoundingRect)
			}
		} else {
			super.setNeedsDisplayInMapRect(mapRect, zoomScale: zoomScale)
		}
		
		self.cache.removeObjectForKey(tilePathString)
	}

	
	func tilePathForMapRect(mapRect: MKMapRect, andZoomScale zoomScale: MKZoomScale) -> MKTileOverlayPath {
		let tileOverlay = self.overlay as! MKTileOverlay
		let factor = tileOverlay.tileSize.width / 256
		let x = Int(round(CGFloat(mapRect.origin.x) * zoomScale / (tileOverlay.tileSize.width / factor)));
		let y = Int(round(CGFloat(mapRect.origin.y) * zoomScale / (tileOverlay.tileSize.width / factor)));
		let z = Int(log2(zoomScale) + 20)
		
		return MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: UIScreen.mainScreen().scale)
	}
}
