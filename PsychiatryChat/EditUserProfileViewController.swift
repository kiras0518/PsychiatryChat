//
//  EditUserProfileViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/22.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class EditUserProfileViewController: UIViewController, UITextFieldDelegate {
    var userRef: DatabaseReference = Database.database().reference().child("users")
    @IBOutlet weak var name: UITextField!
    @IBAction func save(_ sender: UIButton) {
        editInfo()
    }
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userInfoRef: DatabaseReference = userRef.child(currentUserID).child("credentials")
        userInfoRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let name = dictionary["name"] as? String else { return }
            self.name.text = name
        })
        self.name.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func editInfo() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userInfoRef: DatabaseReference = userRef.child(currentUserID).child("credentials")
        guard let name = name.text else { return }
        userInfoRef.updateChildValues(["name": name])
        self.dismiss(animated: true, completion: nil)
    }
}
