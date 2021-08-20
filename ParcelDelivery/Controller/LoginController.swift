//
//  LoginController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 24/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import Firebase

class LoginController : UIViewController{
    
   
    //Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Speed Delivery"
        label.textColor = .black
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 36)
        return label
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-new-post-50"), textField: emailTextField,shadow: true)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return view
    }()
    
    private lazy var passwordContainerView : UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "icons8-password-50"), textField: passwordTextField, shadow : true)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return view
    }()
    
    private let iconContainerView : UIView = {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "How-to-improve-my-E-commerce-conversion-rate-with-Shipping-Returns-Policy")
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        
        return view
    }()
    
    private let emailTextField : UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextField : UITextField = {
       return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
         button.setTitle("Log In", for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
        
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton (type: .system)
        let attributedTitle = NSMutableAttributedString ( string: "Don't have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString ( string: "Sign Up ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightBlue]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    // LifeCyle
    override func viewDidLoad(){
        super.viewDidLoad()
      
        configuredUI()
       let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
              view.addGestureRecognizer(tapGesture)
        //listen for keyboard event
     
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // MARK: Selectors
    
    @objc func handleShowSignUp() {
       
        let controller = SignUpController()
        
        
       
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print ("DEBUG: Failed to sign in \(error.localizedDescription)")
                return
            }
            // show map when log in is successful
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else { return }
            controller.configure()
            self.dismiss(animated: true, completion: nil)
        }
    }
  



    
    // MARK: - Helper Function
    
    func configuredUI(){
       navigationController?.navigationBar.isHidden = true
      

        view.backgroundColor = .white
              
              // titlelable
              view.addSubview(titleLabel)
              titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
              titleLabel.centerX(inView: view)
              
              
              view.addSubview(iconContainerView)
              iconContainerView.anchor(top : titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30 ,paddingLeft: 16, paddingRight: 16, height: 200)

              
              // place containerView in stack
              let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView,loginButton])
              stack.axis = .vertical
              stack.distribution = .fillEqually
              stack.spacing = 16  // spacing between containerView
              
              view.addSubview(stack)
              stack.anchor(top: iconContainerView.bottomAnchor ,left: view.leftAnchor ,right : view.rightAnchor , paddingTop: 50 , paddingLeft: 16, paddingRight: 16)
              
              
              view.addSubview(dontHaveAccountButton)
              dontHaveAccountButton.centerX(inView: view)
              dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor ,height: 30)
    }
    
  
    
}
