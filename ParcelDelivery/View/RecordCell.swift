//
//  RecordCell.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 21/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit
import Foundation

protocol RecordCellDelegate: class {
    func delete(cell: RecordCell)
}

class RecordCell: UITableViewCell {
    
    weak var delegate: RecordCellDelegate?
    
    public var orderid : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .littleBlue
        return label
    }()
    
    public var time : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemGray
        return label
    }()
    
    public var status : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }()
   
    public let deleteButton : UIButton = {
        let button = UIButton(type: .system)
       
        //set the image for button
        let trash = UIImage(named: "trash")
        let tintedImage = trash?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .red

        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
   private lazy var cellView: UIView = {
        let view = UIView()
        
        view.backgroundColor  = UIColor.white
       view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,blue: 0/255.0, alpha: 1.0).cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 5
    
       view.addSubview(orderid)
       orderid.anchor(top: view.topAnchor, left: view.leftAnchor,paddingTop: 30, paddingLeft: 20,  height: 20)
    view.addSubview(status)
    status.anchor(top: orderid.bottomAnchor,left: view.leftAnchor, paddingTop: 10 ,paddingLeft: 20,height: 20)
    
      view.addSubview(time)
    time.anchor(top: status.bottomAnchor,left: view.leftAnchor, paddingTop: 10 ,paddingLeft: 20,height: 20)
    
//    view.addSubview(deleteButton)
//   deleteButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 50 ,paddingRight: 20, width: 50, height: 20)

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //add to contentview is better than add to subview
        contentView.addSubview(cellView)
        
        contentView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        deleteButton.anchor(top: self.topAnchor, right: self.rightAnchor, paddingTop: 95 ,paddingRight: 80, width: 20, height: 20)
        
       
        cellView.setDimension(height: 140, width: self.frame.width  )
        cellView.centerY(inView: self)
        cellView.centerX(inView: self)
      
//        addSubview(orderid)
//        addSubview(time)
//        addSubview(status)
        
        configureLabel()
        //setLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDelete(){
        print("debug hello \(self)")
        
        delegate?.delete(cell: self)
    }
    
    func set(record: Record){
        orderid.text = "Order ID: #\(record.orderid)"
        time.text = record.time
        status.text = record.status
        
        if status.text == "Completed" {
            status.textColor = .systemGreen
        }else {
            status.textColor = .red
        }
    }
    
    func configureLabel(){
        orderid.numberOfLines = 0
        orderid.adjustsFontSizeToFitWidth = true
        
        time.numberOfLines = 0
        time.adjustsFontSizeToFitWidth = true
        
        status.numberOfLines = 0
        status.adjustsFontSizeToFitWidth = true
    }
    

    func setLabel(){
        orderid.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 20, paddingLeft: 10, height: 20)
        time.anchor(top: orderid.bottomAnchor, left: self.leftAnchor, paddingTop: 10, paddingLeft: 10, height: 20)
        status.anchor(top: time.bottomAnchor, left: self.leftAnchor, paddingTop: 10, paddingLeft: 10, height: 20)


    }
    
    
    
    
}
