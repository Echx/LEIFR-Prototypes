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
	private var _databaseQueue: FMDatabaseQueue!
	
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
		self._databaseQueue = FMDatabaseQueue(path: destinationPath)
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
	
	func savePath(path: STPath) {
		_databaseQueue.inDatabase({
			database in
			let insertSQL = "INSERT OR REPLACE INTO tracks (track_geometry) VALUES (LineStringFromText('\(path.WKTString())'));"
			self._database.executeStatements(insertSQL)
		})
	}
	
	func getPathsInRegion(region: MKCoordinateRegion, completion: ([STPath] -> Void)){
		_databaseQueue.inDatabase({
			database in
			let xMin = region.center.longitude - region.span.longitudeDelta
			let yMin = region.center.latitude - region.span.latitudeDelta
			let xMax = region.center.longitude + region.span.longitudeDelta
			let yMax = region.center.latitude + region.span.latitudeDelta
			
			let tolerance = region.span.longitudeDelta / 50
			
			let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
			let select = "SELECT track_id, AsBinary(Intersection(Simplify(track_geometry, \(tolerance)), " + screenPolygon + ")) FROM tracks "
			let querySQL = select + "WHERE MbrOverlaps(track_geometry, " + screenPolygon + ") OR MbrContains(track_geometry, " + screenPolygon + ")"
			let results = self._database.executeQuery(querySQL, withArgumentsInArray: nil)!
			
			var paths = [STPath]()
			
			while (results.next()) {
				if results.hasAnotherRow() {
					if let data = results.dataForColumnIndex(1) {
						let reader = WKBByteReader(data: data)
						reader.byteOrder = Int(CFByteOrderBigEndian.rawValue)
						let geometry = WKBGeometryReader.readGeometryWithReader(reader)
						
						if let lineString = geometry as? WKBLineString {
							let path = STPath(lineString: lineString)
							paths.append(path)
						} else if let multiLineString = geometry as? WKBMultiLineString {
							print("multiline")
							for lineString in multiLineString.getLineStrings() {
								let path = STPath(lineString: lineString as! WKBLineString)
								paths.append(path)
							}
						}
					}
				}
			}
			
			completion(paths)
		})
	}
}
