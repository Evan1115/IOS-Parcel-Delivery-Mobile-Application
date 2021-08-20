//
//  HomeController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 27/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import ARCL
import CoreLocation
import SwiftGraph



private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = " DriverAnnotation"



private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init(){
        self = .showMenu  //initialize itlself as showmenu
    }
}

private enum AnnotationType : String {
    case pickup
    case destination
}

class HomeController : UIViewController {
    
    // MARK: - Properties
    
   
    private let tabBarView = MenuBarView()
    private let driverTabBarView = DriverMenuBar()
    private let mergesort = Mergesort()
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let locationInputActivationView = LocationInputActivationView()
    
   
    private let locationInputView = LocationInputView()
    private let ARNearbyViewController = ARNearbyView()
    private let tableview = UITableView()
    var driverLocation : CLLocationCoordinate2D?
    private var searchResults = [MKPlacemark]() // empty array of mkplacemark
    private final let menuBarViewHeight : CGFloat = 100
    private final let locationInputViewHeight : CGFloat = 250
    private final let rideActionViewHeight : CGFloat = 400 //ori : 300
    private final let tripAcceptedViewHeight : CGFloat = 300
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    private var placemark : CLPlacemark? = nil
    private let rideActionView = RideActiveView()
    private let tripAcceptedView = TripAcceptView()
    private var driverMkmapitemLocation : MKMapItem?
    let vc = FormController()
    private var address : String? = nil
    private var state : TripState?
//    var destinationCoor : [CLLocationCoordinate2D?] = [] latest
    var destinationCoor: CLLocationCoordinate2D?
    var destinationcoor: [MKPlacemark?] = []
    var parcels : [Parcel?] = []
    var placesStruct : [Places?] = [] //contain cllocation, coordinate , distance and placemark
    var destinationCoodinates: [CLLocationCoordinate2D] = []
   
     var groupedRoutes: [(startItem: CLLocationCoordinate2D, endItem: CLLocationCoordinate2D)] = [] //latest
    var distanceRoutes : [(distance: Double,route: MKRoute, location : CLLocationCoordinate2D, polyline : MKPolyline)] = []
   var shortestArray : [Places?] = [] //contain cllocation, coordinate , distANCE, route
    var sortedCoordinates : [CLLocationCoordinate2D] = []
     var dests : [CLLocationCoordinate2D] = []
 
    var arr : [CLLocationCoordinate2D] = []
    var counter : Int = 0
    var tripCount : Int = 0
    private var user : User? {
        didSet{
            locationInputView.user = user
            
            print("debug inside\(user)")
            if user?.accountType == .passenger {
               // showMenuBar()
                fetchDriver()
                print("debug \(user?.accountType)")
                configureLocationInputActivationView()
                ARButton.alpha = 0
               
                observeCurrentTrip()
                //show menu bar
                
               observeDriverRemoved()
                
            } else {
                observeTrip()
              //  showDriverMenuBar()
                
               
//               let switchDemo = UISwitch(frame:CGRect(x: 150, y: 300, width: 0, height: 0))
//               switchDemo.isOn = true
//               switchDemo.setOn(true, animated: false)
//               switchDemo.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
//               self.view!.addSubview(switchDemo)
                
               
            }
        }
    }
    
