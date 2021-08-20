//
//  RideActiveView.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 17/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import MapKit


protocol ShowFormViewDelegate : class {
    func showFormViewController()
    func uploadTriptoFirebase()
}

/*
enum RideActiveViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self =  .requestRide
    }
}

enum ButtonAction : CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "Confirm UberX"
        case .cancel : return "CANCEL RIDE"
        case.getDirections : return "GET DIRECTIONS"
        case .pickup : return "PICKUP PASSENGER"
        case .dropOff : return "DROP OFF PASSENGER"
        
        }
    }
    
    init() {
        self = .requestRide
    }
    
}
 */

class RideActiveView: UIView {
    
    //MARK: -Properties
    //MARK: -Passenger confirm trip UI element
    private var recipient = Recipient()
    weak var delegate : ShowFormViewDelegate?
    private let locationManager = LocationHandler.shared.locationManager
    
    struct Cells{
        static let previewCell = "PreviewCell"
    }
  
    var tableview = UITableView()
    
    
    //var config = RideActiveViewConfiguration()
    var buttonAction = ButtonAction()

    
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
    
    
    var destination : [Places?] = []
//        didSet{
//          removeview()
//
//            guard let placemark1 = destination[0]?.placemark?.description else {return}
//             let address1 = placemark1.split(separator: "@")
////             guard let placemark2 = destination[1]?.placemark?.description else {return}
////             guard let placemark3 = destination[2]?.placemark?.description else {return}
//
//            destinationLabel.text = String(address1[0])
//
//            if destination.count == 2 {
//                 guard let placemark2 = destination[1]?.placemark?.description else {return}
//                 let address2 = placemark2.split(separator: "@")
//                destinationLabel2.text = String(address2[0])
//                destination2view()
//            }
//
//            if destination.count == 3 {
//                 guard let placemark2 = destination[1]?.placemark?.description else {return}
//                 guard let placemark3 = destination[2]?.placemark?.description else {return}
//                let address2 = placemark2.split(separator: "@")
//                let address3 = placemark3.split(separator: "@")
//
//                destinationLabel2.text = String(address2[0])
//                destinationLabel3.text = String(address3[0])
//
//                destination2view()
//                destination3view()
//            }
//
//
//        }
//    }
    
  
    
    private let sourceLabel : UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        
        label.text = " 223, Kampung Baru, 32400 Ayer Tawar, Perak"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    
    private let  destinationLabel : UILabel = {
          
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.text = " Lot 101, Jalan Pasar, 31900 Kampar, Perak"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
        
       }()
    
    private let  destinationLabel2 : UILabel = {
            
          let label = UILabel()
          label.isUserInteractionEnabled = false
          label.text = " Lot 101, Jalan Pasar, 31900 Kampar, Perak"
          label.font = UIFont.boldSystemFont(ofSize: 15)
          label.textColor = .black
          return label
          
         }()
    
    private let  destinationLabel3 : UILabel = {
            
          let label = UILabel()
          label.isUserInteractionEnabled = false
          label.text = " Lot 101, Jalan Pasar, 31900 Kampar, Perak"
          label.font = UIFont.boldSystemFont(ofSize: 15)
          label.textColor = .black
          return label
          
         }()
    
    private let  distanceLabel : UILabel = {
        let label = UILabel()
               
               
               label.font = UIFont.boldSystemFont(ofSize: 18)
               label.textColor = .white
               return label
    }()
    
    private let  fareLabel : UILabel = {
             let label = UILabel()
                 label.font = UIFont.boldSystemFont(ofSize: 18)
                 label.textColor = .white
                  return label
       }()
    
