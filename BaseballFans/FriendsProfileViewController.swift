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
    
    var chatFunctions = ChatFunctions()
    
    var user: User!
    
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
        if user.biography == ""{
            self.biography.text = "This person is so lazy and wrote nothing here..."
        }else{
            self.biography.text = user.biography
        }
        
        FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                
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

}
