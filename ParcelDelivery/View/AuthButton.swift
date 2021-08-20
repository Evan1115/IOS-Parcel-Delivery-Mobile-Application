//
//  AuthButton.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 26/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        backgroundColor = .blue
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        backgroundColor = .lightBlue
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
