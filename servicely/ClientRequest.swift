//
//  ServiceOffer.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/15/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//
import Foundation

class ClientRequest {
    
    private var _serviceDescription:String = ""
    private var _location:String = ""
    private var _userID:String = ""
    private var _userName:String = ""
    private var _category:String = ""
    private var _timestamp:Double = 0
    
    var serviceDescription:String {
        get {return _serviceDescription}
        set(v) { _serviceDescription = v}
    }
    
    var location:String {
        get {return _location}
        set(v) { _location = v}
    }
    
    var userID:String {
        get { return _userID }
        set(v) { _userID = v }
    }
    
    var userName:String {
        get { return _userName }
        set(v) {_userName = v}
    }
    
    var category:String {
        get { return _category }
        set(v) {_category = v}
    }
    
    var timestamp:Double {
        get { return _timestamp}
        set(v) {_timestamp = v}
    }
    
    
    init(serviceDescription:String, location:String, userID:String, userName:String, category:String, timestamp:Double) {
        self.serviceDescription = serviceDescription
        self.location = location
        self.userID = userID
        self.userName = userName
        self.category = category
        self.timestamp = timestamp
    }
}
