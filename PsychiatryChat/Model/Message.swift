//
//  Message.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message {
    var content: String
    var timestamp: Int
    //var image: UIImage
    var isRead: Bool
    var toID: String?
    var fromID: String?
    var owner: MessageOwner
    
    init(outContent: String, outTimestamp: Int, outIsRead: Bool, outOwner: MessageOwner) {
        self.content = outContent
        self.timestamp = outTimestamp
        self.isRead = outIsRead
        self.owner = outOwner
    }
    enum MessageOwner {
        case sender
        case receiver
    }
//    init?(snapshot: DataSnapshot) {
//        guard let value = snapshot.value as? [String : Any] else { print("value error"); return }
//        guard let content = value["content"] as? String else { print("content error"); return }
//        guard let timestamp = value["timestamp"] as? Int else { print("timestamp error"); return }
//        guard let read = value["isRead"] as? Bool else { print("read error"); return }
//        
//        self.ref = snapshot.ref
//        self.content = content
//        self.timestamp = timestamp
//        self.isRead = read
//        
//    }
}
