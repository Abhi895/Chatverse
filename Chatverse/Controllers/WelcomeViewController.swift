//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var superView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var chatverseLogo: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        chatverseLogo.layer.cornerRadius = 20
        loginButton.addRightBorder(color: UIColor(named: Constants.BrandColors.blue)!, width: 1.5)
                
    }
    
}


extension UIButton {
    
    func addRightBorder(color: UIColor, width: CGFloat) {
         let border = CALayer()
         border.backgroundColor = color.cgColor
         border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
         self.layer.addSublayer(border)
     }
}






