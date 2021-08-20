//
//  Parcel.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 01/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Parcel {

var serialNo: String
var courierCenter : String
var id : Int


    init(serialNo: String ,courierCenter:String, id : Int){

         self.serialNo = serialNo
        self.courierCenter = courierCenter
        self.id = id
  
     }
}

