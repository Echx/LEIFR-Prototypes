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
	private func mapRectForTilePath(path: MKTileOverlayPath) -> MKMapRect {
		let zoomLevel: Double = Double(path.z)
		
		let spanIndex = pow(2, zoomLevel)
		let xSpan = 360 / spanIndex
		let ySpan = 170.1022 / spanIndex
		
		let xOrigin = xSpan * Double(path.x)
		let yOrigin = ySpan * Double(path.y)
		
		return MKMapRectMake(xOrigin, yOrigin, xSpan, ySpan)
	}
	
	private func normalizedPointForMapPoint(point: MKMapPoint, inMapRect mapRect: MKMapRect) -> CGPoint {
		let x = (point.x - mapRect.origin.x) / mapRect.size.width
		let y = point.y - mapRect.origin.y / mapRect.size.height
		
		return CGPointMake(CGFloat(x), CGFloat(y));
	}
	
	func tileImageWithNormalizedPoints(points: [CGPoint], sideLength length: CGFloat, andScale scale: CGFloat) -> UIImage {
		
		let imageSize = CGSizeMake(length, length)
		UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
		
		for point in points {
			let realPoint = CGPointMake(length * point.x, length * point.y)
			let pointCurve = UIBezierPath(arcCenter: realPoint, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
			UIColor.redColor().setFill()
			pointCurve.fill()
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	func imageDataForTileWithPath(path: MKTileOverlayPath, andPoints mapPoints: [MKMapPoint]) -> NSData? {
		
		let mapRect = mapRectForTilePath(path)
		let normalizedPoints = mapPoints.map({
			point in
			return normalizedPointForMapPoint(point, inMapRect: mapRect)
		})
		
		let image = tileImageWithNormalizedPoints(normalizedPoints, sideLength: 128, andScale: UIScreen.mainScreen().scale)
		
		return UIImagePNGRepresentation(image)
	}
}
