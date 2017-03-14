//
//  UsersViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UsersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            loadUsers(teamName: currentUser.teamName!, teamType: true)
        case 1:
            loadUsers(teamName: currentUser.teamName!, teamType: false)
        default:
            break
        }
    }
    @IBOutlet weak var tableView: UITableView!
    var usersArray = [User]()
    var chatFunctions = ChatFunctions()
    var currentUser:User!
    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let currentUser1 = FIRAuth.auth()!.currentUser!
        dataBaseRef.child("users").queryOrdered(byChild: "uid").queryEqual(toValue:currentUser1.uid).observe(.value, with: { (snapshot) in
            for user in snapshot.children {
                self.currentUser = User(snapshot: user as! FIRDataSnapshot)
                self.loadUsers(teamName: self.currentUser.teamName!, teamType:true)
            }
            
        }) { (error) in
            let alertView = SCLAlertView()
            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    func loadUsers(teamName:String, teamType:Bool){
        
        if teamType == true{
            dataBaseRef.child("users").queryOrdered(byChild: "teamName").queryEqual(toValue:teamName).observe(.value, with: { (snapshot) in
                
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
        }else{
            
            let usersRef = dataBaseRef.child("users")
            
            usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                var allusers = [User]()
                
                for user in snapshot.children {
                    
                    let newUser = User(snapshot: user as! FIRDataSnapshot)
                    if newUser.teamName != teamName{
                        if newUser.uid != FIRAuth.auth()!.currentUser!.uid{
                            
                            allusers.append(newUser)
                        }
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userscell", for: indexPath) as! UsersTableViewCell
        
        self.configureCell(cell, indexPath: indexPath, usersArray: self.usersArray)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let currentUser = usersArray[indexPath.row]
    
            performSegue(withIdentifier: "goToHomePage", sender: currentUser)
    
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
                        //cell.userImageView.layer.cornerRadius = cell.userImageView.frame.width/2
                    }
                })
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHomePage" {
            
            let friendsVC = segue.destination as! FriendsProfileViewController
            
            friendsVC.user = sender as! User

        }
    }

}
