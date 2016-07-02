//
//  ViewController.swift
//  AnimationTrial
//
//  Created by Lei Mingyu on 2/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {
    var mapView: MGLMapView!
    var locationManager: CLLocationManager!
    var isMapAdded = false
    var isCameraSet = false
    var initialLocation: CLLocationCoordinate2D!
    var isReplayMode = false

    var points = [["latitude": 1.0, "longitude": 20.0], ["latitude": 10.0, "longitude": 80.0]]
    var line: MGLPolyline!
    var trailMarker: MGLPointAnnotation!
    let trailMarkerIdentifier = "trail-marker"
    
    
    @IBOutlet weak var switchButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURLWithVersion(9))
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
    }
    
    func drawTrail() {
        var coordinates: [CLLocationCoordinate2D] = []
        for point in points {
            coordinates.append(CLLocationCoordinate2D(latitude: point["latitude"]!, longitude: point["longitude"]!))
        }
        
        line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        
        trailMarker = MGLPointAnnotation()
        
        mapView.addAnnotation(line)
        mapView.addAnnotation(trailMarker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchMode() {
        if isReplayMode {
            mapView.styleURL = MGLStyle.lightStyleURLWithVersion(9)
            switchButton?.setTitle("🌚", forState: .Normal)
            mapView.showsUserLocation = true
            mapView.removeAnnotation(line)
            mapView.removeAnnotation(trailMarker)
        } else {
            mapView.styleURL = MGLStyle.darkStyleURLWithVersion(9)
            switchButton?.setTitle("🌝", forState: .Normal)
            mapView.showsUserLocation = false
            drawTrail()
        }
        
        isReplayMode = !isReplayMode
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isMapAdded {
            isMapAdded = true
            mapView.setCenterCoordinate((locations.last?.coordinate)!, zoomLevel: 7, direction: 0, animated: false)
            view.insertSubview(mapView, atIndex: 0)
        }
    }
}

extension ViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        if !isCameraSet {
            isCameraSet = true
            let camera = MGLMapCamera(lookingAtCenterCoordinate: mapView.centerCoordinate, fromDistance: 1000, pitch: 15, heading: 0)
            mapView.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation) -> MGLAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(trailMarkerIdentifier)
        
        if annotationView == nil {
            var coordinates: [CLLocationCoordinate2D] = []
            for point in points {
                coordinates.append(CLLocationCoordinate2D(latitude: point["latitude"]!, longitude: point["longitude"]!))
            }
            
            annotationView = MGLAnnotationView(reuseIdentifier: trailMarkerIdentifier)
            
            let keyFrameAnimation = CAKeyframeAnimation(keyPath:"position")
            let animationPath = UIBezierPath()
            animationPath.moveToPoint(mapView.convertCoordinate(coordinates[0], toPointToView: mapView))
            for point in coordinates[1..<coordinates.count] {
                animationPath.addLineToPoint(mapView.convertCoordinate(point, toPointToView: mapView))
            }
            
            let content = UIImage(named: "Annotation")?.CGImage
            annotationView!.frame = CGRectMake(0, 0, 40, 50)
            
            keyFrameAnimation.duration = 4
            keyFrameAnimation.repeatCount = Float.infinity
            keyFrameAnimation.path = animationPath.CGPath
            keyFrameAnimation.calculationMode = kCAAnimationLinear
            annotationView!.layer.contents = content
            annotationView!.layer.addAnimation(keyFrameAnimation, forKey: "moving-position")

        }
        
        return annotationView
    }
}