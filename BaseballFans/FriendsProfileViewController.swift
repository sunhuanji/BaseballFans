//
//  FriendsViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FriendsProfileViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var followingsNum: UILabel!
    @IBOutlet weak var followersNum: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var followFlage:Bool!
    
    var chatFunctions = ChatFunctions()
    
    var user: User!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    
    
    @IBAction func followButtonPressed(_ sender: Any) {
        
        print("press",self.followFlage)
        if self.followFlage == false{
            let currentUser1 = FIRAuth.auth()!.currentUser!
            databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue:currentUser1.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                for user in snapshot.children {
                    var currentUser = User(snapshot: user as! FIRDataSnapshot)
                    
                    let followingRef = self.databaseRef.child("users").child(currentUser.uid).child("Followings").child(self.user.uid)
                    
                    let followerRef = self.databaseRef.child("users").child(self.user.uid).child("Followers").child(currentUser.uid)
                    
                    let currentUserRef = self.databaseRef.child("users").child(currentUser.uid)
                    let currentFriendRef = self.databaseRef.child("users").child(self.user.uid)
                    

                    
                    currentUser.followingsNum = currentUser.followingsNum! + 1
                    let followingsNum = ["followingsNum": currentUser.followingsNum!]
                    
                    self.user.followersNum = self.user.followersNum! + 1
                    let followersNum = ["followersNum": self.user.followersNum]

                     currentUserRef.updateChildValues(followingsNum)
                     currentFriendRef.updateChildValues(followersNum)
                    
                    followingRef.setValue(self.user.toAnyObject())
                    
                    followerRef.setValue(currentUser.toAnyObject())
                    
                }
                
            }) { (error) in
            }
            self.followButton.setImage(UIImage(named: "Following"), for: UIControlState.normal)
            self.followLabel.text = "Following"
            self.followFlage = true
            
        }else{
            let currentUser1 = FIRAuth.auth()!.currentUser!
            databaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue:currentUser1.uid).observeSingleEvent(of:.value, with: { (snapshot) in
                for user in snapshot.children {
                    var currentUser = User(snapshot: user as! FIRDataSnapshot)
                    
                    let followingRef = self.databaseRef.child("users").child(currentUser.uid).child("Followings").child(self.user.uid)
                    
                    let followerRef = self.databaseRef.child("users").child(self.user.uid).child("Followers").child(currentUser.uid)
                    
                    let currentUserRef = self.databaseRef.child("users").child(currentUser.uid)
                    let currentFriendRef = self.databaseRef.child("users").child(self.user.uid)
                    

                    
                    currentUser.followingsNum = currentUser.followingsNum! - 1
                    let followingsNum = ["followingsNum": currentUser.followingsNum!]
                    self.user.followersNum = self.user.followersNum! - 1
                    let followersNum = ["followersNum": self.user.followersNum]
                    
                    currentUserRef.updateChildValues(followingsNum)
                    currentFriendRef.updateChildValues(followersNum)
                    
                    followingRef.removeValue()
                    followerRef.removeValue()
                }
                
            }) { (error) in
            }
            self.followButton.setImage(UIImage(named: "Follow"), for: UIControlState.normal)
            self.followLabel.text = "Follow"
            self.followFlage = false
        }
        
//        if self.followFlage == false{
//            
//            let currentUser = FIRAuth.auth()!.currentUser!
//            
//            let followingRef = self.databaseRef.child("users").child(currentUser.uid).child("Followings").child(self.user.uid)
//            
//           // let followerRef = self.databaseRef.child("users").child(self.user.uid).child("Followers").child(currentUser.uid)
//            
//            followingRef.setValue(self.user.toAnyObject())
//            
//           // followerRef.setValue(currentUser.toAnyObject())
//
//            self.followFlage = true
//            print("end of press", self.followFlage)
//            
//        }else{
//            
//            
//            let currentUser = FIRAuth.auth()!.currentUser!
//            
//            let followingRef = self.databaseRef.child("users").child(currentUser.uid).child("Followings").child(self.user.uid)
//            
//           // let followerRef = self.databaseRef.child("users").child(self.user.uid).child("Followers").child(currentUser.uid)
//            
//            followingRef.removeValue()
//           // followerRef.removeValue()
//            
//            self.followFlage = false
//        }

        
      
    }
    @IBAction func goToChat(_ sender: Any) {
        
            let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
            chatFunctions.startChat(currentUser, user2: self.user)
            
           // performSegue(withIdentifier: "goToChat", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = user.username
        
        self.userImage.layer.cornerRadius = userImage.layer.frame.width/2
        self.username.text = user.username
        self.teamName.text = user.teamName
        self.account.text = "@"+user.account
        self.gender.text = user.gender
        self.age.text = user.age
        self.followingsNum.text = "\(user.followingsNum!)"
        self.followersNum.text = "\(user.followersNum!)"
        
        setFollowState()
        
        if user.biography == ""{
            self.biography.text = "This person is so lazy and wrote nothing here..."
        }else{
            self.biography.text = user.biography
        }
        
        FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if let error = error {
                print(error)
//                let alertView = SCLAlertView()
//                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                
            }else{
                
                DispatchQueue.main.async(execute: {
                    if let data = imgData {
                        self.userImage.image = UIImage(data: data)
                    }
                })
            }
            
        })
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
    func setFollowState(){  //set follow state of follow button and follow label
        
        let currentUser1 = FIRAuth.auth()!.currentUser!
        
        let currentUserRef = FIRDatabase.database().reference().child("users").child(self.user.uid!).child("Followers").queryOrdered(byChild: "uid").queryEqual(toValue: currentUser1.uid)
        //print("hahahaha",currentUserRef)
        
        self.followFlage = false
        self.followButton.setImage(UIImage(named: "Follow"), for: UIControlState.normal)
        self.followLabel.text = "Follow"
        
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for user in snapshot.children {
                //print("user",user)
                //let currentUser = User(snapshot: user as! FIRDataSnapshot)
                self.followFlage = true
                self.followButton.setImage(UIImage(named: "Following"), for: UIControlState.normal)
                self.followLabel.text = "Following"
                print("in", self.followFlage)
                
            }
        })

    }

}
