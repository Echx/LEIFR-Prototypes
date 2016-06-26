//
//  CoreDataManager.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class CoreDataManager: NSObject {
	
	class func managedObjectContext() -> NSManagedObjectContext {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	}
	
	class func mapPointForRegion(region: MKCoordinateRegion, handler: ([MKMapPoint]) -> Void) {
		let minLong = region.center.longitude - region.span.longitudeDelta / 2
		let minLat = region.center.latitude - region.span.latitudeDelta / 2
		let maxLong = region.center.longitude + region.span.longitudeDelta / 2
		let maxLat = region.center.latitude + region.span.latitudeDelta / 2
		
		let fetchRequest = NSFetchRequest()
		
		let entity = NSEntityDescription.entityForName("MapPoint", inManagedObjectContext: self.managedObjectContext())
		fetchRequest.entity = entity
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf", minLong, maxLong, minLat, maxLat)
		fetchRequest.predicate = predicate
		
		if let results = try? self.managedObjectContext().executeFetchRequest(fetchRequest) {
			let points = results.map({
				point in
				return (point as! MapPoint).mapPoint()
			})
			
			handler(points)
			
		} else {
			handler([])
		}
	}
	
	class func mapPointsForMapRect(mapRect: MKMapRect, handler: ([MKMapPoint]) -> Void) {
		let fetchRequest = NSFetchRequest()
		
		let entity = NSEntityDescription.entityForName("MapPoint", inManagedObjectContext: self.managedObjectContext())
		fetchRequest.entity = entity
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf", MKMapRectGetMinX(mapRect), MKMapRectGetMaxX(mapRect), MKMapRectGetMinY(mapRect), MKMapRectGetMaxY(mapRect))
		fetchRequest.predicate = predicate
		
		if let results = try? self.managedObjectContext().executeFetchRequest(fetchRequest) {
			let points = results.map({
				point in
				return (point as! MapPoint).mapPoint()
			})
			
			handler(points)
			
		} else {
			handler([])
		}
	}
	
	class func savePoint(point: MKMapPoint, withZoomLevel zoomLevel: Int) {
		let entityDescription = NSEntityDescription.entityForName("MapPoint", inManagedObjectContext: self.managedObjectContext())!
		let mapPoint = MapPoint(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext())
		
		mapPoint.longitude = NSNumber(double: point.x)
		mapPoint.latitude = NSNumber(double: point.y)
		mapPoint.zoom = NSNumber(integer: zoomLevel)
		
		_ = try? mapPoint.managedObjectContext?.save()
	}
	
}