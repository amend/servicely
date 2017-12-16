//
//  Database.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/16/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


class Database {
    
    private var ref:FIRDatabaseReference!

    init() {
        ref = FIRDatabase.database().reference()
    }
    
    func getCurrentUser(userID:String?, completion: @escaping (_ user:NSDictionary?)->() ) {
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            completion(user)
        })
    }
    
    // kinda shitty cuz getting dicts from snapshot will be done outside of this function
    // TODO: do the convertion here
    func getServicesOffered(completion: @escaping (_ snapshot: FIRDataSnapshot)->()) {
        ref.child("serviceOffer").observeSingleEvent(of: .value, with: { snapshot in
          completion(snapshot)
        })
    }

    // kinda shitty cuz getting dicts from snapshot will be done outside of this function
    // TODO: do the convertion here
    func getUsers(completion: @escaping (_ snapshot: FIRDataSnapshot)->()) {
        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot)
        })
    }
}

