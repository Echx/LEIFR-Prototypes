//
//  TrailOverlayRenderer.swift
//  AnnotationTrial
//
//  Created by Lei Mingyu on 11/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class TrailOverlayRenderer: MKPolylineRenderer {
    override init(overlay: MKOverlay) {
        super.init(overlay: overlay)
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        CGContextAddPath(context, self.path)
        CGContextSetStrokeColorWithColor(context, UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1).CGColor)
        CGContextSetLineWidth(context, 40 / zoomScale)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextStrokePath(context)
        
//        super.drawMapRect(mapRect, zoomScale: zoomScale, inContext: context)
    }
}
 