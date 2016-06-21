//
//  MapBoxTileOverlay.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class MapBoxTileOverlay: MKTileOverlay {
	override func loadTileAtPath(path: MKTileOverlayPath, result: (NSData?, NSError?) -> Void) {
		super.loadTileAtPath(path, result: result)
	}
	
	override func URLForTilePath(path: MKTileOverlayPath) -> NSURL {
		let url = super.URLForTilePath(path)
		print(path)
		print(url)
		print(" ")
		return url
	}
}
