//
//  STDatabaseManager.swift
//  SpatialiteTrial
//
//  Created by Jinghan Wang on 23/8/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class STDatabaseManager: NSObject {
	
	private static let _sharedManager = STDatabaseManager()
	private var _database: FMDatabase!
	
	class func sharedManager() -> STDatabaseManager{
		return self._sharedManager
	}
	
	func database() -> FMDatabase {
		return self._database
	}
	
	func createDatabaseIfNotExist(name: String) {
		let databaseDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
		let destinationPath = databaseDirectory.stringByAppendingString("/\(name).sqlite")
		let fileManager = NSFileManager.defaultManager()
		
		if !fileManager.fileExistsAtPath(destinationPath) {
			let sourcePath = NSBundle.mainBundle().pathForResource("default", ofType: "sqlite")!
			_ = try? fileManager.copyItemAtPath(sourcePath, toPath: destinationPath)
		}
		
		self._database = FMDatabase(path: destinationPath)
	}
	
	func openDatabase() -> Bool {
		if self._database == nil {
			self.createDatabaseIfNotExist("default")
		}
		
		if self._database.open() {
			print("Database opened:  \(self._database.databasePath())")
			return true
		} else {
			print("Database failed to open")
			return false
		}
	}
	
	func savePath(path: STPath) -> Bool {
		let insertSQL = "INSERT OR REPLACE INTO tracks (track_geometry) VALUES (LineStringFromText('\(path.WKTString())'));"
		return self._database.executeStatements(insertSQL)
	}
	
	func pathsInRegion(region: MKCoordinateRegion) -> [STPath]{
		let xMin = region.center.longitude - region.span.longitudeDelta / 2
		let yMin = region.center.latitude - region.span.latitudeDelta / 2
		let xMax = region.center.longitude + region.span.longitudeDelta / 2
		let yMax = region.center.latitude + region.span.latitudeDelta / 2
		
		let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
		
		
		let querySQL = "SELECT track_id, AsBinary(track_geometry) FROM tracks WHERE MbrOverlaps(track_geometry, " + screenPolygon + ")"
		let results = self._database.executeQuery(querySQL, withArgumentsInArray: nil)!
		
		var paths = [STPath]()
		
		while (results.next() && results.columnNameToIndexMap.count != 0) {
			let data = results.dataForColumn("asbinary(track_geometry)")
			let reader = WKBByteReader(data: data)
			reader.byteOrder = Int(CFByteOrderBigEndian.rawValue)
			
			let geometry = WKBGeometryReader.readGeometryWithReader(reader) as! WKBLineString
			let path = STPath(lineString: geometry)
			paths.append(path)
		}
		
		return paths
	}
}
