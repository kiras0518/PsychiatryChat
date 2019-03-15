//
//  RegisterViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/14.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func register(_ sender: Any) {
        registerUser()
    }
    func registerUser() {
        guard let registerName = self.registerName.text else { return }
        guard let registerEmail = self.registerEmail.text else { return }
        guard let registerPassword = self.registerPassword.text else { return }
        if registerName.isEmpty {
            let alert = UIAlertController(title: "Sign In Failed", message: "請輸入完整資訊", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            //Firebase註冊建立帳號
            let userRef = Database.database().reference().child("users")
            Auth.auth().createUser(withEmail: registerEmail, password: registerPassword, completion: { (user, error) in
                if error == nil {
                    let userID = Auth.auth().currentUser!.uid
                    let userData = ["name": registerName, "email": registerEmail]
                    userRef.child(userID).child("credentials").setValue(userData)
                    print("Sucess createUser")
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "segueToTabBarController")
                    self.present(tabBarVC!, animated: true, completion: nil)
                } else {
                    if error != nil {
                        let alert = UIAlertController(title: "註冊失敗", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        print("==失敗原因==", error?.localizedDescription as Any)
                    }
                }
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
