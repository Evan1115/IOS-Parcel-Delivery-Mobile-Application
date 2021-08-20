//
//  Service.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 08/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

// MARK: -DatabaseReference
 let DB_REF = Database.database().reference()
 let REF_USERS = DB_REF.child("users")
 let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
 let REF_TRIPS = DB_REF.child("trips")
let REF_RECORD = DB_REF.child("records")
let REF_DRIVER_RECORD = DB_REF.child("driver-records")

// MARK: DriverService
struct DriverService {
    static let shared = DriverService()
    func observeTrips(completion : @escaping(Trip) -> Void ){
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func uploadDriverRecord(orderID: String,status : String, completion: @escaping(Error?,DatabaseReference) -> Void){
      
           guard let uid = Auth.auth().currentUser?.uid else { return }
          guard let key = REF_RECORD.childByAutoId().key else { return }
          let serverTIme =  ServerValue.timestamp()
         let time =  Service.shared.generateDateandTime()
          let record = ["id" : orderID , "time": time, "status" : status, "timestamp" :  serverTIme, "recordid": key] as [String : Any]
          let childUpdates = ["\(key)" : record]
              REF_DRIVER_RECORD.child(uid).updateChildValues(childUpdates , withCompletionBlock: completion)
      }
    
    func removeTripObserver(){
        REF_TRIPS.removeAllObservers()
    }
    
    func removeDriver(completion: @escaping(Error?,DatabaseReference) -> Void){
         guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_DRIVER_LOCATIONS.child(uid).removeValue(completionBlock: completion)
    }
    func observeTripAccepted(passengerUid : String , completion: @escaping(Trip) -> Void ){
        REF_TRIPS.child(passengerUid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any ] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion : @escaping() -> Void){
        
        // observe whether the child is removed.
        REF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { (snapshot) in
           completion()
        }
       
    }
    
    /* to prevent other driver from accept the trip when it is being accepted by others
     func acceptTrip (trip: Trip , completion : @escaping(Error?, DatabaseReference) -> Void) {
         guard let uid = Auth.auth().currentUser?.uid else { return }
         DriverService.shared.observeTripAccepted(passengerUid: trip.passengerUid) { (trip) in
             if uid != trip.driverUid{
           
                 let values = ["driverUid" : trip.driverUid ,
                               "state" : TripState.accepted.rawValue] as [String : Any]
                 
                 REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
             }
         }
         
     }
     */
    
    func acceptTrip (trip: Trip , completion : @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
     
                let values = ["driverUid" : uid,
                              "state" : TripState.accepted.rawValue] as [String : Any]
                
                REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
       
    }
    
    
    
    func updateTripState(trip : Trip , state : TripState , completion : @escaping(Error?, DatabaseReference) -> Void ){
        REF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        print("debug error called - updatetripstate")
        if state == .completed{
            REF_TRIPS.child(trip.passengerUid).removeAllObservers()
        }
    }
    
    
       func updateTripCount(trip : Trip , count : Int , completion : @escaping(Error?, DatabaseReference) -> Void ){
           REF_TRIPS.child(trip.passengerUid).child("tripCount").setValue(count, withCompletionBlock: completion)
           
       }
    
    
    func updateDriverLocation(location : CLLocation){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
        
    }
    
    func deleteDriverRecord(recordid: String,completion: @escaping(Error?,DatabaseReference) -> Void ){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_DRIVER_RECORD.child(uid).child(recordid).removeValue(completionBlock: completion)
    }
    
    func observeDriverRecord (completion: @escaping([Record]) -> Void){
          guard let uid = Auth.auth().currentUser?.uid else { return }
         print("debug deictionary 123")
         REF_DRIVER_RECORD.child(uid).queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) { (snapshot) in
             var records : [Record] = []
              for child in snapshot.children {
                  let snap = child as! DataSnapshot
                  let placeDict = snap.value as! [String: Any]
                 
                  let id = placeDict["id"] as! String
                  let time = placeDict["time"] as! String
                 let status = placeDict["status"] as! String
                 let timestamps = placeDict["timestamp"] as! Int
                 let recordid = placeDict["recordid"] as! String
                 let record = Record(orderid: id, status: status, time: time, recordid: recordid)
                 records.append(record)
                
              }
             records.reverse()
             completion(records)
         }
     }
}

   //MARK: PassengerService
struct PassengerService {
    static let shared = PassengerService()
    
    func observeDriverRemoved(completion: @escaping(String, [Double]) -> Void){
        REF_DRIVER_LOCATIONS.observe(.childRemoved) { (snapshot) in
               
            guard let dictionary = snapshot.value as? [String: Any] else { return }
             print("debug snapshot \(dictionary)")
            let driverID = snapshot.key
             print("debug snapshot \(driverID)")
            let driverLocation = dictionary["l"] as! [Double]
            completion(driverID,driverLocation)
              }
    }
    func fetchDriver(location: CLLocation, completion: @escaping(User) -> Void){
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geoFire.query(at: location, withRadius: 30).observe(.keyEntered ,with:{ (uid, location) in
                Service.shared.fetchUserData(uid: uid, completion: { (user) in
                    var driver = user
                    driver.userLocation = location
                    
                    completion(driver)
                })
            })
        }
    }
    
    
