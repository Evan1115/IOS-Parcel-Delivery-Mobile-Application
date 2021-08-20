//
//  ARNearbyView.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 11/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation

var sceneLocationView = SceneLocationView()
private let locationManager = LocationHandler.shared.locationManager
private let hm = HomeController()


protocol ARNearbyViewDelegate : class {
   func presentHomeView()
  
}



class ARNearbyView : UIView {
    
  //MARK: - properties
  weak var delegate : ARNearbyViewDelegate?
    var driverName : String?
    var driverDistance : Double?
    private let backButton : UIButton = {
         let button = UIButton(type: .system)
         button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
         button.addTarget(self, action: #selector(presentHomeView), for: .touchUpInside)
         
         return button
     }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
 
   
         sceneLocationView.run()
       addSubview(sceneLocationView)
        sceneLocationView.translatesAutoresizingMaskIntoConstraints = false
        sceneLocationView.anchor(top: topAnchor, left: leftAnchor ,bottom: bottomAnchor,right: rightAnchor,paddingTop: 0,paddingLeft: 0,paddingBottom: 0,paddingRight: 0)
        
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor,left: leftAnchor, paddingTop: 44, paddingLeft:  12, width: 40,height: 40)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func removeNode(){
        sceneLocationView.removeAllNodes()
        
    }
    
    @objc func presentHomeView(){
       delegate?.presentHomeView()
        
    }
    
    // add driver annotation to AR
    func addAnnotationToAR(coordinate: CLLocationCoordinate2D , uid: String){
          
           
           let location = CLLocation(coordinate: coordinate, altitude: 30)
           let image = UIImage(named: "marker")!
           
           let annotationNode = LocationAnnotationNode(location: location, image: image)
        
            Service.shared.fetchUserData(uid: uid) { (driverinfo) in
                 let userLocation = locationManager?.location //current user  location
                              
                              //calculate distane
                              guard let currentUserLocation = userLocation else { return }
                              let loc1 = CLLocation(latitude: (currentUserLocation.coordinate.latitude), longitude: (currentUserLocation.coordinate.longitude))
                              let loc2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                              let distance = loc1.distance(from: loc2)
                              self.driverDistance = distance / 1000
                              
                            self.driverName = driverinfo.fullname
                           annotationNode.annotationNode.name = self.driverName
                           
                           guard let driverDistance = self.driverDistance else { return }
                           
                annotationNode.annotationNode.name?.append(", \(String(format: "%.2f",driverDistance)) KM away.")
                print("Debug : The name is \(driverinfo.fullname) and the distance is \(self.driverDistance)")
            }
           sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        print("debug : \(annotationNode.annotationNode.name) is added")
       }
    
    
       
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneLocationView)
            print("Debug:\(touchLocation)")
            let hitResult = sceneLocationView.hitTest(touchLocation, options: [ .boundingBoxOnly: true])
            print("debug:hittest result \(hitResult)")
            for result in hitResult {
                print("DEBUG : NAME is \(result.node.name)")
            let alert = UIAlertController(title: "Alert", message: result.node.name, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                     switch action.style{
                     case .default:
                           print("default")

                     case .cancel:
                           print("cancel")

                     case .destructive:
                           print("destructive")


               }}))
              // add alert message when pressed on the node
                var topVC = UIApplication.shared.keyWindow?.rootViewController
                while((topVC!.presentedViewController) != nil) {
                    topVC = topVC!.presentedViewController
                }
                
                topVC?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
