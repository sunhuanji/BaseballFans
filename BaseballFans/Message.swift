//
//  Message.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    
    var text: String!
    var senderId: String!
    var username: String!
    var mediaType: String!
    var mediaUrl: String!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    
    init(snapshot: FIRDataSnapshot){
        
        let values = snapshot.value as! Dictionary<String,AnyObject>
        
        self.key = snapshot.key
        self.ref = snapshot.ref
        self.username = values["username"] as! String
        self.text = values["text"] as! String
        self.senderId = values["senderId"] as! String
        self.mediaType = values["mediaType"] as! String
        self.mediaUrl = values["mediaUrl"] as! String
        self.ref = snapshot.ref
        self.key = snapshot.key

    }
    
    
    init(text: String, key: String = "", senderId: String, username: String, mediaType: String, mediaUrl: String){
        
        
        self.text = text
        self.senderId = senderId
        self.username = username
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["text": text as AnyObject,"senderId": senderId as AnyObject, "username": username as AnyObject,"mediaType":mediaType as AnyObject, "mediaUrl":mediaUrl as AnyObject]
    }
    
    
    
}
