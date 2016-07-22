//
//  ViewController.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit
import RealmSwift
import TQLocationConverter

class ViewController: UIViewController {
	
	@IBOutlet var mapView: MKMapView!
	let locationManager = CLLocationManager()
	var fogOverlayRenderer: RFTFogOverlayRenderer!
	var shouldRecordCoordinate = false
	var lastLocation: CLLocation!
	var neglectableSpan = {
		() -> [Double] in
		
		var span = [1.0];
		
		for _ in 0..<19 {
			span.append(span.last! / 2)
		}
		
		return span
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureMapView()
		self.configureLocationManager()
	}
	
	private func configureMapView() {
		self.mapView.delegate = self
		
		//set up overlay
		let fogOverlay = RFTFogOverlay()
		self.mapView.addOverlay(fogOverlay);
		
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
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		
		if !self.shouldRecordCoordinate || newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 100 {
			print("Point not recorded: not accurate enough")
			return
		}
		
		
		self.recordCoordinate(newLocation.coordinate)
		lastLocation = newLocation
	}
	
	private func recordCoordinate(c: CLLocationCoordinate2D) {
		var coordinate = c
		if !TQLocationConverter.isLocationOutOfChina(coordinate) {
			coordinate = TQLocationConverter.transformFromWGSToGCJ(coordinate)
		}
		
		
		
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
			self.fogOverlayRenderer.setNeedsDisplayInMapRect(self.mapView.visibleMapRect)
		} else {
			print("Point not recorded: existed")
		}
	}
}

extension ViewController {
	
	private func getZoomLevelForCoordinate(coordinate: CLLocationCoordinate2D) -> Int? {
		
		let long = coordinate.longitude
		let lat = coordinate.latitude
		
		var compoundPredicate = NSPredicate(value: false)
		for zoom in 0...19 {
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
			if firstZoom < 19 {
				return firstZoom + 1
			} else {
				return nil
			}
		}
	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is RFTFogOverlay {
			if self.fogOverlayRenderer == nil {
				self.fogOverlayRenderer = RFTFogOverlayRenderer(overlay: overlay)
				self.fogOverlayRenderer.mapView = self.mapView
			}
			
			return self.fogOverlayRenderer
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}
