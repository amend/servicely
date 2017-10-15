//
//  ServiceOffer.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/15/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class ServiceOffer {

    private var _serviceType:String = ""
    private var _serviceDescription:String = ""
    private var _askingPrice:String = ""
    private var _location:String = ""
    private var _companyName:String = ""
    private var _contactInfo:String = ""
    
    var serviceType:String {
        get { return _serviceType}
        set(v) {_serviceType = v}
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
    
    init(serviceType:String, serviceDescription:String, askingPrice:String, location:String, companyName:String, contactInfo:String) {
        self.serviceType = serviceType
        self.serviceDescription = serviceDescription
        self.askingPrice = askingPrice
        self.location = location
        self.companyName = companyName
        self.contactInfo = contactInfo
    }
}
