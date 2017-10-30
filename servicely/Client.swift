//
//  Client.swift
//  servicely
//
//  Created by Brenda Salazar on 10/27/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation

class Client {
    var _firstName:String = ""
    var _lastName:String = ""
    var _location:String = ""
    var _aboutMe:String = ""
    
    var firstName:String {
        get { return _firstName }
        set(v) { _firstName = v}
    }
    
    var lastName:String {
        get { return _lastName }
        set(v) { _lastName = v }
    }
    
    var location:String {
        get { return _location }
        set(v) { _location = v }
    }
    
    var aboutMe:String {
        get { return _aboutMe }
        set(v) {_aboutMe = v}
    }
    
    init(firstName:String, lastName:String, location:String, aboutMe:String) {
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.aboutMe = aboutMe
    }
}
