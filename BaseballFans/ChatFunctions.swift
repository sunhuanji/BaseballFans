//
//  ChatFunctions.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct ChatFunctions{
    
    var chatRoom_id =  String()
    
    fileprivate var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    mutating func startChat(_ user1: User, user2: User){
        
        let userId1 = user1.uid
        let userId2 = user2.uid
        
        var chatRoomId = ""
        
        let comparison = userId1?.compare(userId2!).rawValue
        
        let members = [user1.username!, user2.username!]
        
        if comparison! < 0 {
            chatRoomId = userId1! + userId2!
        } else {
            chatRoomId = userId2! + userId1!
        }
        
        self.chatRoom_id = chatRoomId
        self.createChatRoomId(user1, user2: user2, members:members, chatRoomId: chatRoomId)

    }
    
    fileprivate func createChatRoomId(_ user1: User, user2: User, members:[String], chatRoomId: String){
        
        let chatRoomRef = databaseRef.child("ChatRooms").queryOrdered(byChild: "chatRoomId").queryEqual(toValue: chatRoomId)
        chatRoomRef.observe(.value, with: { (snapshot) in
            
            var createChatRoom = true
            
            if snapshot.exists() {
                
                if let values = snapshot.value as? [String:AnyObject] {
                    
                    for chatRoom in values {
                        if chatRoom.value["chatRoomId"] as! String == chatRoomId{ //firebase里面的存的chatroomId与开始聊天创建的chatroomId相同
                            createChatRoom = false
                        }
                    }
                }
            }
            
            if createChatRoom {
                
                self.createNewChatRoomId(user1.username, other_Username: user2.username, userId: user1.uid, other_UserId: user2.uid, members: members, chatRoomId: chatRoomId, lastMessage: "", userPhotoUrl: user1.photoURL, other_UserPhotoUrl: user2.photoURL,date:NSNumber(value:NSDate().timeIntervalSince1970))//创建新的聊天室，存聊天室数据到firebase

            }
            
            
            
            }) { (error) in
                
                DispatchQueue.main.async(execute: {
                    let alertView =  SCLAlertView()
                    _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
                })        }
        
        
    }
    
    
    fileprivate func createNewChatRoomId(_ username: String, other_Username: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,lastMessage: String,userPhotoUrl: String,other_UserPhotoUrl: String, date: NSNumber){
        
        let newChatRoom = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl,date:date)
        
        let chatRoomRef = databaseRef.child("ChatRooms").child(chatRoomId)
        chatRoomRef.setValue(newChatRoom.toAnyObject())
        
    }
    
    
    
    
}
