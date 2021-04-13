//
//  ChatRoomViewController.swift
//  Chatverse
//
//  Created by Abhi Reddy on 07/08/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import RSKImageCropper

class ChatRoomViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var friendList: UITableView!
    @IBOutlet var superView: UIView!
    @IBOutlet weak var noFriendsStackView: UIStackView!
    
    
    var height: CGFloat = 0.0
    var profilePic: UIImage?
    var rightAvatar: String = ""
    var friends: [Friend] = []
    var button: UIButton?
    let userTitle: UIStackView = UIStackView()
    var refreshControl = UIRefreshControl()
    
    
    var addView: Bool = true
    var addFriend: Bool = true
    var removeFriend: Bool = true
    var addProfilePic: Bool = true
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        
        print("hi")
        
        self.noFriendsStackView.isHidden = true
        
        getUserData()
        
        let backButtonImage =  UIImage(systemName: "chevron.left.circle.fill")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .white
        
        navigationItem.leftBarButtonItem = backButton
        
        button = UIButton(type: .custom)
        
        let currWidth = button?.widthAnchor.constraint(equalToConstant: 37)
        currWidth?.isActive = true
        let currHeight = button?.heightAnchor.constraint(equalToConstant: 37)
        currHeight?.isActive = true
//        button?.addTarget(self, action: #selector(addProfilePicPressed(sender:)), for: UIControl.Event.touchUpInside)
        
        userTitle.addArrangedSubview(button!)
        
        friendList.register(UINib(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        loadFriends()
        
        addUserProfilePic()
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        friendList.addSubview(refreshControl)
        
    }
    
    
    
    @objc func refresh(_ sender: AnyObject) {
        print(friends.count)
        self.friendList.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(named: Constants.BrandColors.blue)
        
        userTitle.spacing = 20
        self.navigationItem.titleView = userTitle
        
    }
    
    @objc func backButtonPressed() {
        
        if let destinationVC = self.storyboard?.instantiateViewController(identifier: "ChatViewController") {
            self.navigationController?.pushViewController(destinationVC, animated: false)
        }
        
    }
    
    
    
    @IBAction func addFriendPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Friend", message: "Please enter the name or the email address of the friend you would like to add", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {_ in
            
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [ weak alert] (_) in
            self.addFriend = true
            if let textField = alert?.textFields![0] {
                self.addNewFriend(condition: textField.text!)
                
            }
        }))
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func prepareForChatSegue(rightAvatar: UIImage, leftAvatar: UIImage, friendName: String, friendEmail: String, userName: String) {
        let destinationVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        destinationVC.rightAvatar = rightAvatar
        destinationVC.leftAvatar = leftAvatar
        destinationVC.friendEmail = friendEmail
        destinationVC.friendName = friendName
        destinationVC.userName = userName
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    
    
    
    //MARK: - Firestore Data Retrieval Functions
    
    var deleted: Bool = false
    
    var refresh = false
    
    func getUserData() {
        
        db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments =  querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let emailOfUser = data[Constants.FriendsFStore.emailField] as? String, let nameOfUser = data[Constants.FriendsFStore.nameField] as? String {
                            if emailOfUser == Auth.auth().currentUser?.email {
                                print("ye")
                                
                                let userName = UILabel()
                                userName.text = nameOfUser
                                userName.textColor = .white
                                userName.font = UIFont(name: "Futura-CondensedExtraBold", size: 30)
                                
                                if self.addView == true {
                                    self.userTitle.addArrangedSubview(userName)
                                    self.addView = false
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func loadFriends() {
        
        print("loading")
        
        friends = []
        
        self.db.collection(Constants.FriendsFStore.collectionName)
            .addSnapshotListener { (querySnapshot, error) in
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore \(e)")
                } else {
                    if let snapshotDocuments =  querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let emailOfUser = data[Constants.FriendsFStore.emailField] as? String, let nameOfUser = data[Constants.FriendsFStore.nameField] as? String {
                                if emailOfUser == Auth.auth().currentUser?.email {
                                    self.db.collection("\(nameOfUser)'s Friends").getDocuments { (querySnapshot, error) in
                                        
                                        if querySnapshot?.documents.count == 0 {
                                            print("noFriends")
                                            self.noFriendsStackView.isHidden = false
                                        } else if let e = error {
                                            print("There was an issue retrieving data from Firestore. \(e)")
                                        } else {
                                            
                                            print("here")
                                            self.noFriendsStackView.isHidden = true
                                            
                                            if let snapshotDocuments = querySnapshot?.documents {
                                                for doc in snapshotDocuments {
                                                    let data = doc.data()
                                                    if let emailOfFriend = data[Constants.FriendsFStore.emailField] as? String, let nameOfFriend = data[Constants.FriendsFStore.nameField] as? String, let profilePic = data[Constants.FriendsFStore.profilePicField] as? String {
                                                        print("Booyah")
                                                        let newFriend = Friend(email: emailOfFriend, name: nameOfFriend, profilePic: profilePic)
                                                        self.friends.append(newFriend)
                                                        self.refresh = true
                                                        
                                                        DispatchQueue.main.async {
                                                            self.friendList.reloadData()
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
    }
    
    
    func addNewFriend(condition: String)  {
        
        var userEmail: String?
        var userName: String?
        var userProfilePic: String?
        var addingFriend: Bool?
        var friendEmail: String?
        var friendName: String?
        var friendProfilePic: String?
        
        var friendFound = false
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        self.db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnaphot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments = querySnaphot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email = data[Constants.FriendsFStore.emailField] as? String, let name = data[Constants.FriendsFStore.nameField] as? String, let profilePic = data[Constants.FriendsFStore.profilePicField] as? String {
                            if email == Auth.auth().currentUser?.email {
                                print("Success 1")
                                userName = name
                                userEmail = email
                                userProfilePic = profilePic
                                addingFriend = true
                                
                                
                            }
                            
                        }
                    }
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email = data[Constants.FriendsFStore.emailField] as? String, let name = data[Constants.FriendsFStore.nameField] as? String, let profilePic = data[Constants.FriendsFStore.profilePicField] as? String {
                            if email == condition && email != userEmail || name == condition && name != userName {
                                
                                print("Success 2")
                                friendEmail = email
                                friendName = name
                                friendProfilePic = profilePic
                                print(addingFriend ?? "fail")
                                
                                friendFound = true
                                
                                if addingFriend == true {
                                    print("Success 3")
                                    
                                    self.db.collection("\(userName!)'s Friends").document(friendName!).setData([
                                        Constants.FriendsFStore.emailField: friendEmail!,
                                        Constants.FriendsFStore.nameField: friendName!,
                                        Constants.FriendsFStore.profilePicField: friendProfilePic!
                                    ])
                                    
                                    self.db.collection("\(friendName!)'s Friends").document(userName!).setData([
                                        Constants.FriendsFStore.emailField: userEmail!,
                                        Constants.FriendsFStore.nameField: userName!,
                                        Constants.FriendsFStore.profilePicField: userProfilePic!
                                    ])
                                    
                                    if self.addFriend == true {
                                        self.dismiss(animated: false, completion: {
                                            
                                            let alert = UIAlertController(title: "Success", message: "Friend successfully added", preferredStyle: .alert)
                                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                                            
                                            alert.addAction(ok)
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            //
                                            //                                            var friendCount = self.userDefaults.integer(forKey: "friendCount")
                                            //                                            self.userDefaults.setValue(friendCount += 1, forKey: "friendCount")
                                            //
                                            self.addFriend = false
                                            self.noFriendsStackView.isHidden = true
                                        })
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
        self.dismiss(animated: false) {
            
            if friendFound {
                self.loadFriends()
            } else {
                
                let retry = UIAlertController(title: "Couldn't Find Friend", message: "Sorry but a friend with that name or email could not be found", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                retry.addAction(ok)
                
                self.present(retry, animated: true, completion: nil)
            }
            
        }
        
        
        
    }
    
    func updateUserProfilePic(image: UIImage) {
        
        self.db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments =  querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email = data[Constants.FriendsFStore.emailField] as? String, let name = data[Constants.FriendsFStore.nameField] as? String {
                            if email == Auth.auth().currentUser?.email {
                                if let profilePic = image.toString() {
                                    self.db.collection(Constants.FriendsFStore.collectionName).document(name).updateData([Constants.FriendsFStore.profilePicField: ""])
                                    self.db.collection(Constants.FriendsFStore.collectionName).document(name).updateData([Constants.FriendsFStore.profilePicField: profilePic])
                                    print("updated")
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func addUserProfilePic() {
        
        print(addProfilePic)
        
        self.db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore \(e)")
            } else {
                if let snapshotDocuments =  querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email = data[Constants.FriendsFStore.emailField] as? String, let profilePic = data[Constants.FriendsFStore.profilePicField] as? String {
                            if email == Auth.auth().currentUser?.email {
                                if let userProfilePic = profilePic.toImage() {
                                    if self.addProfilePic == true {
                                        self.button?.setImage(userProfilePic, for: .normal)
                                        self.addProfilePic = false
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func performChatSegue(indexPath: Int) {
        
        var userName: String?
        var userProfilePic: UIImage?
        var friendName: String?
        var friendEmail: String?
        var friendProfilePic: UIImage?
        
        self.db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            if let snapshotDocuments =  querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    if let emailOfUser = data[Constants.FriendsFStore.emailField] as? String, let nameOfUser = data[Constants.FriendsFStore.nameField] as? String, let pfpOfUser = data[Constants.FriendsFStore.profilePicField] as? String {
                        if emailOfUser == Auth.auth().currentUser?.email {
                            userName = nameOfUser
                            userProfilePic = pfpOfUser.toImage()
                        }
                    }
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let emailOfFriend = data[Constants.FriendsFStore.emailField] as? String, let nameOfFriend = data[Constants.FriendsFStore.nameField] as? String, let pfpOfFriend = data[Constants.FriendsFStore.profilePicField] as? String {
                            if emailOfFriend == self.friends[indexPath].email && userName != nil {
                                friendName = nameOfFriend
                                friendEmail = emailOfFriend
                                friendProfilePic = pfpOfFriend.toImage()
                            }
                            
                        }
                    }
                    
                }
                
            }
            
            self.prepareForChatSegue(rightAvatar: (userProfilePic ?? UIImage(named: "Blankpfp.png")!), leftAvatar: (friendProfilePic ?? UIImage(named: "Blankpfp.png")!), friendName: friendName!, friendEmail: friendEmail!, userName: userName!)
            
            
        }
        
        
    }
    
    
    //    func getFriendCount() -> Int {
    //
    //        if let userName = getUserData(returnName: true) {
    //            print(userName)
    //            self.db.collection("\(userName)'s Friends").getDocuments { (querySnapshot, err) in
    //                if let e = err {
    //                    print("ERROR: \(e)")
    //                } else {
    //                    if let safeFriendCount = querySnapshot?.count {
    //                        self.friendCount = safeFriendCount
    //                    }
    //                }
    //            }
    //
    //        }
    //
    //        return friendCount
    //
    //    }
    
    func deleteFriend(withName friendName: String) {
        
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        self.db.collection(Constants.FriendsFStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            if let snapshotDocuments =  querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    if let emailOfUser = data[Constants.FriendsFStore.emailField] as? String, let nameOfUser = data[Constants.FriendsFStore.nameField] as? String {
                        if emailOfUser == Auth.auth().currentUser?.email {
                            
                            self.db.collection("\(nameOfUser)'s Friends").document(friendName).delete() { error in
                                if let e = error {
                                    print("Error removing document: \(e)")
                                } else {
                                    
                                    //                                    if self.removeFriend == true {
                                    
                                    self.dismiss(animated: false, completion: {
                                        
                                        let alert = UIAlertController(title: "Success", message: "Friend successfully removed", preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        
                                        alert.addAction(ok)
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
                                        
                                        //                                            var friendCount = self.userDefaults.integer(forKey: "friendCount")
                                        //                                            self.userDefaults.setValue(friendCount -= 1, forKey: "friendCount")
                                        //                                            self.deleted = true
                                        //
                                    })
                                    
                                    //                                        self.removeFriend = false
                                    
                                    //                                    }
                                    
                                }
                                
                                
                                self.db.collection("\(friendName)'s Friends").document(nameOfUser).delete() { error in
                                    if let e = error {
                                        print("Error removing document: \(e)")
                                    } else {
                                        print("Friend successfully removed!")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        loadFriends()
        
    }
    
}







//MARK: - UITableViewDataSource Methods


extension ChatRoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        if refresh {
        //            print("yes: \(friends.count)")
        //            userDefaults.setValue(friends.count, forKey: "friendCount")
        //        } else {
        //            print("no: \(friends.count)")
        //            return 0
        //        }
        //
        //        return userDefaults.integer(forKey: "friendCount")
        
        print(friends.count)
        return friends.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < friends.count {
            let friend = friends[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                as! FriendsCell
            
            cell.friendName.text = friend.name
            let friendProfilePic = friend.profilePic.toImage()
            cell.friendProfilePic.image = friendProfilePic
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
}

//MARK: - UITableViewDelegate Methods

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performChatSegue(indexPath: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let friendName = friends[indexPath.row].name
        print(friendName)
        
        if editingStyle == .delete {
            
            friends.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteFriend(withName: friendName)
            print("Deleted")
            
            //            removeFriend = true
            
        }
    }
}



//MARK: - RSKImageCropViewControllerDelegate Methods

extension ChatRoomViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        
        updateUserProfilePic(image: croppedImage)
        
        
        addUserProfilePic()
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
}

//MARK: - UIImagePickerControllerDelegate Methods

extension ChatRoomViewController: UIImagePickerControllerDelegate {
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.applyMaskToCroppedImage = true
            imageCropVC.avoidEmptySpaceAroundImage = true
            imageCropVC.delegate = self
            
            
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        
    }
    
    
}













//{ (querySnapshot, error) in
//
//   if let snapshotDocuments = querySnapshot?.documents {
//    for doc in snapshotDocuments {
//        let data = doc.data()
//        if let messageSender = data["sender"] as? String, let messageReceiver = data["receiver"] as? String {
//            if messageSender == userName && messageReceiver == friend.name || messageSender == friend.name && messageReceiver == userName {
//
//                print("succes dos")
//                self.db.collection("messages")
//                    .order(by: Constants.FriendsFStore.dateField).limit(to: 1)
//                    .getDocuments { (querySnapshot, e) in
//                        if let e = error {
//                            print("Error getting documents: \(e)")
//                        } else {
//                            for doc in querySnapshot!.documents {
//                                let data = doc.data()
//
//                                if let messageBody = data["body"] as? String {
//                                    print("Ayyyy succces tressss")
//                                    cell.mostRecentMessage.text = messageBody
//                                }
//
//                            }
//                        }
//                }
//            }
//        }
//    }
//}
//}



//        var index = 0
//        var numOfRepeats = 0
//
//
//        if friends.count != 0 {
//
//            for _ in 0...friends.count - 1 {
//
//                if friends[0].email == friends[index].email {
//                    numOfRepeats += 1
//
//                }
//
//                index += 1
//            }
//
//            let fakeFriends = numOfRepeats - 1
//            print(friends.count)
//            print(fakeFriends)
//            return friends.count - fakeFriends
//        } else {
//            return 0
//        }