    private var trip: Trip?{
        didSet{
            
            guard let user = user else { return }
            
            if user.accountType == .driver {
                
            guard let  trip = trip else { return }
             
                  
                    guard let driverCor = locationManager?.location?.coordinate else { return }
                     
                     var rc = Recipient()
                     
                       rc.calculateDistanceBeforeAccepting(recipientLocation: CLLocation(latitude:trip.pickupCoordinates.latitude, longitude: trip.pickupCoordinates.longitude), userLocation: CLLocation(latitude: driverCor.latitude, longitude: driverCor.longitude))
                     
                    print("debug briver : \(rc.distance)")
                     
                     //driver  within 5km  from user will receive the request
                     if( rc.distance < 5.0){
                         let controller = PickupController(trip: trip)
                         self.getPickUpAddress(location: trip.pickupCoordinates) { (place) in
                         controller.source = place
                         }
                         controller.delegate = self
                         controller.modalPresentationStyle = .fullScreen  // present the controller in full screen
                         self.present(controller, animated: true, completion: nil)
                             
                         } else {
                             print("debug: Show ride action view for accept")
                         }
                
            
                }
                
            
        }
            
    }
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "iconmonstr-log-out-9-240").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        
        return button
    }()
   
    
    lazy var ARButton: UIButton = {
        let button = UIButton()
        button.setTitle("AR View", for: .normal)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 6
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(ARViewButton), for: .touchUpInside)
        return button
    }()
    
    lazy var CalculateRoute :UIButton = {
        let button = UIButton()
        button.setTitle("Calculate", for: .normal)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 6
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(CalculateRouteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //signOut()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        
        
        
      
//         var nums = [500,200,100,400]
//        mergesort.quickSort(array: &nums, startIndex: 0, endIndex: nums.count - 1)
//        print("debug merge \(nums)")
      
        
        
    }
    

    override func viewDidLayoutSubviews() {
        
    }
    
    //MARK: -selector
    
    @objc func actionButtonPressed(){
        
        switch actionButtonConfig {
        case .showMenu:
            print("debug show menu")
       
//            let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
//            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
//                self.signOut()
//
//            }))
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//            self.present(alert, animated : true, completion: nil)
           
           
            
            
        case .dismissActionView:
            
           
            removeArray()
            tabBarView.alpha = 1
            print("debug 246 \(self.parcels)")
            removeAnnotationAndOverlay()
            mapView.showAnnotations(mapView.annotations, animated: true) // show all annotation (zoom out effect) 
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                
                self.animateRiderActionView(shouldShow: false)
                self.animateTripAcceptedView(shouldShow: false)
            }
        }
    }

    
    @objc func CalculateRouteButtonTapped(){
        locationInputView.handleConfirmTapped()
    }
    
    // add AR view when button is pressed
    @objc func ARViewButton(){
       
    
        fetchOnceDrivers()
        ARNearbyViewController.delegate = self
        
        view.addSubview(ARNearbyViewController)
        ARNearbyViewController.frame = view.bounds

    }
    
    //MARK: - Menu Bar task
    
    func handleLogout(){
        let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
       alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
           self.signOut()
       }))

       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

       self.present(alert, animated : true, completion: nil)
    }

    
    
    
    //MARK: - Passenger API
    
    func observeDriverRemoved(){
        PassengerService.shared.observeDriverRemoved { (driverid, location) in
            print("debug called function")
            
            self.mapView.annotations.forEach { (annotation) in
                guard let driverAnno = annotation as? DriverAnnotation else { return }
                
                if driverAnno.uid == driverid {
                    print("debug called function 12")
                    self.mapView.removeAnnotation(annotation)
                    
                }
            }
            
        }
    }

    func observeCurrentTrip(){
        PassengerService.shared.observeCurrentTrip { (trip) in
            self.trip = trip
           guard let orderid = trip.orderID else { return }
         
            guard let state = trip.state else { return }
            guard let driveruid = trip.driverUid else { return }
            
            switch state{
                
            case .requested:
                break
            case .denied:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops", message: "It looks like we couldn't not find you driver. Please try again..")
                 self.removeAnnotationAndOverlay()
                PassengerService.shared.deleteTrip { (err, ref) in
                  
                    self.tabBarView.alpha = 1 //present tab bar
                    self.animateTripAcceptedView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.locationInputActivationView.alpha = 1
                    self.removeArray()
                }
            case .accepted:
                self.actionButton.alpha = 0
                self.shouldPresentLoadingView(false)
                self.removeAnnotationAndOverlay()
                self.zoomforActiveTrip(withDriverUid: driveruid)
                
                Service.shared.fetchUserData(uid: driveruid) { (driver) in
                    
                    self.animateTripAcceptedView(shouldShow: true,   config: .tripAccepted, user: driver)
                   
                  
                    PassengerService.shared.getDriverLocation(uid: driveruid) { (driverlocation) in
                        
                        let placemark1 = MKPlacemark(coordinate : driverlocation.coordinate)
                        let source = MKMapItem(placemark: placemark1)
                        
                        let destination = MKMapItem.forCurrentLocation()
                       
                        self.generatePolyLineUserSide(source: source, destination: destination)
        
                       }
                }
            case .driverArrived:
                self.tripAcceptedView.config = .driverArrived
                print("debug arrive")
            case .inProgress:
                self.mapView.showsUserLocation = false
                self.tripAcceptedView.config = .tripInProgress
                
                
                self.removeAnnotationAndOverlay()
                print("debug tripcount\(self.tripCount)")
                
                if self.tripCount > 0{
                    guard let serialNo = trip.serialNo[self.tripCount - 1] else { return }
                    self.presentAlertController(withTitle:"Order ID:#\(orderid)", message:"\(serialNo) is delivered.")
                }
//                self.removeAnnotationAndOverlay()
                PassengerService.shared.getDriverLocation(uid: driveruid) { (driverlocation) in
//
//                    for destination in trip.destinationCoordinates{ //latest
//                                       guard let dest = destination else { return}  //latest
//
//                                        let placemark1 = MKPlacemark(coordinate : driverlocation.coordinate) //latest
//                                        let source = MKMapItem(placemark: placemark1) //latest
//
//
//                                        let placemark2 = MKPlacemark(coordinate : dest) //latest
//                                        let destination = MKMapItem(placemark: placemark2) //latest
//                                        self.mapView.addAnnotationAndSelect(coordinate: dest) //latest
//
//                                        self.generatePolyLineUserSide(source: source, destination: destination) //latest
//                                   }
                     let driverCoordinate = driverlocation.coordinate
                     let destinationCoordinate = trip.courierCenterCoordinates[self.tripCount]
//
                    let placemark1 = MKPlacemark(coordinate : driverCoordinate)
                    let source = MKMapItem(placemark: placemark1)

                   
                    let placemark2 = MKPlacemark(coordinate : destinationCoordinate)
                    let destination = MKMapItem(placemark: placemark2)
                    
                    
                    
                   
                   
                    
                self.mapView.addAnnotationAndSelect(coordinate: destinationCoordinate)
                     
                 self.generatePolyLineUserSide(source: source, destination: destination)
                    
                    //zoom fit to the driverlocation and destination
                    let anno1 = MKPointAnnotation()
                    anno1.coordinate = destinationCoordinate
                    let anno2 = MKPointAnnotation()
                   anno2.coordinate = driverCoordinate
                   var totalAnno : [MKAnnotation] = []
                   totalAnno.append(anno1)
                   totalAnno.append(anno2)
                   self.mapView.zoomToFit(annotation: totalAnno)
                   
                 self.tripCount += 1
//                    if trip.destinationCoordinates2 != nil {
//                        print("debug not null")
//                        let placemark3 = MKPlacemark(coordinate: trip.destinationCoordinates2)
//                        let destination2 = MKMapItem(placemark: placemark3)
//                        self.mapView.addAnnotationAndSelect(coordinate: trip.destinationCoordinates2)
//                        self.generatePolyLineUserSide(source: destination, destination: destination2)
//                    }
                   }
                
            case .arriveAtDestination:
                self.tripAcceptedView.config = .endTrip
            case .completed:
                
                self.mapView.showsUserLocation = true
               
                self.removeAnnotationAndOverlay()
                guard let serialNo = trip.serialNo[self.tripCount - 1] else { return }
                                   self.presentAlertController(withTitle:"Order ID:#\(orderid)", message:"\(serialNo) is delivered. we hope you enjoy our service")
                PassengerService.shared.deleteTrip { (err, ref) in
                    PassengerService.shared.uploadRecord(orderID: trip.orderID!, status: "Completed") { (err, ref) in
                        
                    }
                    self.tabBarView.alpha = 1 //present tab bar
                    self.animateTripAcceptedView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.locationInputActivationView.alpha = 1
                    
                    print("debug trip count complete \(self.tripCount)")
                    
//
                    self.removeArray()
                     self.tripCount = 0
                }
            }// self.animateRiderActionView(shouldShow: true,   config: .tripAccepted)
            }
            
        }
    
    
    func startTrip(){
        print("debug error called - starttrip 1")
        guard let trip = self.trip else { return }
        removeCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
            DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (err, ref) in
                 print("debug error called - starttrip 2")
                
                self.state = .inProgress
                guard let serialNo = trip.serialNo[self.tripCount] else { return }
                guard let location = trip.destinationName[self.tripCount]?.split(separator: ",") else { return }
                self.tripAcceptedView.addressLabel.text =  String(location[0])
                 self.tripAcceptedView.serialLabel.text = serialNo
                self.tripAcceptedView.config = .tripInProgress
                self.removeAnnotationAndOverlay()
                
//                for destination in trip.destinationCoordinates{ //latest
//                    guard let destination = destination else { return}  //latest
//                    self.mapView.addAnnotationAndSelect(coordinate: destination)  //latest
//
//                    let placemark = MKPlacemark(coordinate : destination)  //latest
//                    let mapItem = MKMapItem(placemark: placemark)  //latest
//
//                    self.setCustomRegion(withType: .destination, coordinates: destination) //latest
//                    self.generatePolyLine(toDestination: mapItem) //latest
//
//                    self.mapView.zoomToFit(annotation: self.mapView.annotations) //latest
//                }
                self.mapView.addAnnotationAndSelect(coordinate: trip.courierCenterCoordinates[self.tripCount])

                let placemark = MKPlacemark(coordinate : trip.courierCenterCoordinates[self.tripCount])
                let mapItem = MKMapItem(placemark: placemark)
                
                 print("debug counter \(self.tripCount)")

//                if self.counter == 1{
                    let placemark2 = MKPlacemark(coordinate : trip.courierCenterCoordinates[self.tripCount])
                   let mapItem2 = MKMapItem(placemark: placemark2)
                    self.setCustomRegion(withType: .destination, coordinates: trip.courierCenterCoordinates[self.tripCount])
                    self.mapView.addAnnotationAndSelect(coordinate: trip.courierCenterCoordinates[self.tripCount])
                     self.generatePolyLine(toDestination: mapItem2)
//                }else {
//                    print("debug start trip 1")
//                    self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
//                    self.generatePolyLine(toDestination: mapItem)
//                }
//                self.setCustomRegion(withType: .destination, coordinates: trip.destinationCoordinates)
//                self.generatePolyLine(toDestination: mapItem)

               self.mapView.zoomToFit(annotation: self.mapView.annotations)
                
            
        }
    
            
        
       
    }
    
    func removeDriver(){
        
    }
    
    
    func fetchDriver(){
   
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDriver(location: location) { (driver) in
          
            guard let coordinates = driver.userLocation?.coordinate else { return}
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinates)
            self.driverLocation = coordinates
            
            var driverIsVisible : Bool {
                return self.mapView.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                   
                    if driverAnno.uid == driver.uid {
                      driverAnno.updateAnnotationPosition(withCoordinate: coordinates)
                        self.zoomforActiveTrip(withDriverUid: driver.uid)
                        return true
                    }
                     return false
                }
            }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
    
               }
        }
    }
    
    //fetch driver location once within 50 radius
    func fetchOnceDrivers(){
          guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchOnceDrive(location: location) { (driver) in
            
            guard let coordinates = driver.oneTimeLocation?.coordinate else { return}
           
            self.ARNearbyViewController.addAnnotationToAR(coordinate: coordinates, uid: driver.uid)
        }
    }
    
    // MARK: - Driver API
    
    func observeTrip(){
        
        DriverService.shared.observeTrips { (trip) in
            print("debug error called - observe trip")
            self.trip = trip
            print("debug driver side \(trip.orderID)")
           
        }
        
    }
    
    // check if there is other driver accept the trip
    func observeTripAccepted(trip : Trip){
        guard let passengerUid = trip.passengerUid else { return }
        DriverService.shared.observeTripAccepted(passengerUid: passengerUid) { (trip) in
            print("driver uid is \(trip.driverUid)")
        }
        
            
    }
    
    func observeCancelledTrip(trip : Trip){
      
        
        DriverService.shared.observeTripCancelled(trip: trip) {
            self.driverTabBarView.alpha = 1
            DriverService.shared.uploadDriverRecord(orderID: trip.orderID!, status: "Cancelled") { (err, ref) in
                               print("debug success upload")
            }
            
            self.tripAcceptedView.addressLabel.text = ""
             self.tripAcceptedView.serialLabel.text = ""
            self.removeAnnotationAndOverlay()
            self.animateTripAcceptedView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops!", message: "The user has cancelled this trip. Press OK to continue.")
            self.tripCount = 0
            
        }
    }
    
    // MARK: - Shared API
    func fetchUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData (uid: currentUid){ user in
            self.user = user
            print("debug : account type  \(user.accountType)")
            
           
        }
    }
    
    func checkIfUserIsLoggedIn(){
        
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                       let nav = UINavigationController(rootViewController: LoginController())
                       if #available(iOS 13.0, *) {
                           nav.isModalInPresentation = true
                       
                       }
             
                       nav.modalPresentationStyle = .fullScreen
                       self.present(nav, animated: true, completion: nil)
                   }
            print("DEBUG: user not log in")
            
        }else {
           
            self.navigationController?.isNavigationBarHidden = false
            print("debug 123")
            configure()
        
        }
        
        
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                                let nav = UINavigationController(rootViewController: LoginController())
                                if #available(iOS 13.0, *) {
                                    nav.isModalInPresentation = true
                                }
                                nav.modalPresentationStyle = .fullScreen
                                self.present(nav, animated: true, completion: nil)
                            }
        }catch{
            print("user error signing out...")
        }
    }
    
    //MARK: - helper function
    
    func addAnnoToAR(coordinate: CLLocationCoordinate2D, uid: String){
        ARNearbyViewController.addAnnotationToAR(coordinate: coordinate, uid: uid)
    }
    
    func configure(){
       configureTabBar()
        configureUI()
        fetchUserData()
        
    }
    
    
    
   fileprivate func configureActionButton(config: ActionButtonConfiguration){
        switch config {
        case .showMenu:
        actionButton.alpha = 0
       
        case .dismissActionView:
             actionButton.alpha = 1
        actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        actionButtonConfig = .dismissActionView
        }
    }

    
    func configureTabBar(){
        //display bar for both driver and passenger
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Service.shared.fetchUserData (uid: currentUid){ user in
            if user.accountType == .passenger {
                self.showMenuBar()
            } else {
                self.showDriverMenuBar()
            }
                  
        }
    }
    
    func configureARButton(){
    view.addSubview(ARButton)
    ARButton.anchor(bottom: view.bottomAnchor, paddingBottom: 50, width: 150, height: 50)
    ARButton.centerX(inView: view)
        ARButton.alpha = 0
       
    }
    
    
    func configureCalculateButton(){
        view.addSubview(CalculateRoute)
        CalculateRoute.anchor(bottom: view.bottomAnchor, paddingBottom: 50, width: 200, height: 50)
        CalculateRoute.centerX(inView: view)
        CalculateRoute.alpha = 0
    }
    
   
    //home view
    func configureUI(){
        
       
        
        configureMapView()
       
        
       
        configureARButton() // AR VIew button
        configureRideActionView()
        configureTripAcceptedView()
        configureCalculateButton()
        rideActionView.delegate = self
        
       
        
        //menu bar delegate
        tabBarView.delegate = self
        
        //driver menu bar delegate
        driverTabBarView.delegate = self
        
    
        view.addSubview(actionButton)
        actionButton.alpha = 0
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor, paddingTop:  16, paddingLeft: 20, width: 30 , height: 30)
        
        let tabBar = UITabBarController()
 
        tabBar.setViewControllers([vc], animated: false)
        present(tabBar,animated: true)
        
        
        //configureTableView()

    }
    
    func configureLocationInputActivationView(){
        view.addSubview(locationInputActivationView)
        locationInputActivationView.centerX(inView: view)
        locationInputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        locationInputActivationView.alpha = 0
        
        // use the protocol
        locationInputActivationView.delegate = self
        
        UIView.animate(withDuration: 2){

            self.locationInputActivationView.alpha = 1
        }
    }
    
    func configureMapView(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate =  self
    }
    
    func showMenuBar(){
        view.addSubview(tabBarView)
    
        tabBarView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 80)
        tabBarView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,blue: 0/255.0, alpha: 1.0).cgColor
        tabBarView.layer.shadowOffset = CGSize(width: 0, height: -0.2)
        tabBarView.layer.shadowOpacity = 0.1
        tabBarView.layer.shadowRadius = 5
    }
    
    func showDriverMenuBar(){
        view.addSubview(driverTabBarView)
               driverTabBarView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 80)
        driverTabBarView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,blue: 0/255.0, alpha: 1.0).cgColor
        driverTabBarView.layer.shadowOffset = CGSize(width: 0, height: -0.2)
        driverTabBarView.layer.shadowOpacity = 0.1
        driverTabBarView.layer.shadowRadius = 5
    }
    
    // show the location input view after tap on the "where to " bar
    func configureLocationInputView (){
        view.addSubview(locationInputView)

        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor ,right: view.rightAnchor,height: locationInputViewHeight)
        
        //animation for back button
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.CalculateRoute.alpha = 1
            self.locationInputView.alpha = 1   // it takes 1 seconds for input view to show up
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                //animate the table view
                self.tableview.frame.origin.y = self.locationInputViewHeight
            }
        }
        
        //use protocol
        locationInputView.delegate = self
        
    }
    
    
    
    func configureTripAcceptedView(){
        view.addSubview(tripAcceptedView)
        tripAcceptedView.delegate = self
        tripAcceptedView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: rideActionViewHeight)
    }
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        vc.delegate = self
        rideActionView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: rideActionViewHeight)
    }
    
    
    //tableview
