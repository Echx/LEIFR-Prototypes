//
//  FlatPoint+CoreDataProperties.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 26/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FlatPoint {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var visibleZoom: NSNumber?

}
