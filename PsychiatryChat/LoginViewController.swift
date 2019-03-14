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
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "segueToTabBarController")
                self.present(tabBarVC!, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}