//    func configureTableView(){
//        tableview.delegate = self
//        tableview.dataSource = self
//        tableview.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
//        tableview.rowHeight = 60
//        tableview.tableFooterView = UIView()
//        tableview.backgroundColor = UIColor.white
//
//
//        let height = view.frame.height - locationInputViewHeight
//        tableview.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: height)
//        view.addSubview(tableview)
//    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil){

            UIView.animate(withDuration: 0.3, animations: {
                self.CalculateRoute.alpha = 0
                 self.locationInputView.alpha = 0 // it takes 0.3 sec for input view to dismiss
                self.tableview.frame.origin.y = self.view.frame.height  // dismiss the table view
                self.locationInputView.removeFromSuperview()
                          
            }, completion: completion)
        }
    
    func animateTripAcceptedView(shouldShow : Bool, config : TripAcceptedViewConfiguration? = nil, user: User? = nil ){
         
        let yOrigin = shouldShow ? self.view.frame.height - self.tripAcceptedViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.tripAcceptedView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let user = user {
            tripAcceptedView.user = user
            }
            
            tripAcceptedView.config = config
            
        }
    }
    
    func animateRiderActionView(shouldShow : Bool, destination: [Places?] = [], source : CLPlacemark? = nil) {
      
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
         self.rideActionView.frame.origin.y = yOrigin
        
        }
        
        if shouldShow {
            
           // guard let config = config else { return }
           // rideActionView.configureUI(withConfig: config)
            
           
//            rideActionView.destination = destinations[0] //latest
//            for destination in destinations { //latest
//                guard let destination = destination else { return } //latest
//                destinationCoor.append(destination.coordinate) //latest
//            }
            
           // guard let destination = destination else { return }
            
      //      destinationCoor = destination.coordinate
            rideActionView.destination = destination
            
            rideActionView.reloadTableView()
            
            guard let source = source else { return }
            rideActionView.source = source
            
            
            rideActionView.calculateTotalDistance() // calculate and update at rideactiveview
            rideActionView.calculateTotalTime() // calculate and update at rideactiveview
            
            
        }
        
        
    }
    func getPickUpAddress(location : CLLocationCoordinate2D, completion : @escaping ((CLPlacemark) -> Void)){
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { (places, error) in
            if let _ = error{
                return
            }
            guard let place = places?.first else { return}
            self.placemark = place
            completion(place)
        }
    }
    
    func getUserCurrentAddress(location: CLLocation, completion : @escaping((CLPlacemark) -> Void))  {
        
        let address = CLGeocoder.init()
       
        
        
        address.reverseGeocodeLocation(CLLocation.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { (places, error) in
            if  let _ = error {
                return
            }

            
            guard let place = places?.first else { return}
            self.placemark = place
            completion(place)
            }
    }
      
       
}

 //MARK: - Map Helper Functions
private extension HomeController{
    
    func generateShortestPolyline3(destinationcoor : CLLocationCoordinate2D, completion : @escaping(MKRoute) -> Void){
        let destinationPlacemark = MKPlacemark(coordinate: destinationcoor)
        let destination = MKMapItem(placemark: destinationPlacemark)
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return }
            var unsortedRouted = response.routes
            unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
            
            self.route = unsortedRouted[0]
            print("debug route short \(self.route?.distance)")
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
            
