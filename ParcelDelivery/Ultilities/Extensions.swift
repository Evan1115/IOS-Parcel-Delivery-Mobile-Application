//
//  Extensions.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 24/05/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit
import MapKit

extension UIColor {
    static func rgb(red: CGFloat,green: CGFloat,blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let lightBlue = UIColor.rgb(red: 55, green: 95, blue: 255)
    static let littleBlue = UIColor.rgb(red: 3, green: 30, blue: 73)
    
    static let brightGreen = UIColor.rgb(red: 74, green: 210, blue: 149)
    static let blueDark = UIColor.rgb(red: 11, green: 34, blue: 57)

}

extension UIView{
    
    func pin(to superView : UIView){
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
    
    func inputContainerView(image : UIImage , textField : UITextField? = nil , segmentedControl : UISegmentedControl? = nil, shadow : Bool = false) -> UIView{
        let view = UIView()
        if shadow == true {
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            view.layer.cornerRadius = 10
            view.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0,                        blue: 0/255.0, alpha: 1.0).cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 1.75)
            view.layer.shadowOpacity = 0.2
            view.layer.shadowRadius = 10
        }
        
        
               let imageView = UIImageView()
               imageView.image = image
               imageView.alpha = 0.87
               view.addSubview(imageView)
               
               
        if let textField = textField {
            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor , paddingLeft: 8, width: 24, height: 24)
               view.addSubview(textField)
               textField.centerY(inView: view)
               textField.anchor(left: imageView.rightAnchor,bottom: view.bottomAnchor,right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        }
        
        if let sc = segmentedControl {
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor,paddingLeft: 8,
                             width:  24, height: 24)
            view.addSubview(sc)
            sc.anchor(left: view.leftAnchor, right: view.rightAnchor , paddingLeft: 8,paddingRight:  8)
            sc.centerY(inView: view, constant: 8)
            
        }
        return view
    }
    func anchor(top: NSLayoutYAxisAnchor? = nil,
        left : NSLayoutXAxisAnchor? = nil,
        bottom : NSLayoutYAxisAnchor? = nil,
        right : NSLayoutXAxisAnchor? = nil ,
        paddingTop: CGFloat = 0,
        paddingLeft: CGFloat = 0,
        paddingBottom : CGFloat = 0,
        paddingRight : CGFloat = 0,
        width : CGFloat? = nil,
        height : CGFloat? = nil){
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top { // if top is not nil then equal to top
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left  = left {
            leftAnchor.constraint(equalTo: left, constant:  paddingLeft).isActive = true
            
        }
        if let bottom  = bottom {
            bottomAnchor.constraint(equalTo: bottom ,constant:  -paddingBottom).isActive = true
            //if want to move the element upside from bottm  on screen toward the center then the paddingBottom must be negative
            
        }
        if let right  = right {
            rightAnchor.constraint(equalTo: right, constant:  -paddingRight).isActive = true
            //if want to move the element on screen move to right side toward the center then the paddingRight must be negative
            
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
            
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
            
        }

        
        
    }
    
    func centerX(inView view: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    func centerY(inView view: UIView, leftAnchor : NSLayoutXAxisAnchor? = nil, paddingLeft : CGFloat = 0, constant: CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimension(height : CGFloat , width : CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addShadow(){
        layer.shadowColor = UIColor.black.cgColor
               layer.shadowOpacity = 0.55
               layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
               layer.masksToBounds = false
    }
}

extension UITextField {
    func textField(withPlaceholder placeholder: String , isSecureTextEntry : Bool) -> UITextField {
        let tf = UITextField()
               tf.borderStyle = .none
               tf.font = UIFont.systemFont(ofSize: 16)
               tf.textColor = .black
               tf.isSecureTextEntry = isSecureTextEntry
               tf.keyboardAppearance = .light
               tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
               return tf
    }
}

extension MKPlacemark{
    var address : String? {
        get{
            guard let subThoroughfare = subThoroughfare else { return nil}
            guard let thoroughfare = thoroughfare else { return nil}
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil}
            print("debug admin area :\(adminArea)")
          
            return "\(subThoroughfare) \(thoroughfare),\(locality) \(adminArea)"
        }
   
    }
}


extension MKMapView {
    func zoomToFit(annotation : [MKAnnotation]){
        var zoomRect = MKMapRect.null
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
         
        }
        
        let insets = UIEdgeInsets(top:100, left: 100, bottom:300,right:100)
         setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect( coordinate : CLLocationCoordinate2D){
        let anno = MKPointAnnotation()
         anno.coordinate = coordinate
        addAnnotation(anno)
        selectAnnotation(anno, animated : true)
    }
}

extension UIViewController {
    
    func presentAlertController(withTitle title: String, message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK ", style: .cancel, handler: nil))
        present(alert, animated: true , completion: nil)
    }
    
    func shouldPresentLoadingView(_ present: Bool , message: String? = nil ){
        if present{
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
             loadingView.addSubview(indicator)
             loadingView.addSubview(label)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor , paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
            
        } else {
            
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }) { _ in
                        
                        subview.removeFromSuperview()
                    }
                }
            }
            
        }
    }
}

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
