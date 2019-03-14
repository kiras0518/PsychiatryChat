//
//  User.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct User {
    let name: String
    let email: String
    let id: String
    let role: String
    //var profilePic: UIImage
    init(name: String, email: String, id: String, role: String) {
        self.name = name
        self.email = email
        self.id = id
        self.role = role
//        //self.profilePic = profilePic
    }
}

struct ConversationID {
    var autoID: String
    init(autoID: String) {
        self.autoID = autoID
    }
}
