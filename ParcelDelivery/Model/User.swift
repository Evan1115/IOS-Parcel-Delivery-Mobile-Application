//
//  User.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 08/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//
import CoreLocation

enum AccountType : Int {
    case passenger
    case driver
}
struct User {
    let fullname : String
    let email : String
    var accountType : AccountType!
    var userLocation : CLLocation?
    var oneTimeLocation : CLLocation?
    let uid : String
    
    init(uid: String, dictionary: [String : Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.uid = uid
        print("debug insid euer struct \(dictionary["accountType"])")
        
        if let index = dictionary["accountType"] as? Int {
            print("debug the index is \(index)")
            self.accountType = AccountType(rawValue: index)
            print("debug the account type is \(self.accountType)")
        }

        
        
    }
}
