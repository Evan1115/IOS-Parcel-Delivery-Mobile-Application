//
//  SignUpController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 25/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    //MARK : -Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
          let label = UILabel()
          label.text = "Speed Delivery"
          label.textColor = .black
          label.font = UIFont(name: "HelveticaNeue-Bold", size: 36)
          return label
      }()
    
    private let iconContainerView : UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "How-to-improve-my-E-commerce-conversion-rate-with-Shipping-Returns-Policy")
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        
        return view
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-new-post-50"), textField: emailTextField, shadow: true)
           view.heightAnchor.constraint(equalToConstant: 50).isActive = true
           
           return view
       }()
       
       private lazy var passwordContainerView : UIView = {
           let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-password-50"), textField: passwordTextField,shadow: true)
           view.heightAnchor.constraint(equalToConstant: 50).isActive = true
           
           return view
       }()
    
    private lazy var nameContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-user-30"), textField: nameTextField,shadow: true)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return view
    }()
    
    private lazy var accountTypeContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-name-30"), segmentedControl: accountTypeSegmentedController )
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    
    private let emailTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextField : UITextField = {
       return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let nameTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    private let accountTypeSegmentedController : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Customer" , "Driver"])
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.5)]
        sc.setTitleTextAttributes(titleTextAttributes, for: .selected)
        sc.backgroundColor = .white
       
        sc.selectedSegmentTintColor = .littleBlue
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let SignUpButton: AuthButton = {
        let button = AuthButton(type: .system)
         button.setTitle("Sign Up", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton (type: .system)
        let attributedTitle = NSMutableAttributedString ( string: "Already have an acoount? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString ( string: "Sign In ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightBlue]))
        
        button.addTarget(self, action: #selector(handleShowSignIn), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    //MARK : -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignUpUI()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
       
        
    
    }
    
    //MARK : -Selectors
    @objc func handleShowSignIn() {
        navigationController?.popViewController(animated: true)
            }
    
    @objc func handleSignUp(){
        guard let email =  emailTextField.text else { return}
        guard let password = passwordTextField.text else { return }
        guard let fullName = nameTextField.text else {return}
        let accountTypeIndex = accountTypeSegmentedController.selectedSegmentIndex
        print (email)
        print( password)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print ("DEBUG: Failed to register \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            let values = [ "email": email , "fullname" : fullName,
                "accountType" : accountTypeIndex ] as [String : Any]

            
            if accountTypeIndex == 1 {  // if sign up as driver then save their data into database
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else {return}
            
                
                geofire.setLocation(location, forKey: uid) { (error) in
                    
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                          
                }
                
            }
            self.uploadUserDataAndShowHomeController(uid: uid, values: values) //else is a user save the data into database
        }
    }
   
    
    //MARK : - Functions
    
    func uploadUserDataAndShowHomeController(uid: String , values: [String: Any]){
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            // show map when sign up is success
             guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return }
             controller.configure()
             self.dismiss(animated: true, completion: nil)
        })
    }
    func configureSignUpUI(){
        view.backgroundColor = .white
        
        // titlelable
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        titleLabel.centerX(inView: view)
        
        //icon
        view.addSubview(iconContainerView)
                 iconContainerView.anchor(top : titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30 ,paddingLeft: 16, paddingRight: 16, height: 200)
        
        // stack
        let stack = UIStackView(arrangedSubviews: [emailContainerView, nameContainerView,passwordContainerView,accountTypeContainerView,SignUpButton])
                     stack.axis = .vertical
                     stack.distribution = .fillProportionally
                     stack.spacing = 16  // spacing between containerView
                     
                     view.addSubview(stack)
                     stack.anchor(top: iconContainerView.bottomAnchor ,left: view.leftAnchor ,right : view.rightAnchor , paddingTop: 50 , paddingLeft: 16, paddingRight: 16)
        

        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor ,height: 30)
                     
    }
}
