//
//  Constants.swift
//  FlashChat
//
//  Created by Abhi Reddy on 02/07/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

struct Constants {
    
    static let appName = "Chatverse"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "signUpToChatRoom"
    static let loginSegue = "loginToChatRoom"
    static let chatRoomSegue = "chatRoomToChat"
    static let loginToRegisterSegue = "loginToSignUp"
    
    struct BrandColors {
        static let red = "BrandRed"
        static let darkRed = "BrandDarkRed"
        static let blue = "BrandBlue"
        static let darkBlue = "BrandDarkBlue"
    }
    
    struct MessagesFStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let receiverField = "receiver"
        static let bodyField = "body"
        static let dateField = "date"
        static let timeField = "time"
    }
    
    struct FriendsFStore {
        static let collectionName = "users"
        static let emailField = "email"
        static let nameField = "name"
        static let profilePicField = "profile pic"
    }
}
