//
//  PreviewCell.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 05/04/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit

class PreviewCell: UITableViewCell {
     public let  destinationLabel : UILabel = {
             
           let label = UILabel()
           label.isUserInteractionEnabled = false
           label.text = " Lot 101, Jalan Pasar, 31900 Kampar, Perak"
           label.font = UIFont.boldSystemFont(ofSize: 15)
           label.textColor = .black
           return label
           
          }()
    
    public let destinationTitle : UILabel = {
        let label = UILabel()
      
        label.text = "Delivery Location"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .darkGray
        return label
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
        
        
      
        view.addSubview(destinationTitle)
        destinationTitle.anchor(top: view.topAnchor ,left : icon.rightAnchor, paddingTop: 2, paddingLeft: 5)
        
        
        view.addSubview(destinationLabel)
        destinationLabel.anchor(left: icon.rightAnchor ,bottom: view.bottomAnchor ,right: view.rightAnchor )
        
        return view
    }()
       

 override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    
    
     super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(destinationLocationContainer)
    destinationLocationContainer.anchor(top: self.topAnchor, left: self.leftAnchor, right: self.rightAnchor,paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 50)
    
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    func set(address : String, index : Int){
          
    //        print("debug index \(index)")
            destinationLabel.text = address
           destinationTitle.text = "Delivery Location \(index)"
            
        }

}
