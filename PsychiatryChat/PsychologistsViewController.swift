//
//  PsychologistsViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/14.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
class PsychologistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var didSelectIndexPath: IndexPath = []
    var userArray = [Psychologist]()
    var chatID = ChatRoom.init(autoID: "")
    var toUserID: String = ""
    var sychologists: [Psychologist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchPsychologist()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PsychologistsCell", for: indexPath) as? PsychologistsCell {
            cell.nameLabel.text = userArray[indexPath.row].name
            cell.educationLable.text = userArray[indexPath.row].education
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("PsyVC 你選擇了 \(indexPath.row)")
        self.didSelectIndexPath = indexPath
        self.performSegue(withIdentifier: "next", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            if let detailController = segue.destination as? PsychologistsDetailViewController {
                detailController.psychologist = userArray[didSelectIndexPath.row]
            } else {
                print("ERROR")
            }
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
    //getPsychologistData
    func fetchPsychologist() {
        Database.database().reference().child("psychologists").observe(.childAdded, with: { (snapshot) in
            guard let snapshotValue = snapshot.value as? [String: Any] else { return }
                //print("snapshotValue",snapshotValue)
                let userID = snapshot.key
            guard let credentials = snapshotValue["credentials"] as? [String: Any] else { return }
            print("==credentials==", credentials)
            guard let name = credentials["name"] as? String else { print("error name");return }
            guard let education = credentials["education"] as? String else { print("error education");return }
            guard let certificate = credentials["certificate"] as? String else { print("error certificate");return }
            guard let personalFee = credentials["personalFee"] as? String else { print("error personalFee");return }
            guard let coupleFee = credentials["coupleFee"] as? String else { print("error coupleFee");return }
            guard let introduction = credentials["education"] as? String else { print("error introduction");return }
            guard let expertise = credentials["expertise"] as? String else { print("error expertise");return }
            guard let position = credentials["position"] as? String else { print("error position");return }
            let psychologistInfo = Psychologist.init(name: name, id: userID, certificate: certificate, education: education, introduction: introduction, personalFee: personalFee, coupleFee: coupleFee, expertise: expertise, position: position)
            self.userArray.append(psychologistInfo)
            self.tableView.reloadData()
        })
    }
}
