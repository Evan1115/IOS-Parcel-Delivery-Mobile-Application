//
//  LocationHandler.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 08/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import Firebase
import CoreLocation

class LocationHandler : NSObject , CLLocationManagerDelegate{
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var locatin : CLLocation?
    
    
    override init (){
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager.requestAlwaysAuthorization()
        }
    }
}
