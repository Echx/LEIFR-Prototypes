//
//  ViewController.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Mapbox
import RealmSwift
import TQLocationConverter

class ViewController: UIViewController {
	
	static let maxZoomLevel = 19
	
    var mapView: MGLMapView!
	let locationManager = CLLocationManager()
	var fogOverlayRenderer: RFTFogOverlayRenderer!
	var shouldRecordCoordinate = false
	var lastLocation: CLLocation!
    var isMapAdded = false
    var isCenterSet = false
    var isCameraSet = false
	var neglectableSpan = {
		() -> [Double] in
		
		var span = [4.0];
		
		for _ in 0 ..< maxZoomLevel {
			span.append(span.last! / 2)
		}
		
		return span
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureMapView()
		self.configureLocationManager()
        self.loadPoints()
	}
	
	private func configureMapView() {
		mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURLWithVersion(9))
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.showsUserLocation = true
        mapView.delegate = self
        view.insertSubview(mapView, atIndex: 0)
        isMapAdded = true
	}
	
	private func configureLocationManager() {
		self.locationManager.delegate = self
		if self.locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
			self.locationManager.requestAlwaysAuthorization()
		}
		
		self.locationManager.allowsBackgroundLocationUpdates = true
		
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.startUpdatingLocation()
		NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(startRecordingPoint), userInfo: nil, repeats: false)
	}
    
    private func loadPoints() {
        let realm = try!Realm()
        let points = realm.objects(RFTPoint.self).sorted("time")
        var pointAnnotations = [MGLPointAnnotation]()
        for point in points {
            let pointAnnotation = MGLPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
            pointAnnotations.append(pointAnnotation)
        }
        mapView.addAnnotations(pointAnnotations)
    }

	func startRecordingPoint() {
		self.shouldRecordCoordinate = true
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		if !self.shouldRecordCoordinate || newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 100 {
			print("Point not recorded: not accurate enough")
			return
		}
		
		self.recordCoordinate(newLocation.coordinate)
		lastLocation = newLocation
        
        if !isCenterSet && isMapAdded {
            isCenterSet = true
            mapView.setCenterCoordinate(lastLocation.coordinate, zoomLevel: 7, direction: 0, animated: false)
        }
	}
	
	private func recordCoordinate(c: CLLocationCoordinate2D) {
		let coordinate = c
//		if !TQLocationConverter.isLocationOutOfChina(coordinate) {
//			coordinate = TQLocationConverter.transformFromWGSToGCJ(coordinate)
//		}
		
		if let zoom = self.getZoomLevelForCoordinate(coordinate) {
			print("Point recorded")
			let point = RFTPoint()
			point.latitude = coordinate.latitude
			point.longitude = coordinate.longitude
			point.time = NSDate()
			point.visibleZoomLevel = zoom
			let realm = try! Realm()
			try! realm.write {
				realm.add(point)
			}
			
			if UIApplication.sharedApplication().applicationState == .Active {
				
//				let mapPoint = MKMapPointForCoordinate(coordinate)
//				if MKMapRectContainsPoint(self.mapView.visibleMapRect, mapPoint) {
//					self.fogOverlayRenderer.setNeedsDisplayInMapRect(self.mapView.visibleMapRect)
//				}
			}
		} else {
			print("Point not recorded: existed")
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
}


extension ViewController {
	
	private func getZoomLevelForCoordinate(coordinate: CLLocationCoordinate2D) -> Int? {
		
		let long = coordinate.longitude
		let lat = coordinate.latitude
		
		var compoundPredicate = NSPredicate(value: false)
		for zoom in 0 ... ViewController.maxZoomLevel {
			let s = neglectableSpan[zoom]
			let currentPredicate = NSPredicate(format: "longitude > %lf AND longitude < %lf AND latitude > %lf AND latitude < %lf AND visibleZoomLevel == %ld", long - s, long + s, lat - s, lat + s, zoom)
			compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [compoundPredicate, currentPredicate])
		}
		
		let realm = try!Realm()
		let points = realm.objects(RFTPoint.self).filter(compoundPredicate).sorted("visibleZoomLevel", ascending: false)
		
		let count = points.count
		if count == 0 {
			return 0
		} else {
			let firstZoom = points.first!.visibleZoomLevel
			if firstZoom < ViewController.maxZoomLevel {
				return firstZoom + 1
			} else {
				return nil
			}
		}
	}
}