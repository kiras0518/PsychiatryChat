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
    //var profilePic: UIImage
    init(name: String, email: String, id: String) {
        self.name = name
        self.email = email
        self.id = id
//        //self.profilePic = profilePic
    }
}

struct Psychologist {
    let name: String
    let id: String
    let education: String
    let personalFee: Double
    let coupleFee: Double
    let certificate: Int
    let introduction: String
    //var profilePic: UIImage
    init(name: String, id: String, education: String, introduction: String, certificate: Int, personalFee: Double, coupleFee: Double) {
        self.name = name
        self.id = id
        self.education = education
        self.introduction = introduction
        self.certificate = certificate
        self.personalFee = personalFee
        self.coupleFee = coupleFee
    }
}

struct ConversationID {
    var autoID: String
    init(autoID: String) {
        self.autoID = autoID
    }
}