            completion(unsortedRouted[0])
        }
    }
    
    func generateShortestPolylineAndRoute(toDestination1 destination: MKMapItem, completion: @escaping(MKRoute) -> Void){
        
        let request = MKDirections.Request()
                  request.source = MKMapItem.forCurrentLocation()
                  request.destination = destination
                  request.transportType = .automobile
                  
                  let directionRequest = MKDirections(request: request)
                  directionRequest.calculate { (response, error) in
                      guard let response = response else {return }
                      var unsortedRouted = response.routes
                    
           
                      unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
               
                             
             
               
                    
                      self.route = unsortedRouted[0]
                     print("debug route short \(self.route?.distance)")
                      guard let polyline = self.route?.polyline else { return }
                      self.mapView.addOverlay(polyline)
                    
                    guard let route = self.route else { return }
                       completion(route)
                  }
       
    }
    
    func generateShortestPolyLine1(toDestination1 destination: MKMapItem){
           let request = MKDirections.Request()
             request.source = MKMapItem.forCurrentLocation()
             request.destination = destination
             request.transportType = .automobile
             
             let directionRequest = MKDirections(request: request)
             directionRequest.calculate { (response, error) in
                 guard let response = response else {return }
                 var unsortedRouted = response.routes
                 unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
             
                 self.route = unsortedRouted[0]
                print("debug route short \(self.route?.distance)")
                 guard let polyline = self.route?.polyline else { return }
                 self.mapView.addOverlay(polyline)
                 
             }
    }
    func generateShortestPolyline2(source: MKMapItem, destination : MKMapItem){
    
        ///
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        
        directionRequest.calculate { (response, error) in
            guard let response = response else {return }
            var unsortedRouted = response.routes
            unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
            let shortestRoute : MKRoute = unsortedRouted[0]
            
             self.route = unsortedRouted[0]
               
                   guard let polyline = self.route?.polyline else { return }
                   self.mapView.addOverlay(polyline)
            
        }
    }
    
  
    
    func searchBy(naturalLanguageQuery: String, completion : @escaping([MKPlacemark]) -> Void){
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            response.mapItems.forEach ({ item in
                results.append(item.placemark)
              print("debug nearest \(item.placemark.coordinate)")  
                
                
               
            })
            completion(results)
        }
        
    }
    
    func generateline(route : MKRoute){
        self.mapView.addOverlay(route.polyline)
    }
    
    func generatePolyLineUserSide(source: MKMapItem, destination : MKMapItem){
         
         let request = MKDirections.Request()
         request.source = source
         request.destination = destination
         request.transportType = .automobile
                
         let directionRequest = MKDirections(request: request)
         
        directionRequest.calculate { (response, error) in
         guard let response = response else {return }
        var unsortedRouted = response.routes
        unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
                    
        self.route = unsortedRouted[0]
            
         guard let polyline = self.route?.polyline else { return }
         self.mapView.addOverlay(polyline)
        }
    }
    
    func generatePolyLine(toDestination destination: MKMapItem){
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
            
        }
    }
    
    func removeArray(){
        self.destinationcoor.removeAll() //remove the coordinate (latest)
        self.placesStruct.removeAll() //being used
        self.parcels.removeAll() //being used in form
        self.shortestArray.removeAll() //being used
        self.sortedCoordinates.removeAll()//being used to store sorted coordinates
        
        self.distanceRoutes.removeAll()
        self.arr.removeAll()
        self.groupedRoutes.removeAll()
        print("debug remove helo")
    }
    
    func removeAnnotationAndOverlay(){
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {  // loop thro all the annotation on the map and find the anno which is a MKpointAnnotation and remove it
                mapView.removeAnnotation(annotation)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
     
        let overlays = mapView.overlays
        for overlay in overlays{
            mapView.removeOverlay(overlay)
        }
        
    }
    
    func centerMapOnUserLocation(){
        print("debug centerMap")
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnDriverLocation(location : CLLocationCoordinate2D){
        print("debug centerMap")
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type : AnnotationType ,coordinates : CLLocationCoordinate2D){
       
        let region = CLCircularRegion(center: coordinates, radius: 30, identifier:  type.rawValue)
            locationManager?.startMonitoring(for: region)
      
       
    }
    
    func removeCustomRegion(withType type : AnnotationType ,coordinates : CLLocationCoordinate2D){
        let region = CLCircularRegion(center: coordinates, radius: 30, identifier:  type.rawValue)
                  locationManager?.stopMonitoring(for: region)
        
    }
    func zoomForDriver(withDriverUid driveruid : String){
        var annotations = [MKAnnotation]()
               
               self.mapView.annotations.forEach { (annotation) in
                   if let anno = annotation as? DriverAnnotation {
                       if anno.uid == driveruid {
                           annotations.append(anno)
                       }
                   }
                
                 self.mapView.zoomToFit(annotation: annotations)
        }
    }
        
    func zoomforActiveTrip(withDriverUid driveruid : String){
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == driveruid {
                    annotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        
        self.mapView.zoomToFit(annotation: annotations)
    }
}


  //MARK: - MKMapviewDelegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("debug didupdate location")
        centerMapOnUserLocation()
        guard let user = self.user else { return }
        guard user.accountType == .driver  else { return }
        guard let location = userLocation.location else{ return }
        
        DriverService.shared.updateDriverLocation(location: location)
       
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation{
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
          
            view.image = #imageLiteral(resourceName: "anno")
            
            view.setDimension(height: 30, width: 30)
           
            return view
        }
        
        return nil
    }
    
    //handle touch event on map
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let eventAnnotation = view.annotation as? DriverAnnotation {
            let TouchedAnnoationDriverUid = eventAnnotation.uid //touched anno driver uid
            let location = locationManager?.location //current user  location
            
            //calculate distane
            let loc1 = CLLocation(latitude: (location!.coordinate.latitude), longitude: (location!.coordinate.longitude))
            let loc2 = CLLocation(latitude: (eventAnnotation.coordinate.latitude), longitude: (eventAnnotation.coordinate.longitude))
            let distance = loc1.distance(from: loc2)
            let kilometer = distance / 1000
             print("debug: distance is \(String(format: "%.2f", kilometer)) KM")
            
            print("debug: touched anno driver uid is \(TouchedAnnoationDriverUid)") //the driver id on touched annotation

           
            Service.shared.fetchUserData (uid: TouchedAnnoationDriverUid){ user in
                let driver = user
                print("Debug :\(driver.fullname)") // the driver name on touched annotation
                
            }
              
           }
        
    }
    
    //show polyline on map when destination is chosen
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline =  route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .lightBlue
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

   // MARK: - LocationServices
extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue{
            print("debug start monitoring pickup region\(region)")
        }
        
      
        if region.identifier == AnnotationType.destination.rawValue{
            print("debug start monitoring destination region\(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        guard let trip = self.trip else { return } // overwrite
        
        print("debug error called - locationManager")
        print("debug monitor trip \(trip)")
        
     
        if region.identifier == AnnotationType.pickup.rawValue{
            print("debug enter pick up")
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (err, ref) in
                self.tripAcceptedView.config = .pickupPassenger
            }
            
        }
        
        if region.identifier == AnnotationType.destination.rawValue{
            print("debug enter destination \(region) ")
            DriverService.shared.updateTripState(trip: trip, state: .arriveAtDestination) { (err, ref) in
                self.tripAcceptedView.config = .endTrip
            }
            
        }
        
        
        
        
        
        
    }
    
    func enableLocationServices (){
        
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus(){
            
        case .notDetermined:
            print("DEBUG: Not determine..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        
        case .authorizedAlways:
             print("DEBUG: Auth always..")
             locationManager?.startUpdatingLocation()
             locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
             print("DEBUG: Auth when in use..")
             locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
}

//  MARK: -protocol
extension HomeController: ShowFormViewDelegate {
    func uploadTriptoFirebase() {
         guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
              //  guard let destinationCoordinates = destinationCoor else { return } //latest
              
        //               print("debug arr location \(self.arr)")
        //        for destination in destinationcoor{
        //            self.destinationCoodinates.append(destination!.coordinate)
        //        }
                var serialNo : [String] = []
                var destinationName : [String] = []
        print("debug arr location \(self.sortedCoordinates) ")
        var latitudeArr : [CLLocationDegrees] = []
        var longitudeArr : [CLLocationDegrees] = []
                
                //put serialNo into array
                shortestArray.forEach { (arr) in
                    guard let serialNum = arr?.serialNo else { return }
                    guard let destName = arr?.placemark?.description.split(separator: "@") else { return }
                    
                    guard let latitude = arr?.coordinate.latitude else { return}
                    guard let longitude = arr?.coordinate.longitude else { return }
                    
                    latitudeArr.append(latitude)
                    longitudeArr.append(longitude)
                    serialNo.append(serialNum)
                    destinationName.append(String(destName[0]))
                }
        print("debug lat long \(latitudeArr) and \(longitudeArr)")
                shouldPresentLoadingView(true, message: "Finding a ride...")
                
        PassengerService.shared.uploadTrip(pickupCoordinates, self.sortedCoordinates, serialNo: serialNo, destinationName: destinationName, latitude: latitudeArr, longitude: longitudeArr ) { (err, ref) in //latest
                    if let error = err {
                        print (" debug upload failed \(error)")
                    }


                    UIView.animate(withDuration: 0.3) {

                        self.rideActionView.frame.origin.y = self.view.frame.height
                       // self.rideActionView.setViewToInvisible()
                    }
                }
    }
    
    func showFormViewController() {
        print("debug showform delegate")
   self.present(vc, animated: true, completion: nil)
        
    }
    
    
    
    
}
extension HomeController: ARNearbyViewDelegate {
    func presentHomeView() {
       // return to HomeScreen
      
        ARNearbyViewController.removeNode() // remove the node on AR when back to homescreen
        
        //self.updateDriverLocation = false
    
//        guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return }
//        
//        controller.configureUI()
//        controller.configureLocationInputActivationView()
//      
//        ARButton.alpha = 1
        
        ARNearbyViewController.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
        
        
    }
}

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputview() {
        
        locationInputActivationView.alpha = 0 // dismiss the "where to" bar
        tabBarView.alpha = 0 //dismiss tab bar
        
       // configureLocationInputView()   // show location input view
        
        //present order table view
         guard let userCoordinate = self.locationManager?.location?.coordinate else { return }
        getPickUpAddress(location: userCoordinate) { (placemark) in
            print("debug address \(placemark.description)")
//            guard let lorong = placemark.thoroughfare else { return }
//            guard let city = placemark.locality else { return }
            let userAdd = placemark.description.split(separator: "@")
            let orderVC = OrderController(userAddress: String(userAdd[0]))
           let nav = UINavigationController(rootViewController: orderVC)
           nav.isModalInPresentation = true
           nav.modalPresentationStyle = .fullScreen
           self.present(nav, animated: true, completion: nil)
        }
       
        
        
    }
}

extension HomeController: LocationInputViewDelegate {
   
    func alertMessageForDestinationLessThanOne(){
        presentAlertController(withTitle: "Incomplete Details", message: "Please input at least one delivery point")
    }
    
//    func findNearestPlace(query : [String], completion : @escaping([Places?]) -> Void){
//        let q = query.removeFirst()
//        completion(placesStruct)
//    }
//
    //Alert Form to get serial number and courier center from user
    func form(int : Int){
          let alertController = UIAlertController(title: "Add New Parcel", message: "", preferredStyle: UIAlertController.Style.alert)
       
          alertController.addTextField { (textField : UITextField!) -> Void in
                 textField.placeholder = "Parcel Serial No"
             }
        
          let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                 let firstTextField = alertController.textFields![0] as UITextField
                 let secondTextField = alertController.textFields![1] as UITextField
           
            self.executeSearchQuery2(query: secondTextField.text!) { (result) in
                //remove the old item in array if there is two duplicate
//                 self.parcels.forEach { (parcel) in
//                     if(parcel?.id == int){
//                         self.parcels.remove(at: int)
//
//                        //new
//                        self.placesStruct.remove(at: int)
//                     }
//                 }
                
               let isExisted =  self.parcels.contains { (parcel) -> Bool in
                    parcel?.id == int
                }
                
                if isExisted {
                    self.parcels.remove(at: int)
                    
                    //new
                    self.placesStruct.remove(at: int)
                }
              
                 
                  //add new item into the array
                 let parcel = Parcel(serialNo: firstTextField.text!, courierCenter: secondTextField.text!, id: int)
                 self.parcels.insert(parcel, at: int)
                
                //new
                self.placesStruct.insert(result, at: int)
                guard let serialNo = firstTextField.text else { return }
                self.placesStruct[int]?.serialNo = serialNo
                
                self.locationInputView.texts = self.parcels
                 
                 print("debug title \(self.parcels)")
                 print("debug title \(self.placesStruct)")
                 
                 //display the text to the textbox
                let address = result.placemark!.description.split(separator: "@")
                print("debug address \(address[0])")
                self.locationInputView.modifyText(integer: int, text: String(address[0]))
                 
            }
           
                 
             })
          let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                 (action : UIAlertAction!) -> Void in })
          alertController.addTextField { (textField : UITextField!) -> Void in
                 textField.placeholder = "Courier Center"
             }
             
             alertController.addAction(saveAction)
             alertController.addAction(cancelAction)
             
          self.present(alertController, animated: true, completion: nil)
      }
    
    func executeSearchQuery2(query: String , completion: @escaping(Places) -> Void){
        searchBy(naturalLanguageQuery: query) { (results) in
             //get current user location
            guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
             let sourceClllocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
             
             //old variable
             self.searchResults = results
             
             //declare a array of struct
             var places:[Places] = [] //does not contain route
                 
             //loop thro the results to append the new Place struct into the array
             results.forEach { (result) in //new function
                 
                 let destinationCoordinate = result.coordinate
                
                 let cllocation = CLLocation(latitude : result.coordinate.latitude , longitude: result.coordinate.longitude)
                 
                 //calculate the distance from the place to user current location
                 let distance =  cllocation.distance(from: sourceClllocation)
                 
                 places.append( Places(cllocation: cllocation, distance: distance, coordinate: destinationCoordinate, placemark: result))
                 
             }
             //before sort
             places.forEach { place in
                 print("debug place \(place.distance ?? 0)")
             }
             
             //sorting progress
        //    places.sort(by: {$0.distance < $1.distance}) old
             self.mergesort.quickSort(array: &places, startIndex: 0, endIndex: places.count - 1) //new method
             
             //after sort
             places.forEach { place in
                 print("debug placeafter \(place.distance ?? 0)")
             }
            
             //append into new array
          //   self.placesStruct.append(places[0])
             print("debug placesstruct \(self.placesStruct)")
             
            guard let placemark = places[0].placemark else { return }
            completion(places[0])
            
         }
    }
    
    func executeSearchQuery(query: [String]) {
        guard !query.isEmpty else {
            print("debug execute \(query)")
            confirmLocationView()
            return
        }
        
       var q = query
        //then pass in to another function to process thius query
       
        let parameter = q.removeFirst()
       
        searchBy(naturalLanguageQuery: parameter) { (results) in
            //get current user location
           guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
            let sourceClllocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
            
            //old variable
            self.searchResults = results
            
            //declare a array of struct
            var places:[Places] = [] //does not contain route
                
            //loop thro the results to append the new Place struct into the array
            results.forEach { (result) in //new function
                
                let destinationCoordinate = result.coordinate
               
                let cllocation = CLLocation(latitude : result.coordinate.latitude , longitude: result.coordinate.longitude)
                
                //calculate the distance from the place to user current location
                let distance =  cllocation.distance(from: sourceClllocation)
                
                places.append( Places(cllocation: cllocation, distance: distance, coordinate: destinationCoordinate, placemark: result))
                
            }
            //before sort
            places.forEach { place in
                print("debug place \(place.distance ?? 0)")
            }
            
            //sorting progress
       //    places.sort(by: {$0.distance < $1.distance}) old
            self.mergesort.quickSort(array: &places, startIndex: 0, endIndex: places.count - 1) //new method
            
            //after sort
            places.forEach { place in
                print("debug placeafter \(place.distance ?? 0)")
            }
           
            //append into new array
            self.placesStruct.append(places[0])
            print("debug placesstruct \(self.placesStruct)")
            
            //old funciton
            self.tableview.reloadData()
            self.executeSearchQuery(query: q)
        }
      
        
    }
    
    func dismissLocationInputView() {
        dismissLocationView { _ in
             UIView.animate(withDuration: 0.3) {
            self.locationInputActivationView.alpha = 1 //takes 0.3 seconds for activation view to show up
            self.destinationcoor.removeAll() //remove the coordinate (latest)
            self.distanceRoutes.removeAll()
            self.arr.removeAll()
            self.groupedRoutes.removeAll()
                print("debug 123 hello")
            self.tabBarView.alpha = 1
                
                self.removeArray()
           }
        }
    }
    
    func getShortesRoute(sourceCoordinate : CLLocationCoordinate2D,destinationCoordinates : [CLLocationCoordinate2D], completion: @escaping([Places]) -> Void){
            var tempArray : [Places] = []
           var counter = 0
          
            destinationCoordinates.forEach({ (destinationCoordinate) in
           
                 let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
                 let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
                 let source = MKMapItem ( placemark: sourcePlacemark)
                 let destination = MKMapItem ( placemark: destinationPlacemark)
                  
                  let request = MKDirections.Request()
                  request.source = source
                  request.destination = destination
                  request.transportType = .automobile
                         
                  let directionRequest = MKDirections(request: request)
                  
                 directionRequest.calculate { (response, error) in
                  guard let response = response else {return }
                 var unsortedRouted = response.routes
                 unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
                 
                    
                let route = unsortedRouted[0]
                 
                    
                let cllocation = CLLocation(latitude : destinationCoordinate.latitude , longitude: destinationCoordinate.longitude)
                let distance = route.distance
                              
                  //append to the temporary Array
                    tempArray.append(Places(cllocation: cllocation, distance: distance, coordinate: destinationCoordinate, route: route))
                    
               print("debug helo temp in function \(counter) and \(tempArray)")
    //              guard let polyline = self.route?.polyline else { return }
    //              self.mapView.addOverlay(polyline)
                   if counter == destinationCoordinates.count - 1{
                   
                    print("debug helo temp in function \(counter) and \(tempArray)")
                    completion(tempArray)
                   }
                    counter += 1
               }
                
        })
            
    }
    
    func findShortest(destinationCoordinates : [CLLocationCoordinate2D]){
        print("debug helo \(dests)")
        
        var tempArray : [Places] = [] //does not contain placemark
        let sourceCoordinate : CLLocationCoordinate2D
        let sourceCllocation : CLLocation
        
        var destination = destinationCoordinates
        
        //if the dests array left one element then run below
        guard destination.count != 1 else {
            
            //get the last element in the shortestArray
            let coor = shortestArray[shortestArray.count - 1]
            guard let coordinate = coor?.coordinate else { return }
            
            sourceCllocation = CLLocation(latitude : coordinate.latitude , longitude: coordinate.longitude)
            
            
            getShortesRoute(sourceCoordinate: coordinate, destinationCoordinates: destination) { (array) in
                
                //remove the last element in dest array
                destination.removeFirst()
                //append to the shortest Array
                
                self.shortestArray.append(array[0])
                
                //loop thro the array
                for(index ,place) in self.shortestArray.enumerated() {
                    
                    //filter the placesStruct array to find the index of the element in the arrray that have the same coordinate
                    let filteredPlace =   self.placesStruct.firstIndex { (arr) -> Bool in
                        arr?.coordinate.latitude == place?.coordinate.latitude && arr?.coordinate.longitude == place?.coordinate.longitude
                    }
                    
                    guard let filteredindex = filteredPlace else { return }
                    
                    print("debug index \(filteredPlace)")
                    
                    //from the index i get from about then go to that element in placesstruct array and assign it to shortestArray
                    self.shortestArray[index]?.serialNo = self.placesStruct[filteredindex]?.serialNo
                    self.shortestArray[index]?.placemark = self.placesStruct[filteredindex]?.placemark
                    
                    if(index == 0){
                        
                        let destPlacemark = MKPlacemark(coordinate: place!.coordinate)
                        let  destItem = MKMapItem ( placemark: destPlacemark)
                        self.generateShortestPolyLine1(toDestination1: destItem)
                    }else {
                        print("debug run ")
                        let sourcePlacemark = MKPlacemark(coordinate: self.shortestArray[index - 1]!.coordinate)
                        let  sourceItem = MKMapItem ( placemark: sourcePlacemark)
                        
                        let destPlacemark = MKPlacemark(coordinate: place!.coordinate)
                        let  destItem = MKMapItem ( placemark: destPlacemark)
                        
                        self.generateShortestPolyline2(source: sourceItem, destination: destItem)
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = place!.coordinate
                    self.mapView.addAnnotation(annotation)
                    self.sortedCoordinates.append(place!.coordinate)
                }
                self.zoomFitAndRiderActionViewTrigger()
                
                //remove loading view
                self.shouldPresentLoadingView(false)
                print("debug helo shortestArray1 \(self.shortestArray)")
                print("debug helo dests \(destination)")
                print("debug helo tempArray \(tempArray)")
                print("debug helo sortedCoordinates \(self.sortedCoordinates)")
                
            }
            
            //end the function
            return
        }
        
        
        //if there is element in the shortestArray
        if shortestArray.count > 0 {
            //get the last element in array
            let coor = shortestArray[shortestArray.count - 1]
            guard let coordinate = coor?.coordinate else {return }
            sourceCoordinate = coordinate
            //find the cllocation
            sourceCllocation = CLLocation(latitude : sourceCoordinate.latitude , longitude: sourceCoordinate.longitude)
            
        }else { //if there is no element in the shortestArray
            //get user current location
            guard let userCoor = locationManager?.location?.coordinate else { return}
            sourceCoordinate = userCoor
            sourceCllocation = CLLocation(latitude : sourceCoordinate.latitude , longitude: sourceCoordinate.longitude)
            
        }
        
        //loop thro the dests to get the distance from each coordinate to either user location or the selected shortest location in shortestArray
        //        dests.forEach { (coordinate) in
        //            getShortesRoute(sourceCoordinate: sourceCoordinate, destinationCoordinate: coordinate) { (route) in
        //                 let cllocation = CLLocation(latitude : coordinate.latitude , longitude: coordinate.longitude)
        //                let distance = route.distance
        //
        //                //append to the temporary Array
        //                tempArray.append(Place(cllocation: cllocation, distance: distance, coordinate: coordinate))
        //            }
        //
        ////            let distance = cllocation.distance(from: sourceCllocation)
        //
        //
        //        }
        
        getShortesRoute(sourceCoordinate: sourceCoordinate, destinationCoordinates: destination) { (array) in
            tempArray = array
            print("debug test before \(tempArray)")
            //sort the temporary array
           
                          
          let startDate = Date()
            self.mergesort.quickSort(array: &tempArray, startIndex: 0, endIndex: tempArray.count - 1)

              let executionTime = Date().timeIntervalSince(startDate)
            print("debug time \(executionTime)")

            
            //  tempArray.sort(by: {$0.distance < $1.distance})
           
            
            
            //remove the coordinate that has the shortest distance from dests array
            for(index, coor ) in destination.enumerated(){
                if coor.latitude == tempArray[0].coordinate.latitude && coor.longitude == tempArray[0].coordinate.longitude{
                    print("debug test before \(  destination)")
                    destination.remove(at: index)
                    print("debug test after \(  destination)")
                }
            }
            
            
            //append the shortest distance to the shortestArray
            self.shortestArray.append(tempArray[0])
            
            
            
            //recursive call
            self.findShortest(destinationCoordinates: destination)//
        }
        
    }
    
    func triggerFind(){
        var destination : [CLLocationCoordinate2D] = []
        
        let sourceCoordinate = CLLocationCoordinate2D(latitude : 4.29 , longitude: 100.765)
        
        self.placesStruct.forEach { (place) in
            guard let coordinate = place?.coordinate else { return }
            destination.append(coordinate)
        }
//               let destinationCoordinate1 = CLLocationCoordinate2D(latitude: 4.209158503904472,   longitude: 100.69957731592997)
//               let destinationCoordinate2 = CLLocationCoordinate2D(latitude: 4.213250192365602, longitude: 100.68228971070694)
//               let destinationCoordinate3 = CLLocationCoordinate2D(latitude: 4.213494049584127, longitude: 100.6834826494374)
            
//               destination.append(destinationCoordinate1)
//               destination.append(destinationCoordinate2)
//               destination.append(destinationCoordinate3)
        
        for dest in destination{
            self.mapView.addAnnotationAndSelect(coordinate: dest)
        }
        
//        let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self)}) // filter on the mapview to filter out driver annotation , $0 is each annotation
//
//        self.mapView.zoomToFit(annotation: annotations)
//
//        guard let uslocation = self.locationManager?.location else { return }
//        self.getUserCurrentAddress(location: uslocation) { (place) in
//
//            self.animateRiderActionView(shouldShow: true , destination: self.placesStruct[0]!.placemark, source: place) //changed
//            //                        self.destinationcoor = []  //changed
//
//        }
        findShortest(destinationCoordinates: destination)
    }
    
    func confirmLocationView() {//(latest)
        
        configureActionButton(config: .dismissActionView)
        //get user current location
     print("debug placesstruct 123\(self.placesStruct)")
    
//
//        if destinationcoor.count > 1{
//            for dest in destinationcoor{
//                let destination = MKMapItem(placemark: dest!)
//                generatePolyLine(toDestination: destination)
//            }
//        }else {
//            let destination = MKMapItem(placemark: destinationcoor[0]!)
//            generatePolyLine(toDestination: destination)
//        }
        
//   //present loading view
        
        shouldPresentLoadingView(true, message: "Loading..")
        dismissLocationView { _ in
//            guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
//
//            guard let destinationCoordinate1 = self.destinationcoor[0]?.coordinate else { return }
//            self.groupedRoutes.append((sourceCoordinate, destinationCoordinate1))
//            self.dests.append(destinationCoordinate1)
            
            //user select one location only
//            if self.placesStruct.count == 1{
////                let destination = MKMapItem(placemark: self.destinationcoor[0]!)
//              let destination = MKMapItem(placemark: self.placesStruct[0]!.placemark)
////                guard let destinationCoordinate = self.destinationcoor[0]?.coordinate else { return }
//                guard  let destinationCoordinate = self.placesStruct[0]?.coordinate else { return }
//                self.arr.append(destinationCoordinate)
//                self.generatePolyLine(toDestination: destination)
//            }
//
//                //if user select two destination
//            if self.placesStruct.count == 2 {
//                guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
//                guard let destinationCoordinate1 = self.placesStruct[0]?.coordinate else { return }
//                guard let destinationCoordinate2 = self.placesStruct[1]?.coordinate else { return }
//                self.dests.append(destinationCoordinate1)
//                self.dests.append(destinationCoordinate2)
//
//                self.groupedRoutes.append((sourceCoordinate, destinationCoordinate1))
//                self.groupedRoutes.append((sourceCoordinate, destinationCoordinate2))
//                self.groupedRoutes.append((destinationCoordinate1, destinationCoordinate2))
//                self.groupedRoutes.append((destinationCoordinate2, destinationCoordinate1))
//                self.calculateRoute()
//            }
//
//            for dest in self.placesStruct{
//
//                guard let dest = dest else {return }
//                self.mapView.addAnnotationAndSelect(coordinate: dest.coordinate)
//            }
            if self.placesStruct.count > 1{
                 self.triggerFind()
            }
           
            if self.placesStruct.count == 1{
                
                let destinationCoordinate = self.placesStruct[0]!.coordinate
                guard let placemark = self.placesStruct[0]?.placemark else { return }
                let destinationItem = MKMapItem(placemark: placemark)
                
                //add coordinate into the array
                self.sortedCoordinates.append(destinationCoordinate)
                
                //generate polyline
                
                self.generateShortestPolylineAndRoute(toDestination1: destinationItem) { (route) in
                    
                      self.placesStruct[0]?.route = route
                      self.shortestArray = self.placesStruct
                    //add annotation
                      self.mapView.addAnnotationAndSelect(coordinate: destinationCoordinate)
                    print("debug helo sorted array \(self.sortedCoordinates) and placesStruct : \(self.shortestArray[0])")
                  
                    self.zoomFitAndRiderActionViewTrigger()
                    
                    //remove loading view
                    self.shouldPresentLoadingView(false)
                }
                
              
            }
            
         
//
//            let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self)}) // filter on the mapview to filter out driver annotation , $0 is each annotation
//
//            self.mapView.zoomToFit(annotation: annotations)
//
//            guard let uslocation = self.locationManager?.location else { return }
//            self.getUserCurrentAddress(location: uslocation) { (place) in
//
//                print("debug test ar\(self.shortestArray)")
//            self.animateRiderActionView(shouldShow: true , destination: self.placesStruct, source: place) //changed
//                //                        self.destinationcoor = []  //changed
//
//            }
        }
        
        
    }
    
    func zoomFitAndRiderActionViewTrigger(){
        let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self)}) // filter on the mapview to filter out driver annotation , $0 is each annotation

                  self.mapView.zoomToFit(annotation: annotations)

                  guard let uslocation = self.locationManager?.location else { return }
                  self.getUserCurrentAddress(location: uslocation) { (place) in

                      print("debug test ar\(self.shortestArray)")
                  self.animateRiderActionView(shouldShow: true , destination: self.shortestArray, source: place) //changed
                      //                        self.destinationcoor = []  //changed

                  }
    }
    
    // new function
    func calculateRoute() {
        
        guard !groupedRoutes.isEmpty else {

            print("debug distance \(distanceRoutes    )")
             
            //closure to get back shortest path from algorithm
            shortPath(routes: distanceRoutes) { (paths) in
                
                print("debug shortest path \(paths[1])")
                
                
              
                for route in self.distanceRoutes {
                   
                    if route.distance == Double(paths[1]){
                       
                        //check if the array already contains the location if no then add the location
                        let c = self.arr.contains { ar -> Bool in
                            return ar.latitude == route.location.latitude //return true if match
                        }
                        
                        if  c == false{
                            let sourcePlacemark = MKPlacemark(coordinate: route.location)
                            let sourceItem = MKMapItem ( placemark: sourcePlacemark)
                            self.generateShortestPolyLine1(toDestination1: sourceItem)
                            
                        
                            self.arr.append(route.location)
                        }
                        
                    }
                    
                    if route.distance == Double(paths[2]){
                        //check if the array already contains the location if no then add the location
                        let c = self.arr.contains { ar -> Bool in
                            return ar.latitude == route.location.latitude //return true if match
                        }
                        
                        if  c == false{
                            let sourcePlacemark = MKPlacemark(coordinate: self.arr[0])
                            let sourceItem = MKMapItem ( placemark: sourcePlacemark)
                            let destinationPlacemark = MKPlacemark(coordinate: self.arr[0])
                            let destinationItem = MKMapItem ( placemark: destinationPlacemark)
                            self.generateShortestPolyline2(source: sourceItem, destination: destinationItem)
                       
                            self.arr.append(route.location)
                        }
                    }
                }
            }
            triggerFind()
            return
        }
        //if it is not empty then continue remove from the groupedRoute array
        let location = groupedRoutes.removeFirst()
        let sourcePlacemark = MKPlacemark(coordinate: location.startItem)
        let destinationPlacemark = MKPlacemark(coordinate: location.endItem)
        let sourceItem = MKMapItem ( placemark: sourcePlacemark)
        let destinationItem = MKMapItem ( placemark: destinationPlacemark)
        
        let routeRequest = MKDirections.Request() //  4.291853, 100.760270
        
        routeRequest.source = sourceItem
        routeRequest.destination = destinationItem
        routeRequest.requestsAlternateRoutes = true
        routeRequest.transportType = .automobile
        
        var distance: Double?
        let direction = MKDirections(request: routeRequest)
        direction.calculate { (response, err) in
            guard let response = response else { return }
            
            
            //                   var dict = [Double: MKRoute]()
            var unsortedRouted = response.routes
            unsortedRouted.sort(by: {$0.expectedTravelTime < $1.expectedTravelTime})
//            let quickesRoute: MKRoute = unsortedRouted[0]
            
            self.route = unsortedRouted[0]
          guard let polyline = self.route?.polyline else { return }
//             self.mapView.addOverlay(polyline)
            
            print("debug polyline \(polyline)")
            distance = Double( self.route!.distance)
            print("debug quicke3st distance \(distance ?? 0)")
            //completion([(distance!,quickesRoute)
            self.distanceRoutes.append((distance!, self.route!, location.endItem , polyline))
            self.calculateRoute() //recursive
        }
    }
    
    
    //new function
    func shortPath(routes : [(distance: Double,route: MKRoute, location : CLLocationCoordinate2D, polyline : MKPolyline)] , completion: @escaping([String]) -> Void){
            let location1 = String(routes[0].distance)
            let location2 = String(routes[1].distance)
            let location3 = String(routes[2].distance)
            let location4 = String(routes[3].distance)

            let cityGraph: WeightedGraph<String, Int> = WeightedGraph<String, Int>(vertices: ["A", location1,location2,location3,location4,"B"])
            cityGraph.addEdge(from: "A", to: location1, weight: Int(routes[0].distance))
            cityGraph.addEdge(from: "A", to: location2, weight:Int(routes[1].distance))
            cityGraph.addEdge(from: location1, to:location3, weight:Int(routes[2].distance))
            cityGraph.addEdge(from: location2 , to:location4, weight:Int(routes[3].distance))
            cityGraph.addEdge(from: location3, to: "B", weight:1)
            cityGraph.addEdge(from: location4, to: "B", weight:1)

             let result1 = cityGraph.dfs(from: "A", to: "B")
            print("debug shortest path \(result1)")
            let (distances, pathDict) = cityGraph.dijkstra(root: "A", startDistance: 0)
            var nameDistance: [String: Int?] = distanceArrayToVertexDict(distances: distances, graph: cityGraph)
            // shortest distance from New York to San Francisco
            let temp = nameDistance["B"]
            print("debug shortest path 1 \(temp?.debugDescription)")
            // path between New York and San Francisco
            let path: [WeightedEdge<Int>] = pathDictToPath(from: cityGraph.indexOfVertex("A")!, to: cityGraph.indexOfVertex("B")!, pathDict: pathDict)
            let stops: [String] = cityGraph.edgesToVertices(edges: path)
            let arr = Array(stops)

            print("debug shortest path 2 \(path) and stop is \(arr)")

            let mst = cityGraph.mst()!
            let cycles = cityGraph.detectCycles()
            let isADAG = cityGraph.isDAG
            completion(arr)
    //        print("debug shortest path mst \(totalWeight(mst)) and cycles \(cycles) and isADAG \(isADAG) ")

           
            
        }
    
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          
        return " "
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count  //return 2 if section == 0 else return searchresult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
   
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        destinationcoor.append(searchResults[indexPath.row]) // (latest)
        print("debug selectedPlace \(destinationcoor)")
       
        
