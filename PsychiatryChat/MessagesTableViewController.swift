//
//  MessagesTableViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MessagesTableViewController: UITableViewController {
    var didSelectIndexPath: IndexPath = []
    var userArray = [User]()
    var selectedUser: User?
    //var messages: [Message] = []
    var selectedChat = [ConversationID]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : Any] {
                let userID = snapshot.key
                if let credentials = snapshotValue["credentials"] as? [String : String] {
                    print("==credentials==", credentials)
                    if let name = credentials["name"] {
                        if let email = credentials["email"] {
                            let userInfo = User.init(name: name, email: email, id: userID)
                            self.userArray.append(userInfo)
                        }
                    }
                }
            }
         self.tableView.reloadData()
        })
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            //cell.nameLabel.text = self.name[indexPath.row]
            //cell.messageLabel.text = self.last[indexPath.row])
            cell.nameLabel.text = self.userArray[indexPath.row].name
            //cell.messageLabel.text = userArray[indexPath.row].id
            return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("你選擇了 \(indexPath.row)")
        self.didSelectIndexPath = indexPath
        let toID = self.userArray[indexPath.row].id
        selectConversations(toID: toID)
        
        
 
        
        
        self.performSegue(withIdentifier: "goChat", sender: self)
        //performSegue(withIdentifier: "goToChatRoom", sender: chatRooms[indexPath.row])
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goChat" {
//            if let vc = segue.destination as? ChatTableViewController {
//                vc.toUser = self.selectedUser
//            }
//        }
//    }
    func selectConversations(toID :String) {
        // 1. ChatID -> conversations
        let conversations: DatabaseReference = Database.database().reference().child("conversations")
        let conversation: DatabaseReference = conversations.childByAutoId()
        conversation.setValue(
            [ "createdAt": Date().timeIntervalSince1970]
        )
        conversation.observeSingleEvent(
            of: .value,
            with: { snapshot in
                let userID = Auth.auth().currentUser?.uid
                let conversionID: String = snapshot.key
                if let dataValue = snapshot.value as? [String : Any] {
                    let userRefA = Database.database().reference().child("users").child(userID!).child("conversations")
                    userRefA.updateChildValues(["chatID": conversionID])
                    let userRefB = Database.database().reference().child("users").child(toID).child("conversations")
                    userRefB.updateChildValues(["chatID": conversionID])
                    let selec = ConversationID.init(autoID: conversionID)
                    self.selectedChat.append(selec)
                    
                } else {
                    print("ERROR data")
                }
        }
        )
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
