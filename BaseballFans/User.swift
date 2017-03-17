//
//  User.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//
import Foundation
import Firebase
import FirebaseDatabase

struct User {
    
    var username: String!
    var email: String?
    var teamName: String?
    var photoURL: String!
    var account:String!
    var biography: String?
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var followingsNum:Int?
    var followersNum:Int?
    var gender:String?
    var age:String?
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String,AnyObject>
        
        key = snapshot.key
        ref = snapshot.ref
        username = values["username"] as! String
        email = values["email"] as? String
        teamName = values["teamName"] as? String
        account = values["account"] as! String
        biography = values["biography"] as? String
        photoURL = values["photoURL"] as! String
        uid = values["uid"] as? String
        followingsNum = values["followingsNum"] as? Int
        followersNum = values["followersNum"] as? Int
        gender = values["gender"] as? String
        age = values["age"] as? String

    }
    
    init(username: String, userId: String, photoUrl: String){
        self.username = username
        self.uid = userId
        self.photoURL = photoUrl
    }
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["username": username as AnyObject,"email": email as AnyObject, "teamName": teamName as AnyObject,"account":account as AnyObject, "biography":biography as AnyObject,"photoURL":photoURL as AnyObject,"uid":uid as AnyObject,"followingsNum":followingsNum as AnyObject,"followersNum":followersNum as AnyObject,"gender":gender as AnyObject,"age":age as AnyObject]
    }
    
}
