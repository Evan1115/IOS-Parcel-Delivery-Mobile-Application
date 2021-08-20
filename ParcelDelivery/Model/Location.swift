//
//  Location.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 27/02/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Location {

var cllocation: CLLocation
var distance : Double
var coordinate : CLLocationCoordinate2D
var route : MKRoute
   


    init(cllocation: CLLocation ,distance:Double!,coordinate: CLLocationCoordinate2D,route : MKRoute){

    self.cllocation = cllocation
    self.coordinate = coordinate
    self.distance = distance
        self.route = route

}
    // Function to calculate the distance from given location.
    mutating func calculateDistance(fromLocation: CLLocation?) {

        distance = cllocation.distance(from: fromLocation!)
    }
}

