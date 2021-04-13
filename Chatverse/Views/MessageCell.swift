//
//  MessageCell.swift
//  FlashChat
//
//  Created by Abhi Reddy on 02/07/2020.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var senderStackView: UIStackView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var receiverStackView: UIStackView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var messageBubble2: UIView!
    @IBOutlet weak var timeLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
        rightImageView.layer.cornerRadius = rightImageView.frame.width / 2
        rightImageView.layer.masksToBounds = true
        
        messageBubble2.layer.cornerRadius = messageBubble.frame.size.height / 5
        leftImageView.layer.cornerRadius = rightImageView.frame.width / 2
        leftImageView.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
