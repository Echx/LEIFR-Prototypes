//
//  OverlayViewController.swift
//  AnnotationTrial
//
//  Created by Lei Mingyu on 7/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class OverlayViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var switchButton: UIButton!
    var manager: CLLocationManager!
    var overlayRenderer: FogOverlayRenderer!
    var wholeOverlay: MKOverlay!
    var movingAnnotation = MKPointAnnotation()
    var animatingPath = false
    
    var crumbs: CrumbPath!
    var crumbRenderer: CrumbPathRenderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OverlayTileViewController.didRecieveNewDataAvailableNotification(_:)), name: CoreDataManager.ATNewDataAvailableNotification, object: nil)
        
        self.configureMapViewWholeOverlay()
        self.initializeLocationTracking()
    }
    
//    	func didRecieveNewDataAvailableNotification(notification: NSNotification) {
//    		if let userInfo = notification.userInfo {
//    			if let coordinateValue = userInfo["coordinate"] as? NSValue {
//    
//    				let coordinate = coordinateValue.MKCoordinateValue
//    				let mapPoint = MKMapPointForCoordinate(coordinate)
//    				let mapRect = MKMapRectMake(mapPoint.x - 16, mapPoint.y - 16, 32, 32)
//    //				let currentZoomScale = CGFloat(self.mapView.bounds.size.width) / CGFloat(self.mapView.visibleMapRect.size.width)
//    				self.overlayRenderer.setNeedsDisplayInMapRect(mapRect)
//    				if self.crumbs == nil {
//    					self.crumbs = CrumbPath(centerCoordinate: coordinate)
//    					self.mapView.addOverlay(self.crumbs, level: .AboveRoads)
//    					let region = self.coordinateRegionWithCenter(coordinate, approximateRadiusInMeters: 2500)
//    					self.mapView.setRegion(region, animated: true)
//    				} else {
//    					var boundingMapRectChanged: ObjCBool = false
//    					var updateRect = self.crumbs.addCoordinate(coordinate, boundingMapRectChanged: &boundingMapRectChanged)
//    
//    					if boundingMapRectChanged {
//    						self.mapView.removeOverlay(self.crumbs)
//    						self.crumbRenderer = nil
//    						self.mapView.addOverlay(self.crumbs, level: .AboveRoads)
//    					} else if !MKMapRectIsNull(updateRect) {
//    						let currentZoomScale = CGFloat(self.mapView.bounds.size.width) / CGFloat(self.mapView.visibleMapRect.size.width)
//    						let lineWidth = Double(MKRoadWidthAtZoomScale(currentZoomScale))
//    						updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth)
//    						self.crumbRenderer.setNeedsDisplayInMapRect(updateRect)
//    					}
//    
//    				}
//    
//    //				let mapPoint = MKMapPointForCoordinate(coordinate)
//    //				let mapRect = MKMapRectMake(mapPoint.x - 16, mapPoint.y - 16, 32, 32)
//    //				self.overlayRenderer.setNeedsDisplayInMapRect(mapRect)
//    			}
//    		}
//    	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureMapViewWholeOverlay() {
        mapView.delegate = self
        mapView.showsUserLocation = false
//        self.wholeOverlay = FogOverlay()
//        mapView.addOverlay(wholeOverlay)
        self.addTrail()
    }
    
    private func addTrail() {
        CoreDataManager.points {
            points in
            let coordinateList = self.chopTrail(points)
            
            for var coordinates in coordinateList {
                let pointsCount = coordinates.count
                let trail = MKPolyline(coordinates: &coordinates, count: pointsCount)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addOverlay(trail)
                })
            }
        }
    }
    
    private func addMovingAnnotation() {
        mapView.addAnnotation(movingAnnotation)
        CoreDataManager.points {
            points in
            
            dispatch_async(dispatch_get_main_queue(), {
//                UIView.animateKeyframesWithDuration(40.0, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.CurveEaseInOut.rawValue), animations: {
//            
                        var delay = 0.0
                        for point in points {
//                            UIView.addKeyframeWithRelativeStartTime(delay, relativeDuration: 0.5, animations: {
//                                self.movingAnnotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude!.doubleValue, longitude: point.longitude!.doubleValue)
                                UIView.animateKeyframesWithDuration(0.03, delay: delay, options: UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.CurveEaseInOut.rawValue), animations: {
                                    self.movingAnnotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude!.doubleValue, longitude: point.longitude!.doubleValue)
                                }, completion: nil)
//                            })
                            delay += 0.03
                        }
//                    }, completion: nil)
                })
            }
    }
    
    private func chopTrail(points: [FlatPoint]) -> [[CLLocationCoordinate2D]] {
        var start = 0
        var coordinateList = [[CLLocationCoordinate2D]]()
        let maxGapDistance: Double = 100
        
        var locations: [CLLocation] = points.map({
            flatPoint in
            return CLLocation(latitude: flatPoint.latitude!.doubleValue, longitude: flatPoint.longitude!.doubleValue)
        })
        
        for i in 0...locations.count - 2 {
            let distance = locations[i].distanceFromLocation(locations[i + 1])
            if distance > maxGapDistance {
                coordinateList.append(locations[start...i].map({
                    location in
                    return location.coordinate
                }))
                start = i + 1
            }
        }
        
        return coordinateList
    }
    
    @IBAction func switchMode() {
        animatingPath = !animatingPath
        if animatingPath {
            addMovingAnnotation()
        } else {
            mapView.removeAnnotation(movingAnnotation)
        }
    }
}

extension OverlayViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let coordinate = newLocation.coordinate
        CoreDataManager.savePointForCoordinate(coordinate)
    }
}

extension OverlayViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CrumbPath {
            if self.crumbRenderer == nil {
                self.crumbRenderer = CrumbPathRenderer(overlay: overlay)
                self.crumbRenderer.map = self.mapView
            }
            return self.crumbRenderer
        } else if overlay is MKPolyline {
            return TrailOverlayRenderer(overlay: overlay)
        } else {
            if self.overlayRenderer == nil {
                self.overlayRenderer = FogOverlayRenderer(overlay: overlay)
//                self.overlayRenderer.map = self.mapView
            }
            return self.overlayRenderer
        }
    }
}

extension OverlayViewController {
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

