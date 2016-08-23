//
//  STDatabaseManager.swift
//  SpatialiteTrial
//
//  Created by Jinghan Wang on 23/8/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

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
	
	
	
	func test() {
		let databasePath = NSBundle.mainBundle().pathForResource("test", ofType: "sqlite")!
		if let database = FMDatabase(path: databasePath) {
			if database.openWithFlags(SQLITE_OPEN_READONLY) {
				let x = 540176.564
				let y = 5041228.401
				let querySQL = "SELECT * FROM Regions Where MbrContains(Geometry, MakePoint(\(x), \(y), \(32632)))"
				let results = database.executeQuery(querySQL, withArgumentsInArray: nil)
				
				if ((results?.next()) != nil) {
					print(results.columnNameToIndexMap)
					print(results.stringForColumn("name"))
					print(results.dataForColumn("geometry"))
				} else {
					print("Record Not Found")
				}
			}
		}
	}
}
