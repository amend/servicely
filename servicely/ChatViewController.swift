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
    var serviceType = ""
    
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
        
        // self.navigationItem.title = "Example Name"

        // get all threads that have user's clientID or providerID
        // in threads/threadID/detail/clientID or providerID
        let ref:FIRDatabaseReference = FIRDatabase.database().reference()
        
        var userType:String = ""
        if(self.serviceType == "client") {
            userType = "clientID"
        } else if(self.serviceType == "serviceProvider") {
            userType = "providerID"
        } else {
            print("Error, user must be client or serviceProvider")
        }
        
        ref.child("threads")
            .queryOrdered(byChild: "details/" + userType)
            .queryEqual(toValue: currentUserID)
            .observeSingleEvent(of: .value, with: { snapshot in
                print(snapshot)
                print(snapshot.childrenCount)
                
                if(snapshot.childrenCount != 0) {
                    self.firstTimeConvo = false
                } else {
                    self.firstTimeConvo = true
                    return
                }
                
                // above query found threads that current user
                // is involved with. this will go through the threads
                // and find the single thread that the recepiant
                // is also involved in
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    if let dict = rest.value as? NSDictionary {
                        print(dict)

                        let detailsDict:NSDictionary = (dict["details"] as? NSDictionary)!
                        if((detailsDict["clientID"] as! String == self.clientID)
                            && (detailsDict["providerID"] as! String == self.providerID)) {
                            self.threadID = rest.key
                            print("threadID: " + self.threadID)
                            print("break point reached")
                            break
                        }

                        // init(serviceType: (dict["serviceType"] as? String)!,
                    } else {
                        print("could not convert snapshot to dictionary")
                    }
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
        
        // if first time convo between users, then
        // create threads/(childByAutoID)/details/(info)
        // and threads/(childByAutoID)/messages/(childByAutoID)/(info)
        if(firstTimeConvo) {
            // this sets:
            // threads/(childByAutoID)/details/(info)
            //let newDetailsRef = ref.child("threads").childByAutoId().child("details")
            
            var newDetailsRef = ref.child("threads").childByAutoId()
            self.threadID = newDetailsRef.key
            print("new threadID:")
            print(self.threadID)
            newDetailsRef = newDetailsRef.child("details")
            
            newDetailsRef.setValue([
                    "providerID": self.providerID,
                    "clientID": self.clientID,
                    "creationDate": "123456",
                    "threadID": self.threadID
                ])
            
            // this sets:
            // threads/self.threadID/messages/(childByAutoID)/(info)
            let messagesRef = ref.child("threads").child(self.threadID).child("messages").childByAutoId()
            messagesRef.setValue([
                "timestamp" : "123456",
                "text": text!,
                "userID": currentUserID
                ])
            
            firstTimeConvo = false
        } else {
            // not first convo between users, so
            // update threads/threadID/messages/childByAutoID/(info)
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
