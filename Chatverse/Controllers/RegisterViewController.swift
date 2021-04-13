//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var accountExistsLabel: UILabel!
    @IBOutlet var superView: UIView!
    
    let db = Firestore.firestore()
    var height: CGFloat = 0.0
    
    let defaultProfilePic = #imageLiteral(resourceName: "Blankpfp").toString()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(named: Constants.BrandColors.red)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createAccountButton.layer.cornerRadius = 25
        createAccountButton.clipsToBounds = true
        
        createAccountButton.applyGradient(colors: [UIColor(named: Constants.BrandColors.red)!.cgColor, UIColor(named: Constants.BrandColors.darkRed)!.cgColor])
        
        accountExistsLabel.addRightBorder(color: .lightGray, width: 2)
        
        nameTextfield.setUnderLine(color: .lightGray)
        nameTextfield.text = ""
        nameTextfield.addPlaceholder(placeholder: "Username", color: .lightGray)
        emailTextfield.setUnderLine(color: .lightGray)
        emailTextfield.text = ""
        emailTextfield.addPlaceholder(placeholder: "Email", color: .lightGray)
        passwordTextfield.text = ""
        passwordTextfield.setUnderLine(color: .lightGray)
        passwordTextfield.addPlaceholder(placeholder: "Password",color: .lightGray)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameTextfield.text = ""
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        if let email = emailTextfield.text, let password = passwordTextfield.text, let name = nameTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let _ = error {
                    
                    let alert = UIAlertController(title: "Failed to sign up", message: "To sign up you must have entered your first name a valid email address and a password which is at least 6 characters long", preferredStyle: .alert)
                    let retry = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    
                    alert.addAction(retry)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.db.collection("users").document(name).setData([
                        "email": email,
                        "password": password,
                        "name": name,
                        "profile pic": self.defaultProfilePic!
                    ])
                    self.performSegue(withIdentifier: Constants.registerSegue, sender: self)
                    
                    sender.isEnabled = true

                }
            }
            
        }
    }
    
}

extension UITextField {
    
    func setUnderLine(color: UIColor) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height - 1), size: CGSize(width: self.frame.width, height:  1))
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    
    func addPlaceholder(placeholder: String, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color.withAlphaComponent(0.7)])
    }
}

extension UINavigationBar {
    
    func setGradientBackground(colorOne: String, colorTwo: String, statusBarHeight: CGFloat) {
        
        let gradient = CAGradientLayer()
        var bounds = self.bounds
        bounds.size.height += statusBarHeight
        gradient.frame = bounds
        gradient.colors = [UIColor(named: colorOne)!.cgColor, UIColor(named: colorTwo)!.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        if let image = getImageFrom(gradientLayer: gradient) {
            self.setBackgroundImage(image, for: UIBarMetrics.default)
        }
        

    }
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
}

extension UIView {
    
    func addGradient(colourOneName: String, colourTwoName: String) {
        
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = [UIColor(named: colourOneName)!.cgColor, UIColor(named: colourTwoName)!.cgColor]
        
        self.layer.insertSublayer(gradient, at: 0)
        
    }
}


extension UIImage {
    func toString() -> String? {
        
        let imageData:NSData = self.pngData()! as NSData
        let string = imageData.base64EncodedString(options: .lineLength64Characters)
        
        return string
    }
}

extension String {
    func toImage() -> UIImage? {
        
            let dataDecoded:Data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        if let image: UIImage = UIImage(data: dataDecoded) {
            return image

        }
            return nil
    }
}
