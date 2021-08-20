//
//  LocationInputView.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 28/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit


protocol LocationInputViewDelegate : class{
    func dismissLocationInputView()
    func executeSearchQuery(query : [String] ) //new
    func confirmLocationView() // (latest)
    func form(int : Int)
    func alertMessageForDestinationLessThanOne()
}


//to allow user to input the location
class LocationInputView: UIView {

    //MARK: -properties
    var textInput : [UITextField?]  = []
    var tapIndex : Int = 0
    var texts : [Parcel?] = []
    var user : User? {
        didSet { titleLabel.text = user?.fullname}
    }
    
    weak var delegate : LocationInputViewDelegate?
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        
        return button
    }()
    
//    private let confirmButton : UIButton = {
//           let button = UIButton(type: .system)
//           button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
//           button.addTarget(self, action: #selector(handleConfirmTapped), for: .touchUpInside)
//
//           return button
//       }()
    
     private let titleLabel : UILabel = {
        let titileLabel = UILabel()
        titileLabel.textColor = .white
       
        titileLabel.font = UIFont.systemFont(ofSize: 16)
        return titileLabel
    }()
    
  
    private let startLocationInputTextField : UITextField = {
        let textField = UITextField ()
       
        textField.backgroundColor = UIColor.rgb(red: 236, green: 236, blue: 236)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Current Location",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.isEnabled = false
        textField.layer.cornerRadius = 3
       
        // to make the text  in the placeholder has some padding to the left
        let paddingView = UIView()
        paddingView.setDimension(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var destinationLocationInputTextField1 : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a delivery point.."
        textField.backgroundColor = UIColor.rgb(red: 236, green: 236, blue: 236)
        textField.returnKeyType = .search  // return key on keyboard is set to "search"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.layer.cornerRadius = 3
        textField.delegate = self
       
        
        // to make the text  in the placeholder has some padding to the left
        let paddingView = UIView()
        paddingView.setDimension(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var destinationLocationInputTextField2 : UITextField = {
           let textField = UITextField()
           textField.placeholder = "Enter a delivery point (optional)"
           textField.backgroundColor = UIColor.rgb(red: 236, green: 236, blue: 236)
           textField.returnKeyType = .search  // return key on keyboard is set to "search"
           textField.font = UIFont.systemFont(ofSize: 14)
           textField.layer.cornerRadius = 3
           textField.delegate = self
       
           
           // to make the text  in the placeholder has some padding to the left
           let paddingView = UIView()
           paddingView.setDimension(height: 30, width: 8)
           textField.leftView = paddingView
           textField.leftViewMode = .always
           return textField
       }()
    
    
    private lazy var destinationLocationInputTextField3 : UITextField = {
           let textField = UITextField()
           textField.placeholder = "Enter a delivery point (optional)"
           textField.backgroundColor = UIColor.rgb(red: 236, green: 236, blue: 236)
           textField.returnKeyType = .search  // return key on keyboard is set to "search"
           textField.font = UIFont.systemFont(ofSize: 14)
           textField.layer.cornerRadius = 3
           textField.delegate = self
     
           
           // to make the text  in the placeholder has some padding to the left
           let paddingView = UIView()
           paddingView.setDimension(height: 30, width: 8)
           textField.leftView = paddingView
           textField.leftViewMode = .always
           return textField
       }()
    
    private let startLocationIndicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView1 : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
        
    }()
    private let linkingView2 : UIView = {
          let view = UIView()
          view.backgroundColor = .white
          return view
          
      }()
    
    private let linkingView3 : UIView = {
             let view = UIView()
             view.backgroundColor = .white
             return view
             
         }()
    
    private let destinationLocationIndicatorView1 : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    private let destinationLocationIndicatorView2 : UIView = {
          let view = UIView()
          view.backgroundColor = .black
          return view
      }()
    
    private let destinationLocationIndicatorView3 : UIView = {
            let view = UIView()
            view.backgroundColor = .black
            return view
        }()
    //MARK: -lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightBlue
        addShadow()
        addSubview(backButton)
        backButton.anchor(top: topAnchor,left: leftAnchor, paddingTop: 44, paddingLeft:  12, width: 24,height: 25)
        
//        addSubview(confirmButton)
//               confirmButton.anchor(top: topAnchor,right: rightAnchor, paddingTop: 44, paddingRight:  12, width: 24,height: 25)
        
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)  // center it with backButton
        titleLabel.centerX(inView: self)
        
        
        addSubview(startLocationInputTextField)
        startLocationInputTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor ,right: rightAnchor,paddingTop: 4,paddingLeft: 40,paddingRight: 40, height: 30)
        
        addSubview(destinationLocationInputTextField1)
        destinationLocationInputTextField1.anchor(top: startLocationInputTextField.bottomAnchor, left: leftAnchor ,right: rightAnchor,paddingTop: 12,paddingLeft: 40,paddingRight: 40, height: 30)
        
        addSubview(destinationLocationInputTextField2)
        destinationLocationInputTextField2.anchor(top: destinationLocationInputTextField1.bottomAnchor, left: leftAnchor ,right: rightAnchor,paddingTop: 12,paddingLeft: 40,paddingRight: 40, height: 30)
        
        addSubview(destinationLocationInputTextField3)
        destinationLocationInputTextField3.anchor(top: destinationLocationInputTextField2.bottomAnchor, left: leftAnchor ,right: rightAnchor,paddingTop: 12,paddingLeft: 40,paddingRight: 40, height: 30)
        
        // the square
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startLocationInputTextField, leftAnchor: leftAnchor,paddingLeft: 20)
        startLocationIndicatorView.setDimension(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        
        //the square
        addSubview(destinationLocationIndicatorView1)
        destinationLocationIndicatorView1.centerY(inView: destinationLocationInputTextField1, leftAnchor: leftAnchor, paddingLeft: 20)
        destinationLocationIndicatorView1.setDimension(height: 6, width: 6)
   
        addSubview(destinationLocationIndicatorView2)
        destinationLocationIndicatorView2.centerY(inView: destinationLocationInputTextField2, leftAnchor: leftAnchor, paddingLeft: 20)
        destinationLocationIndicatorView2.setDimension(height: 6, width: 6)
        
        addSubview(destinationLocationIndicatorView3)
               destinationLocationIndicatorView3.centerY(inView: destinationLocationInputTextField3, leftAnchor: leftAnchor, paddingLeft: 20)
               destinationLocationIndicatorView3.setDimension(height: 6, width: 6)
        
        // the straight line
        addSubview(linkingView1)
        linkingView1.centerX(inView: startLocationIndicatorView)
        linkingView1.anchor(top: startLocationIndicatorView.bottomAnchor ,bottom: destinationLocationIndicatorView1.topAnchor ,paddingTop: 4, paddingBottom: 4, width : 0.5)
        
        addSubview(linkingView2)
        linkingView2.centerX(inView: destinationLocationIndicatorView1)
        linkingView2.anchor(top: destinationLocationIndicatorView1.bottomAnchor ,bottom: destinationLocationIndicatorView2.topAnchor ,paddingTop: 4, paddingBottom: 4, width : 0.5)

        addSubview(linkingView3)
             linkingView3.centerX(inView: destinationLocationIndicatorView2)
             linkingView3.anchor(top: destinationLocationIndicatorView2.bottomAnchor ,bottom: destinationLocationIndicatorView3.topAnchor ,paddingTop: 4, paddingBottom: 4, width : 0.5)
        
        //tap
        let tap1 = MyTapGesture(target: self, action: #selector(self.tapped(sender:)))
        destinationLocationInputTextField1.addGestureRecognizer(tap1)
      tap1.title = 0
       // tap1.textField = destinationLocationInputTextField1
            
          let tap2 = MyTapGesture(target: self, action: #selector(self.tapped(sender:)))
        destinationLocationInputTextField2.addGestureRecognizer(tap2)
       tap2.title = 1
       // tap2.textField = destinationLocationInputTextField2
        
        let tap3 = MyTapGesture(target: self, action: #selector(self.tapped(sender:)))
              destinationLocationInputTextField3.addGestureRecognizer(tap3)
        tap3.title = 2
//        tap3.textField = destinationLocationInputTextField3
       
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -functions
    func setTextToNil(){
        destinationLocationInputTextField1.text = ""
         destinationLocationInputTextField2.text = ""
        destinationLocationInputTextField3.text = ""
        
        tapIndex = 0
        
    }
    
    func modifyText(integer : Int,text : String){
        print("debug title modi \(texts)")
        if integer == 0 {
            destinationLocationInputTextField1.text = text
        }

        if integer == 1{
            destinationLocationInputTextField2.text = text
        }

        if integer == 2{
            destinationLocationInputTextField3.text = text
        }
//        textInput[integer]?.text = text
    }
    
    @objc func handleBackTapped (){
        
        texts.removeAll()
        
        //set the textbox text to nil
        setTextToNil()
        delegate?.dismissLocationInputView()
    }
    
    @objc func tapped(sender : MyTapGesture) {
        
//        if sender.title == nil  {
//            sender.title = tapIndex
//            textInput.append(sender.textField)
//            tapIndex += 1
//        }
       
        
        print("debug title \(sender.title)")
        delegate?.form(int: sender.title!)
      }
    
    
    @objc func handleConfirmTapped() { // (latest)
        var destination : [String] = []
        
        texts.forEach { (text) in
            destination.append(text!.courierCenter)
        }

//        destination.append(destinationLocationInputTextField1.text!)
//        destination.append(destinationLocationInputTextField2.text!)
        
        //validation
        print("debug title texts \(destination)")
        
        if destinationLocationInputTextField1.text == ""{
            
            //validation for destination input text
            delegate?.alertMessageForDestinationLessThanOne()
        }else{
           // delegate?.executeSearchQuery(query: destination)
            delegate?.confirmLocationView()
        }
        
//        delegate?.confirmLocationView(destinationCoordinates: destinationCoordinates) // (latest)
  
        //remove it after calling executeSearch
         texts.removeAll()
         setTextToNil()
      
    }
    
      
        
    
    
    
    
        
}

// MARK: - UITEXTFIELDDELEGATe
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        guard let query = textField.text else { return false }
       
      
//        delegate?.executeSearchQuery(query: query)
        return true
    }
}

class MyTapGesture: UITapGestureRecognizer {
    var title : Int?
    var textField : UITextField?
}
