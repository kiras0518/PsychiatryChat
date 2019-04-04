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
import Crashlytics

class MessagesTableViewController: UITableViewController {
    var didSelectIndexPath: IndexPath = []
    var selectedUser: User?
    var chatID = Array<ChatRoom>()//ChatRoom.init(autoID: "")
    var lastMessage = [Message]()
    var toUser: String = ""
    var psychologistCredentials = [Psychologist]()
    var usersCredentials = [User]()
    var personArray = [Person]()
    var asdf = [UserInfo]()
    //var toUser1 = Array<Person>()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        //getPsychologistsInfo()
        //getUsersInfo()
        //downloadLastMessage()
        observeUserMessages()
        //downloadLastMessage()
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("viewWillDisappear")
//        self.rootReference.removeAllObservers()
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        downloadLastMessage()
    }

    let rootReference = Database.database().reference()

    func observeUserMessages() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
    rootReference.child("users").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
            let toPsychologistID = snapshot.key
            self.toUser = toPsychologistID
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let chatID = data["chatID"] as? String else { return }
            //print("getPsychologistsInfo 下",chatID)
            let chatRoom = ChatRoom.init(autoID: chatID)
            self.chatID.append(chatRoom)

            if currentUserID != toPsychologistID {
                print("111111")
                self.rootReference.child("psychologists").child(toPsychologistID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("psychologists INFO",snapshot)
                    if let data = snapshot.value as? [String: Any] {
                        guard let name = data["name"] as? String else { return }
                        guard let email = data["email"] as? String else { return }
                        let psychologists = Person.init(name: name, id: toPsychologistID, conversationsID: chatID)
                        self.personArray.append(psychologists)
                    } else { print("Error psychologists data") }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            } else {
                print("23333")
            }
        }

        rootReference.child("psychologists").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
            let toUserID = snapshot.key
            self.toUser = toUserID
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let chatID = data["chatID"] as? String else { return }
            print("getUsersInfo 下",chatID)
            let chatRoom = ChatRoom.init(autoID: chatID)
            self.chatID.append(chatRoom)
            if currentUserID != toUserID {
                print("333333")
                self.rootReference.child("users").child(toUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("users INFO",snapshot)
                    if let data = snapshot.value as? [String: Any] {
                        guard let name = data["name"] as? String else { return }
                        guard let email = data["email"] as? String else { return }
                        let users = Person.init(name: name, id: toUserID, conversationsID: chatID)
                        self.personArray.append(users)
                    } else { print("error users data") }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            } else {
                print("444444")
            }
        }
    }

    func downloadLastMessage() {
        let chatRoomsReference = rootReference.child("conversations")
        chatRoomsReference.observeSingleEvent(of: .childAdded) { (snap) in
            let chatID = snap.key
            let chatRoom = ChatRoom.init(autoID: chatID)
            self.chatID.append(chatRoom)
             //chatID
            let request = chatRoomsReference.child(chatID).queryOrdered(byChild: "timestamp")
            request.queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
                for snap in snapshot.children {
                    guard let childSnapshot = snap as? DataSnapshot else { print("error childSnapshot"); return }
                    guard let values = childSnapshot.value as? [String: Any] else { print("error values"); return }
                    guard let timestamp = values["timestamp"] as? Int else { print("error timestamp"); return }
                    guard let content = values["content"] as? String else { return }
                    let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: false, outOwner: .sender, id: chatID)
                    print("MESSSSSSSSS")
                    self.lastMessage.append(emptyMessage)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
}

extension MessagesTableViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.personArray.count
        //return self.psychologistCredentials.count
        //return self.usersCredentials.count
        //return self.lastMessage.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            print("GGGGGGGGGGGGGGGGGGGGGG")
            cell.nameLabel.text = self.personArray[indexPath.row].name
            //時間格式轉換
            //print("TIMETIMETIMETIMETIMETIMETIMETIME")
            //let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.lastMessage[indexPath.row].timestamp))
//            print("messageDate",messageDate)
//            let dataformatter = DateFormatter.init()
//            dataformatter.timeStyle = .short
//            let date = dataformatter.string(from: messageDate)
//            cell.timeLabel.text = date
//            cell.messageLabel.text = self.lastMessage[indexPath.row].content
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Messages 你選擇了 \(indexPath.row)")
        //getting the index path of selected row
        //let indexPath2 = tableView.indexPathForSelectedRow
        //print("indexPath2",indexPath2)
        self.didSelectIndexPath = indexPath
//        print("你選擇了",self.chatID[indexPath.row].autoID)
//        print("你選擇了1",self.chatID[indexPath.row])
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
            print("MessNextChatVC")
            //print("你選擇了toUser=",toUser)
            print("你選擇了chatID[indexPath.row].autoID=",chatID[indexPath.row].autoID)
            print("你選擇了personArray[indexPath.row].id=",self.personArray[indexPath.row].id)
            //chatVC.toUser = self.toUser
            print("SELF",self.toUser)
            chatVC.toUser = self.personArray[indexPath.row].id
            chatVC.chatKey.autoID = self.chatID[indexPath.row].autoID
            chatVC.currentUser = self.personArray[indexPath.row].name
//                            let navigationRootController = UINavigationController(rootViewController: chatVC)
//                            navigationRootController.navigationBar.barTintColor = #colorLiteral(red: 0.6588235294, green: 0.8470588235, blue: 0.7254901961, alpha: 1)
//                            self.present(navigationRootController, animated: true, completion: nil)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
