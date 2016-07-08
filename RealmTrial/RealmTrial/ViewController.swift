//
//  ViewController.swift
//  RealmTrial
//
//  Created by Jinghan Wang on 7/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import RealmSwift

class ViewController: UIViewController {

	@IBOutlet var mapView: MKMapView!
	let locationManager = CLLocationManager()
	let currentPath = RTPath()
	
	var fogOverlayRenderer: RTFogOverlayRenderer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureCurrentPath()
		self.configureLocationManager()
		self.configureMapView()
	}
	
	private func configureCurrentPath() {
		self.currentPath.id = NSUUID().UUIDString
		let realm = try! Realm()
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
	}
	
	private func configureMapView() {
		self.mapView.delegate = self
		
		//set up overlay
		let fogOverlay = RTFogOverlay()
		self.mapView.addOverlay(fogOverlay);
		
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let latestLocation = locations.first {
			
			let point = RTPoint()
			point.sequence = self.currentPath.points.count
			point.latitude = latestLocation.coordinate.latitude
			point.longitude = latestLocation.coordinate.longitude
			
			let realm = try! Realm()
			try! realm.write {
				self.currentPath.addPoint(point)
			}
			self.fogOverlayRenderer.setNeedsDisplayInMapRect(self.mapView.visibleMapRect)
		}
	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is RTFogOverlay {
			if self.fogOverlayRenderer == nil {
				self.fogOverlayRenderer = RTFogOverlayRenderer(overlay: overlay)
				self.fogOverlayRenderer.alpha = 0.5
				self.fogOverlayRenderer.mapView = self.mapView
			}
			
			return self.fogOverlayRenderer
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}
