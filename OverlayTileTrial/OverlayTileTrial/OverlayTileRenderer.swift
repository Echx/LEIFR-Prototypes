//
//  OverlayTileRenderer.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class OverlayTileRenderer: NSObject {
	class func mapRectForTilePath(path: MKTileOverlayPath) -> MKMapRect {
		let zoomLevel: Double = Double(path.z)
		
		let spanIndex = pow(2, zoomLevel)
		let xSpan = 360 / spanIndex
		
		let xOrigin = xSpan * Double(path.x) - 180
		
		let n = M_PI - 2 * M_PI * Double(path.y) / spanIndex
		let yOrigin = 180 / M_PI * atan(sinh(n))
		
		let m = M_PI - 2 * M_PI * Double(path.y + 1) / spanIndex
		let nextYOrigin = 180 / M_PI * atan(sinh(m))
		
		return MKMapRectMake(xOrigin, nextYOrigin, xSpan, abs(nextYOrigin - yOrigin))
	}
	
	class func worldCoordinateForMapPoint(mapPoint: MKMapPoint) -> CGPoint {
		let long = mapPoint.x
		let lat = mapPoint.y
		
		var siny = sin(lat * M_PI / 180)
		siny = min(max(siny, -0.9999), 0.9999)
		
		let x = 0.5 + long / 360
		let y = 0.5 - log((1 + siny) / (1 - siny)) / (4 * M_PI)
		
		return CGPointMake(CGFloat(x), CGFloat(y))
	}
	
	class func pixelCooredinateForMapPoint(mapPoint: MKMapPoint, tileSideLength: CGFloat, inTileAtPath tilePath: MKTileOverlayPath) -> CGPoint {
		
		let scale = pow(2, CGFloat(tilePath.z))
		let worldCoordinate = worldCoordinateForMapPoint(mapPoint)
		let x = floor(worldCoordinate.x * scale * tileSideLength) % tileSideLength
		let y = floor(worldCoordinate.y * scale * tileSideLength) % tileSideLength
		
		return CGPointMake(x, y)
	}
	
	class func tileImageForMapPoints(mapPoints: [MKMapPoint], sideLength length: CGFloat, Scale scale: CGFloat, andTilePath path: MKTileOverlayPath) -> UIImage {
		
		let imageSize = CGSizeMake(length, length)
		UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
		
		for point in mapPoints {
			let realPoint = pixelCooredinateForMapPoint(point, tileSideLength: length, inTileAtPath: path)
			let pointCurve = UIBezierPath(arcCenter: realPoint, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
			UIColor.redColor().setFill()
			pointCurve.fill()
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	class func imageDataForTileWithPath(path: MKTileOverlayPath, andPoints mapPoints: [MKMapPoint]) -> NSData? {
		
		if mapPoints.count == 0 {
			return nil
		}
		
		let image = tileImageForMapPoints(mapPoints, sideLength: 128, Scale: UIScreen.mainScreen().scale, andTilePath: path)
		
		return UIImagePNGRepresentation(image)
	}
}
