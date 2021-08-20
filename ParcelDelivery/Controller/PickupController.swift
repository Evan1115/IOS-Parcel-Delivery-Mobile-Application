//
//  PickupController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 24/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate : class {
    func didAcceptTrip(_ trip : Trip)
}

class PickupController : UIViewController{
   
     //MARK: - Properties
    private let mapView = MKMapView()
    
    let trip: Trip
    
    weak var delegate : PickupControllerDelegate?
    
    var source : CLPlacemark? {
        didSet{
            guard let source = source else { return }
           
            let postcode = source.postalCode ?? ""
            let state = source.administrativeArea ?? ""
            let city = source.locality ?? ""
            let country = source.country ?? ""
            var userAddress = String()
            userAddress.append("\(city), \(postcode), \(state), \(country)")
            sourceLabel.text = userAddress
            
        }
    }
    
    private let cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel2"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let acceptButton : UIButton = {
           let button = UIButton(type: .system)
        button.setTitle("Accept Trip", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
       
           return button
       }()
    
    private let pickupLabel : UILabel = {
        let label = UILabel()
        label.text = "Would you like to accept this request?"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    
    
    private let sourceLabel : UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        
        label.text = " "
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private let destinationLabel1 : UILabel = {
          let label = UILabel()
          label.isUserInteractionEnabled = false
          
          label.text = " 321312312312312"
          label.font = UIFont.boldSystemFont(ofSize: 15)
          label.textColor = .white
          return label
      }()
    
    private let destinationLabel2 : UILabel = {
          let label = UILabel()
          label.isUserInteractionEnabled = false
          
          label.text = " "
          label.font = UIFont.boldSystemFont(ofSize: 15)
          label.textColor = .white
          return label
      }()
      
    private let destinationLabel3 : UILabel = {
          let label = UILabel()
          label.isUserInteractionEnabled = false
          
          label.text = " "
          label.font = UIFont.boldSystemFont(ofSize: 15)
          label.textColor = .white
          return label
      }()
      
    
    private lazy var sourceView: UIView = {
    let view = UIView()
     view.backgroundColor = .lightBlue
     view.layer.cornerRadius = 10
    view.addSubview(sourceLabel)
       
    sourceLabel.centerX(inView: view)
    sourceLabel.centerY(inView: view)
    
        
        let icon = UIImageView()
        view.addSubview(icon)
        icon.image = #imageLiteral(resourceName: "marker")
        icon.centerY(inView: view)
        icon.setDimension(height: 20, width: 20)
        
        icon.anchor(left: sourceLabel.leftAnchor, paddingLeft: -25)

    return view
    }()
    
    private lazy var destinationView1: UIView = {
       let view = UIView()
        view.backgroundColor = .lightBlue
        view.layer.cornerRadius = 10
       view.addSubview(destinationLabel1)
          
       destinationLabel1.centerX(inView: view)
       destinationLabel1.centerY(inView: view)
       
           
           let icon = UIImageView()
           view.addSubview(icon)
           icon.image = #imageLiteral(resourceName: "marker")
           icon.centerY(inView: view)
           icon.setDimension(height: 20, width: 20)
           
           icon.anchor(left: destinationLabel1.leftAnchor, paddingLeft: -25)

       return view
       }()
    
    
    
    
    //MARK: - Lifecycle
    init(trip: Trip) {
        self.trip = trip
      
        super.init(nibName: nil, bundle : nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
       configureUI()
        configureMapView()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @objc func handleDismissal(){
        DriverService.shared.updateTripState(trip: trip, state: .denied) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
    @objc func handleAcceptTrip() {
            DriverService.shared.acceptTrip(trip: trip) { (error, ref) in
            
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(coordinate: trip.pickupCoordinates)
        
    }
    
    
    func configureUI(){
        view.backgroundColor = .lightBlue
        
         view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor , left: view.leftAnchor,paddingTop: 20 ,paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimension(height: 270, width: 270)
        mapView.layer.cornerRadius = 270/2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -200)
        
        mapView.layer.borderWidth = 5
        mapView.layer.borderColor = UIColor.lightBlue.cgColor
        mapView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,blue: 0/255.0, alpha: 1.0).cgColor
        mapView.layer.shadowOffset = CGSize(width: 0, height: 10)
        mapView.layer.shadowOpacity = 0.5
        mapView.layer.shadowRadius = 200
        
        view.addSubview(sourceView)
        sourceView.centerX(inView: view)
        sourceView.anchor(top: mapView.bottomAnchor , paddingTop: 20)
        sourceView.setDimension(height: 40, width: 300)
        
        
//        sourceView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,blue: 0/255.0, alpha: 1.0).cgColor
//          sourceView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
//              sourceView.layer.shadowOpacity = 0.2
//              sourceView.layer.shadowRadius = 5
        
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(bottom: view.bottomAnchor, paddingBottom: 360)
        
        view.addSubview(acceptButton)
        
        acceptButton.anchor( left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingBottom: 300,paddingRight: 32, height: 50)
        
    }
}


