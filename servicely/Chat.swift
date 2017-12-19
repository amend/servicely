//
//  ListChat.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class Chat {
    
    private var _chatID:String = ""
    private var _owners:[String:String]? = ["client": "", "serviceProvider": ""]
    private var _messages:[[String:String]]? = nil
    
    var chatID:String {
        get { return _chatID}
        set(v) { _chatID = v}
    }
    var owners:[String:String]? {
        get { return _owners}
        set(v) {
            _owners!["client"] = v!["client"]
            _owners!["serviceProvider"] = v!["serviceProvider"]
        }
    }
    var messages:[[String:String]]? {
        get { return _messages}
        set(v) {
            var mArray:[[String:String]]? = nil
            for message in messages! {
                var m:[String:String] = [String:String]()
                
                m["senderID"] = message["senderID"]
                m["senderName"] = message["senderName"]
                m["text"] = message["text"]
                
                mArray!.append(m)
            }
        }
    }
    
    init(chatID:String, clientOwner:String, providerOwner:String, messages:[[String:String]]?) {
        self.chatID = chatID
        
        var owners:[String:String]? = nil
        owners!["client"] = clientOwner
        owners!["serviceProvider"] = providerOwner
        self.owners = owners
        
        for message in messages! {
            self.messages!.append(message)
        }
    }
    
    func addMessage(message: [String:String]) {
        self.messages!.append(message)
    }
}

