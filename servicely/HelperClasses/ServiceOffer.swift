//
//  ServiceOffer.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/15/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class ServiceOffer {

    private var _category:String = ""
    private var _serviceDescription:String = ""
    private var _askingPrice:String = ""
    private var _location:String = ""
    private var _companyName:String = ""
    private var _contactInfo:String = ""
    private var _userID:String = ""
    private var _timestamp:Double = 0
    
    var category:String {
        get { return _category}
        set(v) {_category = v}
    }
    
    var serviceDescription:String {
        get {return _serviceDescription}
        set(v) { _serviceDescription = v}
    }
    
    var askingPrice:String {
        get {return _askingPrice}
        set(v) { _askingPrice = v}
    }
    
    var location:String {
        get {return _location}
        set(v) { _location = v}
    }
    
    var companyName:String {
        get {return _companyName}
        set(v) { _companyName = v}
    }
    
    var contactInfo:String {
        get { return _contactInfo}
        set(v) { _contactInfo = v}
    }
    
    var userID:String {
        get { return _userID }
        set(v) { _userID = v }
    }
    
    var timestamp:Double {
        get { return _timestamp }
        set(v) { _timestamp = v }
    }
    
    init(category:String, serviceDescription:String, askingPrice:String, location:String, companyName:String, contactInfo:String, userID:String, timestamp:Double) {
        self.category = category
        self.serviceDescription = serviceDescription
        self.askingPrice = askingPrice
        self.location = location
        self.companyName = companyName
        self.contactInfo = contactInfo
        self.userID = userID
        self.timestamp = timestamp
    }
}
