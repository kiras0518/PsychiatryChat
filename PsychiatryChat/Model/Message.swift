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
import MapKit

struct Message {
    var content: String
    var timestamp: Int
    //var image: UIImage
    var isRead: Bool
    var fromID: String?
    var toID: String?
    var id: String?
    var owner: MessageOwner
    init(outContent: String, outTimestamp: Int, outIsRead: Bool, outOwner: MessageOwner, id: String) {
        self.content = outContent
        self.timestamp = outTimestamp
        self.isRead = outIsRead
        self.owner = outOwner
        self.id = id
        //self.toName = toName
    }
}

struct ChatRoom {
    var autoID: String
    init(autoID: String) {
        self.autoID = autoID
    }
}

enum MessageOwner {
        case sender
        case receiver
}
