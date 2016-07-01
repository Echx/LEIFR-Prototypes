//
//  FogOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 27/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class FogOverlayRendererTools {
	
	class func regionForTilePath(path: MKTileOverlayPath) -> MKCoordinateRegion {
		return MKCoordinateRegionForMapRect(self.mapRectForTilePath(path))
	}
	
	class func stringForTilePath(path: MKTileOverlayPath) -> String {
		return "(\(path.x), \(path.y), \(path.z))"
	}
	
	class func mapRectForTilePath(path: MKTileOverlayPath) -> MKMapRect {
		let sideLength = 1 << (28 - path.z)
		let mapRect = MKMapRectMake(Double(sideLength * path.x), Double(sideLength * path.y), Double(sideLength), Double(sideLength))
		return mapRect
	}
	
	class func pixelCooredinateForLocationCoordinate(coordinate: CLLocationCoordinate2D, tileSideLength: CGFloat, inTileAtPath path: MKTileOverlayPath) -> CGPoint {
		let mapPoint = MKMapPointForCoordinate(coordinate)
		let mapRect = self.mapRectForTilePath(path)
		let x = CGFloat((mapPoint.x - mapRect.origin.x) / mapRect.size.width) * tileSideLength
		let y = CGFloat((mapPoint.y - mapRect.origin.y) / mapRect.size.height) * tileSideLength
		
		return CGPointMake(x, y)
	}
	
	class func tileImageForLocationCoordinates(coordinates: [CLLocationCoordinate2D], sideLength length: CGFloat, Scale scale: CGFloat, andTilePath path: MKTileOverlayPath) -> UIImage {
		
		let imageSize = CGSizeMake(length, length)
		UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
		CGContextSetBlendMode(UIGraphicsGetCurrentContext(), .Clear)
		
		UIColor(white: 0, alpha: 0.5).set()
		UIRectFill(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height));
		
		for point in coordinates {
			let realPoint = pixelCooredinateForLocationCoordinate(point, tileSideLength: length, inTileAtPath: path)
			let pointCurve = UIBezierPath(arcCenter: realPoint, radius: 5, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
			UIColor(white: 1, alpha: 1).setFill()
			pointCurve.fill()
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		UIGraphicsBeginImageContext(imageSize)
		CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
		let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return flippedImage
	}
	
	class func imageDataForTileWithPath(path: MKTileOverlayPath, andLocationCoordinates coordinates: [CLLocationCoordinate2D]) -> NSData? {
	
		
		let image = tileImageForLocationCoordinates(coordinates, sideLength: 128, Scale: UIScreen.mainScreen().scale, andTilePath: path)
		
		return UIImagePNGRepresentation(image)
	}
}
