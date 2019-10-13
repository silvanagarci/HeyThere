//
//  Message.swift
//  HeyThere
//
//  Created by Silvana Garcia on 10/10/19.
//  Copyright © 2019 Silvana Garcia. All rights reserved.
//

import Foundation
import MessageKit

struct Message {
    let messageId: String
    let sender: Sender
    let text: String
    let username: String

    
    init(sender: Sender, messageId: String,text: String, username: String) {
        self.sender = sender
        self.text = text
        self.messageId = messageId
        self.username = username
    }
}

extension Message: MessageType {
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}

