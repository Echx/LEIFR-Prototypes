//
//  FogOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 27/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class FogOverlayRenderer {
	
	class func regionForTilePath(path: MKTileOverlayPath) -> MKCoordinateRegion {
		let sideLength = 1 << (28 - path.z)
		let mapRect = MKMapRectMake(Double(sideLength * path.x), Double(sideLength * path.y), Double(sideLength), Double(sideLength))
		return MKCoordinateRegionForMapRect(mapRect)
	}
	
	class func pixelCooredinateForLocationCoordinate(coordinate: CLLocationCoordinate2D, tileSideLength: CGFloat, inTileAtPath path: MKTileOverlayPath) -> CGPoint {
		
		let mapPoint = MKMapPointForCoordinate(coordinate)
		
		let tileSideLengthUnit = 1 << (28 - path.z)
		let x = CGFloat(Int(mapPoint.x) % tileSideLengthUnit) / CGFloat(tileSideLengthUnit) * tileSideLength
		let y = CGFloat(Int(mapPoint.y) % tileSideLengthUnit) / CGFloat(tileSideLengthUnit) * tileSideLength
		
		return CGPointMake(x, y)
	}
	
	class func tileImageForLocationCoordinates(coordinates: [CLLocationCoordinate2D], sideLength length: CGFloat, Scale scale: CGFloat, andTilePath path: MKTileOverlayPath) -> UIImage {
		
		let imageSize = CGSizeMake(length, length)
		UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetBlendMode(context, .Clear)
		
		UIColor(white: 0, alpha: 0.2).set()
		UIRectFill(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height));
		
		for point in coordinates {
			let realPoint = pixelCooredinateForLocationCoordinate(point, tileSideLength: length, inTileAtPath: path)
			let pointCurve = UIBezierPath(arcCenter: realPoint, radius: 5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
			UIColor.whiteColor().setFill()
			pointCurve.fill()
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	class func imageDataForTileWithPath(path: MKTileOverlayPath, andLocationCoordinates coordinates: [CLLocationCoordinate2D]) -> NSData? {
	
		
		let image = tileImageForLocationCoordinates(coordinates, sideLength: 128, Scale: UIScreen.mainScreen().scale, andTilePath: path)
		
		return UIImagePNGRepresentation(image)
	}
}
