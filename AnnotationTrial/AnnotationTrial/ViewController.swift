import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {
	
	var mapView: MGLMapView!
	var progressView: UIProgressView!
	var annotations: [ATPointAnnotation] = []
	var manager: CLLocationManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		manager = CLLocationManager()
		manager.requestAlwaysAuthorization()
		manager.startUpdatingLocation()
		manager.delegate = self
		
		mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURLWithVersion(9))
		mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		mapView.tintColor = .grayColor()
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .Follow
		view.addSubview(mapView)
		
//		mapView.setCenterCoordinate(CLLocationCoordinate2DMake(45.8038, 126.6350),
//		                            zoomLevel: 9, animated: false)
		
		// Setup offline pack notification handlers.
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.offlinePackProgressDidChange(_:)), name: MGLOfflinePackProgressChangedNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.offlinePackDidReceiveError(_:)), name: MGLOfflinePackErrorNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.offlinePackDidReceiveMaximumAllowedMapboxTiles(_:)), name: MGLOfflinePackMaximumMapboxTilesReachedNotification, object: nil)
	}
	
	func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
		// Start downloading tiles and resources for z13-16.
//		startOfflinePackDownload()
	}
	
	deinit {
		// Remove offline pack observers.
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func startOfflinePackDownload() {
		// Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
		// Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
		let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: 0, toZoomLevel: 19)
		
		// Store some data for identification purposes alongside the downloaded resources.
		let userInfo = ["name": "My Offline Pack"]
		let context = NSKeyedArchiver.archivedDataWithRootObject(userInfo)
		
		// Create and register an offline pack with the shared offline storage object.
		MGLOfflineStorage.sharedOfflineStorage().addPackForRegion(region, withContext: context) { (pack, error) in
			guard error == nil else {
				// The pack couldn’t be created for some reason.
				print("Error: \(error?.localizedFailureReason)")
				return
			}
			
			// Start downloading.
			pack!.resume()
		}
	}
	
	// MARK: - MGLOfflinePack notification handlers
	
	func offlinePackProgressDidChange(notification: NSNotification) {
		// Get the offline pack this notification is regarding,
		// and the associated user info for the pack; in this case, `name = My Offline Pack`
		if let pack = notification.object as? MGLOfflinePack,
			userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String] {
			let progress = pack.progress
			// or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
			let completedResources = progress.countOfResourcesCompleted
			let expectedResources = progress.countOfResourcesExpected
			
			// Calculate current progress percentage.
			let progressPercentage = Float(completedResources) / Float(expectedResources)
			
			// Setup the progress bar.
			if progressView == nil {
				progressView = UIProgressView(progressViewStyle: .Default)
				let frame = view.bounds.size
				progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75, frame.width / 2, 10)
				view.addSubview(progressView)
			}
			
			progressView.progress = progressPercentage
			
			// If this pack has finished, print its size and resource count.
			if completedResources == expectedResources {
				let byteCount = NSByteCountFormatter.stringFromByteCount(Int64(pack.progress.countOfBytesCompleted), countStyle: NSByteCountFormatterCountStyle.Memory)
				print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
				progressView.removeFromSuperview()
			} else {
				// Otherwise, print download/verification progress.
				print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
			}
		}
	}
	
	func offlinePackDidReceiveError(notification: NSNotification) {
		if let pack = notification.object as? MGLOfflinePack,
			userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
			error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? NSError {
			print("Offline pack “\(userInfo["name"])” received error: \(error.localizedFailureReason)")
		}
	}
	
	func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
		if let pack = notification.object as? MGLOfflinePack,
			userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
			maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey]?.unsignedLongLongValue {
			print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
		}
	}
	
	func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
		
		CoreDataManager.pointsForRegionWithVisibleCoordinateBounds(mapView.visibleCoordinateBounds, andZoom: Int(floor(mapView.zoomLevel)), andHandler: {
			points in
			
			let annotations:[ATPointAnnotation] = points.map({
				point in
				let annotation =  ATPointAnnotation()
				annotation.coordinate = CLLocationCoordinate2DMake(point.latitude!.doubleValue, point.longitude!.doubleValue)
				return annotation
			})
			
			if let originalAnnotations = mapView.annotations {
				for annotation in originalAnnotations {
					var contains = false
					for a in annotations {
						if a.coordinate.latitude == annotation.coordinate.latitude &&
							a.coordinate.longitude == annotation.coordinate.longitude {
							contains = true
							break
						}
					}
					
					if !contains {
						mapView.removeAnnotation(annotation)
					}
				}
			}
			
			for annotation in annotations {
				if !self.annotations.contains(annotation) {
					mapView.addAnnotations([annotation])
				}
			}
		})
	}
	
	func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
		// Try to reuse the existing ‘pisa’ annotation image, if it exists
		var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("dot")
		
		if annotationImage == nil {
			let image = UIImage(named: "dot")!
			annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "dot")
		}
		
		return annotationImage
	}
	
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
		let coordinate = newLocation.coordinate
		CoreDataManager.savePointForCoordinate(coordinate)
	}
}