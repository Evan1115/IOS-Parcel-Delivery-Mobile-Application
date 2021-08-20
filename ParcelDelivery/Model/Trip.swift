//
//  Trip.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 23/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import CoreLocation

enum TripState : Int {
    case requested
    case denied
    case accepted
    case driverArrived
    case inProgress
    case arriveAtDestination
    case completed
}

struct Trip {
    var pickupCoordinates : CLLocationCoordinate2D!
//    var destinationCoordinates : [CLLocationCoordinate2D?] = []//latest
    var destinationCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates2: CLLocationCoordinate2D!
    var destinationCoordinates3: CLLocationCoordinate2D!
    let passengerUid : String!
    var driverUid : String?
    var state : TripState!
    var tripCount : Int?
    var coordinatesArray : [CLLocationCoordinate2D] = []
    var serialNo : [String?] = []
    var orderID : String?
    var destinationName : [String?] = []
    var latitude: [CLLocationDegrees] = []
     var longitude: [CLLocationDegrees] = []
    var courierCenterCoordinates : [CLLocationCoordinate2D] = []
    
    // get data back from the database
    init ( passengerUid : String, dictionary : [String: Any]){
        self.passengerUid = passengerUid
        if let latitude = dictionary["latitudeArr"] as? NSArray{
            self.latitude = latitude as! [CLLocationDegrees]
        }
        
        if let longitude = dictionary["longitudeArr"] as? NSArray{
            self.longitude = longitude as! [CLLocationDegrees]
        }
        
        for (index, _) in self.latitude.enumerated() {
            courierCenterCoordinates.append(CLLocationCoordinate2D(latitude: self.latitude[index], longitude: self.longitude[index]))
        }
        
        print("debug lat and long in trip\(self.latitude) and \(self.longitude) and \(self.courierCenterCoordinates)")
        
        if let pickupCoordinates = dictionary["pickupCoordinates" ] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates" ] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
//            for destinationCoor in destinationCoordinates{
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.coordinatesArray.append(self.destinationCoordinates)
//                guard let dest1 = destinationCoordinates[0] as? CLLocationCoordinate2D else { return } //latest
//                guard let dest2 = destinationCoordinates[1] as? CLLocationCoordinate2D else { return }//latest
//                self.destinationCoordinates.append(dest1)//latest
//                self.destinationCoordinates.append(dest2)//latest
//            print("debug destinationCoordinate in Trip mode \(self.destinationCoordinates)")
       }
        
         if let destinationCoordinates = dictionary["destinationCoordinates2" ] as? NSArray {
                    guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
                    guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
        //            for destinationCoor in destinationCoordinates{
                    self.destinationCoordinates2 = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.coordinatesArray.append(self.destinationCoordinates2)
             print("debug popo\(self.coordinatesArray)")
        //                guard let dest1 = destinationCoordinates[0] as? CLLocationCoordinate2D else { return } //latest
        //                guard let dest2 = destinationCoordinates[1] as? CLLocationCoordinate2D else { return }//latest
        //                self.destinationCoordinates.append(dest1)//latest
        //                self.destinationCoordinates.append(dest2)//latest
        //            print("debug destinationCoordinate in Trip mode \(self.destinationCoordinates)")
               }
        
        if let destinationCoordinates = dictionary["destinationCoordinates3" ] as? NSArray {
                    guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
                    guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
        //            for destinationCoor in destinationCoordinates{
                    self.destinationCoordinates3 = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.coordinatesArray.append(self.destinationCoordinates3)
             print("debug popo\(self.coordinatesArray)")
        //                guard let dest1 = destinationCoordinates[0] as? CLLocationCoordinate2D else { return } //latest
        //                guard let dest2 = destinationCoordinates[1] as? CLLocationCoordinate2D else { return }//latest
        //                self.destinationCoordinates.append(dest1)//latest
        //                self.destinationCoordinates.append(dest2)//latest
        //            print("debug destinationCoordinate in Trip mode \(self.destinationCoordinates)")
               }
       
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
        
        self.tripCount = dictionary["tripCount"] as? Int ?? 0
        self.serialNo =  dictionary["serialNo"] as? [String] ?? []
        print("debug serialNo \( self.serialNo)")
      
        self.orderID = dictionary["orderID"] as? String ?? ""
        
        self.destinationName = dictionary["destinationName"] as? [String] ?? []
    
        
        
    }
    
}


