//
//  ChatViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MobileCoreServices
import AVKit


class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chatRoomId: String!
    
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!

    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var userIsTypingRef: FIRDatabaseReference!
    
    fileprivate var localTyping: Bool = false
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        observeTypingUser()
        
            self.title = "MESSAGES"
        let factory = JSQMessagesBubbleImageFactory()
        
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        fetchMessages()
        
    }


    
    func fetchMessages(){
        
        let messageQuery = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").queryLimited(toLast: 30)
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            let values = snapshot.value as! Dictionary<String,AnyObject>
            
            let senderId = values["senderId"] as! String
            let text = values["text"] as! String
            let displayName = values["username"] as! String
            let mediaType = values["mediaType"] as! String
            let mediaUrl = values["mediaUrl"] as! String
   
            switch mediaType {
            case "TEXT":
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))

            case "PHOTO":
                
                let picture = UIImage(data: try! Data(contentsOf: URL(string: mediaUrl)!))
                let photo = JSQPhotoMediaItem(image: picture)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))

            case "VIDEO":
                
                if let url = URL(string: mediaUrl) {
                let video = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))

                    }
                
            default: break
            }
            
            self.finishReceivingMessage()
            
        }) { (error) in
//            let alertView = SCLAlertView()
//            _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
        }
        

    }
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    fileprivate func observeTypingUser(){
        let typingRef = databaseRef.child("ChatRooms").child(chatRoomId).child("typingIndicator")
        userIsTypingRef = typingRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        let userIsTypingQuery = typingRef.queryOrderedByValue().queryEqual(toValue: true)
        
        userIsTypingQuery.observe(.value, with: { (snapshot) in
            
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
            
            
            
            }) { (error) in
//                let alertView = SCLAlertView()
//                _ = alertView.showError("ERROR", subTitle: error.localizedDescription)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageRef = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
        let message = Message(text: text, senderId: senderId, username: senderDisplayName, mediaType: "TEXT", mediaUrl: "")
        
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
                
                let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                lastMessageRef.setValue(text, withCompletionBlock: { (error, ref) in
                    if error == nil {
                      
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDiscussions"), object: nil)
                 
                    }else {
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)

                    }
                    
                    
                })
                let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                lastTimeRef.setValue(Date().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                    if error == nil {
                                                
                    }else {
//                        let alertView = SCLAlertView()
//                        _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
                        
                    }
                })
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
            }else {
//                let alertView = SCLAlertView()
//                _ = alertView.showError("ERROR", subTitle: error!.localizedDescription)
            }
        }
    }

    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if !message.isMediaMessage {
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
        }else {
            cell.textView.textColor = UIColor.black
        }
        }
        
        
        return cell
    }
  
}
