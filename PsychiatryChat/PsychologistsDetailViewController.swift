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
        print("touch")
        selectConversations(toID: toUserID)
    }

    //var itemsArray = ["自我介紹","學歷","專長項目","證號"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let psychologist = self.psychologist {
            toUserID = psychologist.id
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
            self.personalFee.text = "\(personalFee)元"
            self.coupleFee.text = "\(coupleFee)元"
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
        guard let currentUserID = Auth.auth().currentUser?.uid else { print("currentID nil"); return }
        //找尋使用者底下聊天室ID
        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(
                of: .value,
                with: { (snapshot) in
            if snapshot.exists() {
                guard let data = snapshot.value as? [String: Any] else { print("exists error"); return }
                guard let chatID = data["chatID"] as? String else { print("chatID error"); return }
                if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                    chatVC.toUser = self.toUserID
                    chatVC.chatKey.autoID = chatID
                    self.navigationController?.pushViewController(chatVC, animated: true)
                }
            } else {
                print("creat!!!!!")
                //沒有的話會產生新的聊天室
                conversation.observeSingleEvent(
                    of: .value,
                    with: { snapshot in
                        guard let userID = Auth.auth().currentUser?.uid else { return }
                        let chatID: String = snapshot.key
                        let userRefHuman = Database.database().reference().child("users").child(userID).child("conversations").child(toID)
                        userRefHuman.updateChildValues(["chatID": chatID])
                        let userRefPsychologists = Database.database().reference().child("psychologists").child(toID).child("conversations").child(userID)
                        userRefPsychologists.updateChildValues(["chatID": chatID])
                        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                            chatVC.toUser = self.toUserID
                            chatVC.chatKey.autoID = chatID
                            self.navigationController?.pushViewController(chatVC, animated: true)
                        } else {
                            print("error chat VC")
                        }
                })
            }
        })
    }
}

//extension PsychologistsDetailViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        //return self.itemsArray.count
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
////        //cell.textLabel?.text = itemsArray[indexPath.row]
////        return cell
//        return UITableViewCell()
//    }
//}
