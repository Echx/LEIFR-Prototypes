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
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayTileViewController.didRecieveNewDataAvailableNotification(_:)), name: CoreDataManager.ATNewDataAvailableNotification, object: nil)
		
        super.viewDidLoad()

//		self.configureMapBoxOverlay()
		self.configureMapView()
        // Do any additional setup after loading the view.
    }

	func didRecieveNewDataAvailableNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			if let coordinateValue = userInfo["coordinate"] as? NSValue {
				let coordinate = coordinateValue.MKCoordinateValue
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let mapRect = MKMapRectMake(mapPoint.x - 16, mapPoint.y - 16, 32, 32)
				self.overlayRenderer.setNeedsDisplayInMapRect(mapRect)
			}
		}
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
	
	private func configureMapBoxOverlay() {
		let urlTemplateString = "https://api.mapbox.com/v4/mapbox.light/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
		let tileOverlay = MKTileOverlay(URLTemplate: urlTemplateString)
		
		tileOverlay.canReplaceMapContent = true
		mapView.addOverlay(tileOverlay)
	}
}

extension OverlayTileViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let coordinate = newLocation.coordinate
		CoreDataManager.savePointForCoordinate(coordinate)
	}
}

extension OverlayTileViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		if overlay as! MKTileOverlay == self.overlay {
			if  self.overlayRenderer == nil {
				self.overlayRenderer = FogTileOverlayRenderer(overlay:overlay)
			}
			return self.overlayRenderer
		} else {
			return MKTileOverlayRenderer(overlay: overlay)
		}
	}
	
	
	
	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//		CoreDataManager.mapPointForRegion(mapView.region, handler: {
//			points in
//			
//			print(points.count)
//		})
	}
}

