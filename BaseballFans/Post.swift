//
//  Post.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/19.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import Foundation
import Foundation
import FirebaseDatabase

struct Post {
    
    var ref: FIRDatabaseReference!
    var key: String!
    var username: String!
    var account: String!
    var postId: String!
    var postText: String!
    var postImageURL: String!
    var userImageURL: String!
    var isSwitched: Bool
    
    
    init(username: String, postId: String, postText: String, isSwitched: Bool, postImageURL: String, userImageURL: String, account: String, key: String = ""){
        
        self.username = username
        self.account = account
        self.postId = postId
        self.postImageURL = postImageURL
        self.postText = postText
        self.userImageURL = userImageURL
        self.isSwitched = isSwitched
        
    }
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String,AnyObject>
        
        
        self.account = values["account"] as! String
        self.userImageURL = values["userImageURL"] as! String
        self.postText = values["postText"] as! String
        self.postImageURL = values["postImageURL"] as! String
        self.username = values["username"] as! String
        self.postId = values["postId"] as! String
        self.isSwitched = values["isSwitched"] as! Bool
        self.ref = snapshot.ref
        self.key = snapshot.key
        
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["account":account as AnyObject, "username":username as AnyObject, "postText":postText as AnyObject,"postId":postId as AnyObject,"userImageURL":userImageURL as AnyObject,"postImageURL":postImageURL as AnyObject, "isSwitched":isSwitched as AnyObject]
    }
    
    
}
