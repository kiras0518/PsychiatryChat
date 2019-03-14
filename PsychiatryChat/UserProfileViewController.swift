//
//  UserProfileViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/14.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("登出成功")
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView")
            self.present(loginVC!, animated: true, completion: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
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
