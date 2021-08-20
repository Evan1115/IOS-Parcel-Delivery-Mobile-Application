//
//  ARNavigationController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 11/07/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import ARCL 
import CoreLocation
import MapKit
import AVFoundation


protocol ARNavigationControllerDelegate : class {
    func dismissController()
}

class ARNavigationController: UIViewController {
    
    
    //MARK : properties
    weak var delegate : ARNavigationControllerDelegate?
   
    let coordinate : CLLocationCoordinate2D?
    let mapView = MKMapView()
    let sceneLocationView = SceneLocationView()
    var currentLocation : CLLocation? {
        print(sceneLocationView.sceneLocationManager.currentLocation)
        return sceneLocationView.sceneLocationManager.currentLocation
    }
    
    var steps : [MKRoute.Step] = []
    var stepCounter = 0
    var route : MKRoute?
    var showMapRoute = false
    var navigationStarted = false
    let locationDistance : Double = 500
    
    var speechsynthesizer = AVSpeechSynthesizer()
    
    
    // MARK: -properties
    lazy var directionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var startStopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start Navigation", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        
        return button
    }()
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            handleAuthorizationStatus(locationManager: locationManager , status: CLLocationManager.authorizationStatus())
        }else {
            print("location services are not enabled")
        }
        return locationManager
    }()
    
    
    
    // MARK: -lifecycle
    
    init(coordinate : CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        super.init(nibName: nil, bundle : nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sceneLocationView)
        sceneLocationView.frame = CGRect(x: 0, y: 0, width:  view.frame.size.width, height:( view.frame.size.height/3)*2)
        locationManager.startUpdatingLocation()
        
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor,left: view.leftAnchor, paddingTop: 44, paddingLeft:  12, width: 40,height: 40)
        
        
        // add mapview
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.showsUserLocation =  true
        if let center = locationManager.location?.coordinate{
            centerViewToUserLocation(center: center )
        }
        mapRoute()
        mapView.alpha = 1
        
        
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
        
        // navigate()
        addAnnotation()
        configureUI()
        
        print("debug : trip.pick up coor in ar : \(coordinate)")
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneLocationView.run()
        mapView.frame = CGRect(x: 0, y: ( self.view.frame.height/3)*2, width:  self.view.frame.size.width, height: self.view.frame.size.height/3)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneLocationView)
            let hitResult = sceneLocationView.hitTest(touchLocation, options: [ .boundingBoxOnly: true])
            for result in hitResult {
                let alert = UIAlertController(title: "Address Information", message: "Name:Joram , House No: 220", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK : -function
    @objc func dismissController(){
        delegate?.dismissController()
        removeNode()
    }
    
    func configureUI(){
        view.addSubview(startStopButton)
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        startStopButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        startStopButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startStopButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        //add direction label
        view.addSubview(directionLabel)
        directionLabel.translatesAutoresizingMaskIntoConstraints = false
        directionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        directionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        directionLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        directionLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
}

extension ARNavigationController {
    /* func navigate (){
     let request  = MKDirections.Request()
     
     request.source = MKMapItem.forCurrentLocation()
     
     request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 4.291669, longitude: 100.760231), addressDictionary: nil))
     
     request.requestsAlternateRoutes = false
     request.transportType = .automobile
     
     let directions = MKDirections(request: request)
     
     directions.calculate { response, error in
     if let error = error {
     return print("error getting directions:\(error.localizedDescription)")
     }
     
     guard let response = response else {
     return assertionFailure("No error, but response, either.")
     }
     
     
     DispatchQueue.main.async { [weak self] in
     guard let self = self else {
     return
     }
     
     self.show(routes : response.routes)
     }
     }
     }
     */
    
    
    func show ( routes: [MKRoute]){
        guard let location = currentLocation, location.horizontalAccuracy < 15 else {
            return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.show(routes: routes)
            }
        }
        self.sceneLocationView.addRoutes(routes: routes)
    }
    
    func removeNode(){
        sceneLocationView.removeAllNodes()
        
    }
    
    /*
     func algorithmProcess(dictionary : [Double : MKRoute]) -> Double{
     let dungeon = AdjacencyList<String>()
     
     let source = dungeon.createVertex(data: "Source")
     let destA = dungeon.createVertex(data: "destA")
     
     
     for (key,value) in dictionary{
     dungeon.add(.undirected, from: source, to: destA, weight: key)
     }
     
     
     
     dungeon.description
     
     var weight : Double = 0.0
     if let edges = dungeon.dijkstra(from: source, to: destA) {
     for edge in edges {
     print("debug :\(edge.source) -> \(edge.destination)")
     guard let edgeWeight = edge.weight else { return 0.0 }
     weight = edgeWeight
     
     }
     }
     return weight
     }
     */
    func algorithmProcess(dictionary : [Double : MKRoute]) -> Double{
        class MyNode: Node {
            let name: String
            
            init(name: String) {
                self.name = name
                super.init()
            }
        }
        
        let nodeA = MyNode(name: "A")
        let nodeB = MyNode(name: "B")
        
        for (key,_) in dictionary {
            nodeA.connections.append(Connection(to: nodeB, weight: key))
        }
        let sourceNode = nodeA
        let destinationNode = nodeB
        
        let path = shortestPath(source: sourceNode, destination: destinationNode)
        var weight : Double = 0.0
        if let succession: [String] = path?.array.reversed().flatMap({ $0 as? MyNode}).map({$0.name}) {
            print(" Quickest path: \(succession)")
            
            guard let pathweight = path?.cumulativeWeight else { return 0.0}
            weight = pathweight
        } else {
            print(" No path between \(sourceNode.name) & \(destinationNode.name)")
        }
        return weight
    }
    
    func addAnnotation(){
        guard let currentLocation = currentLocation,
            currentLocation.horizontalAccuracy < 15 else {
                return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.addAnnotation()
                }
        }
        
        
        
        let image = UIImage(named: "marker")!
        
        
        guard let coord = coordinate else { return }
        
        
        let location = CLLocation(coordinate: coord, altitude: 10)
        
        let arclNode = LocationAnnotationNode(location: location, image: image)
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: arclNode)
    }
}


