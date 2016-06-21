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
		
		let urlTemplateString = "https://api.mapbox.com/v4/mapbox.light/{z}/{x}/{y}@2x.png?access_token=pk.eyJ1IjoibnVsbDA5MjY0IiwiYSI6ImNpcG01b2Z2bjAwMGp1ZG03YTkzcXNkMjkifQ.z2KU_Qb8SxhlALWHgLwf2A"
		let tileOverlay = MapBoxTileOverlay(URLTemplate: urlTemplateString)
		
		tileOverlay.canReplaceMapContent = true
		tileOverlay.tileSize = CGSizeMake(512, 512)
		mapView.addOverlay(tileOverlay)
	}

}

extension ViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, rendererForOverlay overlay:
		MKOverlay) -> MKOverlayRenderer {
		return MKTileOverlayRenderer(overlay:overlay)
	}
}