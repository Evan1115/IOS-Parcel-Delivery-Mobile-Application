//
//  OrderCell.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 31/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit
protocol OrderCellDelegate: class {
    func delete(cell: OrderCell)
    
    func edit(cell: OrderCell)
}

class OrderCell: UITableViewCell {
    
    weak var delegate : OrderCellDelegate?
    
    public var courierCenterAddress : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        
        
        return label
    }()
    
    public var serialNo : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .systemGray
        
        return label
    }()
    
    public let deliveryLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
       
        return label
    }()
    
    public let editButton : UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.font =  UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .orange
        
       
        
        return label
    }()
    
    public let deleteButton : UIButton = {
          let button = UIButton(type: .system)
         
          //set the image for button
          let trash = UIImage(named: "remove")
          let tintedImage = trash?.withRenderingMode(.alwaysTemplate)
          button.setImage(tintedImage, for: .normal)
          button.tintColor = .orange

          button.layer.cornerRadius = 10
          button.backgroundColor = .white
          button.setTitleColor(.white, for: .normal)
          
          return button
      }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(deliveryLabel)
        deliveryLabel.anchor(top: self.topAnchor, left: self.leftAnchor, paddingLeft: 15, height: 14)
   
        contentView.addSubview(courierCenterAddress)
        courierCenterAddress.anchor(top: self.topAnchor, left: self.leftAnchor,  right: self.rightAnchor, paddingTop: 23, paddingLeft: 15, paddingRight: 45, height: 20)
        
        contentView.addSubview(serialNo)
        serialNo.anchor(top: courierCenterAddress.bottomAnchor, left: self.leftAnchor,  right: self.rightAnchor, paddingTop: 5, paddingLeft: 15, paddingRight: 15, height: 20)
        
        contentView.addSubview(editButton)
        editButton.anchor(top: self.topAnchor, right: self.rightAnchor, paddingTop: 15, paddingRight: 15, width: 30, height: 20)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEdit))
        editButton.isUserInteractionEnabled = true
        editButton.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(deleteButton)
        deleteButton.anchor( top: editButton.bottomAnchor, right: self.rightAnchor, paddingTop: 10, paddingRight: 20, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        
      
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    @objc func handleDelete(){
        print("debug delete")
        delegate?.delete(cell: self)
    }
    
    @objc func handleEdit(){
        print("edit")
        delegate?.edit(cell: self)
    }
    
    func set(order: Order, index: Int){
      
//        print("debug index \(index)")
        deliveryLabel.text = "Location \(index)"
        courierCenterAddress.text = order.courier
        serialNo.text = order.serial
    }

}
