//
//  FollowersTableViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/18.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class FollowersTableViewController: UITableViewController {
    
    var user:User!
    var flag:String!
    var usersArray = [User]()
    var usersUidArray = [String]()
    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
       loadUsers()

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUsers(){
        var followRef = dataBaseRef.child("users").child(self.user.uid).child("Followings")
        
        if self.flag == "followers"{
          followRef = dataBaseRef.child("users").child(self.user.uid).child("Followers")
        }
        
        followRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for user in snapshot.children {
                
                let newUser = User(snapshot: user as! FIRDataSnapshot)

                    self.usersUidArray.append(newUser.uid)
            
                
            }
            
            for userUid in self.usersUidArray{
                
                let currentUserRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: userUid)
                print("hehehe3",currentUserRef)
                currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    for user in snapshot.children {
                        let newUser = User(snapshot: user as! FIRDataSnapshot)
                        self.usersArray.append(newUser)
                    }
                                self.tableView.reloadData()
                })
            }
//            self.usersArray = allusers.sorted(by: { (user1, user2) -> Bool in
//                user1.username < user2.username
//                
//            })
        }) { (error) in

        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentUser = usersArray[indexPath.row]
        if currentUser.uid != FIRAuth.auth()!.currentUser!.uid{
            performSegue(withIdentifier: "goToHomePage1", sender: currentUser)
        }else{
            performSegue(withIdentifier: "goToMyPage", sender: currentUser)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! UsersTableViewCell
        
        self.configureCell(cell, indexPath: indexPath, usersArray: self.usersArray)
        
        return cell
    }
    
    
    fileprivate func configureCell(_ cell: UsersTableViewCell, indexPath: IndexPath, usersArray: [User]){
        
        cell.usernameLabel.text = usersArray[indexPath.row].username
        cell.userTeamNameLabel.text = usersArray[indexPath.row].teamName
        storageRef.reference(forURL: usersArray[indexPath.row].photoURL).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            if let error = error {
                print(error)
            }else {
                DispatchQueue.main.async(execute: {
                    if let data = imgData {
                        cell.userImageView.image = UIImage(data: data)
                    }
                })
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToHomePage1" {
            
            let friendsVC = segue.destination as! FriendsProfileViewController
            
            friendsVC.user = sender as! User! 
            
        }
    }

}
