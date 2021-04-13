//
//  FriendsCell.swift
//  Chatverse
//
//  Created by Abhi Reddy on 07/08/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {
    
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendProfilePic: UIImageView!
    @IBOutlet weak var mostRecentMessage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

