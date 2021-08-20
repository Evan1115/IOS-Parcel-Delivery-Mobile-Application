//
//  OrderController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 31/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



class OrderController: UIViewController {
     private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
      private let mergesort = Mergesort()
 
    
    var order : [Order] = []
    var index : Int = 0
    var editIndex : Int = 0
    var isEdit : Bool = false
    var tableview = UITableView()
    private let bluringEffect : UIView = {
        let view = UIView()
              //view.frame = self.view.frame
              view.backgroundColor = .black
              view.alpha = 0.7
              view.tag = 1
        return view
    }()
    
    private let courierNameTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
       
        textField.keyboardAppearance = .light
        textField.attributedPlaceholder = NSAttributedString(string: "Courier Center Name*", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return textField
    }()
    
    private let serialNoTextField : UITextField = {
           let textField = UITextField()
           textField.borderStyle = .none
           textField.font = UIFont.systemFont(ofSize: 14)
           textField.textColor = .black
        textField.textAlignment = .left
           textField.keyboardAppearance = .light
           textField.attributedPlaceholder = NSAttributedString(string: "Serial No*", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
           return textField
       }()
    
    private let separateLine1 : UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    
    private let separateLine2 : UIView = {
          let line = UIView()
          line.backgroundColor = .lightGray
          return line
      }()
    
    private let saveButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 6
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    public let exitButton : UIButton = {
        let button = UIButton(type: .system)
       
        //set the image for button
        let trash = UIImage(named: "cancel")
        let tintedImage = trash?.withRenderingMode(.alwaysOriginal)
        button.setImage(tintedImage, for: .normal)
       button.addTarget(self, action: #selector(handleExit), for: .touchUpInside)
        button.setDimension(height: 18, width: 18)
        
        return button
    }()
    
    private lazy var formView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        let title = UILabel()
        title.text = "Delivery Details"
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .lightBlue
        view.addSubview(title)
        title.centerX(inView: view)
        title.anchor(top: view.topAnchor, paddingTop: 40)
  
        view.addSubview(courierNameTextField)
        courierNameTextField.centerX(inView: view)
        courierNameTextField.anchor(top: title.bottomAnchor, left: view.leftAnchor,right: view.rightAnchor, paddingTop: 30,paddingLeft: 20,paddingRight: 20, height: 50)
        
        view.addSubview(separateLine1)
        separateLine1.anchor(top: courierNameTextField.bottomAnchor, left: view.leftAnchor,right: view.rightAnchor, paddingTop:-10,paddingLeft: 20,paddingRight: 20, height: 1)
        
        
        
        view.addSubview(serialNoTextField)
        serialNoTextField.centerX(inView: view)
        serialNoTextField.anchor(top: courierNameTextField.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor, paddingTop: 10,paddingLeft: 20,paddingRight: 20, height: 50)
        
        view.addSubview(separateLine2)
        separateLine2.anchor(top: serialNoTextField.bottomAnchor, left: view.leftAnchor,right: view.rightAnchor, paddingTop:-10,paddingLeft: 20,paddingRight: 20, height: 1)
        
        view.addSubview(saveButton)
        saveButton.anchor( left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingLeft: 20,paddingBottom: 20,paddingRight: 20)
        
        view.addSubview(exitButton)
        exitButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 20,paddingRight: 20)
        

        return view
    }()
    
