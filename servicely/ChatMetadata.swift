//
//  ListChat.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class ChatMetadata {
    
    private var _providerID:String = ""
    private var _clientID:String = ""
    private var _providerName:String = ""
    private var _clientName:String = ""
    private var _timestamp:String = "" // string cuz not sure what format it will be
    private var _serviceType:String = ""
    private var _category:String = ""
    
    var providerID:String {
        get { return _providerID}
        set(v) { _providerID = v}
    }
    var clientID:String {
        get { return _clientID}
        set(v) { _clientID = v}
    }
    var providerName:String {
        get { return _providerName}
        set(v) { _providerName = v}
    }
    var clientName:String {
        get { return _clientName}
        set(v) { _clientName = v}
    }
    var timestamp:String {
        get { return _timestamp}
        set(v) { _timestamp = v}
    }
    var serviceType:String {
        get { return _serviceType}
        set(v) { _serviceType = v}
    }
    var category:String {
        get { return _category}
        set(v) { _category = v}
    }
    
    init(providerID:String, clientID:String, providerName:String, clientName:String, timestamp:String, serviceType:String, category:String) {
        self.providerID = providerID
        self.clientID = clientID
        self.providerName = providerName
        self.clientName = clientName
        self.timestamp = timestamp
        self.serviceType = serviceType
        self.category = category
    }
}

