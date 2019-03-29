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

class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var keyboardHeight: CGFloat = 0 // keep 住鍵盤的高度，在每次 ChangeFrame 的時侯記錄
    var container: NSLayoutConstraint?
    @IBOutlet weak var containerViewBottomAncher: NSLayoutConstraint!
    //var messageArray: [Message] = []
    var messageArray = [Message]()
    var converID: ChatRoom = ChatRoom.init(autoID: "")
    var toUser: String = ""
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
        print("chatid",chatKey.autoID)
        getConversations()
        exitBarButton()
    }
    //View 要被呈現前，發生於 viewDidLoad 之後：
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //configureObserver()
        //getConversations()
    }

    func configureObserver() {
        // 鍵盤的生命週期
        // 註冊監聽鍵盤出現的事件
        NotificationCenter.default.addObserver(self, selector: #selector(ChatTableViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        //註冊監聽鍵盤消失的事件
        NotificationCenter.default.addObserver(self, selector: #selector(ChatTableViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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

    /// 監聽鍵盤開啟事件(鍵盤切換時總會觸發，不管是不是相同 type 的....例如：預設鍵盤 → 數字鍵盤)
    ///
    /// - Parameter notification: _
    @objc func keyboardWillShow(notification: Notification) {
        print("keyboardWillShow...")

        //guard let userinfo = notification.userInfo else { return }
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: 0) {
            let transform = CGAffineTransform(translationX: 0, y: -(rect.size.height))
            self.view.transform = transform
        }
//        guard let keyboardFrame = (userinfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }

        
        
//        if let userinfo = notification.userInfo
//        {
//            let keyboardFrame = (userinfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
//            let keyboardDuration = (userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double)
//            containerViewBottomAncher.constant = ((keyboardFrame?.height)!)
//            UIView.animate(withDuration: keyboardDuration!) {
//                self.view.layoutIfNeeded()
//            }
//        }
    }



//        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let height = frame.cgRectValue.height
//            print("hieght",height)
        
            
        
//        if let userInfo = notification.userInfo {
//            if let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                if let duration: Double = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
//
//            UIView.animate(withDuration: duration, animations: { () -> Void in
//                var frame = self.view.frame
//                frame.origin.y = keyboardFrame.minY - self.view.frame.height
//                self.view.frame = frame
//                 print("self.view.frame",self.view.frame)
//            })
//                }
//            }
//        }

//            self.tableView.contentInset.bottom = height
//            self.tableView.scrollIndicatorInsets.bottom = height
//            if self.messageArray.count > 0 {
//                self.tableView.scrollToRow(at: IndexPath.init(row: self.messageArray.count - 1, section: 0), at: .bottom, animated: true)
//            }
        
  //  }
    
    // 監聽鍵盤關閉事件(鍵盤關掉時才會觸發)
    @objc func keyboardWillHide(notification: Notification) {
        print("keyboardWillHide...")
//        if self.view.frame.origin.y != 0 {
//            containerViewBottomAncher.constant = 0
//    }
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: 0) {
            self.view.transform = CGAffineTransform.identity
        }

    }

    
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.5) {
//            self.heightConstraint.constant = 300
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    //send Message
    func composeMessage() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            //創建Ref
            let messagesRef = rootReference.child("conversations")
            let usersRef = rootReference.child("users")
       
            let postMessage = ["content": self.inputTextField.text,
                           "fromID": currentUserID,
                           "isRead": false,
                           "toID": self.toUser,
                           "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
        //先取得user底下的chitID,取得chatID後再新增 message
        usersRef.child(currentUserID).child("conversations").child(toUser).observeSingleEvent(of: .value, with: { (snapshot) in
            //print("users",snapshot,snapshot.key)
            //if snapshot.exists() {
                guard let data = snapshot.value as? [String: Any] else { return }
                guard let chatID = data["chatID"] as? String else { return }
                //print("users 底下",chatID)
                
                messagesRef.child(chatID).childByAutoId().setValue(postMessage)
            //}
            })
    }
    //Downloads messages
    func getConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let conversationsRef = rootReference.child("conversations")
        let usersRef = rootReference.child("users")
        usersRef.child(currentUserID).child("conversations").child(toUser).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                guard let data = snapshot.value as? [String: String] else { return }
                guard let chatID = data["chatID"] as? String else { return }
                
                conversationsRef.child(chatID).observe(.value, with: { (snapshot) in
                    
                    let chatID = snapshot.key
                    print("conversationsRef底下",chatID)
                   // if snapshot.exists() {
                    self.messageArray = []
                    for eachMessage in snapshot.children {
                        //print("eachMessage",eachMessage)
                        guard let childSnapshot = eachMessage as? DataSnapshot else { print("error childSnapshot"); return }
                            //print("MMMMMMMM",childSnapshot)
                            //print("childSnapshot", childSnapshot)
                            //print("childSnapshot.value",childSnapshot.value)
                        guard let snapshotValue = childSnapshot.value as? [String: Any] else { print("ChatTableVC error snapshotValue"); return }
                        guard let content = snapshotValue["content"] as? String else { print("error content"); return }
                        guard let timestamp = snapshotValue["timestamp"] as? Int else { print("error timestamp"); return }
                        guard let isRead = snapshotValue["isRead"] as? Bool else { print("error isRead"); return }
                        guard let fromID = snapshotValue["fromID"] as? String else { print("error fromID"); return }
                        if fromID == currentUserID {
                            let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .receiver)
                            self.messageArray.append(newMessages)
                                //print("messageArray receiver",self.messageArray)
                        } else {
                            let newMessages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: true, outOwner: .sender)
                            self.messageArray.append(newMessages)
                                //print("messageArray sender",self.messageArray)
                            }
                        }
                   // }
                    DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.messageArray.count - 1, section: 0), at: .bottom, animated: true)
                    }
                })
            }
        })
    }
}