    private lazy var sourceLocationContainer : UIView = {
        let view = UIView()
       
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        let icon = UIImageView()
        view.addSubview(icon)
        icon.image = #imageLiteral(resourceName: "marker")
        icon.centerY(inView: view)
        icon.setDimension(height: 30, width: 30)
        icon.anchor(left: view.leftAnchor)
        
        let label = UILabel()
        view.addSubview(label)
        label.text = "Parcel Store Location"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .darkGray
        label.anchor(top: view.topAnchor ,left : icon.rightAnchor, paddingTop: 2, paddingLeft: 5)
        
        view.addSubview(sourceLabel)
        sourceLabel.anchor(left: icon.rightAnchor ,bottom: view.bottomAnchor ,right: view.rightAnchor )
        return view
    }()
    
    
    private let seperateView : UIView  = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        
        return view
    }()
    
    private let seperateView2 : UIView  = {
          let view = UIView()
          view.backgroundColor = .lightGray
          
          
          return view
      }()
    
    private let seperateView3 : UIView  = {
          let view = UIView()
          view.backgroundColor = .lightGray
          
          
          return view
      }()
    
    private lazy var destinationLocationContainer : UIView = {
        let view = UITextField()
        //view.setDimension(height: 50, width: 390)
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.isUserInteractionEnabled = false
        
        let icon = UIImageView()
        view.addSubview(icon)
        icon.image = #imageLiteral(resourceName: "flag")
        icon.centerY(inView: view)
        icon.setDimension(height: 30, width: 30)
        icon.anchor(left: view.leftAnchor)
        
        
        
        
        let label = UILabel()
        view.addSubview(label)
        label.text = "Delivery Location"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .darkGray
        
        label.anchor(top: view.topAnchor ,left : icon.rightAnchor, paddingTop: 2, paddingLeft: 5)
        
        
        view.addSubview(destinationLabel)
        destinationLabel.anchor(left: icon.rightAnchor ,bottom: view.bottomAnchor ,right: view.rightAnchor )
        
        return view
    }()
    
    private lazy var destinationLocationContainer2 : UIView = {
        let view = UITextField()
        //view.setDimension(height: 50, width: 390)
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.isUserInteractionEnabled = false
        
        let icon = UIImageView()
        view.addSubview(icon)
        icon.image = #imageLiteral(resourceName: "flag")
        icon.centerY(inView: view)
        icon.setDimension(height: 30, width: 30)
        icon.anchor(left: view.leftAnchor)
        
        
        
        
        let label = UILabel()
        view.addSubview(label)
        label.text = "Delivery Location2"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .darkGray
        
        label.anchor(top: view.topAnchor ,left : icon.rightAnchor, paddingTop: 2, paddingLeft: 5)
        
        
        view.addSubview(destinationLabel2)
        destinationLabel2.anchor(left: icon.rightAnchor ,bottom: view.bottomAnchor ,right: view.rightAnchor )
        
        return view
    }()
    
    private lazy var destinationLocationContainer3 : UIView = {
           let view = UITextField()
           //view.setDimension(height: 50, width: 390)
           view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
           view.isUserInteractionEnabled = false
           
           let icon = UIImageView()
           view.addSubview(icon)
           icon.image = #imageLiteral(resourceName: "flag")
           icon.centerY(inView: view)
           icon.setDimension(height: 30, width: 30)
           icon.anchor(left: view.leftAnchor)
           
           
           
           
           let label = UILabel()
           view.addSubview(label)
           label.text = "Delivery Location3"
           label.font = UIFont.boldSystemFont(ofSize: 13)
           label.textColor = .darkGray
           
           label.anchor(top: view.topAnchor ,left : icon.rightAnchor, paddingTop: 2, paddingLeft: 5)
           
           
           view.addSubview(destinationLabel3)
           destinationLabel3.anchor(left: icon.rightAnchor ,bottom: view.bottomAnchor ,right: view.rightAnchor )
           
           return view
       }()
    
    private lazy var distanceView : UIView = {
        let view = UIView()
        //view.setDimension(height: 50, width: 180)
        view.backgroundColor = .lightBlue
        view.layer.cornerRadius = 6
        view.constrainHeight(50)
        
      
        view.addSubview(distanceLabel)
        distanceLabel.centerX(inView: view)
        distanceLabel.anchor(top: view.topAnchor , paddingTop: 5)
        
        
        let label2 = UILabel()
        view.addSubview(label2)
        label2.text = " Distance"
        label2.font = UIFont.systemFont(ofSize: 15)
        label2.textColor = .white
        label2.centerX(inView: view)
        label2.anchor(bottom: view.bottomAnchor , paddingBottom: 5)
        
        return view
    }()
    
    private lazy var fareView : UIView = {
        
        let view = UIView()
        
        view.backgroundColor = #colorLiteral(red: 0.2147612274, green: 0.371550858, blue: 1, alpha: 1)
        view.layer.cornerRadius = 6
//        view.layer.borderColor =  UIColor.darkGray.cgColor
//        view.layer.borderWidth = 1
        view.constrainHeight(50)
        
        view.addSubview(fareLabel)
        fareLabel.centerX(inView: view)
        fareLabel.anchor(top: view.topAnchor , paddingTop: 5)
        
        let label2 = UILabel()
        view.addSubview(label2)
        label2.text = " Total Time"
        label2.font = UIFont.systemFont(ofSize: 15)
        label2.textColor = .white
        label2.centerX(inView: view)
        label2.anchor(bottom: view.bottomAnchor , paddingBottom: 5)
        return view
    }()
    
    
    private let nextStepButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleNextStep), for: .touchUpInside)
        return button
    }()
    
   
    
    
    
    //MARK: -Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.layer.cornerRadius = 25
        addShadow()
         
      // configurePassengerConfirmTrip()
        
        setTableViewDelegate()
       configureTable()
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleNextStep(){
       /* let controller = FormController()
         var topVC = UIApplication.shared.keyWindow?.rootViewController
         while((topVC!.presentedViewController) != nil) {
             topVC = topVC!.presentedViewController
         }
         
        topVC?.present(controller, animated: true, completion: nil)
        */
      //  delegate?.showFormViewController()
        delegate?.uploadTriptoFirebase()
    }
    
   /* @objc func actionButtonPressed(){
        print("debug hello button")
    }
 */
    
    
    func setTableViewDelegate(){
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func reloadTableView(){
        tableview.reloadData()
    }
    
    func configurePassengerConfirmTrip(){
        
        
        
        let stack2 = UIStackView(arrangedSubviews: [distanceView, fareView])
         stack2.axis = .horizontal
         stack2.spacing = 30
         stack2.distribution = .fillEqually
         addSubview(stack2)
        
         stack2.centerX(inView: self)
         stack2.anchor(top:  topAnchor ,left: leftAnchor, right: rightAnchor, paddingTop: 12,paddingLeft: 20, paddingRight: 20)
         
         
         addSubview(sourceLocationContainer)
         sourceLocationContainer.anchor(top: stack2.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)
         
         addSubview(seperateView)
         seperateView.anchor(top: sourceLocationContainer.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 5, paddingLeft: 50, paddingRight: 25,height: 0.75)
         
         addSubview(destinationLocationContainer)
         destinationLocationContainer.anchor(top: seperateView.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)
        
        addSubview(seperateView2)
                seperateView2.anchor(top: destinationLocationContainer.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 5, paddingLeft: 50, paddingRight: 25,height: 0.75)
        
        
//
         addSubview(nextStepButton)
         nextStepButton.centerX(inView: self)
        nextStepButton.anchor(left: leftAnchor, bottom: bottomAnchor,right: rightAnchor, paddingLeft: 12, paddingBottom: 20 ,paddingRight: 12,height: 50)
    }
    
    func configureTable(){
        let stack2 = UIStackView(arrangedSubviews: [distanceView, fareView])
                stack2.axis = .horizontal
                stack2.spacing = 30
                stack2.distribution = .fillEqually
                addSubview(stack2)
               
                stack2.centerX(inView: self)
                stack2.anchor(top:  topAnchor ,left: leftAnchor, right: rightAnchor,
                paddingTop: 12,paddingLeft: 20, paddingRight: 20)
        
        addSubview(sourceLocationContainer)
                sourceLocationContainer.anchor(top: stack2.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)
        
        addSubview(nextStepButton)
         nextStepButton.centerX(inView: self)
        nextStepButton.anchor(left: leftAnchor, bottom: bottomAnchor,right: rightAnchor, paddingLeft: 12, paddingBottom: 20 ,paddingRight: 12,height: 50)
        
        addSubview(tableview)
        tableview.anchor(top: sourceLocationContainer.bottomAnchor, left: leftAnchor,  bottom: nextStepButton.topAnchor,right: rightAnchor, paddingBottom: 15)
               
                tableview.separatorStyle = .none
                tableview.tableFooterView = UIView()
                tableview.delaysContentTouches = false
                tableview.allowsSelection = false
                   //setdelegate
                setTableViewDelegate()
                   
               //disable scrolling
               tableview.alwaysBounceVertical = false
               
                   //set row height
                   tableview.rowHeight = 80
                   
                   //register cell
                   tableview.register(PreviewCell.self, forCellReuseIdentifier: Cells.previewCell)
                   
    }
    
    func destination2view(){
        addSubview(destinationLocationContainer2)
                   destinationLocationContainer2.anchor(top: seperateView2.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)

                    addSubview(seperateView3)
                    seperateView3.anchor(top: destinationLocationContainer2.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 5, paddingLeft: 50, paddingRight: 25,height: 0.75)
    }
    
    func destination3view(){
        addSubview(destinationLocationContainer3)
        destinationLocationContainer3.anchor(top: seperateView3.bottomAnchor, left: leftAnchor, right: rightAnchor,paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)
    }
    
   /*
    func configurePassengerDriverView(){
        
     
        
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
               stack.axis = .vertical
               stack.spacing = 4
               stack.distribution = .fillEqually
               
               addSubview(stack)
               stack.centerX(inView: self)
               stack.anchor(top: topAnchor, paddingTop: 12)
               
               addSubview(infoView)
               infoView.centerX(inView: self)
               infoView.anchor(top: stack.bottomAnchor, paddingTop: 16, width: 60, height: 60)
               infoView.layer.cornerRadius = 60 / 2
               
               addSubview(uberInfoLabel)
               uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 8)
               uberInfoLabel.centerX(inView: self)
               
               let separatorView = UIView()
               separatorView.backgroundColor = .lightGray
               addSubview(separatorView)
               separatorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor,
                                    right: rightAnchor, paddingTop: 4, height: 0.75)
               
               addSubview(actionButton)
               actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                   right: rightAnchor, paddingLeft: 12, paddingBottom: 12,
                                   paddingRight: 12, height: 50)
    }
 */
    func removeview(){
          destinationLocationContainer3.removeFromSuperview()
          destinationLocationContainer2.removeFromSuperview()
          seperateView3.removeFromSuperview()
    }
    
    func calculateTotalDistance(){
        var totalDistance : Double = 0.0
        destination.forEach { (dest) in
           
            guard let distance = dest?.distance else { return }
            totalDistance += distance/1000
        }
       
        let distanceText = String(format : "%.0f", round(totalDistance))
        distanceLabel.text = "\(distanceText) KM"
        
//        recipient.calculateDistance(recipientLocation: destination[0]?.placemark?.location, userLocation: source?.location) { (distance) in
//
//            distanceLabel.text = "\(distance) KM"
//
//
//        }
    }
    
    func calculateTotalTime(){
        var totalTravelTime : Double = 0.0
        destination.forEach { (dest) in
                 
                  guard let route = dest?.route else { return }
            totalTravelTime += route.expectedTravelTime/60
        }
        let timeText = String(format : "%.0f", totalTravelTime)
               fareLabel.text = "\(timeText) Min"
               
//        recipient.calculateFare { (fare) in
//            fareLabel.text = "RM \(fare)"
//        }
    }
    
  /*  func configureUI(withConfig config : RideActiveViewConfiguration){
        switch config {
            
        case .requestRide:
            configurePassengerConfirmTrip()
        case .tripAccepted:
             print ("debug 123sa")
              configurePassengerDriverView()
             titleLabel.text = "EN Route To Passenger"
             buttonAction = .getDirections
             actionButton.setTitle(buttonAction.description, for: .normal)
        case .pickupPassenger:
           break
        case .tripInProgress:
            break
        case .endTrip:
            break
       
        }
    }
 */
}

extension RideActiveView: UITableViewDelegate, UITableViewDataSource {
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return destination.count
 }
 
 //this get call everytime the new cell comes up to the screen
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableview.dequeueReusableCell(withIdentifier: Cells.previewCell) as! PreviewCell //to access the function in recordcell
    
     
     let placemark = self.destination[indexPath.row]?.placemark?.description
    let address = placemark!.split(separator: "@")
    

    cell.set(address: String(address[0]), index: indexPath.row + 1)
     return cell
 }
}
