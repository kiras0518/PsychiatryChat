//
//  LoginViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func login(_ sender: Any) {
        loginUser()
    }
    func loginUser() {
        guard let email = self.loginEmailField.text else { print("mail error"); return }
        guard let password = self.loginPasswordField.text else { print("password error"); return }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("successfully logged in")
 //               self.performSegue(withIdentifier: "goChat", sender: self)
                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
                self.present(messageVC!, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    @IBAction func register(_ sender: Any) {
        registerUser()
    }
    func registerUser() {
        guard let registerName = self.registerNameField.text else { return }
        guard let registerEmail = self.registerEmailField.text else { return }
        guard let registerPassword = self.registerPasswordField.text else { return }
        if registerName.isEmpty {
            let alert = UIAlertController(title: "Sign In Failed", message: "請輸入完整資訊", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                return
        }
        //Firebase註冊建立帳號
        let userRef = Database.database().reference().child("users")
        Auth.auth().createUser(withEmail: registerEmail, password: registerPassword, completion: { (user, error) in
            if error == nil {
                //let newUser = User.init(name: registerName, email: registerEmail, id: (userData?.user.uid)!)
                let userdata = ["name": registerName, "email": registerEmail, "pass": registerPassword]
                userRef.child((user?.user.uid)!).child("credentials").setValue(userdata)
                //usersRef.updateChildValues(userdata)
                print("Sucess createUser")
                let messageVC = self.storyboard?.instantiateViewController(withIdentifier: "Navigation")
                self.present(messageVC!, animated: true, completion: nil)
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
