//
//  EditPsychologistViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/25.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class EditPsychologistViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var userRef: DatabaseReference = Database.database().reference().child("psychologists")
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var education: UITextField!
    @IBOutlet weak var position: UITextField!
    @IBOutlet weak var personalFee: UITextField!
    @IBOutlet weak var coupleFee: UITextField!
    @IBOutlet weak var expertise: UITextField!
    @IBOutlet weak var introduction: UITextView!
    @IBAction func saveButton(_ sender: UIButton) {
        editInfo()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userInfoRef: DatabaseReference = userRef.child(currentUserID).child("credentials")
        userInfoRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            //guard let name = dictionary["name"] as? String else { return }
            guard let education = dictionary["education"] as? String else { return }
            guard let position = dictionary["position"] as? String else { return }
            guard let personalFee = dictionary["personalFee"] as? String else { return }
            guard let coupleFee = dictionary["coupleFee"] as? String else { return }
            guard let expertise = dictionary["expertise"] as? String else { return }
            guard let introduction = dictionary["introduction"] as? String else { return }
            //self.name.text = name
            self.education.text = education
            self.position.text = position
            self.coupleFee.text = coupleFee
            self.personalFee.text = personalFee
            self.expertise.text = expertise
            self.introduction.text = introduction
        })
        self.name.delegate = self
        self.education.delegate = self
        self.position.delegate = self
        self.coupleFee.delegate = self
        self.coupleFee.delegate = self
        self.expertise.delegate = self
        self.introduction.delegate = self
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
        //guard let name = name.text else { return }
        guard let education = education.text else { return }
        guard let position = position.text else { return }
        guard let personalFee = personalFee.text else { return }
        guard let coupleFee = coupleFee.text else { return }
        guard let expertise = expertise.text else { return }
        guard let introduction = introduction.text else { return }
        //userInfoRef.updateChildValues(["name": name])
        userInfoRef.updateChildValues(["education": education])
        userInfoRef.updateChildValues(["position": position])
        userInfoRef.updateChildValues(["personalFee": personalFee])
        userInfoRef.updateChildValues(["coupleFee": coupleFee])
        userInfoRef.updateChildValues(["expertise": expertise])
        userInfoRef.updateChildValues(["introduction": introduction])
        self.dismiss(animated: true, completion: nil)
    }
}
