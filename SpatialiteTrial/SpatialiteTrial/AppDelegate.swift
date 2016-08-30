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
	var database:FMDatabase!

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		
		spatialite_init(1);
//		STDatabaseManager.sharedManager().test()
		let manager = STDatabaseManager.sharedManager()
		manager.openDatabase()
		let database = manager.database()
		self.database = database
//		let insertSQL = "INSERT INTO tracks (track_geometry) VALUES (GeomFromText('LINESTRING(689001.702718 4798988.808442, 689027.602471 4798996.686619, 689029.54214 4798989.585948, 689029.54214 4798989.585948)'));"
//		if database.executeStatements(insertSQL) {
//			print("inserted!")
//		} else {
//			print("not inserted!")
//		}
		
		insert()
		query()
		
		return true
	}
	
	func query() {
		let querySQL = "SELECT track_id, AsBinary(track_geometry) FROM tracks"
		let results = database.executeQuery(querySQL, withArgumentsInArray: nil)
		
		if ((results?.next()) != nil) {
			print(results.columnNameToIndexMap)
			print(results.stringForColumn("track_id"))
			let data = results.dataForColumn("asbinary(track_geometry)")
			let reader = WKBByteReader(data: data)
			reader.byteOrder = Int(CFByteOrderBigEndian.rawValue)
			
			let geometry = WKBGeometryReader.readGeometryWithReader(reader) as! WKBLineString
			for point in geometry.points {
				print("(\(point.x as NSDecimalNumber), \(point.y as NSDecimalNumber), \(point.z as NSDecimalNumber), \(point.m as NSDecimalNumber))")
			}
		} else {
			print("Record Not Found")
		}
	}
	
	func insert() {
		let lineString = WKBLineString(hasZ: true, andHasM: true)
		
		for i in 0..<10 {
			let point = WKBPoint(hasZ: true, andHasM: true, andX: NSDecimalNumber(double: Double(10 * i)), andY: 45)
			point.m = NSDecimalNumber(integer: i)
			point.z = NSDecimalNumber(integer: 0)
			lineString.addPoint(point)
		}
		
		let insertSQL = "INSERT OR REPLACE INTO tracks (track_geometry) VALUES (GeomFromText('\(STDatabaseManager.WKTStringForLineString(lineString))'));"
		if database.executeStatements(insertSQL) {
			print("inserted!")
		} else {
			print("not inserted!")
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

