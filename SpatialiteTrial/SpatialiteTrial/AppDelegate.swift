//
//  AppDelegate.swift
//  SpatialiteTrial
//
//  Created by Jinghan Wang on 21/8/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var database:COpaquePointer = nil

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		dbInit()
		testDB()
		
		return true
	}
	
	func dbInit() {
		spatialite_init(1);
		let dpPath = NSBundle.mainBundle().pathForResource("test", ofType: "sqlite")!
		let name = dpPath.cStringUsingEncoding(NSUTF8StringEncoding)!
		let dbOpen = sqlite3_open_v2(name, &database, SQLITE_OPEN_READONLY, nil)
		
		if dbOpen != SQLITE_OK {
			print("Error")
		} else {
			print("Database is open")
		}
	}
	
	func testDB() {
		let x = 540176.564
		let y = 5041228.401
		let request = "SELECT * FROM Regions Where MbrContains(Geometry, MakePoint(\(x), \(y), \(32632)))"
		print("The query is \(request)")
		let sql = request.cStringUsingEncoding(NSUTF8StringEncoding)!
		var statement:COpaquePointer = nil
		let returnValue = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
		if returnValue == SQLITE_OK {
			while sqlite3_step(statement) == SQLITE_ROW {
				let temp = sqlite3_column_text(statement,1)
				let name = String.fromCString(UnsafePointer<CChar>(temp))!
				print("The region name is: \(name)")
			}
		}
		
		
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

