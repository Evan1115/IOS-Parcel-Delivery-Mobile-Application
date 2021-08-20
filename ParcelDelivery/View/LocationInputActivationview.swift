//
//  LocationInputActivationview.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 28/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit

//allow user to activate the input option
protocol LocationInputActivationViewDelegate : class {
    func presentLocationInputview()
}

//view container to hold label and the black square
class LocationInputActivationView : UIView{
    //MARK - Properties
    
    weak var delegate : LocationInputActivationViewDelegate?
    private let indicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let indicatorView2 : UIView = {
           let view = UIView()
           view.backgroundColor = .black
           return view
       }()
    //MARK - Lifecycle
    private let placeholderLabel : UIView = {
        let label = UILabel()
        label.text = "Where to ?"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
        
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        //set shadow for indicator view container
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16 )
        indicatorView.setDimension(height: 6, width: 6)
        
      
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 16)
        
        //Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        
     
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK - Selectors
    
    @objc func presentLocationInputView(){
        delegate?.presentLocationInputview()
    }
}
