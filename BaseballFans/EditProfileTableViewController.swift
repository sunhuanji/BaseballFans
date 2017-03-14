//
//  EditProfileTableViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    @IBOutlet weak var teamNameTextField: UITextField!
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }

    
    var pickerView: UIPickerView!
    var teamArrays = ["福岡ソフトバンクホークス","北海道日本ハムファイターズ","埼玉西武ライオンズ","オリックス・バファローズ","東北楽天ゴールデンイーグルス","千葉ロッテマリーンズ","中日ドラゴンズ","東京ヤクルトスワローズ","読売ジャイアンツ","阪神タイガース","広島東洋カープ","横浜DeNAベイスターズ"]
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        teamNameTextField.delegate = self
        biographyTextField.delegate = self
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.black
        teamNameTextField.inputView = pickerView
        
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
       
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        fetchCurrentUserInfo()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       // fetchCurrentUserInfo()
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }

    
    
    func fetchCurrentUserInfo(){
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        self.userImageView.layer.cornerRadius = self.userImageView.layer.frame.width/2
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.emailTextField.text = user.email
                self.usernameTextField.text = user.username
                self.biographyTextField.text = user.biography
                self.teamNameTextField.text = user.teamName
                
            }
            
            let imageURL = self.user.photoURL
            
            FIRStorage.storage().reference(forURL: imageURL!).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    if let data = data {
                        DispatchQueue.main.async(execute: {
                            
                            self.userImageView.image = UIImage(data: data)
                        })  }
                    
                }else {
//                    let alertView = SCLAlertView()
//                    _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                }
            })
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
            
        }


        
        
    }
    
    @IBAction func updateAction(_ sender: AnyObject) {
    
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let teamName = teamNameTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image

        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        
        if finalEmail.isEmpty || finalEmail.characters.count < 8 || teamName.isEmpty || username.isEmpty {
            DispatchQueue.main.async(execute: {
                let alertView =  SCLAlertView()
                _ = alertView.showError("ERROR", subTitle: "Did not fill the information correctly")
                
            })
            
        }else {
            
            let imagePath = "profileImage\(user.uid!)/userPic.jpg"
            
            let imageRef = storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.put(imgData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    FIRAuth.auth()!.currentUser!.updateEmail(finalEmail, completion: { (error) in
                        if error == nil {
                            print("email updated successfully")
                        }else {
                            DispatchQueue.main.async(execute: {
//                                let alertView =  SCLAlertView()
//                                _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                            })
                        }
                    })
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = username
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChanges(completion: { (error) in
                        if error == nil {
                            let user = FIRAuth.auth()!.currentUser!
                            
                            let userInfo = ["email": user.email!, "username": username, "teamName": teamName,"biography": biography, "uid": user.uid, "photoURL": String(describing: user.photoURL!)]
                            
                            let userRef = self.databaseRef.child("users").child(user.uid)
                            
                            userRef.updateChildValues(userInfo, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    _ = self.navigationController?.popToRootViewController(animated: true)
                                }else {
                                    DispatchQueue.main.async(execute: {
//                                        let alertView =  SCLAlertView()
//                                        _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                                    })
                                    
                                }
                            })
                        }
                        else {
                            
                            DispatchQueue.main.async(execute: {
//                                let alertView =  SCLAlertView()
//                                _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                            })
                        }
                        
                    })
                }else {
                    
                    DispatchQueue.main.async(execute: {
//                        let alertView =  SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                    })
                }
            }
            
          
            
        }

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        teamNameTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.choosePictureAction()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.userImageView.image = image
    }
    
   

    // MARK: - Picker view data source
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        teamNameTextField.text = teamArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamArrays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let title = NSAttributedString(string: teamArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return title
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
}
