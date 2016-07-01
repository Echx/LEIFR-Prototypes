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
		let urlString = "https://api.mapbox.com/v4/mapbox.light/\(path.z)/\(path.x)/\(path.y)@2x.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
		let url = NSURL(string: urlString)!
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		
		CoreDataManager.fetchOfflineMapTileForTileAtPath(path, completion: {
			offlineResult in
			if let tile = offlineResult {
				result(tile.imageData, nil)
			} else {
				
				let task = session.dataTaskWithURL(url, completionHandler: {
					data, response, error in
					CoreDataManager.saveImageDataForTileAtPath(path, andImageData: data)
					result(data, error)
				})
				
				task.resume()
			}
			
		})
	}
}
