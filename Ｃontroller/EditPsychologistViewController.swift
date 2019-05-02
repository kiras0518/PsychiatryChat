//
//  EditPsychologistViewController.swift
//  PsychiatryChat
//
//  Created by YU on 2019/3/25.
//  Copyright © 2019 ameyo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditPsychologistViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    private var currentUserID: String {

        return (Auth.auth().currentUser?.uid)!

    }

    var userRef: DatabaseReference = Database.database().reference().child("psychologists")

    var imagePicker = UIImagePickerController()

    @IBOutlet weak var education: UITextField!

    @IBOutlet weak var position: UITextField!

    @IBOutlet weak var personalFee: UITextField!

    @IBOutlet weak var coupleFee: UITextField!

    @IBOutlet weak var expertise: UITextField!

    @IBOutlet weak var introduction: UITextView!

    @IBOutlet weak var psyImageView: UIImageView!

    @IBAction func saveButton(_ sender: UIButton) {

        editInfo()

    }

    @IBAction func uploadButton(_ sender: UIButton) {

        openPicker()

    }

    @IBAction func closeButton(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    func fetchImage() {
        //let reference = storageRef.child("images/stars.jpg")
        let photoID = String(currentUserID)

        let storageRef = Storage.storage().reference().child("PsychologistsImages").child("\(photoID).jpg")

        storageRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in

            if error != nil {

                print("FetchImage Error: \(String(describing: error))")

            } else {

                if let imageData = data {
                    
                    DispatchQueue.main.async {
                        
                        let image = UIImage(data: imageData)
                        
                        self.psyImageView.image = image
                        
                        //self.psyImageView.contentMode = .scaleAspectFit
                    }
                }
            }
        })
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        
        psyImageView.clipsToBounds = true

        fetchImage()

        self.imagePicker.delegate = self

        let userInfoRef: DatabaseReference = userRef.child(currentUserID).child("credentials")

        userInfoRef.observe(.value, with: { (snapshot) in

            guard let dictionary = snapshot.value as? [String: Any] else { return }

            guard let education = dictionary["education"] as? String else { return }

            guard let position = dictionary["position"] as? String else { return }

            guard let personalFee = dictionary["personalFee"] as? String else { return }

            guard let coupleFee = dictionary["coupleFee"] as? String else { return }

            guard let expertise = dictionary["expertise"] as? String else { return }

            guard let introduction = dictionary["introduction"] as? String else { return }

            self.education.text = education

            self.position.text = position

            self.coupleFee.text = coupleFee

            self.personalFee.text = personalFee

            self.expertise.text = expertise

            self.introduction.text = introduction

        })

        self.education.delegate = self

        self.position.delegate = self

        self.coupleFee.delegate = self

        self.personalFee.delegate = self

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

        guard let education = education.text else { return }

        guard let position = position.text else { return }

        guard let personalFee = personalFee.text else { return }

        guard let coupleFee = coupleFee.text else { return }

        guard let expertise = expertise.text else { return }

        guard let introduction = introduction.text else { return }

        userInfoRef.updateChildValues(["education": education])

        userInfoRef.updateChildValues(["position": position])

        userInfoRef.updateChildValues(["personalFee": personalFee])

        userInfoRef.updateChildValues(["coupleFee": coupleFee])

        userInfoRef.updateChildValues(["expertise": expertise])

        userInfoRef.updateChildValues(["introduction": introduction])

        self.dismiss(animated: true, completion: nil)
    }

    func setPhoto(userImageURL: String) {

        if let imageUrl = URL(string: userImageURL) {

            let task = URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in

                if error != nil {

                    print("Download Image Task Fail: \(error!.localizedDescription)")

                } else if let imagedata = data {

                    print("讀取頭貼成功")

                    DispatchQueue.main.async() {

                        self.psyImageView.image = UIImage(data: imagedata)
                        //self.psyImageView.contentMode = .scaleAspectFill
                        self.dismissHUD(isAnimated: true)
                    }
                }
            })
            task.resume()
        }
    }
}

extension EditPsychologistViewController {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var selectedImageFromPicker: UIImage?

        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[.originalImage] as? UIImage {

                selectedImageFromPicker = pickedImage

        }

        let photoID = String(currentUserID)
        // 將照片上傳到 Storage
        if let selectImage = selectedImageFromPicker {

            print("photoString",photoID, "selectImage", selectImage)

            let storageRef = Storage.storage().reference().child("PsychologistsImages").child("\(photoID).jpg")

             // 將圖片轉成 jpg 後上傳到 storage
            if let uploadData = selectImage.jpegData(compressionQuality: 0.5) {
                self.showHUD(progressLabel: "上傳中....")
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    if error != nil {

                        print("Error: \(error!.localizedDescription)")
                        return

                    }
                    // 取得上傳圖片連結的方式
                    storageRef.downloadURL(completion: { (url, error) in

                        if error != nil {

                            print("Error: \(String(describing: error?.localizedDescription))")
                            return

                        } else {
                            // Get the download URL for 'images/stars.jpg'
                            //print("Photo Url: \(url?.absoluteString)")
                            let uploadImageUrl = url?.absoluteString
                            
                            let databaseRef = self.userRef.child(self.currentUserID).child("credentials").child("profilePic")

                            databaseRef.setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in

                                print("dataRef",dataRef)
                                if error != nil {
                                    
                                    print("Error: \(error!.localizedDescription)")

                                } else {
                                   print("圖片已儲存")
                                   DispatchQueue.main.async() {

                                    self.setPhoto(userImageURL: uploadImageUrl!)

                                    }
                                }
                            })
                        }
                    })
                })
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    func openPicker() {
        
        let alert = UIAlertController(title: "上傳圖片", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "相機", style: .default, handler: { (view) in
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                print("can't open camera library"); return }
            
            self.imagePicker.sourceType = .camera
            
            self.imagePicker.allowsEditing = true
            
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))

        alert.addAction(UIAlertAction(title: "照片圖庫", style: .default, handler: { (view) in
            //判斷是否可以從照片圖庫取得照片來源
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                print("can't open photo library"); return }
            //指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
            self.imagePicker.sourceType = .photoLibrary
            //為選取後的照片是否能編緝
            self.imagePicker.allowsEditing = true

            self.present(self.imagePicker, animated: true, completion: nil)

        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }

}