//
//        configureActionButton(config: .dismissActionView)
//
//        let destination = MKMapItem(placemark: selectedPlacemark)
//        generatePolyLine(toDestination: destination)
//
//        dismissLocationView { _ in
//
//            self.mapView.addAnnotationAndSelect(coordinate: selectedPlacemark.coordinate)
//
//            let annotations = self.mapView.annotations.filter ({ !$0.isKind(of: DriverAnnotation.self)}) // filter on the mapview to filter out driver annotation , $0 is each annotation
//
//            self.mapView.zoomToFit(annotation: annotations)
//
//            guard let uslocation = self.locationManager?.location else { return }
//            self.getUserCurrentAddress(location: uslocation) { (place) in
//
//                self.animateRiderActionView(shouldShow: true , destination: selectedPlacemark, source: place)
//            }
//        }
    }
}

//MARK: - FormControllerDelegate
extension HomeController : FormControllerDelegate {
    func uploadTrip() {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
      //  guard let destinationCoordinates = destinationCoor else { return } //latest
      
//               print("debug arr location \(self.arr)")
//        for destination in destinationcoor{
//            self.destinationCoodinates.append(destination!.coordinate)
//        }
        var serialNo : [String] = []
        var destinationName : [String] = []
        print("debug arr location 123 \(self.sortedCoordinates)")
       
        var latitude : [CLLocationDegrees] = []
         var longitude : [CLLocationDegrees] = []
        
        //put serialNo into array
        shortestArray.forEach { (arr) in
            guard let serialNum = arr?.serialNo else { return }
            guard let destName = arr?.placemark?.description.split(separator: "@") else { return }
            
            latitude.append((arr?.coordinate.latitude)!)
            longitude.append((arr?.coordinate.longitude)!)
            serialNo.append(serialNum)
            destinationName.append(String(destName[0]))
        }
        
        shouldPresentLoadingView(true, message: "Finding a ride...")
        
        PassengerService.shared.uploadTrip(pickupCoordinates, self.sortedCoordinates, serialNo: serialNo, destinationName: destinationName, latitude: latitude, longitude: longitude ) { (err, ref) in //latest
            if let error = err {
                print (" debug upload failed \(error)")
            }


            UIView.animate(withDuration: 0.3) {

                self.rideActionView.frame.origin.y = self.view.frame.height
               // self.rideActionView.setViewToInvisible()
            }
        }
    }
    
     
}

