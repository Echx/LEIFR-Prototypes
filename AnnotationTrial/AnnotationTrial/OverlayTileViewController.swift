//
//  OverlayTileViewController.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 27/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class OverlayTileViewController: UIViewController {
	
	@IBOutlet var mapView: MKMapView!
	var manager: CLLocationManager!
	var overlayRenderer: MKTileOverlayRenderer!
	var overlay: MKTileOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()

		self.configureMapView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func configureMapView() {
		
		manager = CLLocationManager()
		manager.requestAlwaysAuthorization()
		manager.startUpdatingLocation()
		manager.delegate = self
		
		mapView.delegate = self
		
		self.overlay = FogTileOverlay()
		mapView.addOverlay(overlay)
	}
}

extension OverlayTileViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let coordinate = newLocation.coordinate
		CoreDataManager.savePointForCoordinate(coordinate)

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
			
			let mapPoint = MKMapPointForCoordinate(coordinate)
			let mapRect = MKMapRectMake(mapPoint.x - 512, mapPoint.y - 512, 1024, 1024)
			
			self.overlayRenderer.setNeedsDisplayInMapRect(mapRect)
		})
	}
}

extension OverlayTileViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		let renderer = MKTileOverlayRenderer(overlay:overlay)
		self.overlayRenderer = renderer
		return renderer
	}
	
	
	
	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//		CoreDataManager.mapPointForRegion(mapView.region, handler: {
//			points in
//			
//			print(points.count)
//		})
	}
}

