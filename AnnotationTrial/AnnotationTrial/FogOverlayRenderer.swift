//
//  FogOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Lei Mingyu on 7/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class FogOverlayRenderer: MKOverlayRenderer {
    let cache: NSCache = NSCache()
    
//    override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
//        let key = self.cacheKeyForMapRect(mapRect, andZoomScale: zoomScale)
//        if let _ = self.cache.objectForKey(key) {
//            return true
//        } else {
//            CoreDataManager.pointsForMapRect(mapRect, zoomScale: zoomScale, andHandler: {
//                points in
//                
//                self.cache.setObject(points, forKey: key)
//                self.setNeedsDisplayInMapRect(mapRect, zoomScale: zoomScale)
//            })
//            
//            return false
//        }
//    }

    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.8);
        let rect = rectForMapRect(mapRect)
        CGContextFillRect(context, rect)
        CGContextSetBlendMode(context, .Clear)
        
//        let key = self.cacheKeyForMapRect(mapRect, andZoomScale: zoomScale)
//        
//        let points = self.cache.objectForKey(key) as! [FlatPoint]
//        
//        let cgPoints: [CGPoint] = points.map({
//            flatPoint in
//            let coordinate = CLLocationCoordinate2DMake(flatPoint.latitude!.doubleValue, flatPoint.longitude!.doubleValue)
//            let mapPoint = MKMapPointForCoordinate(coordinate)
//            let point = self.pointForMapPoint(mapPoint)
//            return point
//        })
//        let path = CGPathCreateMutable()
//        let radius: CGFloat = rect.size.height * 0.1
//        for point in cgPoints {
//            let pointBoundingRect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2)
//            CGPathAddEllipseInRect(path, nil, pointBoundingRect)
//        }
//        
//        CGContextAddPath(context, path)
//        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
//        CGContextFillPath(context)
        
        
//        self.cache.removeObjectForKey(key)
    }

    
    func cacheKeyForMapRect(rect: MKMapRect, andZoomScale zoomScale: MKZoomScale) -> String {
        return "(\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height),\(zoomScale))"
    }


}
