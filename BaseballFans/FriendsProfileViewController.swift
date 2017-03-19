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

class FriendsProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingNumBtn: UIButton!
    @IBOutlet weak var followerNumBtn: UIButton!
    
    var followFlage:Bool!
    
    var chatFunctions = ChatFunctions()
    
    var user: User!
    
    var postsArray = [Post]()
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
                    self.followerNumBtn.setTitle("\(self.user.followersNum!)", for: .normal)
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
                    self.followerNumBtn.setTitle("\(self.user.followersNum!)", for: .normal)
                    
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

        
      
    }
    @IBAction func goToChat(_ sender: Any) {
        
            let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
            chatFunctions.startChat(currentUser, user2: self.user)
            
           // performSegue(withIdentifier: "goToChat", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 307
        loadUser()
        fetchPosts()
    }

    
    func loadUser(){
        
        self.title = user.username
        
        self.userImage.layer.cornerRadius = userImage.layer.frame.width/2
        self.username.text = user.username
        self.teamName.text = user.teamName
        self.account.text = "@"+user.account
        self.gender.text = user.gender
        self.age.text = user.age
        self.followingNumBtn.setTitle("\(user.followingsNum!)", for: .normal)
        self.followingNumBtn.setTitleColor(UIColor.black, for: .normal)
        self.followerNumBtn.setTitle("\(user.followersNum!)", for: .normal)
        self.followerNumBtn.setTitleColor(UIColor.black, for: .normal)
        
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
       else if segue.identifier == "goToFollowing"{
            let followingsVC = segue.destination as! FollowersTableViewController
           followingsVC.user = self.user
           followingsVC.flag = "followings"
        }else if segue.identifier == "goToFollower"{
            let followingsVC = segue.destination as! FollowersTableViewController
            followingsVC.user = self.user
            followingsVC.flag = "followers"
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
            for _ in snapshot.children {
                //print("user",user)
                //let currentUser = User(snapshot: user as! FIRDataSnapshot)
                self.followFlage = true
                self.followButton.setImage(UIImage(named: "Following"), for: UIControlState.normal)
                self.followLabel.text = "Following"
                print("in", self.followFlage)
                
            }
        })

    }
    
    fileprivate func fetchPosts(){
        
        databaseRef.child("Posts").observe(.value, with: { (posts) in
            
            var newPostsArray = [Post]()
            for post in posts.children {
                
                let newPost = Post(snapshot: post as! FIRDataSnapshot)
                newPostsArray.insert(newPost, at: 0)
            }
            
            self.postsArray = newPostsArray
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if postsArray[indexPath.row].isSwitched == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postWithImage", for: indexPath) as! ImagePostTableViewCell
            cell.account.text = "@" + postsArray[indexPath.row].account
            cell.username.text =  postsArray[indexPath.row].username
            cell.post.text = postsArray[indexPath.row].postText
            
            storageRef.reference(forURL: postsArray[indexPath.row].userImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.userImage.image = UIImage(data: data)
                        }
                    })
                    
                    
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            storageRef.reference(forURL: postsArray[indexPath.row].postImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                print("hehehe1",self.postsArray[indexPath.row].postImageURL)
                if error == nil {
                    
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.postImage.image = UIImage(data: data)
                        }
                    })
                    
                    
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postWithText", for: indexPath) as! PostsTableViewCell
            
            cell.account.text = "@" + postsArray[indexPath.row].account
            cell.username.text =  postsArray[indexPath.row].username
            cell.post.text = postsArray[indexPath.row].postText
            
            storageRef.reference(forURL: postsArray[indexPath.row].userImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.userImage.image = UIImage(data: data)
                        }
                    })
                    
                    
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            return cell
            
        }
    }

}
