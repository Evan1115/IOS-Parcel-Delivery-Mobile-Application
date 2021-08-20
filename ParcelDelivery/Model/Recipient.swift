//
//  Recipient.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 19/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import CoreLocation

struct Recipient {
    var totalFare : String = ""
    var distance : Double = 0.0
    var totalDistance : String = ""
   
    mutating func calculateDistance(recipientLocation : CLLocation?,userLocation : CLLocation?,completion: ((String) -> Void)){
       
        guard let recipientLocation = recipientLocation else { return }
        guard let userLocation = userLocation else { return  }
      
        let loc1 = CLLocation(latitude: (recipientLocation.coordinate.latitude), longitude: (recipientLocation.coordinate.longitude))
        
        let loc2 = CLLocation(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
          distance = loc1.distance(from: loc2) / 1000
        self.totalDistance = String(format: "%.2f",distance)
        completion(totalDistance)
    }
    
    mutating func calculateDistanceBeforeAccepting(recipientLocation : CLLocation?,userLocation : CLLocation?){
       
        guard let recipientLocation = recipientLocation else { return }
        guard let userLocation = userLocation else { return  }
      
        let loc1 = CLLocation(latitude: (recipientLocation.coordinate.latitude), longitude: (recipientLocation.coordinate.longitude))
        
        let loc2 = CLLocation(latitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude))
          distance = loc1.distance(from: loc2) / 1000
        
        
    }
    
    mutating func calculateFare(completion: ((String) -> Void)){
        let fare = distance * 1.3 + 1.0
         self.totalFare = String(format: "%.2f",fare)
        completion(totalFare)
    }
}
