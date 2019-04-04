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
        exitBarButton()
    }

    @IBAction func login(_ sender: Any) {
        loginUser()
    }

    func loginUser() {
        guard let email = self.loginEmailField.text else { print("mail error"); return }
        guard let password = self.loginPasswordField.text else { print("password error"); return }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user , error) in
            if error == nil {
                print("successfully logged in")
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "segueToTabBarController")
                self.present(tabBarVC!, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func exitBarButton() {
        let cannel = UIButton(type: .system)
        cannel.frame = CGRect(x: 30, y: 30, width: 30, height: 30)
        cannel.tintColor = .lightGray
        cannel.setImage(UIImage(named: "back"), for: .normal)
        cannel.addTarget(self, action: #selector(LoginViewController.onClose)
            , for: .touchUpInside)
        self.view.addSubview(cannel)
    }

    @objc func onClose() {
        self.dismiss(animated: true, completion: nil)
    }

}
