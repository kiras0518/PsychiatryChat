//
//  UserProfileViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/14.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class UserProfileViewController: UIViewController {

    //根參考點
    let rootReference = Database.database().reference()
    var patient = "patient"
    var psychologists = "psy"
    let currentUserIDs = Auth.auth().currentUser?.uid
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCertificate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setBarButton()
        userInfo()
    }
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("登出成功")
            let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: "welcomeVC")
            self.present(welcomeVC!, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    @IBAction func editUserInfo(_ sender: Any) {
        selectInfo()
    }
}

extension UserProfileViewController {

    func userInfo() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef: DatabaseReference = Database.database().reference().child("users").child(currentUserID).child("credentials")
        userRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let name = dictionary["name"] as? String else { return }
            self.userName.text = name
        })
        let psychologistsRef: DatabaseReference = Database.database().reference().child("psychologists").child(currentUserID).child("credentials")
        psychologistsRef.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let name = dictionary["name"] as? String else { return }
            guard let certificate = dictionary["certificate"] as? String else { return }
            self.userName.text = name
            self.userCertificate.text = "諮心字第\(certificate)號"
        })
    }

    func selectInfo() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        rootReference.child("users").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? [String: Any] else { return}
            guard let role = data["role"] as? String else { print("error jobs"); return}
            if role == self.patient {
                if let editUserVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditUsersVC") as? EditUserProfileViewController {
                    self.present(editUserVC, animated: true, completion: nil)
                }
            } else {
                print("error")
            }
        }
        rootReference.child("psychologists").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? [String: Any] else { return}
            guard let role = data["role"] as? String else { print("error jobs"); return}
            if role == self.psychologists {
                print("3")
                if let edidPsychologistVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPsycholistVC") as? EditPsychologistViewController {
                    self.present(edidPsychologistVC, animated: true, completion: nil)
                }
            } else {
                print("error")
            }
        }
    }
}
