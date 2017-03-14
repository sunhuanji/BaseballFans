//
//  ChatRoom.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct ChatRoom {
    
    var username: String!
    var other_Username: String!
    var userId: String!
    var other_UserId: String!
    var members: [String]!
    var chatRoomId: String!
    var key: String = ""
    var lastMessage: String!
    var ref: FIRDatabaseReference!
    var userPhotoUrl: String!
    var other_UserPhotoUrl: String!
    var date: NSNumber!
    
    init(snapshot: FIRDataSnapshot){
        let values = snapshot.value as! Dictionary<String,AnyObject>
        
        self.key = snapshot.key
        self.ref = snapshot.ref
        self.username = values["username"] as! String
        self.other_Username = values["other_Username"] as! String
        self.userId = values["userId"] as! String
        self.other_UserId = values["other_UserId"] as! String
        self.members = values["members"] as! [String]
        self.chatRoomId = values["chatRoomId"] as! String
        self.lastMessage = values["lastMessage"] as! String
        self.userPhotoUrl = values["userPhotoUrl"] as! String
        self.other_UserPhotoUrl = values["other_UserPhotoUrl"] as! String
        self.date = values["date"] as! NSNumber
    }
    
    
    init(username: String, other_Username: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,lastMessage: String,key: String = "",userPhotoUrl: String,other_UserPhotoUrl: String, date: NSNumber){
        
        self.username = username
        self.other_UserPhotoUrl = other_UserPhotoUrl
        self.other_Username = other_Username
        self.userId = userId
        self.other_UserId = other_UserId
        self.userPhotoUrl = userPhotoUrl
        self.members = members
        self.lastMessage = lastMessage
        self.chatRoomId = chatRoomId
        self.date = date
    
        
    }

    func toAnyObject() -> [String: AnyObject] {
        
        return ["username": username as AnyObject, "other_Username": other_Username as AnyObject,"userId": userId as AnyObject,"other_UserId": other_UserId as AnyObject,"members": members as AnyObject,"chatRoomId": chatRoomId as AnyObject,"lastMessage": lastMessage as AnyObject,"userPhotoUrl": userPhotoUrl as AnyObject,"other_UserPhotoUrl": other_UserPhotoUrl as AnyObject,"date":date]
        
    }
    
}
