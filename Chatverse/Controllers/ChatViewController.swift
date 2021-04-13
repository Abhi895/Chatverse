//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet var superView: UIView!
    
    
    let db = Firestore.firestore()
    var rightAvatar: UIImage?
    var leftAvatar: UIImage?
    var friendName: String?
    var friendEmail: String?
    var userName: String?
    var messages: [Message] = []
    let messageCell = MessageCell()
    var height: CGFloat = 0.0
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor(named: Constants.BrandColors.red)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = friendName
        
        messagesTableView.dataSource = self
        navigationItem.hidesBackButton = true
        
        messagesTableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        messageTextField.delegate = self
        
        print(friendName!)
                
        loadMessages()
    }
    
    func loadMessages() {
        
        db.collection("messages")
            .order(by: Constants.MessagesFStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                
                self.messages = []
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore \(e)")
                } else {
                    if let snapshotDocuments =  querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            
                            let data = doc.data()
                            if let messageSender = data[Constants.MessagesFStore.senderField] as? String,
                               let messageReceiver = data[Constants.MessagesFStore.receiverField] as? String,
                               let messageBody = data[Constants.MessagesFStore.bodyField] as? String,
                               let messageTime = data[Constants.MessagesFStore.timeField] as? String {
                                
                                if messageSender == Auth.auth().currentUser?.email && messageReceiver == self.friendEmail {
                                    let newMessage = Message(sender: messageSender, receiver: messageReceiver, body: messageBody, time: messageTime)
                                    self.messages.append(newMessage)
                                    
                                } else if messageSender == self.friendEmail && messageReceiver == Auth.auth().currentUser?.email {
                                    let newMessage = Message(sender: messageSender, receiver: messageReceiver, body: messageBody, time: messageTime)
                                    self.messages.append(newMessage)
                                    
                                }
                                
                                DispatchQueue.main.async {
                                    self.messagesTableView.reloadData()
                                    if self.messages.count != 0 {
                                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                        self.messagesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(phoneCallURL)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        let currentTime = formatter.string(from:currentDateTime)
        
        if messageTextField.text == "" {
            let alert = UIAlertController(title: "Message error", message: "Please type a message", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else if let messageBody =  messageTextField.text, let messageSender = Auth.auth().currentUser?.email, let messageReceiver = friendEmail {
            db.collection("messages").addDocument(data: [
                
                Constants.MessagesFStore.senderField: messageSender,
                Constants.MessagesFStore.receiverField: messageReceiver,
                Constants.MessagesFStore.bodyField: messageBody,
                Constants.MessagesFStore.dateField: Date().timeIntervalSince1970,
                Constants.MessagesFStore.timeField: currentTime
                
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data")
                    
                }
            }
        }
        
        self.messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func callPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Phone Number", message: "Which number would you like to call?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { [ weak alert] (_) in
            if let textField = alert?.textFields![0] {
                self.callNumber(phoneNumber: "\(textField.text!)")
                print(textField.text!)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        let destinationVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatRoom") as! ChatRoomViewController
        destinationVC.friendList?.reloadData()
        self.navigationController?.pushViewController(destinationVC, animated: false)

    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages.isEmpty == false {
            let message = messages[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
                as! MessageCell
            
            if message.sender == Auth.auth().currentUser?.email {
                
                cell.receiverStackView.isHidden = true
                cell.senderStackView.isHidden = false
                cell.label.text = " \(message.body)"
                cell.rightImageView.image = rightAvatar
                cell.timeLabel.text = message.time
                
                
            } else {
                
                cell.receiverStackView.isHidden = false
                cell.senderStackView.isHidden = true
                cell.label2.text = " \(message.body)"
                cell.leftImageView.image = leftAvatar
                cell.timeLabel.text = message.time
                
            }
            
            
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        let currentTime = formatter.string(from:currentDateTime)
        
        
        if messageTextField.text == "" {
            let alert = UIAlertController(title: "Message error", message: "Please type a message", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else if let messageBody =  messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(Constants.MessagesFStore.collectionName).addDocument(data: [
                
                Constants.MessagesFStore.senderField: messageSender,
                Constants.MessagesFStore.bodyField: messageBody,
                Constants.MessagesFStore.dateField: Date().timeIntervalSince1970,
                Constants.MessagesFStore.timeField: currentTime
                
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data")
                    
                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                        
                    }
                }
            }
        }
        
        messageTextField.resignFirstResponder()
        return true
    }
    
}

class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor(named: Constants.BrandColors.blue)!.cgColor, UIColor(named: Constants.BrandColors.darkBlue)!.cgColor]
    }
}
