//
//  MyProfileViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var followingNumBtn: UIButton!
    @IBOutlet weak var followerNumBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    
    var postsArray = [Post]()
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 307
        fetchPosts()
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
                
                self.username.text = user.username
                self.account.text = "@"+user.account
                self.country.text = user.teamName
                self.gender.text = user.gender
                self.age.text = user.age
                self.followingNumBtn.setTitle("\(user.followingsNum!)", for: .normal)
                self.followingNumBtn.setTitleColor(UIColor.black, for: .normal)
                self.followerNumBtn.setTitle("\(user.followersNum!)", for: .normal)
                self.followerNumBtn.setTitleColor(UIColor.black, for: .normal)
                
                if user.biography == ""{
                  self.biography.text = "This person is so lazy and wrote nothing here..."
                }else{
                  self.biography.text = user.biography
                }
                
                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        print(error)
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                        
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
    @IBAction func logout(_ sender: UIBarButtonItem){
        
        do {
            
            try FIRAuth.auth()?.signOut()
            
            if FIRAuth.auth()?.currentUser == nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                present(vc, animated: true, completion: nil)
            }
            
        }
        catch let error as NSError {
            print(error)
//            let alertView = SCLAlertView()
//            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
        }
        
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFollowings"{
            let followingsVC = segue.destination as! FollowersTableViewController
            followingsVC.user = self.user
            followingsVC.flag = "followings"
        }else if segue.identifier == "showFollowers"{
            let followingsVC = segue.destination as! FollowersTableViewController
            followingsVC.user = self.user
            followingsVC.flag = "followers"
        }
    }

}
