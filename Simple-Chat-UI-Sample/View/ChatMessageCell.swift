//
//  ChatMessageCell.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import UIKit

class ChatMessageCell: UITableViewCell {

    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var sendTimeLabel: UILabel!
    @IBOutlet weak var messageBackgroundView: UIView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func setCellData(object: ChatMessage) {
        self.messageText.text = object.message
        self.sendTimeLabel.text = object.time?.stringDate(format: "hh:mm")
    }
    
}
