//
//  ConversationsTableViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ConversationsTableViewController: UITableViewController {

    var chatFunctions = ChatFunctions()

    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    var chatsArray = [ChatRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChats()
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationsTableViewController.fetchChats), name: NSNotification.Name(rawValue: "updateDiscussions"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetchChats()
    }
    

    func fetchChats(){
        chatsArray.removeAll(keepingCapacity: false)
        dataBaseRef.child("ChatRooms").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String,AnyObject>
            
            let key = snapshot.key
            let ref = snapshot.ref
            let username = values["username"] as! String
            let other_Username = values["other_Username"] as! String
            let userId = values["userId"] as! String
            let other_UserId = values["other_UserId"] as! String
            let members = values["members"] as! [String]
            let chatRoomId = values["chatRoomId"] as! String
            let lastMessage = values["lastMessage"] as! String
            let userPhotoUrl = values["userPhotoUrl"] as! String
            let other_UserPhotoUrl = values["other_UserPhotoUrl"] as! String
            let date = values["date"] as! NSNumber

            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl:other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
            
            
            
            }) { (error) in
//                let alertView = SCLAlertView()
//                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                

        }
        
        
        dataBaseRef.child("ChatRooms").queryOrdered(byChild: "other_UserId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String,AnyObject>
            
            let key = snapshot.key
            let ref = snapshot.ref
            let username = values["username"] as! String
            let other_Username = values["other_Username"] as! String
            let userId = values["userId"] as! String
            let other_UserId = values["other_UserId"] as! String
            let members = values["members"] as! [String]
            let chatRoomId = values["chatRoomId"] as! String
            let lastMessage = values["lastMessage"] as! String
            let userPhotoUrl = values["userPhotoUrl"] as! String
            let other_UserPhotoUrl = values["other_UserPhotoUrl"] as! String
            let date = values["date"] as! NSNumber

            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
            
            
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
            
            
        }


    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationsCell", for: indexPath) as! ConversationsTableViewCell
        
        var userPhotoUrlString: String? = ""
        
        if chatsArray[indexPath.row].userId == FIRAuth.auth()!.currentUser!.uid {
            userPhotoUrlString = chatsArray[indexPath.row].other_UserPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].other_Username
        }else {
            userPhotoUrlString = chatsArray[indexPath.row].userPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].username
        }
        
        let fromDate = Date(timeIntervalSince1970: TimeInterval(chatsArray[indexPath.row].date))
        let toDate = Date()
        
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth,]
        let differenceOfDate = (Calendar.current as NSCalendar).components(components, from: fromDate, to: toDate, options: [])
        
        if differenceOfDate.second! <= 0 {
            cell.dateLabel.text = "now"
        } else if differenceOfDate.second! > 0 && differenceOfDate.minute! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.second!)s."

        }else if differenceOfDate.minute! > 0 && differenceOfDate.hour! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.minute!)m."
            
        }else if differenceOfDate.hour! > 0 && differenceOfDate.day! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.hour!)h."
            
        }else if differenceOfDate.day! > 0 && differenceOfDate.weekOfMonth! == 0 {
            cell.dateLabel.text = "\(differenceOfDate.day!)d."
            
        }else if differenceOfDate.weekOfMonth! > 0 {
            cell.dateLabel.text = "\(differenceOfDate.weekOfMonth!)w."
        }
        
        
        
        
        
        cell.lastMessageLabel.text = chatsArray[indexPath.row].lastMessage
        if let urlString = userPhotoUrlString {
            storageRef.reference(forURL: urlString).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if let error = error {
                    print(error)
//                    let alertView = SCLAlertView()
//                    _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                }else {
                    
                    DispatchQueue.main.async(execute: { 
                        if let data = imgData {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                    
                }
            })
            
            
        }
        

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        var otherUser: User!
        if currentUser.uid == chatsArray[indexPath.row].userId{
             otherUser = User(username: chatsArray[indexPath.row].other_Username, userId: chatsArray[indexPath.row].other_UserId, photoUrl: chatsArray[indexPath.row].other_UserPhotoUrl)
        }else {
            otherUser = User(username: chatsArray[indexPath.row].username, userId: chatsArray[indexPath.row].userId, photoUrl: chatsArray[indexPath.row].userPhotoUrl)
        }
        
        chatFunctions.startChat(currentUser, user2: otherUser)

        performSegue(withIdentifier: "goToChat1", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.chatsArray[indexPath.row].ref?.removeValue()
            self.chatsArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat1" {
            
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
}
