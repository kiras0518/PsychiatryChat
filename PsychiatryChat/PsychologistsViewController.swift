//
//  PsychologistsViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/14.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
class PsychologistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var didSelectIndexPath: IndexPath = []
    var userArray = [Psychologist]()
    var chatID = ChatRoom.init(autoID: "")
    var toUserID: String = ""
    var sychologists: [Psychologist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchPsychologist()
    }
    func selectConversations(toID: String) {
        // 1. ChatID -> conversations
        let conversations: DatabaseReference = Database.database().reference().child("conversations")
        let conversation: DatabaseReference = conversations.childByAutoId()
        conversation.updateChildValues(
            [ "createdAt": Int(Date().timeIntervalSince1970)]
        )
        self.chatID.autoID.append(conversation.key!)
        conversation.observeSingleEvent(
            of: .value,
            with: { snapshot in
                let userID = Auth.auth().currentUser?.uid
                let conversionID: String = snapshot.key
                if let conversationData = snapshot.value as? [String: Any] {
                    let userRefA = Database.database().reference().child("users").child(userID!).child("conversations")
                    userRefA.updateChildValues(["chatID": conversionID])
                    let userRefB = Database.database().reference().child("psychologists").child(toID).child("conversations")
                    userRefB.updateChildValues(["chatID": conversionID])
                } else {
                    print("ERROR data")
                }
        }
        )
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PsychologistsCell", for: indexPath) as? PsychologistsCell {
            cell.nameLabel.text = userArray[indexPath.row].name
            //cell.educationLable.text = userArray[indexPath.row].education
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("你選擇了 \(indexPath.row)")
        self.didSelectIndexPath = indexPath
//        toUserID = self.userArray[indexPath.row].id
//        selectConversations(toID: toUserID)
//        //print("toID", toUserID)
        self.performSegue(withIdentifier: "next", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let detailController = segue.destination as? PsychologistsDetailViewController {
                detailController.psychologist = userArray[didSelectIndexPath.row]
            } else {
                print("ERROR")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //getPsychologistData
    func fetchPsychologist() {
        Database.database().reference().child("psychologists").observe(.childAdded, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String: Any] {
                let userID = snapshot.key
                if let credentials = snapshotValue["credentials"] as? [String: Any] {
                    //print("==credentials==", credentials)
                    if let name = credentials["name"] as? String {
                        if let email = credentials["email"] as? String {
                            if let certificate = credentials["certificate"] as? String {
                                let psychologistInfo = Psychologist.init(name: name, id: userID, certificate: certificate)
                                self.userArray.append(psychologistInfo)
                            } else {
                                print("error certificate")
                            }
                        } else {
                            print("error email")
                        }
                    } else {
                        print("error name")
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
}
