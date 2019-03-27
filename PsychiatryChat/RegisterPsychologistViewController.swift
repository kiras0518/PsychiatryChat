//
//  RegisterPsychologistViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/15.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class RegisterPsychologistViewController: UIViewController {

    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registercertificate: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        exitBarButton()
    }
    @IBAction func register(_ sender: Any) {
        registerUser()
    }
    func registerUser() {
        guard let registerName = self.registerName.text else { return }
        guard let registerEmail = self.registerEmail.text else { return }
        guard let registerPassword = self.registerPassword.text else { return }
        guard let registercertificate = self.registercertificate.text else { return }
        if registerName.isEmpty {
            let alert = UIAlertController(title: "Sign In Failed", message: "請輸入完整資訊", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else if registercertificate.isEmpty || registercertificate.count > 6 || registercertificate.count < 6 {
            let alert = UIAlertController(title: "Sign In Failed", message: "請輸入正確證字書號", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            //Firebase註冊建立帳號
            let userRef = Database.database().reference().child("psychologists")
            Auth.auth().createUser(withEmail: registerEmail, password: registerPassword, completion: { (user, error) in
                if error == nil {
                    let userID = Auth.auth().currentUser!.uid
                    let userData = ["name": registerName, "email": registerEmail, "certificate": registercertificate]
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