//    func uploadTrip(_ pickupCoordinates : CLLocationCoordinate2D, _ destinationCoordinates : [CLLocationCoordinate2D?] = [], completion: @escaping (Error?, DatabaseReference) -> Void){
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
////        let destinationArray = [ destinationCoordinates.latitude, destinationCoordinates.longitude]  ////////latest
//        let destinationArray = destinationCoordinates
//        print("debug destinationCoordinates in service \(destinationArray)")
//        let values = ["pickupCoordinates": pickupArray , "destinationCoordinates" : destinationArray,
//                      "state": TripState.requested.rawValue] as [String : Any]
//
//        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
//
//    }
    
    func uploadTrip(_ pickupCoordinates : CLLocationCoordinate2D, _ destinationCoordinates : [CLLocationCoordinate2D], serialNo : [String], destinationName : [String] , latitude : [CLLocationDegrees] , longitude : [CLLocationDegrees] ,completion: @escaping (Error?, DatabaseReference) -> Void){
        
        print("debug error called")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //create random orderID
        let randomNum = Int.random(in: 10000..<19999)
        let orderID = "\(randomNum)"
        print("debug random num \(orderID)")
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        
        
        var values: [String : Any] = [:]
        
 
        values = ["pickupCoordinates": pickupArray ,"state": TripState.requested.rawValue, "tripCount" : latitude.count, "serialNo" : serialNo,  "orderID" : orderID,"destinationName" : destinationName, "latitudeArr": latitude, "longitudeArr" : longitude] as [String : Any]
            
        
 
//
            REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
//
//            print("debug destinationCoordinates in service \(destinationArray)")
//
//
//            REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
            
        
}
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void ){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any ] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
        
        
    }
    
    func deleteRecord(recordid: String,completion: @escaping(Error?,DatabaseReference) -> Void ){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_RECORD.child(uid).child(recordid).removeValue(completionBlock: completion)
    }
    
    func observeRecord (completion: @escaping([Record]) -> Void){
         guard let uid = Auth.auth().currentUser?.uid else { return }
        print("debug deictionary 123")
        REF_RECORD.child(uid).queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            var records : [Record] = []
             for child in snapshot.children {
                 let snap = child as! DataSnapshot
                 let placeDict = snap.value as! [String: Any]
                
                 let id = placeDict["id"] as! String
                 let time = placeDict["time"] as! String
                let status = placeDict["status"] as! String
                let timestamps = placeDict["timestamp"] as! Int
                let recordid = placeDict["recordid"] as! String
                let record = Record(orderid: id, status: status, time: time, recordid: recordid)
                records.append(record)
                 print("debug record \(id)\(time) \(status) \(timestamps)")
             }
            records.reverse()
            completion(records)
        }
    }
    
    func uploadRecord(orderID: String, status : String , completion: @escaping(Error?,DatabaseReference) -> Void){
    
         guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let key = REF_RECORD.childByAutoId().key else { return }
        let serverTIme =  ServerValue.timestamp()
        let time = Service.shared.generateDateandTime()
        let record = ["id" : orderID , "time": time, "status" : status , "timestamp" :  serverTIme, "recordid": key] as [String : Any]
        let childUpdates = ["\(key)" : record]
            REF_RECORD.child(uid).updateChildValues(childUpdates , withCompletionBlock: completion)
    }
    
   
    
    func deleteTrip(completion: @escaping(Error?,DatabaseReference) -> Void ){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func getDriverLocation(uid : String , completion : @escaping(CLLocation) -> Void){
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.getLocationForKey(uid) { (location, err) in
            
            guard let driverLocation = location else { return }
            completion(driverLocation)
        }
    }
    
    
    func fetchOnceDrive(location: CLLocation , completion : @escaping(User) -> Void){
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        REF_DRIVER_LOCATIONS.observeSingleEvent(of: .value) { (snapshot) in
            geoFire.query(at: location, withRadius: 10).observe(.keyEntered ,with:{(uid,location) in
                Service.shared.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.oneTimeLocation = location
                    completion(driver)
                    
                }
            })
        }
    }
    
    
}

struct Service {
    
    static let shared = Service() // create a static instance so that other class can access the function inside without create an instance every time
    
   func generateDateandTime() -> String{
       let date = Date()
       let formatter = DateFormatter()
       formatter.dateFormat = "dd MMM yyy"
       let result = formatter.string(from: date)
       formatter.dateFormat = "hh:mm a"
       let time = formatter.string(from: date)
       let timeNdate = "\(result) | \(time)"
       return timeNdate
   }
    
    func fetchUserData(uid: String ,completion: @escaping(User) -> Void){ // completion block will return user once the api call is finished executing
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            print("debug deictionary \(dictionary)")
            let uid = snapshot.key
            let user = User(uid: uid , dictionary: dictionary) // user will hold the dictionary now
             completion(user)
        }
    }
    
    
    
    
    
    
    
    
    
}
