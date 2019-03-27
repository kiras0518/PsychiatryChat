//
//  PsychologistsDetailViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/18.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class PsychologistsDetailViewController: UIViewController {
    var chatID = ChatRoom.init(autoID: "")
    var toUserID: String = ""
    var userArray = [Psychologist]()
    var userArrays: [Psychologist] = []
    var psychologist: Psychologist?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!

    @IBAction func next(_ sender: UIButton) {
        selectConversations(toID: toUserID)
    }

    func selectConversations(toID: String) {
        // 1. ChatID -> conversations
        let conversations: DatabaseReference = Database.database().reference().child("conversations")
        let conversation: DatabaseReference = conversations.childByAutoId()
////        print("按下送出\(conversation.key)")
//        //print("按下送出\(singleMessageRef.key)")        
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("currentID nil"); return }
    //找尋使用者底下聊天室ID 當沒有的時候去產生
        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("USERS",snapshot)
            if snapshot.exists() {
                guard let data = snapshot.value as? [String: String] else { return }
                guard let chatID = data["chatID"] as? String else { return }
                print("snapshot.exists")
                if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                    chatVC.toUser = self.toUserID
                    chatVC.chatKey.autoID = chatID
                let navigationRootController = UINavigationController(rootViewController: chatVC)
                    navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
                    self.present(navigationRootController, animated: true, completion: nil)
                }
            } else {
                //沒有的話會產生新的
                //conversation.updateChildValues([ "createdAt": Int(Date().timeIntervalSince1970)])
                    conversation.observeSingleEvent(
                        of: .value,
                            with: { snapshot in
                                let userID = Auth.auth().currentUser?.uid
                                let conversionID: String = snapshot.key
                                print("==conversationID==",conversionID)
                                let userRefHuman = Database.database().reference().child("users").child(userID!).child("conversations").child(toID)
                                userRefHuman.updateChildValues(["chatID": conversionID])
                                let userRefPsychologists = Database.database().reference().child("psychologists").child(toID).child("conversations").child(userID!)
                                userRefPsychologists.updateChildValues(["chatID": conversionID])
                                
                                
                                if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                                    chatVC.toUser = self.toUserID
                                    chatVC.chatKey.autoID = conversionID
                                    print("VCVCVC",chatVC.toUser,chatVC.chatKey.autoID)
                                    let navigationRootController = UINavigationController(rootViewController: chatVC)
                                    navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
                                    self.present(navigationRootController, animated: true, completion: nil)
                                } else {
                                    print("error chat VC")
                                }
                    })
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let psychologist = self.psychologist {
            nameLabel.text = psychologist.name
            certificateLabel.text = psychologist.certificate
            toUserID = psychologist.id
            print("toUserIDviewDidLoad",toUserID)
        }
    }
}
