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
    var toUserID: String = ""
//    var userArray = [Psychologist]()
//    var userArrays: [Psychologist] = []
    var psychologist: Psychologist?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!
    @IBOutlet weak var personalFee: UILabel!
    @IBOutlet weak var coupleFee: UILabel!
    @IBOutlet weak var education: UILabel!
    @IBOutlet weak var expertise: UILabel!
    @IBOutlet weak var introduction: UILabel!
    @IBAction func next(_ sender: UIButton) {
        selectConversations(toID: toUserID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let psychologist = self.psychologist {
            toUserID = psychologist.id
            //print("toUserIDviewDidLoad",toUserID)
        }
        getInfo()
    }
}

extension PsychologistsDetailViewController {

    func getInfo() {
        let psychologistsRef: DatabaseReference = Database.database().reference().child("psychologists").child(toUserID).child("credentials")
        psychologistsRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            //print("dictionary",dictionary)
            guard let name = dictionary["name"] as? String else { return }
            guard let certificate = dictionary["certificate"] as? String else { return }
            guard let personalFee = dictionary["personalFee"] as? String else { return }
            guard let coupleFee = dictionary["coupleFee"] as? String else { return }
            guard let education = dictionary["education"] as? String else { return }
            guard let expertise = dictionary["expertise"] as? String else { return }
            guard let introduction = dictionary["introduction"] as? String else { return }
            guard let position = dictionary["position"] as? String else { return }
            self.nameLabel.text = name
            self.certificateLabel.text = "諮心字第\(certificate)號"
            self.personalFee.text = personalFee
            self.coupleFee.text = coupleFee
            self.education.text = education
            self.expertise.text = expertise
            self.introduction.text = introduction
            self.position.text = position
        })
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
            //print("USERS",snapshot)
            if snapshot.exists() {
                guard let data = snapshot.value as? [String: String] else { return }
                guard let chatID = data["chatID"] else { return }
//                print("snapshot.exists")
//                print("==chatID==",chatID)
                if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                    chatVC.toUser = self.toUserID
                    chatVC.chatKey.autoID = chatID
                    //let navigationRootController = UINavigationController(rootViewController: chatVC)
                    //navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
                    //self.present(navigationRootController, animated: true, completion: nil)
                    self.navigationController?.pushViewController(chatVC, animated: true)
                }
            } else {
                //沒有的話會產生新的聊天室
                conversation.observeSingleEvent(
                    of: .value,
                    with: { snapshot in
                        guard let userID = Auth.auth().currentUser?.uid else { return }
                        let chatID: String = snapshot.key
                        //print("==chatID==",chatID)
                        let userRefHuman = Database.database().reference().child("users").child(userID).child("conversations").child(toID)
                        userRefHuman.updateChildValues(["chatID": chatID])
                        let userRefPsychologists = Database.database().reference().child("psychologists").child(toID).child("conversations").child(userID)
                        userRefPsychologists.updateChildValues(["chatID": chatID])
                        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                            chatVC.toUser = self.toUserID
                            chatVC.chatKey.autoID = chatID
                            //print("VCVCVC",chatVC.toUser,chatVC.chatKey.autoID)
                            self.navigationController?.pushViewController(chatVC, animated: true)
                        } else {
                            print("error chat VC")
                        }
                })
            }
        })
    }
}
