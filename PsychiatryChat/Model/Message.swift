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

struct Message {
    
    var content: String
    var timestamp: Int
    var image: UIImage
    var isRead: Bool
    var toID: String
    var fromID: String
    
}
