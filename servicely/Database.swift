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
import FirebaseAuth
import FirebaseStorage

class Database {
    
    private var ref:FIRDatabaseReference!

    init() {
        ref = FIRDatabase.database().reference()
    }
    
    // gets user that is currently logged in
    func getCurrentUser(completion: @escaping (_ user:NSDictionary?)->() ) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            completion(user)
        })
    }
    
    // writes to child "path" of currently logged in user
    // path "example" will be expanded to users/userID/example by this function
    func writeToCurrentUser(path: String, valueToWrite: String, completion: @escaping(_ didWrite: Bool)->()) {
        let userID = FIRAuth.auth()?.currentUser?.uid

        // write
        ref.child("users")
            .child("\(userID!)/\(path)")
            .setValue(valueToWrite, withCompletionBlock: { (error, snapshot) in
                // check if write successful
                if(error != nil) {
                    print("error in writeToCurrentUser")
                    completion(false)
                } else {
                    completion(true)
                }
            })
    }
    
    // writes ratings of user specified by "userID"
    // path "example" will be expanded to users/userID/example by this function
    func writeRatingOfUser(userID: String, path: String, valueToWrite: Double, completion: @escaping(_ didWrite: Bool)->()) {
        // write
        ref.child("users")
            .child("\(userID)/\(path)")
            .setValue(valueToWrite, withCompletionBlock: { (error, snapshot) in
                // check if write successful
                if(error != nil) {
                    print("error in writeToCurrentUser")
                    completion(false)
                } else {
                    completion(true)
                }
            })
    }
    
    // gets all services offered
    // need to make this paginate when reaching end of table view
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
    
    // gets all users for ratings. not the best approach to get ratings.
    // this refactoring is kinda shitty cuz getting dicts from snapshot will be done outside of this function
    // there's probably a better way to get ratings for users, so think of one
    // and delete this
    func getUsers(completion: @escaping (_ snapshot: FIRDataSnapshot)->()) {
        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot)
        })
    }
    
    // gets client requests of currently logged in user
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
    // gets offered services of currently logged in user
    func getCurrentUsersServices(completion: @escaping (_ usersServices: [ServiceOffer])->()) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("serviceOffer").queryOrdered(byChild: "userID").queryEqual(toValue: userID!).observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            
            var services = [ServiceOffer]()
            
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to requests array...")
                if let dict = rest.value as? NSDictionary {
                    
                    services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                    
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionary")
                }
            }
            
            completion(services)
        })
    }
    
    // gets all offered services of specified category
    // need to paginate this too
    func getServicesOfCategory(category: String, completion: @escaping (_ services: [ServiceOffer])->()) {
        ref.child("serviceOffer").queryOrdered(byChild: "serviceType").queryEqual(toValue: category).observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            
            var services = [ServiceOffer]()
            
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to services array...")
                if let dict = rest.value as? NSDictionary {
                    
                    services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                    
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionary")
                }
            }
            
            completion(services)
        })
    }
    
    // gets all client requests of specified category
    // need to paginate this
    func getRequestsOfCategory(category: String, completion: @escaping (_ requests: [ClientRequest])->()) {
        ref.child("clientRequest").queryOrdered(byChild: "serviceType").queryEqual(toValue: category).observeSingleEvent(of: .value, with: { snapshot in
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
    
    // retreives image from firebase storage when given a url
    func retrieveImage(_ URL: String, completionBlock: @escaping (UIImage) -> Void) {
        let ref = FIRStorage.storage().reference(forURL: URL)
        
        // max download size limit is 10Mb in this case
        ref.data(withMaxSize: 10 * 1024 * 1024, completion: { retrievedData, error in
            if error != nil {
                // handle the error
                print("error in retrieveImage")
                return
            }
            
            let image = UIImage(data: retrievedData!)!
            completionBlock(image)
        })
    }
    
    // will delete this soon and rewrite after restructuring chat json
    func getCurrentUsersChats(completion: @escaping (_ chats: [Chat])->()) {
        let userID = FIRAuth.auth()?.currentUser?.uid

        getCurrentUser() { (user:NSDictionary?) in
            
            let serviceType:String = user?["serviceType"] as! String
            
            self.ref.child("chats")
                .queryOrdered(byChild: serviceType)
                .queryEqual(toValue: userID)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    print("\(snapshot.key)")
                })
        }
    }
}

