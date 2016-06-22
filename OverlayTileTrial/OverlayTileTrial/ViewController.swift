//
//  ViewController.swift
//  OverlayTileTrial
//
//  Created by Jinghan Wang on 21/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
	
	@IBOutlet var mapView: MKMapView!
	var manager: CLLocationManager!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureMapView()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func configureMapView() {
		mapView.delegate = self
		
		manager = CLLocationManager()
		manager.requestAlwaysAuthorization()
		manager.startUpdatingLocation()
		manager.delegate = self
		
//		mapView.showsUserLocation = true
		
//		let urlTemplateString = "https://api.mapbox.com/v4/mapbox.dark/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
		let tileOverlay = FogTileOverlay()
		mapView.addOverlay(tileOverlay)
	}

}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let coordinate = newLocation.coordinate
		let mapPoint = MKMapPoint(x: coordinate.longitude, y: coordinate.latitude)
		CoreDataManager.savePoint(mapPoint, withZoomLevel: 0)
		
	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		let renderer = MKTileOverlayRenderer(overlay:overlay)
		renderer.reloadData()
		return renderer
	}
}









