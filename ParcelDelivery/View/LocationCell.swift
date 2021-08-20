//
//  LocationCell.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 29/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    // MARK: - properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.title
            
            
        }
    }
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.black
       label.backgroundColor = UIColor.white
        return label
    }()
    
    private let addressLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.backgroundColor = UIColor.white
       
        return label
    }()
    // MARK: -Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = UIColor.white
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor , paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
