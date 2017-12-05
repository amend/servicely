//
//  ServiceOffer.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/15/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class ClientRequest {
    
    private var _serviceType:String = ""
    private var _serviceDescription:String = ""
    private var _location:String = ""
    private var _contactInfo:String = ""
    private var _userID:String = ""
    
    var serviceType:String {
        get { return _serviceType}
        set(v) {_serviceType = v}
    }
    
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
    
    init(serviceType:String, serviceDescription:String, location:String, contactInfo:String, userID:String) {
        self.serviceType = serviceType
        self.serviceDescription = serviceDescription
        self.location = location
        self.contactInfo = contactInfo
        self.userID = userID
    }
}
