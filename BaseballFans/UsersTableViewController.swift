//
//  UsersTableViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UsersTableViewController: UITableViewController {

    var usersArray = [User]()
    var chatFunctions = ChatFunctions()
    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadUsers()
    }

    func loadUsers(){
        
        let usersRef = dataBaseRef.child("users")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var allusers = [User]()
            
            for user in snapshot.children {
                
                let newUser = User(snapshot: user as! FIRDataSnapshot)
                
                if newUser.uid != FIRAuth.auth()!.currentUser!.uid{
                
                    allusers.append(newUser)
                }
                
            }
            self.usersArray = allusers.sorted(by: { (user1, user2) -> Bool in
                user1.username < user2.username
            
            })
            self.tableView.reloadData()

            
            
            }) { (error) in
                let alertView = SCLAlertView()
                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                

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
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        chatFunctions.startChat(currentUser, user2: usersArray[indexPath.row])
        
        performSegue(withIdentifier: "goToChat", sender: self)

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell
        
        self.configureCell(cell, indexPath: indexPath, usersArray: self.usersArray)

        return cell
    }
    
    
   fileprivate func configureCell(_ cell: UsersTableViewCell, indexPath: IndexPath, usersArray: [User]){
        
        cell.usernameLabel.text = usersArray[indexPath.row].username
        cell.userTeamNameLabel.text = usersArray[indexPath.row].teamName
        storageRef.reference(forURL: usersArray[indexPath.row].photoURL).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
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
        if segue.identifier == "goToChat" {
            
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
}