//MARK: - pickupControllerDelegate
extension HomeController : PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        print("debug error called - didaccept")
        self.driverTabBarView.alpha = 0
        self.trip = trip //overwrite previous trip if there is two orders
      print("debug driver side random orderID \(trip.orderID)")
        print("debug popoopoop\(trip.coordinatesArray) and \(trip.courierCenterCoordinates)")
        
        self.state = .accepted
        self.mapView.addAnnotationAndSelect(coordinate: trip.pickupCoordinates)
        
      
        setCustomRegion(withType: .pickup, coordinates: trip.pickupCoordinates)
       
        
       
        
       
        
        let placemark = MKPlacemark(coordinate : trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyLine(toDestination: mapItem)
        
        mapView.zoomToFit(annotation: mapView.annotations)
        
        observeCancelledTrip(trip: trip)
        
        self.dismiss(animated: true) {
           // self.animateRiderActionView(shouldShow: true, config : .tripAccepted)
            Service.shared.fetchUserData(uid: trip.passengerUid) { (passenger) in
                 self.animateTripAcceptedView(shouldShow: true,   config: .tripAccepted, user: passenger)
                
            }
        }
    }

}

//MARK: - TripAcceptedViewDelegate
extension HomeController: TripAcceptedViewDelegate {
    func getDirection() {
        
        
       /* let vc = TestingController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil) */
      guard let trip = self.trip else { return }
       
     
     
    if state == .accepted{
     let vc = ARNavigationController(coordinate: trip.pickupCoordinates)
       
     vc.delegate = self
        
     vc.modalPresentationStyle = .fullScreen
     self.present(vc, animated: true, completion: nil)
        }
        
        if state == .inProgress{
            print("debug tripCount AR\(tripCount)")
            let vc = ARNavigationController(coordinate: trip.courierCenterCoordinates[tripCount]) //ori
//            guard let destination = trip.destinationCoordinates[0] else { return } //latest
//            let vc = ARNavigationController(coordinate: destination) //latest
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
     
    
}
    
    func dropOffParcel() {
        guard let trip = self.trip else { return }
        
        //if only one destination then increasee counter to 1 so it will not run starttrip() again
//        if trip.destinationCoordinates2 == nil {
//             counter += 1
//        }
        
        guard let totalTrip = trip.tripCount else { return }
        
        
        if self.tripCount == totalTrip - 1{
            
            
            DriverService.shared.updateTripState(trip: trip, state: .completed) { (err, ref) in
                print("debug counter end")
                  self.driverTabBarView.alpha = 1
                self.removeAnnotationAndOverlay()
                self.tripAcceptedView.addressLabel.text = ""
                 self.tripAcceptedView.serialLabel.text = ""
                //stop monitoring
                self.removeCustomRegion(withType: .destination, coordinates: trip.courierCenterCoordinates[self.tripCount])
                self.animateTripAcceptedView(shouldShow: false)
                self.centerMapOnUserLocation()
                self.tripCount = 0
                self.counter = 0
                //upload driver records
                DriverService.shared.uploadDriverRecord(orderID: trip.orderID!, status: "Completed") { (err, ref) in
                    print("debug success upload")
                }
            }
            
        }else{
            self.tripCount += 1
            self.startTrip()
        }
       
        //old
//        if counter == 0{
//            DriverService.shared.updateTripCount(trip: trip, count: 1) { (err, ref) in
//                self.counter += 1
//
//
//                self.startTrip()
//
//            }
//
//        }else{
//            DriverService.shared.updateTripState(trip: trip, state: .completed) { (err, ref) in
//                       self.removeAnnotationAndOverlay()
//                       self.centerMapOnUserLocation()
//                       self.animateTripAcceptedView(shouldShow: false)
//                      self.counter = 0
//           }
//        }
        
       
    }
    
    func pickupPassenger() {
             startTrip()
    }
    
    func cancelRide() {
        PassengerService.shared.deleteTrip { (error, ref) in
            
            if let error = error {
                print("debug : error deleting trip: \(error)")
                return
            }
            self.tripCount = 0
            self.tabBarView.alpha = 1 //present tab bar
            self.centerMapOnUserLocation()
            self.animateTripAcceptedView(shouldShow: false)
            self.removeAnnotationAndOverlay()
            self.removeArray()
           // self.actionButton.setImage(#imageLiteral(resourceName: "iconmonstr-log-out-9-240").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            self.locationInputActivationView.alpha = 1
            guard let orderID = self.trip?.orderID else { return }
            PassengerService.shared.uploadRecord(orderID: orderID, status: "Cancelled") { (err, ref) in
                guard let err = err else { return }
                print("debug  upload record error\(err)")
                
            }
            
            
        }
    }
    
    
}

//MARK: ARNavigationControllerDelegate
extension HomeController: ARNavigationControllerDelegate {
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension HomeController: MenuBarViewDelegate {
    func handleMenuOption(option: String) {
        switch option {
        case "AR":
            print("debug AR")
            fetchOnceDrivers()
                   ARNearbyViewController.delegate = self
                   
                   view.addSubview(ARNearbyViewController)
                   ARNearbyViewController.frame = view.bounds
        case "myorder":
            print("debug myorder")
            PassengerService.shared.observeRecord { (records) in
                let recordVC = RecordListVC(recordlist: records, user : "customer")
               // recordVC.modalPresentationStyle = .fullScreen
                //self.navigationController?.pushViewController(recordVC, animated: false)
                
                let nav = UINavigationController(rootViewController: recordVC)
                         
                nav.isModalInPresentation = true
                          
                nav.modalPresentationStyle = .fullScreen
                
                self.present(nav, animated: true, completion: nil)
                // self.present(recordVC, animated: true, completion: nil)
            }
                      
            
        case "logout":
            print("debug logout")
            handleLogout()
        default:
            print("debug nothing")
        }
    }
    
  
    
}


extension HomeController : DriverMenuBarDelegate {
    func handleSwitchButtonOption(isOn: Bool) {
            if (isOn){
                 print("on")
                 observeTrip()
                 self.mapView.showsUserLocation = true
             }
             else{
                 print("off")
                 DriverService.shared.removeDriver { (err, ref) in
                     DriverService.shared.removeTripObserver()
                     self.mapView.showsUserLocation = false
                 }
             }
    }
    
