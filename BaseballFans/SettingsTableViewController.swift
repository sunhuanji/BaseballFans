//
//  SettingsTableViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAccountLabel: UILabel!

    var user: User!
    var chatsArray = [ChatRoom]()
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.layer.cornerRadius = userImageView.layer.frame.width/2    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.usernameLabel.text = user.username
                self.userAccountLabel.text = "@"+user.account

                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        let alertView = SCLAlertView()
                        _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                        
                    }else{
                        
                        DispatchQueue.main.async(execute: {
                            if let data = imgData {
                                self.userImageView.image = UIImage(data: data)
                            }
                        })
                    }
                    
                })
                
                
            }
            
            
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
            
        }
        
    }
    
    func deleteAccount(){
        let alertView1 = SCLAlertView()
        _ = alertView1.addButton("Delete") {
            Void in
            let currentUserRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
            
            currentUserRef.observe(.value, with: { (snapshot) in
                
                for user in snapshot.children {
                let currentUser = User(snapshot: user as! FIRDataSnapshot)
                    
//              FIRDatabase.database().reference().child("ChatRooms").queryOrdered(byChild: "userId").queryEqual(toValue: currentUser.uid).observe(.value, with: { (snapshot) in
//                
//                  print("hehehehehehe!",snapshot.ref)
//                
//                    }) { (error) in
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
//                    }
            
//             FIRDatabase.database().reference().child("ChatRooms").queryOrdered(byChild: "other_UserId").queryEqual(toValue: currentUser.uid).observe(.value, with: { (snapshot) in
//                
//                       snapshot.ref.removeValue()
//                        
//                    }) { (error) in
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
//                    }
          //delete related image in storage.
                    let imagePath = "profileImage\(currentUser.uid!)/userPic.jpg"
                    
                    let imageRef = FIRStorage.storage().reference().child(imagePath)
                    
                    imageRef.delete(completion: { (error) in
                        if error == nil{
                        
                        }else{
//                            let alertView = SCLAlertView()
//                            _ = alertView.showError("ERROR", subTitle: (error?.localizedDescription)!)
                        }
                    })
                    
                    //delete user in database
                currentUser.ref?.removeValue(completionBlock: { (error, ref) in
                    if error == nil {
                        
                        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                            if error == nil {
                                
                                print("account successfully deleted!")
                                DispatchQueue.main.async(execute: {
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                                    self.present(vc, animated: true, completion: nil)
                                    
                                })
                                
                            }else {
//                                let alertView = SCLAlertView()
//                                _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                                
                            }
                        })
                        
                    }else {
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                        
                    }
                })
                
                
            }}) { (error) in
//                let alertView = SCLAlertView()
//                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                
            }
            

        }
        _ = alertView1.showWarning("WARNING", subTitle: "Are you sure that you want to delete your Account?")
    
    }
    
    func resetPassword(){
        let email = FIRAuth.auth()!.currentUser!.email!
         AuthenticationService().resetPassword(email)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0  {
            deleteAccount()
        }else if indexPath.section == 1 && indexPath.row == 1 {
            resetPassword()
        }
    }
    
    

}
