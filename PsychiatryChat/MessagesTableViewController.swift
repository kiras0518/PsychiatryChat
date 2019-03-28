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
//    var userArray = [User]()
//    var userArrayP = [Psychologist]()
    var selectedUser: User?

    var chatID = ChatRoom.init(autoID: "")
    var chatIDS: String = ""
    //var toUserID: String = ""
    var lastMessage = [Message]()
    var timeDate: Int = 0
    var psychologistCredentials = [Psychologist]()
    var usersCredentials = [User]()
    var userArray = [User]()
    var toUser: String = ""
    var convenience = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.delegate = self
        //self.tableView.dataSource = self

        getPsychologistsInfo()
        getUsersInfo()
        downloadLastMessage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.rootReference.removeAllObservers()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.chatRoom.count
        //return self.lastMessage.count
        //return self.psychologistCredentials.count
        //return self.usersCredentials.count
        return self.userArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            print("GGGGGGGGGGGGGGGGGGGGGG")
            //print("====",self.psychologistCredentials[indexPath.row].id)
            //cell.nameLabel.text = self.psychologistCredentials[indexPath.row].name
             print("TTTTTTTTTTTTTTTTTTTTTT")
             //print("====",self.usersCredentials[indexPath.row].id)
            //cell.nameLabel.text = self.usersCredentials[indexPath.row].name
            //cell.nameLabel.text = textname[indexPath.row]
            cell.nameLabel.text = self.userArray[indexPath.row].name
            
            if let currentID = Auth.auth().currentUser?.uid {
                print("userIDuserID = \(currentID)")
            }
            //時間格式轉換
//            let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.lastMessage[indexPath.row].timestamp))
//                        print("messageDate",messageDate)
//                        let dataformatter = DateFormatter.init()
//                        dataformatter.timeStyle = .short
//                        let date = dataformatter.string(from: messageDate)
//                        cell.timeLabel.text = date
//                        cell.messageLabel.text = self.lastMessage[indexPath.row].content
            
            return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Messages 你選擇了 \(indexPath.row)")
        //getting the index path of selected row
        let indexPath2 = tableView.indexPathForSelectedRow
        print("indexPath2",indexPath2)
        self.didSelectIndexPath = indexPath
        
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
                chatVC.toUser = toUser
                chatVC.chatKey.autoID = chatID.autoID
            let navigationRootController = UINavigationController(rootViewController: chatVC)
                navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
                self.present(navigationRootController, animated: true, completion: nil)
            }
        
    
        
        
        
        
        
        //getUsersConversationsChatID()
        //self.performSegue(withIdentifier: "gotoChat", sender: self)
        
//        if let currentUserID = Auth.auth().currentUser?.uid {
//            Database.database().reference().child("users").child(currentUserID).child("conversations").child("toUser").observe(.childAdded, with: { (snapshot) in
//                let fromID = snapshot.key
//                if let values = snapshot.value as? [String: String] {
//                    if let chatID = values["chatID"] as? String {
//                    }
//                }
//            })

//
//        guard let currentUserID = Auth.auth().currentUser?.uid else { print("currentID nil"); return }
//        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
//            print("USERS",snapshot)
//            if snapshot.exists() {
//                guard let data = snapshot.value as? [String: String] else { return }
//                guard let chatID = data["chatID"] as? String else { return }
//                print("snapshot.exists")
//                if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
//                    //chatVC.toUser = self.toUserID
//                    chatVC.chatKey.autoID = chatID
//                    let navigationRootController = UINavigationController(rootViewController: chatVC)
//                    navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
//                    self.present(navigationRootController, animated: true, completion: nil)
//                }
//            }
//        })
        
        
        
        
//        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
//                let navigationRootController = UINavigationController(rootViewController: chatVC)
//                navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
//                print("presentBBB chatVC")
//                //chatVC.chatKey.autoID = self.chatIDS
////            if chatVC.chatKey.autoID == self.chatID.autoID  {
////                 self.present(navigationRootController, animated: true, completion: nil)
////            }
//             self.present(navigationRootController, animated: true, completion: nil)
//        }

    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "gotoChat" {
//            if let chatTableVC = segue.destination as? ChatTableViewController {
//                chatTableVC.chatKey.autoID = self.chatID.autoID
//                chatTableVC.toUser = toUser
//            }
//        }
//    }

    let rootReference = Database.database().reference()

    func getPsychologistsInfo() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        //當登入狀態是Users 會去get醫生的資料
        rootReference.child("users").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
                let toPsychologistID = snapshot.key
                print("toPsychologistID",toPsychologistID)
            self.toUser = toPsychologistID
                self.rootReference.child("psychologists").child(toPsychologistID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                print("psychologists INFO",snapshot)
                if let data = snapshot.value as? [String: Any] {
                    guard let name = data["name"] as? String else { return }
                    guard let email = data["email"] as? String else { return }
                    guard let certificate = data["certificate"] as? String else { return }
                    //let psychologists = Psychologist.init(name: name, id: toPsychologistID, certificate: certificate)
                    let psychologists = User.init(name: name, email: email, id: toPsychologistID)
                        //self.psychologistCredentials.append(psychologists)
                    self.userArray.append(psychologists)
                        //print("123456789",self.psychologistCredentials)
                    print("AAAAAAAAAAA",self.userArray)
                } else { print("Error psychologists data") }
                  self.tableView.reloadData()
                })
        }
    }
    
    func getUsersInfo() {
         guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        //當登入狀態是Psychologists 會去 get Users的資料
        rootReference.child("psychologists").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
            let toUsersID = snapshot.key
            print("toUsersID",toUsersID)
            self.toUser = toUsersID
            self.rootReference.child("users").child(toUsersID).child("credentials").observeSingleEvent(of: .value, with:  { (snapshot) in
                print("users INFO",snapshot)
                if let data = snapshot.value as? [String: Any] {
                    guard let name = data["name"] as? String else { return }
                    guard let email = data["email"] as? String else { return }
                    let users = User.init(name: name, email: email, id: toUsersID)
                    //self.usersCredentials.append(users)
                    self.userArray.append(users)
                    //print("BBBBBBBBB",self.usersCredentials)
                    print("BBBBBBBBB",self.userArray)
                } else { print("error users data") }
                  self.tableView.reloadData()
            })
        }
    }
    func downloadLastMessage() {
        let chatRoomsReference = rootReference.child("conversations")
        chatRoomsReference.observe(.childAdded) { (snap) in
            let chatID = snap.key
            self.chatID.autoID = chatID
            let request = chatRoomsReference.child(chatID).queryOrdered(byChild: "timestamp")
            request.queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
                for snap in snapshot.children {
                    guard let childSnapshot = snap as? DataSnapshot else { print("error childSnapshot"); return }
                    guard let values = childSnapshot.value as? [String: Any] else { print("error values"); return }
                    //print("request values",values)
                    guard let timestamp = values["timestamp"] as? Int else { print("error timestamp"); return }
                    //print("timestamptimestamp",timestamp)
                    guard let content = values["content"] as? String else { return }
                    let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .sender)
                    self.lastMessage.append(emptyMessage)
                }
                print("self.lastMessage",self.lastMessage)
                self.tableView.reloadData()
            })
        }
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
