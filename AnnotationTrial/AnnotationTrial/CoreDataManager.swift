//
//  CoreDataManager.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 26/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Mapbox
import CoreData

class CoreDataManager: NSObject {
	
	static var neglectableSpan = {
		() -> [Double] in
		
		var span = [1.0];
		
		for _ in 0..<19 {
			span.append(span.last! / 2)
		}
		
		return span
	}()
	
	class func managedObjectContext() -> NSManagedObjectContext {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	}
	
	class func pointsForRegionWithVisibleCoordinateBounds(bounds: MGLCoordinateBounds, andZoom zoom: Int, andHandler handler: ([FlatPoint]) -> Void) {
		let minLat = bounds.sw.latitude
		let maxLat = bounds.ne.latitude
		let minLon = bounds.sw.longitude
		let maxLon = bounds.ne.longitude
		
		let fetchRequest = NSFetchRequest()
		
		let entity = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: self.managedObjectContext())
		fetchRequest.entity = entity
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoom < %ld", minLon, maxLon, minLat, maxLat, zoom)
		fetchRequest.predicate = predicate
		
		if let results = try? self.managedObjectContext().executeFetchRequest(fetchRequest) {
			let points = results.map({
				point in
				return point as! FlatPoint
			})
			
			handler(points)
			
		} else {
			handler([])
		}

	}
	
	class func savePointForCoordinate(coordinate: CLLocationCoordinate2D) {
		
		let lat = coordinate.latitude
		let long = coordinate.longitude
		let fetchRequest = NSFetchRequest()
		
		let entity = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: self.managedObjectContext())
		fetchRequest.entity = entity
		
		var compoundPredicate = NSPredicate(value: false)
		for zoom in 0...19 {
			let s = neglectableSpan[zoom]
			let currentPredicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoom == %ld", long - s, long + s, lat - s, lat + s, zoom)
			compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [compoundPredicate, currentPredicate])
		}
		fetchRequest.predicate = compoundPredicate
		
		let sortDescriptor = NSSortDescriptor(key: "visibleZoom", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		if let results = try? self.managedObjectContext().executeFetchRequest(fetchRequest) {
			if let detailMostPoint = results.first {
				let flatPoint = detailMostPoint as! FlatPoint
				let flatPointZoom = flatPoint.visibleZoom!.integerValue
				if  flatPointZoom < 19 {
					self.savePointForCoordinate(coordinate, andVisibleZoomLevel: flatPointZoom + 1)
				}
			} else {
				self.savePointForCoordinate(coordinate, andVisibleZoomLevel: 0)
			}
		}
	}
	
	class func savePointForCoordinate(coordinate: CLLocationCoordinate2D, andVisibleZoomLevel zoomLevel: Int) {
		let entityDescription = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: self.managedObjectContext())!
		let flatPoint = FlatPoint(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext())
		
		flatPoint.latitude = coordinate.latitude
		flatPoint.longitude = coordinate.longitude
		flatPoint.visibleZoom = zoomLevel
		
		_ = try? flatPoint.managedObjectContext?.save()	
	}
}