    /// tableview UI
    private let pickupLabel : UILabel = {
        let label = UILabel()
        label.text = "Pickup Location"
       
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let destinationLabel : UILabel = {
        let label = UILabel()
        label.text = "Delivery Location"
       
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let currentAddress : UILabel = {
        let label = UILabel()
       
        label.textColor = .systemGray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let addLocationText : UILabel = {
        let label = UILabel()
        label.text = "Add delivery location"
        label.textColor = .orange
         label.font = UIFont.systemFont(ofSize: 16)
       return label
    }()
    
    private let continueButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .lightBlue
        button.layer.cornerRadius = 6
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    
    
    private lazy var addLocationButton : UIView = {
       let view = UIView()
        //set the image for button
        view.backgroundColor = .none
        
        let add = UIImage(named: "add")
        
       
        
        let imageView = UIImageView(image: add)
        imageView.setImageColor(color: .orange)
        imageView.setDimension(height: 20, width: 20)
        
        
        view.addSubview(imageView)
        imageView.centerY(inView: view)
        imageView.anchor( left: view.leftAnchor)
        
        view.addSubview(addLocationText)
        addLocationText.centerY(inView: view)
        addLocationText.anchor( left: imageView.rightAnchor, paddingLeft: 10)
        
        
        
        
       let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(targetViewDidTapped))
       gesture.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    
    struct Cells{
           static let orderCell = "OrderCell"
       }
 
    //initialize
    init( userAddress : String) {
        self.currentAddress.text = userAddress
        
        super.init(nibName: nil, bundle : nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.title = "Order Details"
        
        
        setTableViewDelegate()
        configureTableView()
        
        configureTabBar()
        // Do any additional setup after loading the view.
    }
    
    func configureTabBar(){
           let button = UIButton(type: .system)
          button.frame = CGRect(x: -10, y: 0, width: 30, height: 30 )
          button.backgroundColor = nil
          button.setImage(UIImage.init(named: "left-arrow"), for: .normal)
          button.addTarget(self, action: #selector(dismissRecord), for: .touchUpInside)

          let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 35)));
          view.addSubview(button);
          view.backgroundColor = nil

          let leftButton = UIBarButtonItem(customView: view)
          self.navigationItem.leftBarButtonItem = leftButton

          navigationController?.navigationBar.barTintColor = .lightBlue
          navigationController?.navigationBar.tintColor = .white
          navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
                //123
                  
      }
    
    func configureForm(){
        view.addSubview(bluringEffect)
                   bluringEffect.frame = self.view.frame
                   view.addSubview(formView)
                   formView.centerY(inView: view)
                   formView.centerX(inView: view)
                   formView.setDimension(height: view.frame.size.height/3, width: view.frame.size.width/1.5)
    }
    
    //selectors
    
    @objc func targetViewDidTapped(){
        print("debug tag")
        
        //if delivery location more than 6 then display error message
        if self.order.count > 5 {
            self.presentAlertController(withTitle: "Tips", message: "Maximum number of delivery location has reached.")
        }else {
            configureForm()
        }
            
    }
    
    @objc func dismissRecord(){
          dismiss(animated: true, completion: nil)
           guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return }
          controller.returnToHomePage()
     }
    
    @objc func handleContinue (){
        print("deug order \(self.order)")
        print("handle continue")
        if self.order.count < 1 {
            self.presentAlertController(withTitle: "Tips", message: "Please set at least one delivery location")
        }else {
            
           
            dismiss(animated: true, completion: nil)
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return }
            controller.dismissOrderVC(orders: self.order)
        }
     
    }
    
    @objc func handleSave(){
        
        print("debug save")
        
        if courierNameTextField.text == "" || serialNoTextField.text == "" {
            self.presentAlertController(withTitle: "Tips", message: "Please fill in required detail")
        }else{
            getNearestCourierCenter()
        }
        
    }
        
    @objc func handleExit(){
        print("debug exit")
        
        formView.removeFromSuperview()
        bluringEffect.removeFromSuperview()
          self.isEdit = false
        
        //clear the text field
        courierNameTextField.text = ""
        serialNoTextField.text = ""
    }
    
    

       func configureTableView(){
            view.backgroundColor = .white
            
        view.addSubview(pickupLabel)
        pickupLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 12, paddingRight: 12, width: 50)
        
