//
//  PostsViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/19.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class PostsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var tableView: UITableView!
    var postsArray = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "Twitter_Logo"))
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 307
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchPosts()
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