extension ARNavigationController {
    
    
    @objc func startStopButtonTapped(){
        if !navigationStarted {
            showMapRoute = true
            if let location = locationManager.location {
                let center = location.coordinate
                centerViewToUserLocation(center: center)
            }
        }else {
            if let route = route {
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
                self.steps.removeAll()
                self.stepCounter = 0
            }
        }
        
        navigationStarted.toggle()
        startStopButton.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation ", for: .normal)
    }
    
    
    
    
    
    func mapRoute(){
        guard let sourceCoordinate = locationManager.location?.coordinate else {
            return
        }
        
        guard let coord = coordinate else { return }
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        print("DEBUG:\(sourcePlacemark)")
        let destinationPlacemark = MKPlacemark(coordinate: coord)
        
        let sourceItem = MKMapItem ( placemark: sourcePlacemark)
        let destinationItem = MKMapItem ( placemark: destinationPlacemark)
        
        let routeRequest = MKDirections.Request() //  4.291853, 100.760270
        
        routeRequest.source = sourceItem
        routeRequest.destination = destinationItem
        routeRequest.requestsAlternateRoutes = true
        routeRequest.transportType = .automobile
        
        let direction = MKDirections(request: routeRequest)
        direction.calculate { (response, err) in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            guard let response = response, let route = response.routes.first else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.show(routes : response.routes) // pass in all posible route
            }
            
            // use algorithm/////
            var dict = [Double: MKRoute]()
            let unsortedRouted = response.routes //return all the possible routes
            
            for routes in unsortedRouted{
                print("debug the route distance is : \(routes.distance)")
                dict[routes.distance] = routes
            }
            
            let weight = self.algorithmProcess(dictionary: dict)
            
            print("debug the return weight is : \(weight)")
            
            
            for (key,value) in dict {
                /*
                 if key == weight{
                 print("debug the match weight is : \(weight)")
                 value.polyline.title = "shortest"
                 }
                 */
            self.mapView.addOverlay(value.polyline)
            self.mapView.setVisibleMapRect(value.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
                
            }
            guard let shortestRoute = dict[weight] else { return }
            shortestRoute.polyline.title = "shortest"
            self.mapView.addOverlay(shortestRoute.polyline)
            self.mapView.setVisibleMapRect(shortestRoute.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            // use algorithm ///////////
            
            
            /* original implementation
             self.route = route
             self.mapView.addOverlay(route.polyline)
             self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
             // self.getRouteSteps(route: route) call the getroutestep function
             */
        }
        
    }
    
    /*
     fileprivate func getRouteSteps(route : MKRoute){
     for monitoredRegion in locationManager.monitoredRegions {
     locationManager.stopMonitoring(for: monitoredRegion)
     }
     
     let steps = route.steps
     self.steps = steps
     
     for i in 0..<steps.count {  //4.292080, 100.760430
     let step = steps[i]
     print(step.instructions)
     print(step.distance)
     
     let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
     locationManager.startMonitoring(for: region)
     
     let circle = MKCircle(center: region.center, radius: region.radius)
     mapView.addOverlay(circle)
     }
     
     stepCounter += 1
     
     var initialMessage = "In \(steps[stepCounter].distance) meters \(steps[stepCounter].instructions) "
     
     
     if stepCounter + 1 < steps.count {
     initialMessage.append("Then In \(steps[stepCounter + 1].distance) meters \(steps[stepCounter + 1].instructions) ")
     }
     
     
     directionLabel.text = initialMessage
     let speechUtterance = AVSpeechUtterance(string: initialMessage)
     speechsynthesizer.speak(speechUtterance)
     }
     */
    
    fileprivate func centerViewToUserLocation(center : CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: center, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func handleAuthorizationStatus(locationManager: CLLocationManager , status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //
            break
        case .denied:
            //
            break
            
        case .authorizedAlways:
            //
            break
        case .authorizedWhenInUse:
            //
            // if let center = locationManager.location?.coordinate{
            //     centerViewToUserLocation(center: center )
            // }
            break
        @unknown default:
            //
            break
        }
        
    }
}

extension ARNavigationController: CLLocationManagerDelegate {
    /* func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     if !showMapRoute {
     if let location = locations.last {
     let center = location.coordinate
     centerViewToUserLocation(center: center)
     }
     }
     }
     */
   
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapView.camera.heading = newHeading.magneticHeading
        mapView.setCamera(mapView.camera, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(locationManager: locationManager, status: status)
    }
    
    //voice command
    /*
     func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
     print("did enter regions")
     stepCounter += 1
     
     if stepCounter < steps.count {
     print("continue")
     let message = "In \(steps[stepCounter].distance) meters \(steps[stepCounter].instructions) "
     directionLabel.text = message
     let speechUtterance = AVSpeechUtterance(string: message)
     speechsynthesizer.speak(speechUtterance)
     
     }else {
     print("done")
     let message = "You have arrived your destination"
     directionLabel.text = message
     let speechUtterance = AVSpeechUtterance(string: message)
     speechsynthesizer.speak(speechUtterance)
     stepCounter = 0
     navigationStarted = false
     for monitorRegion in locationManager.monitoredRegions {
     locationManager.stopMonitoring(for: monitorRegion)
     }
     }
     }
     */
    
}

extension ARNavigationController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
              
          }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        /* original implementation
         if overlay is MKPolyline{
         let renderer = MKPolylineRenderer(overlay: overlay)
         renderer.strokeColor = .systemBlue
         return renderer
         } */
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        if polyline.title == "shortest"{
            renderer.strokeColor = UIColor.blue
        } else {
            renderer.strokeColor = UIColor.lightGray
        }
        
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return renderer
    }
}

