//
//  FogTileOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 29/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class FogTileOverlayRenderer: MKTileOverlayRenderer {
	
	var context: CGContext?
	var map: MKMapView?
	let cache: NSCache = NSCache()
	
	func setNeedsDisplayTileAtPath(tilePath: MKTileOverlayPath) {
		let mapRect = FogOverlayRendererTools.mapRectForTilePath(tilePath)
		self.cache.removeObjectForKey(FogOverlayRendererTools.stringForTilePath(tilePath))
		self.setNeedsDisplayInMapRect(mapRect)
	}
	
	override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		
		let tilePath = self.tilePathForMapRect(mapRect, andZoomScale: zoomScale)
		let key = self.cacheKeyForMapRect(mapRect, andZoomScale: zoomScale)
		if let _ = self.cache.objectForKey(key) {
			return true
		} else {
			CoreDataManager.pointsForTileAtPath(tilePath, andHandler: {
				points in
				let cgPoints: [CGPoint] = points.map({
					flatPoint in
					let coordinate = CLLocationCoordinate2DMake(flatPoint.latitude!.doubleValue, flatPoint.longitude!.doubleValue)
					let mapPoint = MKMapPointForCoordinate(coordinate)
					let point = self.pointForMapPoint(mapPoint)
					return point
				})
				
				let path = CGPathCreateMutable()
				let rect = self.rectForMapRect(mapRect)
				let radius: CGFloat = rect.size.height * 0.08
				for point in cgPoints {
					let pointBoundingRect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2)
					CGPathAddEllipseInRect(path, nil, pointBoundingRect)
				}
				
				self.cache.setObject(path, forKey: key)
				self.setNeedsDisplayInMapRect(mapRect, zoomScale: zoomScale)
			})
			
			return false
		}
	}
	
	override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
		CGContextSetRGBFillColor(context, 0, 0, 0, 0.5);
		let rect = rectForMapRect(mapRect)
		CGContextFillRect(context, rect)
		CGContextSetBlendMode(context, .Clear)
		
		let key = self.cacheKeyForMapRect(mapRect, andZoomScale: zoomScale)
		
		let path = self.cache.objectForKey(key) as! CGPath
		CGContextAddPath(context, path)
		CGContextSetRGBFillColor(context, 1, 1, 1, 1);
		CGContextFillPath(context)
		
		self.cache.removeObjectForKey(key)
	}

	
	func tilePathForMapRect(mapRect: MKMapRect, andZoomScale zoomScale: MKZoomScale) -> MKTileOverlayPath {
		let tileOverlay = self.overlay as! MKTileOverlay
		let factor = tileOverlay.tileSize.width / 256
		let x = Int(round(CGFloat(mapRect.origin.x) * zoomScale / (tileOverlay.tileSize.width / factor)));
		let y = Int(round(CGFloat(mapRect.origin.y) * zoomScale / (tileOverlay.tileSize.width / factor)));
		let z = Int(log2(zoomScale) + 20)
		
		return MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: UIScreen.mainScreen().scale)
	}
	
	func cacheKeyForMapRect(rect: MKMapRect, andZoomScale zoomScale: MKZoomScale) -> String {
		return "(\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height),\(zoomScale))"
	}
}
