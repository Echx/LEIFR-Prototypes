//
//  ATPointAnnotation.swift
//  AnnotationTrial
//
//  Created by Jinghan Wang on 26/6/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Mapbox

class ATPointAnnotation: MGLPointAnnotation {

}

func ==(lhs: MGLPointAnnotation, rhs: MGLPointAnnotation) -> Bool {
	return (lhs.coordinate.latitude == rhs.coordinate.latitude) && (lhs.coordinate.longitude == rhs.coordinate.longitude)
}