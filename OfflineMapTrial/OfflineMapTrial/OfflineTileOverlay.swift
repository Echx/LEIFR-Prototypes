//
//  OfflineTileOverlay.swift
//  OfflineMapTrial
//
//  Created by Jinghan Wang on 1/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class OfflineTileOverlay: MKTileOverlay {
	override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
		CoreDataManager.fetchOfflineMapTileForTileAtPath(path, completion: {
			offlineResult in
			if let tile = offlineResult {
				result(tile.imageData, nil)
			} else {
				let urlString = "https://api.mapbox.com/v4/mapbox.light/\(path.z)/\(path.x)/\(path.y)@2x.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
				let url = NSURL(string: urlString)!
				let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
				
				let task = session.dataTaskWithURL(url, completionHandler: {
					data, response, error in
					CoreDataManager.saveImageDataForTileAtPath(path, andImageData: data)
					result(data, error)
				})
				
				task.resume()
			}
			
		})
	}
	
	
	class func downloadOfflineTilesForMapRect(mapRect: MKMapRect) {
		
	}
	
	class func downloadRoughWorldMap(level: Int, progressUpdateHandler handler:(current: Int, all: Int) -> Void) {
		
		let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
		let queue = dispatch_queue_create("OFFLINE_MAP", DISPATCH_QUEUE_SERIAL)
		dispatch_async(queue, {
			let all = Int(pow(4.0, Double(level) + 1))
			
			print(all)
			var count = 0;
			
			for z in 0...level {
				let max = 2 << z
				for x in 0..<max {
					for y in 0..<max {
						print("\(x), \(y), \(z)")
						
						let urlString = "https://api.mapbox.com/v4/mapbox.light/\(z)/\(x)/\(y)@2x.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
						let url = NSURL(string: urlString)!
						let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
						
						let task = session.dataTaskWithURL(url, completionHandler: {
							data, response, error in
							dispatch_sync(lockQueue) {
								let path = MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: 2)
								CoreDataManager.saveImageDataForTileAtPath(path, andImageData: data)
								count = count + 1
								print("count: \(count)")
								handler(current: count, all: all)
							}
						})
						
						task.resume()
					}
				}
			}
		})
	}
}
