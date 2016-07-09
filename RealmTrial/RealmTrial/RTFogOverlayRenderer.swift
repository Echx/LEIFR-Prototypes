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
		
		let threshold = 32768.0
		let lineWidth = CGFloat(max(MKMapRectGetWidth(self.mapView.visibleMapRect), threshold)/40)
		CGContextSetLineWidth(context, lineWidth)
		CGContextSetBlendMode(context, .Clear)
		CGContextSetLineCap(context, .Round)
		CGContextSetLineJoin(context, .Round)
		
		let predicate = self.getPredicateFromMapRect(mapRect, edgeTolerance: Double(lineWidth))
		
		let realm = try!Realm()
		let paths = realm.objects(RTPath.self).filter(predicate)
		
		let cgPath = CGPathCreateMutable()
		CGPathMoveToPoint(cgPath, nil, 0, 0)
		for path in paths {
			print(paths.count)
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
	
	private func getPredicateFromMapRect(mapRect: MKMapRect, edgeTolerance: Double) -> NSPredicate {
		
		// N,S,E,W are in map points, of which the origin (0, 0) is at the left top
		// therefore southern point has larger y than northern points
		// and eastern points has larger x than western points
		
		let predicateNorth = NSPredicate(format: "boundSouth < %lf", MKMapRectGetMinY(mapRect) - edgeTolerance)
		let predicateSouth = NSPredicate(format: "boundNorth > %lf", MKMapRectGetMaxY(mapRect) + edgeTolerance)
		let predicateEast = NSPredicate(format: "boundWest > %lf", MKMapRectGetMaxX(mapRect) + edgeTolerance)
		let predicateWest = NSPredicate(format: "boundEast < %lf", MKMapRectGetMinX(mapRect) - edgeTolerance)
		
		
		let compoundOr = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateWest, predicateEast, predicateSouth, predicateNorth])
		return NSCompoundPredicate(notPredicateWithSubpredicate: compoundOr)
	}
}
