//
//  ChatTableViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    //var messageArray: [Message] = []
    var messageArray = [Message]()
    var converID: ChatRoom = ChatRoom.init(autoID: "")
    //var psychologist: Psychologist?
    //var selectedChatRoom: ChatRoom?
    //var converIDS: String = ""
    var toUser: String = ""
    //var currentUser: User?
    //用來接前面一個畫面傳過來的roomID
    var chatKey: ChatRoom = ChatRoom.init(autoID: "")
    //根參考點
    let rootReference = Database.database().reference()
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.count > 0 {
                composeMessage()
                self.inputTextField.text = ""
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("CTVC",toUser)
        print("chatid",chatKey.autoID)
//        if let currentUserID = Auth.auth().currentUser?.uid { Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
//            //let toUserID = snapshot.key
//            //print("toUserID",toUserID)
//            self.toUser = snapshot.key
//            if let values = snapshot.value as? [String: String] {
//                print("values",values)
//                if let chatID = values["chatID"] as? String {
//                    print("chatID",chatID)
//                    //self.chatID.autoID.append(chatID)
//                    self.chatKey.autoID.append(chatID)
//                }
//            }
//        })
//        }
        getConversations()
        exitBarButton()

    }
    func exitBarButton() {
        let cannel = UIButton(type: .system)
        cannel.setImage(UIImage(named: "close"), for: .normal)
        cannel.addTarget(self, action: #selector(ChatTableViewController.onClose)
            , for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cannel)
    }
    @objc func onClose() {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.messageArray[indexPath.row].owner {
        case .sender:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as? SenderCell {
                cell.message.text = self.messageArray[indexPath.row].content
                print("AAAAA",cell)
                print("BBBBBBB",cell.message.text)
                cell.test.text = "@@第 \(indexPath.row) 個Cell@@"
                print("MEASSSSS",self.messageArray[indexPath.row].content)
                return cell
            }
        case .receiver:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as? ReceiverCell {
                cell.message.text = self.messageArray[indexPath.row].content
                return cell
            }
        }
        return UITableViewCell()
    }
    //send Message
    func composeMessage() {
        if let currentUserID = Auth.auth().currentUser?.uid {
            //聊天室ID
            //let selectChatID = converID.autoID
            //print("composeMessage,selectChatID",selectChatID)
            //創建Ref
            let messagesRef = rootReference.child("conversations")
            let singleMessageAutoRef = messagesRef.child(self.chatKey.autoID)
            let singleMessageRef = singleMessageAutoRef.childByAutoId()
            
            print("按下送出\(singleMessageAutoRef.key)")
            print("按下送出\(singleMessageRef.key)")
            let postMessage = ["content": self.inputTextField.text!,
                               "fromID": currentUserID,
                               "isRead": false,
                               "toID": self.toUser,
                               "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
            print("postMessage",postMessage)
            singleMessageRef.setValue(postMessage)
//            messagesRef.observe(.value) { (snapsh) in
//                let singleMessageAutoRef = messagesRef.child(self.chatKey.autoID)
//                let singleMessageRef = singleMessageAutoRef.childByAutoId()
//                print("按下送出\(singleMessageAutoRef.key)")
//                print("按下送出\(singleMessageRef.key)")
//
//
//
//                let postMessage = ["content": self.inputTextField.text!,
//                                   "fromID": currentUserID,
//                                   "isRead": false,
//                                   "toID": self.toUser,
//                                   "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
//                print("postMessage",postMessage)
//                //寫入到Firebase
//  //              singleMessageRef.updateChildValues(postMessage)
////                singleMessageRef.setValue(postMessage)
////                print("singleMessageRef",singleMessageRef)
//            }
        }
    }
    //Downloads messages
    func getConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let conversationsRef = rootReference.child("conversations")
        //要到選擇的聊天室的節點
        let singleChatIDRef = conversationsRef.child(self.chatKey.autoID)
        //guard let selectedChatRoom = selectedChatRoom else { return }
        print("@@singleMessageAutoRef@@2",singleChatIDRef)
        
        //conversationsRef.observe(.value) { (snapshot) in
            //let selectChatID = self.converID.autoID
            //print("snapshotmessagesRef",snapshot.value)
            singleChatIDRef.observe(.value, with: { (snapshot) in
            print("singleChatIDRef",snapshot)
                self.messageArray = []
                for eachMessage in snapshot.children {
                    print("eachMessage",eachMessage)
                    guard let childSnapshot = eachMessage as? DataSnapshot else { print("error childSnapshot"); return }
                    print("childSnapshot", childSnapshot)
                    print("childSnapshot.value",childSnapshot.value)
                    
                    guard let snapshotValue = childSnapshot.value as? [String: Any] else { print("ChatTableVC error snapshotValue"); return }
                    print("snapshotValue",snapshotValue)
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    guard let content = snapshotValue["content"] as? String else { print("error content"); return }
                    guard let timestamp = snapshotValue["timestamp"] as? Int else { print("error timestamp"); return }
                    guard let isRead = snapshotValue["isRead"] as? Bool else { print("error isRead"); return }
                    guard let fromID = snapshotValue["fromID"] as? String else { print("error fromID"); return }
                    
                    if fromID == currentUserID {
                    let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .receiver)
                        self.messageArray.append(newMessages)
                        print("messageArray receiver",self.messageArray)
                    } else {
                        let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .sender)
                        self.messageArray.append(newMessages)
                        print("messageArray sender",self.messageArray)
                    }
                }
                self.tableView.reloadData()
////                guard let dictionary: [String : Any] = snapshot.value as? [String : Any] else { print("dictionary error");return }
////                print("CTVCdictionary",dictionary)
////                guard let content = dictionary["content"] as? String else { print("error content"); return }
////                guard let timestamp = dictionary["timestamp"] as? Int else { print("error timestamp"); return }
////                guard let isRead = dictionary["isRead"] as? Bool else { print("error isRead"); return }
////                guard let fromID = dictionary["fromID"] as? String else { print("error fromID"); return }
////                if fromID == currentUserID {
////                    let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .receiver)
////                    self.messageArray = [newMessages]
////                } else {
////                    let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .sender)
////                    self.messageArray.append(newMessages)
////                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            })
        //}
    }
}
