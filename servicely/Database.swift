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
    
    func getServicesOffered(completion: @escaping (_ servicesArray: [ServiceOffer])->()) {
        ref.child("serviceOffer").observeSingleEvent(of: .value, with: { snapshot in
           print(snapshot.childrenCount)
            
            var services = [ServiceOffer]()
            
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to services array...")
                
                if let dict = rest.value as? NSDictionary {
                    
                    services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                    
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionay")
                }
            }
            
            completion(services)
        })
    }
    
    // kinda shitty cuz getting dicts from snapshot will be done outside of this function
    // there's probably a better way to get ratings for users, so think of one
    // and delete this
    func getUsers(completion: @escaping (_ snapshot: FIRDataSnapshot)->()) {
        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot)
        })
    }
    
    func getCurrentUsersRequests(completion: @escaping (_ usersRequests: [ClientRequest])->()) {
        let userID = FIRAuth.auth()?.currentUser?.uid

        ref.child("clientRequest").queryOrdered(byChild: "userID").queryEqual(toValue: userID!).observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            
            var requests = [ClientRequest]()
            
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to requests array...")
                if let dict = rest.value as? NSDictionary {
                    
                    requests.append(ClientRequest.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["requestDescription"] as? String)!, location: (dict["location"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!, userName: (dict["userName"] as? String)!))
        
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionary")
                }
            }
            
            completion(requests)
        })
    }
}

