//
//  FormController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 18/06/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import LBTATools

protocol FormControllerDelegate : class {
    func uploadTrip()
}
class FormController : LBTAFormController {
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "About Recipient"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
       
        return label
    }()
    
    weak var delegate : FormControllerDelegate?
    
    private let nameTextContainer : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)

        let image = UIImageView()
        view.addSubview(image)
        image.image = #imageLiteral(resourceName: "person")
        image.centerY(inView: view)
        image.anchor(left: view.leftAnchor , width: 24, height: 24)
        
        let tf = UITextField()
        view.addSubview(tf)
        tf.placeholder = "Recipient Name"
        tf.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        tf.centerY(inView: view)
        tf.anchor(left: image.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        tf.constrainHeight(50)
        
        return view
    }()
    
    private let addressTextContainer : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        
       
        
        let image = UIImageView()
        view.addSubview(image)
        image.image = #imageLiteral(resourceName: "address")
        image.centerY(inView: view)
        image.anchor(left: view.leftAnchor , width: 24, height: 24)
        
        let tf = UITextField()
        view.addSubview(tf)
        tf.placeholder = "Additional details : House / Office No. ....."
        tf.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        tf.centerY(inView: view)
        tf.anchor(left: image.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        tf.constrainHeight(50)
        
       
        return view
    }()
    
    private let phoneTextContainer : UIView = {
           let view = UIView()
           view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
           
          
           
           let image = UIImageView()
           view.addSubview(image)
           image.image = #imageLiteral(resourceName: "phone")
           image.centerY(inView: view)
           image.anchor(left: view.leftAnchor , width: 24, height: 24)
           
           let tf = UITextField()
           view.addSubview(tf)
           tf.placeholder = "Mobile Number (Optional)"
           tf.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
           tf.centerY(inView: view)
           tf.anchor(left: image.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
           tf.constrainHeight(50)
           
          
           return view
       }()
    
    private let parcelTextContainer : UIView = {
           let view = UIView()
           view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
           
          
           
           let image = UIImageView()
           view.addSubview(image)
           image.image = #imageLiteral(resourceName: "parcel")
           image.centerY(inView: view)
           image.anchor(left: view.leftAnchor , width: 24, height: 24)
           
           let tf = UITextField()
           view.addSubview(tf)
           tf.placeholder = "Parcel Details"
           tf.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
           tf.centerY(inView: view)
           tf.anchor(left: image.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
           tf.constrainHeight(50)
           
          
           return view
       }()
    
    private let noteTextContainer : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        
       
        
        let image = UIImageView()
        view.addSubview(image)
        image.image = #imageLiteral(resourceName: "note")
        image.centerY(inView: view)
        image.anchor(left: view.leftAnchor , width: 24, height: 24)
        
        let tf = UITextField()
        view.addSubview(tf)
        tf.placeholder = "Delivery instructions "
        tf.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        tf.centerY(inView: view)
        tf.anchor(left: image.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        tf.constrainHeight(50)
        
       
        return view
    }()
    
    private let submitButton : UIButton = {
    let submitButton = UIButton(title: "Submit", titleColor: .white, font: .boldSystemFont(ofSize: 16), backgroundColor: .lightBlue, target: self, action: #selector(handleSubmit))
        submitButton.layer.cornerRadius = 8
         return submitButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9332515597, green: 0.9333856702, blue: 0.9332222342, alpha: 1)
        
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 12
        formContainerStackView.layoutMargins = .init(top: 30, left: 24, bottom: 0, right: 24)
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.constrainHeight(0.75)
        
        formContainerStackView.addArrangedSubview(titleLabel)
        titleLabel.centerX(inView: view)
        formContainerStackView.addArrangedSubview(separator)
        formContainerStackView.addArrangedSubview(nameTextContainer)
        formContainerStackView.addArrangedSubview(addressTextContainer)
        formContainerStackView.addArrangedSubview(phoneTextContainer)
        formContainerStackView.addArrangedSubview(parcelTextContainer)
        formContainerStackView.addArrangedSubview(noteTextContainer)
    
        
        formContainerStackView.addArrangedSubview(submitButton)
        submitButton.constrainHeight(50)
    }
    
    
    @objc func handleSubmit(){
        
        delegate?.uploadTrip()
        self.dismiss(animated: true, completion: nil)
    }
}
