//
//  AddPostViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/19.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class AddPostViewController: UIViewController
, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var isSwitched: UISwitch!
    @IBOutlet weak var numberOfCharLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postImageView: UIImageView!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    
    var currentUser: User!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postTextView.layer.cornerRadius = 5
        self.postTextView.layer.borderWidth = 2
        self.postTextView.layer.borderColor = UIColor(red: 16/255.0, green: 171/255.0, blue: 235/255.0, alpha: 1.0).cgColor
        postTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = true
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.currentUser = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            
        }) { (error) in
            
        }
        
    }
    
    @IBAction func choosePictureAction() {
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.postImageView.image = image
    }
    
    
    @IBAction func showPictureAction(_ sender: AnyObject) {
        
        if isSwitched.isOn {
            postImageView.alpha = 1.0
        }else{
            postImageView.alpha = 0.0
            
        }
        
    }
    
    @IBAction func saveTweetAction(_ sender: AnyObject) {
        
        var postText: String!
        if let text: String = postTextView.text {
            postText = text
        }else{
            postText = ""
        }
        
        if isSwitched.isOn {
            let imageData = UIImageJPEGRepresentation(postImageView.image!, 0.8)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let imagePath = "postImage\(UUID().uuidString)/postPic.jpg"
            
            let imageRef = storageRef.reference().child(imagePath)
            
            imageRef.put(imageData!, metadata: metaData, completion: { (newMetaData, error) in
                if error == nil {
                    
                    let newPost = Post(username: self.currentUser.username, postId: UUID().uuidString, postText: postText, isSwitched: true, postImageURL: String(describing: newMetaData!.downloadURL()!), userImageURL: self.currentUser.photoURL, account: self.currentUser.account)
                    
                    let postRef = self.databaseRef.child("Posts").childByAutoId()
                    postRef.setValue(newPost.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    
                    
                }else {
                    print(error!.localizedDescription)
                }
            })
            
        } else {
            let newPost = Post(username: self.currentUser.username, postId: UUID().uuidString, postText: postText, isSwitched: false, postImageURL: "", userImageURL: self.currentUser.photoURL, account: self.currentUser.account)
            
            let postRef = self.databaseRef.child("Posts").childByAutoId()
            postRef.setValue(newPost.toAnyObject(), withCompletionBlock: { (error, ref) in
                if error == nil {
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar:Int = 140 - newLength
        
        numberOfCharLabel.text = "\(remainingChar)"
        if remainingChar == -1 {
            numberOfCharLabel.text = "0"
            numberOfCharLabel.textColor = UIColor.red
        }else{
            numberOfCharLabel.textColor = UIColor.black
            numberOfCharLabel.text = "\(remainingChar)"
            
        }
        
        return (newLength > 140) ? false : true
    }
}
