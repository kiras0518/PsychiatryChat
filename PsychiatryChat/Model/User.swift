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

struct User {
    var name: String
    var email: String
    var id: String
    //var profilePic: UIImage
    init(name: String, email: String, id: String) {
        self.name = name
        self.email = email
        self.id = id
//        //self.profilePic = profilePic
    }
}

struct Psychologist {
    var name: String
    let id: String
    var education: String?
    var personalFee: String?
    var coupleFee: String?
    var certificate: String
    var introduction: String?
    var expertise: String?
    var position: String?
    //var profilePic: UIImage
    init(name: String, id: String, certificate: String, education: String, introduction: String, personalFee: String, coupleFee: String, expertise: String, position: String) {
        self.name = name
        self.id = id
        self.education = education
        self.introduction = introduction
        self.certificate = certificate
        self.personalFee = personalFee
        self.coupleFee = coupleFee
        self.expertise = expertise
        self.position = position
    }
}

struct Person {
    var name: String
    let id: String
    let conversationsID: String
    init(name: String, id: String, conversationsID: String) {
        self.name = name
        self.id = id
        self.conversationsID = conversationsID
    }
}

//struct UserInfo {
////    var name: String?
//      let id: String?
//
//    let user: Person
//    var lastMessage: Message
//
//    init(user: Person, lastMessage: Message, id: String) {
//        self.user = user
//        self.lastMessage = lastMessage
//        self.id = id
//    }
//}
