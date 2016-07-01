//
//  CoreDataManager.swift
//  OfflineMapTrial
//
//  Created by Jinghan Wang on 1/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import CoreData

class CoreDataManager: NSObject {
	
	static let serialQueue = dispatch_queue_create("CORE_DATA_ACCESS", DISPATCH_QUEUE_SERIAL)
	
	class func managedObjectContext() -> NSManagedObjectContext {
		return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	}
	
	class func saveImageDataForTileAtPath(tilePath: MKTileOverlayPath, andImageData imageData: NSData?) {
		dispatch_async(serialQueue, {
			let context = self.managedObjectContext()
			let tilePathString = StringForTileAtPath(tilePath)
			
			//check existing
			self.fetchOfflineMapTileForTileAtPath(tilePath, completion: {
				tile in
				if tile != nil {
					context.deleteObject(tile!)
				}
			})
			
			//add new
			let entityDescription = NSEntityDescription.entityForName("OfflineMapTile", inManagedObjectContext: self.managedObjectContext())!
			let offlineMapTile = OfflineMapTile(entity: entityDescription, insertIntoManagedObjectContext: context)
			offlineMapTile.path = tilePathString
			offlineMapTile.imageData = imageData
			
			_ = try? context.save()
		})
	}
	
	class func fetchOfflineMapTileForTileAtPath(tilePath: MKTileOverlayPath, completion: (OfflineMapTile?) -> Void) {
		dispatch_async(serialQueue, {
			let context = self.managedObjectContext()
			let tilePathString = StringForTileAtPath(tilePath)
			
			let fetchRequest = NSFetchRequest(entityName: "OfflineMapTile")
			let predicate = NSPredicate(format: "path == %@", tilePathString)
			fetchRequest.predicate = predicate
			if let results = try? context.executeFetchRequest(fetchRequest) {
				if results.count == 1 {
					if let offlineMapTile = results.first as? OfflineMapTile {
						completion(offlineMapTile)
					}
				} else {
					for object in results {
						context.deleteObject(object as! NSManagedObject)
					}
					
					_ = try? context.save()
				}
			}
			
			completion(nil)
		})
	}
}

func StringForTileAtPath(tilePath: MKTileOverlayPath) -> String {
	return "(\(tilePath.x),\(tilePath.y),\(tilePath.z)"
}
