//
//  TestingController.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 11/07/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import UIKit

protocol TestingControllerDelegate : class {
    func testingview()
}

class TestingController : UIViewController {
    
    weak var delegate : TestingControllerDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = .blue
    }
    
    func testingview(){
        delegate?.testingview()
    }
    
}
