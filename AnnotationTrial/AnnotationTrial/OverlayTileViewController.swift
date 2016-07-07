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
	var overlayRenderer: FogTileOverlayRenderer!
	var overlay: MKTileOverlay!
	
	var crumbs: CrumbPath!
	var crumbRenderer: CrumbPathRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayTileViewController.didRecieveNewDataAvailableNotification(_:)), name: CoreDataManager.ATNewDataAvailableNotification, object: nil)

//		self.configureMapBoxOverlay()
		self.configureMapView()
		self.initializeLocationTracking()
    }

	func didRecieveNewDataAvailableNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			if let coordinateValue = userInfo["coordinate"] as? NSValue {
			
				let coordinate = coordinateValue.MKCoordinateValue
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let mapRect = MKMapRectMake(mapPoint.x - 16, mapPoint.y - 16, 32, 32)
//				let currentZoomScale = CGFloat(self.mapView.bounds.size.width) / CGFloat(self.mapView.visibleMapRect.size.width)
				self.overlayRenderer.setNeedsDisplayInMapRect(mapRect)
			}
		}
	}
	
	func updatePathWithCoordinate(coordinate: CLLocationCoordinate2D) {
		if self.crumbs == nil {
			self.crumbs = CrumbPath(centerCoordinate: coordinate)
			self.mapView.addOverlay(self.crumbs, level: .AboveRoads)
			let region = self.coordinateRegionWithCenter(coordinate, approximateRadiusInMeters: 2500)
			self.mapView.setRegion(region, animated: true)
		} else {
			var boundingMapRectChanged: ObjCBool = false
			var updateRect = self.crumbs.addCoordinate(coordinate, boundingMapRectChanged: &boundingMapRectChanged)
			
			if boundingMapRectChanged {
				self.mapView.removeOverlay(self.crumbs)
				self.crumbRenderer = nil
				self.mapView.addOverlay(self.crumbs, level: .AboveRoads)
			} else if !MKMapRectIsNull(updateRect) {
				let currentZoomScale = CGFloat(self.mapView.bounds.size.width) / CGFloat(self.mapView.visibleMapRect.size.width)
				let lineWidth = Double(MKRoadWidthAtZoomScale(currentZoomScale))
				updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth)
				
				if let crumbRenderer = self.crumbRenderer {
					crumbRenderer.setNeedsDisplayInMapRect(updateRect)
				}
			}
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func configureMapView() {
		mapView.delegate = self
		self.overlay = FogTileOverlay()
		mapView.addOverlay(overlay, level: .AboveRoads)
	}
	
	private func configureMapBoxOverlay() {
		let urlTemplateString = "https://api.mapbox.com/v4/mapbox.light/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
		let tileOverlay = MKTileOverlay(URLTemplate: urlTemplateString)
		
		tileOverlay.canReplaceMapContent = true
		tileOverlay.tileSize = CGSizeMake(512, 512)
		mapView.addOverlay(tileOverlay, level: .AboveLabels)
	}
}

extension OverlayTileViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let coordinate = newLocation.coordinate
		CoreDataManager.savePointForCoordinate(coordinate)
//		self.updatePathWithCoordinate(coordinate)
	}
}

extension OverlayTileViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		if overlay is MKTileOverlay {
			if  self.overlayRenderer == nil {
				self.overlayRenderer = FogTileOverlayRenderer(overlay:overlay)
				self.overlayRenderer.map = self.mapView
				self.overlayRenderer.alpha = 0.2
			}
			return self.overlayRenderer
		} else if overlay is CrumbPath {
			if self.crumbRenderer == nil {
				self.crumbRenderer = CrumbPathRenderer(overlay: overlay)
				self.crumbRenderer.map = self.mapView
			}
			return self.crumbRenderer
		} else {
			return MKTileOverlayRenderer(overlay: overlay)
		}
	}
}

extension OverlayTileViewController {
	func initializeLocationTracking() {
		manager = CLLocationManager()
		manager.delegate = self
		manager.requestAlwaysAuthorization()
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.startUpdatingLocation()
	}
	
	func coordinateRegionWithCenter(centerCoordinate: CLLocationCoordinate2D, approximateRadiusInMeters radiusInMeters: CLLocationDistance) -> MKCoordinateRegion {
		let radiusInMapPoints = radiusInMeters * MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude)
		let regionOrigin = MKMapPointForCoordinate(centerCoordinate)
		var regionRect = MKMapRectMake(regionOrigin.x, regionOrigin.y, radiusInMapPoints, radiusInMapPoints)
		regionRect = MKMapRectOffset(regionRect, -radiusInMapPoints/2, -radiusInMapPoints/2)
		regionRect = MKMapRectIntersection(regionRect, MKMapRectWorld)
		let region = MKCoordinateRegionForMapRect(regionRect)
		
		return region
	}
}

