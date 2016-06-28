//
//  FogTileOverlay.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 27/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class FogTileOverlay: MKTileOverlay {
	
	override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
		
		let serialQueue = dispatch_queue_create("CORE_DATA_QUEUE", DISPATCH_QUEUE_SERIAL)
		dispatch_async(serialQueue, {
			CoreDataManager.pointsForTileAtPath(path, andHandler: {
				points in
				let coordinates = points.map({
					flatPoint in
					return CLLocationCoordinate2DMake(flatPoint.latitude!.doubleValue, flatPoint.longitude!.doubleValue)
				})
				
				let data = FogOverlayRenderer.imageDataForTileWithPath(path, andLocationCoordinates: coordinates)
				result(data, nil)
			})
		})
	}
	
	override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
		let url = super.URLForTilePath(path)
		return url
	}
}
