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
        print("按下送出\(conversation.key)")
        //print("按下送出\(singleMessageRef.key)")
        conversation.updateChildValues(
            [ "createdAt": Int(Date().timeIntervalSince1970)]
        )
        //print("converUSer", toID)
        conversation.observe(.value, with: { snapshot in
            if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                //print("conversation",snapshot)
                self.chatID.autoID.append(snapshot.key)
                //print("BBBBBBBB",self.chatID.autoID)
                chatVC.converID.autoID = self.chatID.autoID
                let navigationRootController = UINavigationController(rootViewController: chatVC)
                navigationRootController.navigationBar.barStyle = UIBarStyle.black
                self.present(navigationRootController, animated: true, completion: nil)
            }
        })
        conversation.observeSingleEvent(
            of: .value,
            with: { snapshot in
                let userID = Auth.auth().currentUser?.uid
                let conversionID: String = snapshot.key
                print("conversionID",conversionID)
                if let conversationData = snapshot.value as? [String: Any] {
                    let userRefA = Database.database().reference().child("users").child(userID!).child("conversations").child(toID)
                    userRefA.updateChildValues(["chatID": conversionID])
                    let userRefB = Database.database().reference().child("psychologists").child(toID).child("conversations").child(userID!)
                    userRefB.updateChildValues(["chatID": conversionID])
                } else {
                    print("ERROR data")
                }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let psychologist = self.psychologist {
            nameLabel.text = psychologist.name
            certificateLabel.text = psychologist.certificate
            toUserID = psychologist.id
        }
    }
}
