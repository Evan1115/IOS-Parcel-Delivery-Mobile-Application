//
//  DriverMenuBar.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 24/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit

protocol DriverMenuBarDelegate: class {
    func handleDriverMenuOption(option : String)
    func handleSwitchButtonOption(isOn: Bool)
}


class DriverMenuBar: UIView {
   weak var delegate : DriverMenuBarDelegate?
     private let orderText : UILabel = {
         let label = UILabel()
         label.text = "History"
         label.font = UIFont.boldSystemFont(ofSize: 14)
         label.textColor = .systemGray
         return label
     }()
     
     private let orderHistory : UILabel = {
         let label = UILabel()
         label.text = "Status"
         label.font = UIFont.boldSystemFont(ofSize: 14)
         label.textColor = .systemGray
         return label
     }()
     
     private let logout : UILabel = {
         let label = UILabel()
         label.text = "Logout"
         label.font = UIFont.boldSystemFont(ofSize: 14)
         label.textColor = .systemGray
         return label
     }()

     private let circle : UIButton = {
         let button = UIButton()
         
         //set the image for button
         button.setImage(#imageLiteral(resourceName: "result").withRenderingMode(.alwaysOriginal), for: .normal)
         button.imageEdgeInsets = UIEdgeInsets(top: 13, left: 15, bottom: 13, right: 8)
         button.layer.cornerRadius = 65/2
         button.clipsToBounds = true
          button.titleLabel?.text = "history"
         button.adjustsImageWhenHighlighted = false
         button.backgroundColor = .lightBlue
         button.addTarget(self, action:  #selector(handleMenu(sender:)), for: .touchUpInside)
         return button
         
     }()
     
//     private let ARButton : UIButton = {
//          let button = UIButton()
//
//          //set the image for button
//          button.setImage(#imageLiteral(resourceName: "camera").withRenderingMode(.alwaysTemplate), for: .normal)
//        button.imageView?.tintColor = .gray
//         button.titleLabel?.text = "status"
//          button.adjustsImageWhenHighlighted = false
//         button.addTarget(self, action:  #selector(handleMenu(sender:)), for: .touchUpInside)
//          return button
//
//      }()
     
     private let logoutButton : UIButton = {
         let button = UIButton()
          
          //set the image for button
         button.setImage(#imageLiteral(resourceName: "exit").withRenderingMode(.alwaysTemplate), for: .normal)
         button.imageView?.tintColor = .gray
         button.titleLabel?.text = "logout"
          button.adjustsImageWhenHighlighted = false
          button.addTarget(self, action:  #selector(handleMenu(sender:)), for: .touchUpInside)
          return button
          
      }()
     private lazy var historyView : UIView = {
         let view = UIView()
         //view.backgroundColor = .red
         
         let switchDemo = UISwitch()
         switchDemo.isOn = true
         switchDemo.onTintColor = .lightBlue
         switchDemo.setOn(true, animated: false)
         switchDemo.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
         view.addSubview(switchDemo)
        
        switchDemo.anchor(top:view.topAnchor, left: view.leftAnchor,paddingTop: 10,paddingLeft: 25)
         
         
         view.addSubview(orderHistory)
         orderHistory.centerX(inView: view)
         orderHistory.anchor(bottom:view.bottomAnchor, paddingBottom: 15)
         return view
     }()
     
     private lazy var logoutView : UIView = {
            let view = UIView()
           // view.backgroundColor = .red
            
            view.addSubview(logoutButton)
            logoutButton.centerX(inView: view)
            logoutButton.anchor(top:view.topAnchor, paddingTop: 10)
            logoutButton.setDimension(height: 30, width: 30)
            
            view.addSubview(logout)
            logout.centerX(inView: view)
            logout.anchor(bottom:view.bottomAnchor, paddingBottom: 15)
            return view
        }()
     

    override init(frame: CGRect) {
         super.init(frame: frame)
         backgroundColor = . white
        
         addSubview(circle)
         circle.setDimension(height: 65, width: 65)
         circle.centerX(inView: self)
         circle.anchor(bottom: self.bottomAnchor ,  paddingBottom: 35)
         
         addSubview(historyView)
         historyView.anchor(top: self.topAnchor, left : self.leftAnchor, paddingLeft: 25)
         historyView.setDimension(height: 80, width: 100)
         
         addSubview(logoutView)
         logoutView.anchor(top: self.topAnchor, right : self.rightAnchor, paddingRight: 25)
         logoutView.setDimension(height: 80, width: 100)
     
         addSubview(orderText)
         orderText.centerX(inView: self)
         orderText.anchor(bottom:self.bottomAnchor, paddingBottom: 15)
     }
     
     
     
     required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
      
    
     @objc func handleMenu(sender : UIButton){
         guard let optionName = sender.titleLabel?.text else { return }
         
         delegate?.handleDriverMenuOption(option : optionName )
     }
    
//    func configureSwitchButton(){
//        let switchDemo = UISwitch(frame:CGRect(x: 0, y: 0, width: 100, height: 50))
//        switchDemo.isOn = true
//        switchDemo.onTintColor = .lightBlue
//        switchDemo.setOn(true, animated: false)
//        switchDemo.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
//        addSubview(switchDemo)
//        switchDemo.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 20, paddingLeft: 50)
//
//    }
    
 
 //toggle user location enable/disable
 @objc func switchValueDidChange(_ sender: UISwitch!) {

    
    delegate?.handleSwitchButtonOption(isOn: sender.isOn)
 }
    
}
