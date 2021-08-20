//
//  Place.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 23/02/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Places {

var cllocation: CLLocation
var distance : Double
var coordinate : CLLocationCoordinate2D
var placemark : MKPlacemark?
var route : MKRoute?
    var serialNo : String?

    init(cllocation: CLLocation ,distance:Double!,coordinate: CLLocationCoordinate2D,placemark: MKPlacemark? = nil , route : MKRoute? = nil, serialNo : String? = nil){

    self.cllocation = cllocation
    self.coordinate = coordinate
    self.distance = distance
        
    //optional
    if let placemark = placemark {
             self.placemark = placemark
        }

    if let route = route {
             self.route = route
        }
        
    if let serialNo = serialNo {
             self.serialNo = serialNo
        
    }
    
}
    // Function to calculate the distance from given location.
    mutating func calculateDistance(fromLocation: CLLocation?) {

        distance = cllocation.distance(from: fromLocation!)
    }
}
