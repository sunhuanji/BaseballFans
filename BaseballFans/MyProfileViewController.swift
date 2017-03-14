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

class MyProfileViewController: UIViewController {

    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var biography: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var user: User!
    
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
                
                self.username.text = user.username
                self.account.text = "@"+user.account
                self.country.text = user.teamName
                
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

}
