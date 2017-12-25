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
    private var _contactInfo:String = ""
    private var _userID:String = ""
    private var _userName:String = ""
    private var _category:String = ""
    
    var serviceDescription:String {
        get {return _serviceDescription}
        set(v) { _serviceDescription = v}
    }
    
    var location:String {
        get {return _location}
        set(v) { _location = v}
    }
    
    var contactInfo:String {
        get { return _contactInfo}
        set(v) { _contactInfo = v}
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
    
    
    init(serviceDescription:String, location:String, contactInfo:String, userID:String, userName:String, category:String) {
        self.serviceDescription = serviceDescription
        self.location = location
        self.contactInfo = contactInfo
        self.userID = userID
        self.userName = userName
        self.category = category
    }
}
