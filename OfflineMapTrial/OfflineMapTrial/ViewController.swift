//
//  ViewController.swift
//  OfflineMapTrial
//
//  Created by Jinghan Wang on 1/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
	
	@IBOutlet var mapView: MKMapView!
	@IBOutlet var offlineOverlay: MKTileOverlay!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configureMapView()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	func configureMapView() {
		self.mapView.delegate = self
		let tileOverlay = OfflineTileOverlay()
		
		tileOverlay.canReplaceMapContent = true
		tileOverlay.tileSize = CGSizeMake(512, 512)
		
		self.mapView.addOverlay(tileOverlay)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}


extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		return MKTileOverlayRenderer(overlay: overlay)
	}
}

