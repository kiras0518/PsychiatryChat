//
//  LoginViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/6.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        exitBarButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                print("User is signed in. Show home screen")
                // User is signed in. Show home screen
                let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "segueToTabBarController")
                self.present(tabBarVC!, animated: true, completion: nil)
            } else {
                // No User is signed in. Show user the login screen
                print("No User is signed in")
            }
        }
    }
    @IBAction func login(_ sender: Any) {
        loginUser()
    }

    @IBAction func forgotPasswordTapped(_ sender: Any) {
        forgetPasswordWithEmail()
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
        self.showHUD(progressLabel: "Loading...")
        DispatchQueue.main.async {
            self.dismissHUD(isAnimated: true)
        }
    }

    func forgetPasswordWithEmail() {
        let forgotPasswordAlert = UIAlertController(title: "Forgot password?", message: "Enter email address", preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = "Enter email address"
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                //Make sure you execute the following code on the main queue
                DispatchQueue.main.async {
                    //Use "if let" to access the error, if it is non-nil
                    if let error = error {
                        let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    } else {
                        let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                }
            })
        }))
        self.present(forgotPasswordAlert, animated: true, completion: nil)
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

extension UIViewController {
    func showHUD(progressLabel: String) {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = progressLabel
    }
    func dismissHUD(isAnimated: Bool) {
        MBProgressHUD.hide(for: self.view, animated: isAnimated)
    }
}
