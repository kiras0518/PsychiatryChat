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
    var selectedUser: Person?
//    var conversations = [Conversation]() {
//        didSet {
//            print("Conversationss \n", conversations, conversations.count)
//        }
//    }
    var toUser = [String]()
    var chatID = Array<ChatRoom>()//ChatRoom.init(autoID: "")
//    var lastMessage = [Message]() {
//        didSet {
//            print("LastMessage \n", lastMessage, lastMessage.count)
//        }
//    }
    var personArray = [Person]() {
        didSet {
            print("PersonArray \n", personArray, personArray.count)
        }
    }

//    private var currentUserID: String {
//        return Auth.auth().currentUser?.uid ?? ""
//    }
    //var toUser1 = Array<Person>()
    override func viewDidLoad() {
        super.viewDidLoad()
        //observeUserMessages()
        //observerPsyMessages()
        //downloadLastMessage()
//        observeUserMessages { (status) in
//            if status {
//                self.rootReference.child("psychologists").child(self.toUser).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
//                                        print("psychologists INFO",snapshot)
//                                        if let data = snapshot.value as? [String: Any] {
//                                            guard let name = data["name"] as? String else { return }
//                                            guard let email = data["email"] as? String else { return }
//                                            let psychologists = Person.init(name: name, id: self.toUser, conversationsID: self.chatkey)
//                                            self.personArray.append(psychologists)
//
//                                        } else { print("Error psychologists data") }
//                                        DispatchQueue.main.async {
//                                            self.tableView.reloadData()
//                                        }
//                                    })
//            } else {
//                print("VVVVVVVVVVVVVV")
//            }
//        }
//
//        observerPsychologists { (status: Bool) in
//            if status {
//
//            } else {
//
//            }
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        //self.rootReference.removeAllObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        observeUserMessages()
        observerPsyMessages()
    }

    let rootReference = Database.database().reference()

    func observeUserMessages() {
        print("observeUserMessages")
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let chatRoomsReference = rootReference.child("conversations")
        rootReference.child("users").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
            let toPsychologistID = snapshot.key
            //print("toPsychologistID",toPsychologistID)
            //self.toUser = [toPsychologistID]
            self.toUser.append(toPsychologistID)
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let chatID = data["chatID"] as? String else { return  }
            //print("datadatadatadatadata",data)
            guard let lastTime = data["timestamp"] as? Int else { return }
            guard let lastContent = data["content"] as? String else { return }
            //print("getSsersInfo 下",chatID)
            let chatRoom = ChatRoom.init(autoID: chatID)
            self.chatID.append(chatRoom)
            if currentUserID != toPsychologistID {
            self.personArray = [Person]()
                self.rootReference.child("psychologists").child(toPsychologistID).child("credentials").observe(.value, with: { (snapshot) in
                    //print("psychologists INFO",snapshot)
                    if let data = snapshot.value as? [String: Any] {
                        guard let name = data["name"] as? String else { return }
                        let psychologists = Person.init(name: name, id: toPsychologistID, conversationsID: chatID, lastTime: lastTime, lastContent: lastContent)
                        self.personArray.append(psychologists)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else { print("Error psychologists data") }
                })
                //downloadLastMessage
//                let request = chatRoomsReference.child(chatID).queryOrdered(byChild: "timestamp")
//                request.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
//                    //print("queryLimited", snapshot.value)
//                    guard let data = snapshot.value as? [String: Any] else { print("lastMessage error data");return}
//                    guard let timestamp = data["timestamp"] as? Int else { print("lastMessag error timestamp"); return }
//                    guard let content = data["content"] as? String else { print("lastMessage error content"); return }
//                    let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: false, outOwner: .sender, id: chatID)
//                    self.lastMessage.append(emptyMessage)
//                    self.tableView.reloadData()
//                })
            }
        }
    }

    func observerPsyMessages() {
        print("observerPsyMessages")
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let chatRoomsReference = rootReference.child("conversations")
        rootReference.child("psychologists").child(currentUserID).child("conversations").observe(.childAdded) { (snapshot) in
            //print("snapshotsnapshot",snapshot)
            let toUsersID = snapshot.key
            self.toUser.append(toUsersID)
            guard let data = snapshot.value as? [String: Any] else { return }
            guard let chatID = data["chatID"] as? String else { return  }
            guard let lastTime = data["timestamp"] as? Int else { return }
            guard let lastContent = data["content"] as? String else { return }
            let chatRoom = ChatRoom.init(autoID: chatID)
            self.chatID.append(chatRoom)
            if currentUserID != toUsersID {
                self.personArray = [Person]()
                self.rootReference.child("users").child(toUsersID).child("credentials").observe(.value, with: { (snapshot) in
                    //print("User INFO",snapshot)
                    if let data = snapshot.value as? [String: Any] {
                        guard let name = data["name"] as? String else { return }
                        let users = Person.init(name: name, id: toUsersID, conversationsID: chatID, lastTime: lastTime, lastContent: lastContent)
                        self.personArray.append(users)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else { print("Error users data") }
                })
                //downloadLastMessage
                //                let request = chatRoomsReference.child(chatID).queryOrdered(byChild: "timestamp")
                //                request.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
                //                    //print("queryLimited", snapshot.value)
                //                    guard let data = snapshot.value as? [String: Any] else { print("lastMessage error data");return}
                //                    guard let timestamp = data["timestamp"] as? Int else { print("lastMessag error timestamp"); return }
                //                    guard let content = data["content"] as? String else { print("lastMessage error content"); return }
                //                    let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: false, outOwner: .sender, id: chatID)
                //                    self.lastMessage.append(emptyMessage)
                //                    self.tableView.reloadData()
                //                })
            }
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
        //return self.lastMessage.count
        //return conversations.count
        //return chatID.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            cell.nameLabel.text = self.personArray[indexPath.row].name
            cell.messageLabel.text = self.personArray[indexPath.row].lastContent
            //時間格式轉換
            let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.personArray[indexPath.row].lastTime))
            let dataformatter = DateFormatter.init()
            dataformatter.timeStyle = .short
            let date = dataformatter.string(from: messageDate)
            cell.timeLabel.text = date
            //cell.messageLabel.text = self.lastMessage[indexPath.row].content
            //cell.messageLabel.text = self.conversations[indexPath.row].lastMessage.content
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
        if let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatTableViewController {
            print("didSelectRowAt-NextChatVC")
            chatVC.toUser = self.toUser[indexPath.row]
            chatVC.chatKey.autoID = self.chatID[indexPath.row].autoID
            chatVC.userTitle = self.personArray[indexPath.row].name
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

//抓取最後時間和訊息想丟在cell上
//    func downloadLastMessage() {
//        let chatRoomsReference = rootReference.child("conversations")
//        chatRoomsReference.observeSingleEvent(of: .childAdded) { (snap) in
//            let chatID = snap.key
//            let chatRoom = ChatRoom.init(autoID: chatID)
//            self.chatID.append(chatRoom)
//             //chatID
//            let request = chatRoomsReference.child(chatID).queryOrdered(byChild: "timestamp")
//            request.queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
//                for snap in snapshot.children {
//                    guard let childSnapshot = snap as? DataSnapshot else { print("error childSnapshot"); return }
//                    guard let values = childSnapshot.value as? [String: Any] else { print("error values"); return }
//                    guard let timestamp = values["timestamp"] as? Int else { print("error timestamp"); return }
//                    guard let content = values["content"] as? String else { return }
//                    let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: false, outOwner: .sender, id: chatID)
//                    //print("MESSSSSSSSS")
//                    self.lastMessage.append(emptyMessage)
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            })
//        }
//    }







//                    for snap in snapshot.children {
//                        guard let childSnapshot = snap as? DataSnapshot else { print("error childSnapshot"); return }
//                        guard let values = childSnapshot.value as? [String: Any] else { print("error values"); return }
//                        guard let timestamp = values["timestamp"] as? Int else { print("error timestamp"); return }
//                        guard let content = values["content"] as? String else { print("error content"); return }
//                        let emptyMessage = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: false, outOwner: .sender, id: chatID)
//                        self.lastMessage.append(emptyMessage)


//
//                        //                        if self.personArray.count == self.lastMessage.count {
//                        //                            DispatchQueue.main.async {
//                        //                                self.tableView.reloadData()
//                        //                            }
//                        //                        } else {
//                        //                            print("Nooooooooo!!!")
//                        //                        }
//                        //                        for personIfno in self.personArray {
//                        //                            print("person",personIfno)
//                        //                             let showConversations = Conversation.init(user: personIfno, lastMessage: emptyMessage)
//                        //                            self.conversations.append(showConversations)
//                        //
//                        //                        }
//                        //
//                        //                        DispatchQueue.main.async {
//                        //                            self.tableView.reloadData()
//                        //                        }
//
//                    }
