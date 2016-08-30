//
//  ViewController.swift
//  SpatialiteTrial
//
//  Created by Jinghan Wang on 21/8/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

	@IBOutlet var mapView: MKMapView!
	let locationManager = CLLocationManager()
	var shouldRecordCoordinate = false
	var fogOverlayRenderer: RFTFogOverlayRenderer!
	let path = STPath()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureMapView()
		self.configureLocationManager()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplicationWillTerminateNotification, object: nil)
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
	
	func applicationWillTerminate(notification: NSNotification) {
		print("Application is terminating, saving data.")
		STDatabaseManager.sharedManager().savePath(path)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		
	}
	
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

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		if !self.shouldRecordCoordinate || newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 100 {
			print("Point not recorded: not accurate enough")
			return
		}
		
		path.addPoint(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude, altitude: newLocation.altitude)
	}
}

