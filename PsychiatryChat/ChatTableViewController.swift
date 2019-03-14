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
    var messageArray: [Message] = []
    //var selectedChatRoom: ChatRoom?
    var toChatID =  [String]()
    var toUser: User?
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                composeMessage()
                self.inputTextField.text = ""
            }
        }
    }
//    func exitButton() {
//        print("EXIRRRRRR")
//        let back = UIButton(type: .system)
//        back.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        back.tintColor = .white
//        back.setImage(UIImage(named: "back"), for: .normal)
//        back.addTarget(self, action: #selector(ChatTableViewController.onBack), for: .touchUpInside)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
//    }
//    
//    @objc func onBack() {
//        dismiss(animated: true, completion: nil)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getConversations()
        getChat()
        
        //exitButton()
//        let seRef = Database.database().reference().child("conversations")
//        seRef.observeSingleEvent(of: .value, with: { snapshot in
//
//            for item in snapshot.children {
//                if let child = item as? DataSnapshot {
//                    let info = child.value as? [String: Any] ?? [:]
//                    print("infoID:", info)
//                    print("childID:", child.key)
//                    print("content:", info["content"])
//                    print("isRead:", info["isRead"])
//                    print("outTimestamp:", info["outTimestamp"])
//                    //mess.append(info)
//                }
//
//            }
//
//        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         //self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    var selectChat: ConversationID?
    
    //根參考點
    let rootReference = Database.database().reference()
    func composeMessage() {
        if let currentUserID = Auth.auth().currentUser?.uid {
            //創建訊息Ref
            guard let selectChatID = self.selectChat?.autoID else { return }
            let messagesRef: DatabaseReference = rootReference.child("conversations")
            let singleMessageAutoRef = messagesRef.childByAutoId()
            let singleMessageRef = singleMessageAutoRef.child("messages").childByAutoId()
            //print("按下送出\(singleMessageAutoRef.key)")
            //print("按下送出\(singleMessageRef.key)")
            let postMessage = ["content": inputTextField.text!, "fromID": currentUserID, "isRead": false, "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
            //寫入到Firebase
            singleMessageRef.updateChildValues(postMessage)
        }
    }
//    func selectConversations() {
//        //let chatroomID = Database.database().reference().child("Chat_ID")
//        // 1. ChatID -> conversations
//        let conversations: DatabaseReference = Database.database().reference().child("conversations")
//        let conversation: DatabaseReference = conversations.childByAutoId()
//        //let conversionID: String? = conversation.key
//        conversation.setValue(
//            [ "createdAt": Int(Date().timeIntervalSince1970) ]
//        )
//        conversation.observeSingleEvent(
//            of: .childAdded,
//            with: { snapshot in
//                // Converstion ID.
//                let conversionID: String = snapshot.key
//                self.selectedChatRoom?.autoID.append(conversionID)
//                // 2. UserA
//                
//                // 3. UserB
//                
//        }
//        )
//    }
    
    func uploadMessage() {
        if let currentUserID = Auth.auth().currentUser?.uid {
            //            Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value) { (snapshot) in
            //                print("=============")
            //                print(snapshot)
            //                if let data = snapshot.value as? [String : String] {
            //                    let location = data["location"]
            //                    print("@@data@@",data)
            //                    //Database.database().reference().child("conversations").child(location!).childByAutoId().setValue()
            //                }
            //                Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
        }
    }
    
    func getChat() {
        let chatRef = rootReference.child("Chat_ID")
        //let key = chatRef.key
        //print("chatREF", key)
        chatRef.observe(.value) { (snapshot) in
            if let rootDictionary  = snapshot.value as? [String : Any] {
                for (key, value) in rootDictionary {
                    let chatID = key
                    if let value = rootDictionary[chatID] as? [String : Any] {
                        if let location = value["location"] as? String {
                            
                        } else {
                            print("ERROR location")
                        }
                    }
                }
                
            }
        }
    }
    //Downloads messages
    func getConversations() {
        let messagesRef = rootReference.child("conversations").child("conversationsID")
        messagesRef.observe(.value) { (snapshot) in
            var masArray = [Message]()
            if let dictionary: [String : Any] = snapshot.value as? [String : Any] {
                // Key: String, Value: Any
                for (key, value) in dictionary {
                    let conversionID: String = key
                    //print("最外層ID",conversionID)
                    if let messageData = dictionary[conversionID] as? [String : Any] {
                        if let messages = messageData["messages"] as? [String : Any] {
                            for (key, value) in messages {
                                let messageID: String = key
                                //print("messageID", key)
                                if let messageValue = messages[messageID] as? [String : Any] {
                                    if let content = messageValue["content"] as? String {
                                        if let isRead = messageValue["isRead"] as? Bool {
                                            if let timestamp = messageValue["timestamp"] as? Int {
                                                let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: isRead, outOwner: .sender)
                                                    masArray.append(newMessages)
                                            } else {
                                                print("error timestamp")
                                            }
                                        } else {
                                            print("error isRead")
                                        }
                                    } else {
                                        print("error content")
                                    }
                                } else {
                                    print("error messageValue")
                                }
                            }
                        } else {
                            print("error messages")
                        }
                    } else {
                        print("error messageData")
                    }
                }

           }
            self.messageArray = masArray
            self.tableView.reloadData()
        }
    }

}
