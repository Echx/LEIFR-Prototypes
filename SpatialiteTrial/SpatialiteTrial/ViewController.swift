//
//  ViewController.swift
//  SpatialiteTrial
//
//  Created by Jinghan Wang on 21/8/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureDatabase()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func configureDatabase() {
		let databasePath = NSBundle.mainBundle().pathForResource("test", ofType: "sqlite")!
		if let database = FMDatabase(path: databasePath) {
			if database.openWithFlags(SQLITE_OPEN_READONLY) {
				let x = 540176.564
				let y = 5041228.401
				let querySQL = "SELECT * FROM Regions Where MbrContains(Geometry, MakePoint(\(x), \(y), \(32632)))"
				let results = database.executeQuery(querySQL, withArgumentsInArray: nil)
				
				if ((results?.next()) != nil) {
					print(results.columnNameToIndexMap)
					for i in 0..<results.columnCount() {
						print(results.stringForColumnIndex(i))
					}
				} else {
					print("Record Not Found")
				}
			}
		}
	}
}

