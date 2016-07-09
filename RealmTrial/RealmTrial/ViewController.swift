//
//  ViewController.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 7/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import RealmSwift
import TQLocationConverter

class ViewController: UIViewController {

	private let MAX_POINT_ALLOWED_PER_PATH = 100
	
	@IBOutlet var mapView: MKMapView!
	let locationManager = CLLocationManager()
	var currentPath = RTPath()
	var lastLocation: CLLocation!
	var shouldRecordCoordinate = false
	
	var fogOverlayRenderer: RTFogOverlayRenderer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureLocationManager()
		self.configureMapView()
	}
	
	private func configureNewCurrentPath() {
		let realm = try! Realm()
		
		if self.currentPath.points.count != 0 {
			try! realm.write {
				self.currentPath.endEditing()
			}
			self.currentPath = RTPath()
		}
		
		self.currentPath.id = NSUUID().UUIDString
		try! realm.write {
			realm.add(self.currentPath)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func configureLocationManager() {
		self.locationManager.delegate = self
		if self.locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) {
			self.locationManager.requestAlwaysAuthorization()
		}
		
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.startUpdatingLocation()
		NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(startRecordingPoint), userInfo: nil, repeats: false)
	}
	
	func startRecordingPoint() {
		self.shouldRecordCoordinate = true
	}
	
	private func configureMapView() {
		self.mapView.delegate = self
		
		//set up overlay
		let fogOverlay = RTFogOverlay()
		self.mapView.addOverlay(fogOverlay);
		
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		
		if !self.shouldRecordCoordinate {
			return
		}
		
		let latestLocation = newLocation
			
		if lastLocation == nil || latestLocation.distanceFromLocation(lastLocation) > 2000 || self.currentPath.points.count >= MAX_POINT_ALLOWED_PER_PATH {
			
			self.recordCoordinate(latestLocation.coordinate)
			self.configureNewCurrentPath()
		}
		
		self.recordCoordinate(latestLocation.coordinate)
		lastLocation = latestLocation
	}
	
	private func recordCoordinate(c: CLLocationCoordinate2D) {
		var coordinate = c
		if !TQLocationConverter.isLocationOutOfChina(coordinate) {
			coordinate = TQLocationConverter.transformFromWGSToGCJ(coordinate)
		}
		
		let point = RTPoint()
		point.sequence = self.currentPath.points.count
		point.latitude = coordinate.latitude
		point.longitude = coordinate.longitude
		
		let realm = try! Realm()
		try! realm.write {
			self.currentPath.addPoint(point)
		}
		self.fogOverlayRenderer.setNeedsDisplayInMapRect(self.mapView.visibleMapRect)
	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is RTFogOverlay {
			if self.fogOverlayRenderer == nil {
				self.fogOverlayRenderer = RTFogOverlayRenderer(overlay: overlay)
				self.fogOverlayRenderer.mapView = self.mapView
			}
			
			return self.fogOverlayRenderer
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}