        view.addSubview(currentAddress)
          currentAddress.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12, width: 50)

        
        view.addSubview(destinationLabel)
        destinationLabel.anchor(top: currentAddress.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 12, paddingRight: 12, width: 50)
        
        view.addSubview(addLocationButton)
        addLocationButton.anchor(top: destinationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12, width: 100, height: 30)
        
        let line = UIView()
        line.backgroundColor = .lightGray
        view.addSubview(line)
        line.anchor(top: addLocationButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 5, paddingLeft: 12, paddingRight: 12, height: 1)
        
        view.addSubview(continueButton)
        continueButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,  paddingLeft: 12, paddingBottom: 50, paddingRight: 12)
        
        view.addSubview(tableview)
               tableview.anchor(top: line.bottomAnchor, left: view.leftAnchor, bottom: continueButton.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingBottom: 10)
        
            tableview.separatorStyle = .none
            tableview.tableFooterView = UIView()
            tableview.delaysContentTouches = false
            tableview.allowsSelection = false
            //setdelegate
            setTableViewDelegate()
            
        //disable scrolling
        tableview.alwaysBounceVertical = false
        
            //set row height
            tableview.rowHeight = 100
            
            //register cell
            tableview.register(OrderCell.self, forCellReuseIdentifier: Cells.orderCell)
            
            //set constraints
           // tableview.pin(to: view)
        }
        
        func setTableViewDelegate(){
            tableview.delegate = self
            tableview.dataSource = self
        }
        
    func getIndex(order: OrderCell)  {
        let index = tableview.indexPath(for: order)
       print("debug index index \(index)")
    }
    
    func reloadAndReset(){
        self.tableview.reloadData()
        self.index = 0
    }
    
    func confirmationDelete(indexPath : IndexPath){
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete?", preferredStyle: .alert)
         
        //add delete option
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            
            self.order.remove(at: indexPath.row)
            self.tableview.deleteRows(at: [indexPath], with: .fade)
                   
            //reload data and reset index
            self.reloadAndReset()
        
        }))
    
        //add cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated : true, completion: nil)
      
    }

}

extension OrderController: UITableViewDelegate, UITableViewDataSource {
    
  
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
////        if (editingStyle == .delete) {
////            records.remove(at: indexPath.row)
////            tableView.beginUpdates()
////            tableView.deleteRows(at: [indexPath], with: .middle)
////            tableView.endUpdates()
////        }
//  }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return order.count
    }
    
    //this get call everytime the new cell comes up to the screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: Cells.orderCell) as! OrderCell //to access the function in recordcell
        
        cell.delegate = self
        
        let order = self.order[indexPath.row]
        
       
        cell.set(order: order ,index :indexPath.row + 1)
        
        return cell
    }
    
    
 
    
}

extension OrderController: OrderCellDelegate {
    func edit(cell: OrderCell) {
         guard let index = tableview.indexPath(for: cell) else { return }
        configureForm()
        courierNameTextField.text = cell.courierCenterAddress.text
        serialNoTextField.text = cell.serialNo.text
        
        self.isEdit = true
        self.editIndex = index.row
         
    }
    
    func delete(cell: OrderCell) {
        guard let index = tableview.indexPath(for: cell) else { return }
        confirmationDelete(indexPath: index)
       
    }
    
    
}

extension OrderController {
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
    
    func getNearestCourierCenter(){
        guard let couriername = courierNameTextField.text else { return }
        guard let serialno = serialNoTextField.text else { return }
        
        //get all the possible location of user input
        searchBy(naturalLanguageQuery: couriername) { (placemarks) in
            //find the nearest
            self.mergesort(results: placemarks) { (nearestPlacemark) in
                self.formView.removeFromSuperview()
                self.bluringEffect.removeFromSuperview()
                
                //split the text
                let name = nearestPlacemark.description.split(separator: "@")
             
                
                //create new order item
                let parcel = Order(courier: String(name[0]), serial: serialno, placemark: nearestPlacemark)
                
                
                //add new order to the array or edit current array
                if self.isEdit == true {
                    self.order[self.editIndex] = parcel
                    self.isEdit = false
                }else{
                    self.order.append(parcel)
                }
                
                
                //reload data and reset index
                self.reloadAndReset()
                
                //clear the text field
                self.courierNameTextField.text = ""
                self.serialNoTextField.text = ""
            }//mergesort
            
        }//search
        
        
    }//getNearby
    
    func mergesort(results : [MKPlacemark], completion: @escaping(MKPlacemark) -> Void) {
        //get current user location
        guard let sourceCoordinate = self.locationManager?.location?.coordinate else { return }
        let sourceClllocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
                   
        
                   
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
    
       
       //sorting progress
  //    places.sort(by: {$0.distance < $1.distance}) old
       self.mergesort.quickSort(array: &places, startIndex: 0, endIndex: places.count - 1) //new method
     
      
     
       
      guard let placemark = places[0].placemark else { return }
      completion(placemark)
    }
}