    func handleDriverMenuOption(option: String) {
          switch option {
              case "history":
                  print("debug myorder")
                  DriverService.shared.observeDriverRecord { (records) in
                    let recordVC = RecordListVC(recordlist: records , user: "driver")
                     // recordVC.modalPresentationStyle = .fullScreen
                      //self.navigationController?.pushViewController(recordVC, animated: false)
                  //  let orderVC = OrderController()
                      let nav = UINavigationController(rootViewController: recordVC)
                               
                      nav.isModalInPresentation = true
                    
                      nav.modalPresentationStyle = .fullScreen

                      self.present(nav, animated: true, completion: nil)
                      // self.present(recordVC, animated: true, completion: nil)
                  }
//
                  
              case "logout":
                  print("debug logout")
                  handleLogout()
              default:
                  print("debug nothing")
              }
    }
    
    
}

//ordercontroller function
extension HomeController {
    func returnToHomePage(){
        dismissLocationView { _ in
        UIView.animate(withDuration: 0.3) {
                 self.locationInputActivationView.alpha = 1 //takes 0.3 seconds for activation view to show up
                 self.destinationcoor.removeAll() //remove the coordinate (latest)
                 self.distanceRoutes.removeAll()
                 self.arr.removeAll()
                 self.groupedRoutes.removeAll()
             
                 self.tabBarView.alpha = 1
                     
                self.removeArray()
             }
        }
    }
    
    func dismissOrderVC(orders: [Order]){
        orders.forEach { (order) in
            guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
            let sourceClllocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
            
            let placemark = order.placemark
            let destinationCoordinate = placemark.coordinate
                     
          let cllocation = CLLocation(latitude : placemark.coordinate.latitude , longitude: placemark.coordinate.longitude)
          
          //calculate the distance from the place to user current location
          let distance =  cllocation.distance(from: sourceClllocation)
            
            self.placesStruct.append(Places(cllocation: cllocation, distance: distance, coordinate: destinationCoordinate, placemark: placemark, serialNo: order.serial))
        }
        confirmLocationView()
    }
}


