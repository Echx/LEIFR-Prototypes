//
//  CoreDataManager.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 26/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Mapbox
import CoreData
import MapKit

class CoreDataManager: NSObject {
	static let serialQueue = dispatch_queue_create("CORE_DATA_QUEUE", DISPATCH_QUEUE_SERIAL)
	static let ATNewDataAvailableNotification = "ATNewDataAvailableNotification"
	static var neglectableSpan = {
		() -> [Double] in
		
		var span = [8.0];
		
		for _ in 0..<19 {
			span.append(span.last! / 2)
		}
		
		return span
	}()
	
	class func managedObjectContext() -> NSManagedObjectContext {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	}
    
    class func points(handler:([FlatPoint] -> Void)) {
        let fetchRequest = NSFetchRequest()
        let managedObjectContext = self.managedObjectContext()
        let entity = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        dispatch_async(serialQueue) {
            if let results = try? managedObjectContext.executeFetchRequest(fetchRequest) {
                let points = results.map({
                    point in
                    return point as! FlatPoint
                })
                
                handler(points)
            } else {
                handler([])
            }
        }
    }
	
	class func pointsForMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, andHandler handler:([FlatPoint] -> Void)) {
		let region = MKCoordinateRegionForMapRect(mapRect)
		let minLon = region.center.longitude - region.span.longitudeDelta / 2
		let minLat = region.center.latitude - region.span.latitudeDelta / 2
		let maxLon = region.center.longitude + region.span.longitudeDelta / 2
		let maxLat = region.center.latitude + region.span.latitudeDelta / 2
//		let zoom = zoomScale
        
        let zoom = log2(MKMapSizeWorld.width / 256.0) + log2(Double(zoomScale));

		let deltaLon = maxLon - minLon
		let deltaLat = maxLat - minLat
		
		let boundaryLon = 0.05 * deltaLon
		let boundaryLat = 0.05 * deltaLat
		
		
		let fetchRequest = NSFetchRequest()
		
		let managedObjectContext = self.managedObjectContext()
		
		let entity = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: managedObjectContext)
		fetchRequest.entity = entity
        
//        print("minLon: \(minLon) maxLon: \(maxLon) minLat: \(minLat) maxLat: \(maxLat) zoom: \(zoom) boundaryLon: \(boundaryLon) boundaryLat: \(boundaryLat)")
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoom < %lf", minLon - boundaryLon, maxLon + boundaryLon, minLat - boundaryLat, maxLat + boundaryLat, zoom)
		fetchRequest.predicate = predicate
		
		dispatch_async(serialQueue, {
			if let results = try? managedObjectContext.executeFetchRequest(fetchRequest) {
				let points = results.map({
					point in
					return point as! FlatPoint
				})
				
				handler(points)
				
			} else {
				handler([])
			}
		})
	}
	
	class func pointsForTileAtPath(path: MKTileOverlayPath, andHandler handler:([FlatPoint] -> Void)) {
		let region = FogOverlayRendererTools.regionForTilePath(path)
		let minLon = region.center.longitude - region.span.longitudeDelta / 2
		let minLat = region.center.latitude - region.span.latitudeDelta / 2
		let maxLon = region.center.longitude + region.span.longitudeDelta / 2
		let maxLat = region.center.latitude + region.span.latitudeDelta / 2
		let zoom = path.z
		
		let deltaLon = maxLon - minLon
		let deltaLat = maxLat - minLat
		
		let boundaryLon = 0.05 * deltaLon
		let boundaryLat = 0.05 * deltaLat
		
		
		let fetchRequest = NSFetchRequest()
		
		let managedObjectContext = self.managedObjectContext()
		
		let entity = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: managedObjectContext)
		fetchRequest.entity = entity
		
		let predicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoom < %ld", minLon - boundaryLon, maxLon + boundaryLon, minLat - boundaryLat, maxLat + boundaryLat, zoom)
		fetchRequest.predicate = predicate
		
		dispatch_async(serialQueue, {
			if let results = try? managedObjectContext.executeFetchRequest(fetchRequest) {
				let points = results.map({
					point in
					return point as! FlatPoint
				})
				
				handler(points)
				
			} else {
				handler([])
			}
		})
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
        
        let sort = NSSortDescriptor(key: "timeCreated", ascending: true)
        fetchRequest.sortDescriptors = [sort]
		
		dispatch_async(serialQueue, {
			if let results = try? self.managedObjectContext().executeFetchRequest(fetchRequest) {
				let points = results.map({
					point in
					return point as! FlatPoint
				})
				
				handler(points)
				
			} else {
				handler([])
			}
		})
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
		
		dispatch_async(serialQueue, {
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
		})
	}
	
	class func savePointForCoordinate(coordinate: CLLocationCoordinate2D, andVisibleZoomLevel zoomLevel: Int) {
		let entityDescription = NSEntityDescription.entityForName("FlatPoint", inManagedObjectContext: self.managedObjectContext())!
		let flatPoint = FlatPoint(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext())
		
		flatPoint.latitude = coordinate.latitude
		flatPoint.longitude = coordinate.longitude
		flatPoint.visibleZoom = zoomLevel
        flatPoint.timeCreated = NSDate()
		
		dispatch_async(serialQueue, {
			_ = try? flatPoint.managedObjectContext?.save()
		})
		
		NSNotificationCenter.defaultCenter().postNotificationName(ATNewDataAvailableNotification, object: nil, userInfo: ["coordinate": NSValue(MKCoordinate: coordinate)])
	}
}
