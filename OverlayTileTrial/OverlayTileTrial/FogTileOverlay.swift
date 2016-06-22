//
//  FogTileOverlay.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class FogTileOverlay: MKTileOverlay {
	override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
		CoreDataManager.mapPointsForTileAtPath(path, handler: {
			points in
			let data = OverlayTileRenderer.imageDataForTileWithPath(path, andPoints: points)
			
			if data != nil {
				let image = UIImage(data: data!)
			}
			
			result(data, nil)
		})
	}
	
	override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
		let url = super.URLForTilePath(path)
		return url
	}
}
