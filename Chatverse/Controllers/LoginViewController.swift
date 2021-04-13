//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var superView: UIView!
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    var height: CGFloat = 0.0
    var pressed: Bool?
    var unchecked: Bool!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(named: Constants.BrandColors.blue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unchecked = userDefaults.bool(forKey: "unchecked")
        loginButton.applyGradient(colors: [ UIColor(named: Constants.BrandColors.blue)!.cgColor, UIColor(named: Constants.BrandColors.darkBlue)!.cgColor])
        loginButton.layer.cornerRadius = 25
        loginButton.clipsToBounds = true
        
        noAccountLabel.addRightBorder(color: .lightGray, width: 2)
        
        emailTextfield.setUnderLine(color: .lightGray)
        emailTextfield.addPlaceholder(placeholder: "Email", color: .lightGray)
        passwordTextfield.setUnderLine(color: .lightGray)
        passwordTextfield.addPlaceholder(placeholder: "Password", color: .lightGray)
        passwordTextfield.text = ""
        
        let retrievedString: String? = KeychainWrapper.standard.string(forKey: "myKey")
        emailTextfield.text = retrievedString
        
        if unchecked == false {
            checkBox.setImage(UIImage(named:"checked.png"), for: UIControl.State.normal)
        } else if unchecked == true {
            checkBox.setImage(UIImage(named:"unchecked.png"), for: UIControl.State.normal)

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        passwordTextfield.text = ""
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.loginToRegisterSegue, sender: self)
    }
    
    @IBAction func barPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func checkBox(_ sender: UIButton) {
        
                if unchecked == true {
                    sender.setImage(UIImage(named:"checked.png"), for: UIControl.State.normal)
                    unchecked = false
                    userDefaults.set(unchecked, forKey: "unchecked")
                    
                } else {
                    sender.setImage(UIImage(named:"unchecked.png"), for: UIControl.State.normal)
                    unchecked = true
                    userDefaults.set(unchecked, forKey: "unchecked")

                }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        
        
        if segue.identifier == Constants.loginSegue {
            
            let destinationVC = segue.destination as! ChatRoomViewController
            
            self.db.collection("users").addSnapshotListener { (querySnapshot, error) in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore \(e)")
                } else {
                    if let snapshotDocuments =  querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let email = data["email"] as? String, let name = data["name"] as? String {
                                if email == Auth.auth().currentUser?.email {
                                    
                                    destinationVC.rightAvatar = name
                                }
                            }
                        }
                    }
                }
            }

        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let _ = error {
                    let alert = UIAlertController(title: "Failed to login", message: "Invalid Email Address or Password", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                    sender.isEnabled = true
                    
                    
                } else {
                    
                    if self.unchecked == true {
                        let _: Bool = KeychainWrapper.standard.removeObject(forKey: "myKey")
                        self.emailTextfield.text = ""
                        
                    } else if self.unchecked == false {
                        let _: Bool = KeychainWrapper.standard.set(email, forKey: "myKey")
                        
                        
                    }
                    
                    sender.isEnabled = true
                }
                
                self.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                
            }
        }
    }
}

extension UILabel {
    
    func addRightBorder(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width + 5, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIButton {
    
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
