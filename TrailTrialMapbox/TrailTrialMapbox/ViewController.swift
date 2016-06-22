//
//  ViewController.swift
//  TrailTrialMapbox
//
//  Created by Lei Mingyu on 22/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let styleURL = NSURL(string: "<#mapbox://styles/echx/cippukp1n003ocwm6ylz90bt8#>")
        let mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.addSubview(mapView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

