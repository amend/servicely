//
//  ChatViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import JSQMessagesViewController

// delete these after wrapping the queries here in Database
import Firebase
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var providerID = ""
    var clientID = ""
    var providerName = ""
    var clientName = ""
    var timestamp = ""
    var threadID = ""
    
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    var firstTimeConvo:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this is done through storyboards otherwise, tab bar hidden
        // for all views
        //self.tabBarController?.tabBar.isHidden = true
        
        self.senderId = clientID
        self.senderDisplayName = clientName
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //self.navigationItem.title = "Example Name"
        
        // check if users have chatted before
        let ref:FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("users")
            .child(currentUserID!)
            .child("threads")
            .observeSingleEvent(of: .value, with: { snapshot in
                let threads = snapshot.value as? NSDictionary
                if(threads == nil) {
                    self.firstTimeConvo = true
                    return
                }
                let keys:[String] = threads?.allKeys as! [String]
                var i:Int = 0
                for key in keys {
                    let v = threads?[key] as! NSDictionary
                    let cID = v["clientID"] as! String
                    let pID = v["providerID"] as! String
                    
                    // check if this a first-time chat. if so, then function
                    // didPressSend will create users/uids/threads/threadID/(info)
                    // with the .self vars above and also threads/threadID/(info)
                    if(cID == self.clientID && pID == self.providerID) {
                        break
                    }
                    i += 1
                }
                if(i == keys.count) {
                    self.firstTimeConvo = true
                }
            })

        print("exiting viewdidload")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let ref:FIRDatabaseReference = FIRDatabase.database().reference()
        
        // if first time convo between users, then create /users/userID/threads/threadID/(info)
        if(firstTimeConvo) {
            let newUsersThreadRef = ref.child("users").child(self.currentUserID!).child("threads").childByAutoId()

            self.threadID = newUsersThreadRef.key
            
            newUsersThreadRef.setValue([
                    "providerID": self.providerID,
                    "clientID": self.clientID,
                    "providerName": self.providerName,
                    "clientName": self.clientName,
                    "timestamp": "123456",
                    "threadID": self.threadID
                ])
            
            let detailsRef = ref.child("threads").child(self.threadID).child("details")
            detailsRef.setValue([
                "creationDate": "123456",
                "lastMessageAdded": "123456"
                ])
            
            let messagesRef = ref.child("threads").child(self.threadID).child("messages").childByAutoId()
            messagesRef.setValue([
                "timestamp" : "123456",
                "text": text!,
                "userID": currentUserID
                ])
            
            firstTimeConvo = false
        } else {
            // not first convo between users, so update threads/threadID/messages/autoID/(info)
            let messagesRef = ref.child("threads").child(self.threadID).child("messages").childByAutoId()
            messagesRef.setValue([
                "timestamp": "123456",
                "text": text!,
                "userID": currentUserID
                ])
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
