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
    
    var messageArray : [Message] = []
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.characters.count > 0 {
                let messageRef = Database.database().reference().child("conversations").childByAutoId()
                let message = ["content": inputTextField.text!,"isRead": false, "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
                messageRef.updateChildValues(message)
                self.inputTextField.text = ""
            }
        }
        print(inputTextField.text!)
    }
    func getConversations() {
        let messagesRef = Database.database().reference().child("conversations")
        messagesRef.observe(.childAdded) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : Any] {
                print("snapshotValue",snapshotValue)
                if let content = snapshotValue["content"] as? String {
                    print("content",content)
                    if let isRead = snapshotValue["isRead"] as? Bool {
                        print("isRead",isRead)
                        if let timestamp = snapshotValue["timestamp"] as? Int {
                            print("timestamp",timestamp)
                            let messages = Message.init(outContent: content, outTimestamp: timestamp, outIsRead: isRead)
                            self.messageArray.append(messages)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getConversations()
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
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as? SenderCell {

            cell.message.text = messageArray[indexPath.row].content
            return cell
        }
        return UITableViewCell()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
