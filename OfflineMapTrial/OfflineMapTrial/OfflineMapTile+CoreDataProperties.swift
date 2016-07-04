//
//  OfflineMapTile+CoreDataProperties.swift
//  OfflineMapTrial
//
//  Created by Jinghan Wang on 1/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension OfflineMapTile {

    @NSManaged var path: String?
    @NSManaged var imageData: NSData?

}
