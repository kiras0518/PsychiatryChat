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

class ChatTableViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerViewBottomAncher: NSLayoutConstraint!
    //var messageArray: [Message] = []
    var messageArray = [Message]()
    var toUser: String = ""
    var currentUser: String = ""
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
        self.inputTextField.delegate = self
        print("CTVCtoUser",toUser)
        print("CTVCtoChatID",chatKey.autoID)
        print("CTVCtoName",currentUser)
        self.navigationItem.title = self.currentUser
        getConversations()
        exitBarButton()
    }
    //View 要被呈現前，發生於 viewDidLoad 之後：
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //configureObserver()
        //getConversations()
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.rootReference.removeAllObservers()
//    }

    func exitBarButton() {
        let cannel = UIButton(type: .system)
        cannel.setImage(UIImage(named: "close"), for: .normal)
        cannel.addTarget(self, action: #selector(ChatTableViewController.onClose)
            , for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cannel)
    }

    @objc func onClose() {
        self.navigationController?.popViewController(animated: true)
         //self.dismiss(animated: true, completion: nil)
    }

    //send Message
    func composeMessage() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            //創建Ref
            let messagesRef = rootReference.child("conversations")
            let usersRef = rootReference.child("users")
            let psychologistRef = rootReference.child("psychologists")
            guard let inputTextField = self.inputTextField.text else { return }
            let postMessage = ["content": inputTextField,
                           "fromID": currentUserID,
                           "isRead": false,
                           "toID": self.toUser,
                           "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
        //先去user底下的查看是否有chitID,確定有chatID 後再新增 message
        usersRef.child(currentUserID).child("conversations").child(toUser).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("users",snapshot,snapshot.key)
                guard let data = snapshot.value as? [String: Any] else { return }
                guard let chatID = data["chatID"] as? String else { return }
                //print("users 底下",chatID)
                messagesRef.child(chatID).childByAutoId().setValue(postMessage)
            })
        psychologistRef.child(currentUserID).child("conversations").child(toUser).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let data = snapshot.value as? [String: Any] else { return }
                guard let chatID = data["chatID"] as? String else { return }
                messagesRef.child(chatID).childByAutoId().setValue(postMessage)
        })
    }
    //Downloads messages
    func getConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let conversationsRef = rootReference.child("conversations")
        print("getConversations test")
        conversationsRef.child(chatKey.autoID).observe(.childAdded) { (snapshot) in
            //print("value",snapshot.value)
            let chatID = self.chatKey.autoID
            guard let data = snapshot.value as? [String: Any] else { return }
            //print("DDDDDDD",data)
            guard let content = data["content"] as? String else { return }
            guard let timestamp = data["timestamp"] as? Int else { return }
            guard let isRead = data["isRead"] as? Bool else { print("error isRead"); return }
            guard let fromID = data["fromID"] as? String else { print("error fromID"); return }
            if fromID == currentUserID {
                let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .receiver, id: chatID)
                    self.messageArray.append(newMessages)
            } else {
                let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .sender, id: chatID)
                    self.messageArray.append(newMessages)
            }
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
}

extension ChatTableViewController {

//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ChatTableViewController: UITableViewDelegate, UITableViewDataSource {
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
}
