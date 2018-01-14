//
//  PostsHelper.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/10/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import CoreLocation
import GeoFire

class PostsHelper {
    
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()

    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    
    // TODO: make services and requests atomic
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String: Double]()
    
    var isClient:Bool? = nil
    
    var latitude:Double? = nil
    var longitude:Double? = nil
    
    var category:String = ""
    
    init(isClient:Bool?) {
        self.isClient = isClient
    }
    
    func setCategory(category:String) {
        self.category = category
    }
    
    func getData(latitude:Double, longitude:Double,  completion: @escaping (_ services:[ServiceOffer],_ requests:[ClientRequest],_ ratings:[String: Double],_ keys:[String])->()) {
        self.keys.removeAll()
        
        self.latitude = latitude
        self.longitude = longitude
        
        if(self.isClient == nil) {
            print("isClient is nil in getData")
            return
        }
        
        self.cleanUpData()
        self.getPostsKeys() { (services, requests, ratings) in
            completion(services, requests, ratings, self.keys)
        }
    }
    
    
    
    func getPostsKeys(completion: @escaping (_ services:[ServiceOffer],_ requests:[ClientRequest],_ ratings:[String: Double])->()) {
        // check if client or proivder type flag has been set
        var queryType:String = ""
        if(self.isClient == nil) {
            return
        } else if((self.isClient!)) {
            queryType = "location-serviceOffers"
        } else if(!(self.isClient!)) {
            queryType = "location-clientRequests"
        } else {
            print("could not get user's serviceType")
            return
        }
        
        // get geofire ref for service offers
        let geoFireRef:DatabaseReference! = Database.database().reference().child(queryType)
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        
        let center = CLLocation(latitude: (self.latitude)!, longitude: (self.longitude)!)
        // 10 kilometers
        let defaults = UserDefaults.standard
        var distMiles = defaults.integer(forKey: "distance")
        if(distMiles == 0) {
            distMiles = 10
            defaults.set(10, forKey: "distance")
        }
        let distKilo = Double(distMiles) * 1.60934
        var circleQuery = geoFire?.query(at: center, withRadius: distKilo)
        
        // handle query
        var queryHandle = circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            self.keys.append(key)
        })
        // get objects from firebasedb after geofire collects all keys
        circleQuery?.observeReady({
            circleQuery?.removeObserver(withFirebaseHandle: queryHandle!)
            
            self.keys.reverse()
            
            self.paginate(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                completion(services, requests, ratings)
            }
            
            print("All initial data has been loaded and events have been fired!")
        })
    }
    
    
    
    func paginate(latitude:Double, longitude:Double, completion: @escaping (_ services:[ServiceOffer],_ requests:[ClientRequest],_ ratings:[String: Double],_ keys:[String])->()) {
        if(self.keys.count == 0) {
            print("no keys loaded from geofire query")
            return
        }
        
        if(loadedAllPosts) {
            print("loaded all posts already, returning from pagination")
            return
        }
        
        var endIndex = 0
        
        // check if at end of posts
        if((self.postsLoadedTotal + self.postsPerBatch) >= (self.keys.count)) {
            endIndex = self.keys.count - 1
            self.loadedAllPosts = true
        } else {
            endIndex = self.postsLoadedTotal + self.postsPerBatch - 1
        }
        
        for i in self.postsLoadedTotal...endIndex {
            getPost(key: self.keys[i], index:i) { (shouldReloadData) in
                if(shouldReloadData) {
                    // sort by timestamp, most recent posts first
                    if(self.isClient)! {
                        self.services.sort {
                            $0.timestamp > $1.timestamp
                        }
                    } else {
                        self.requests.sort {
                            $0.timestamp > $1.timestamp
                        }
                    }
                    
                    completion(self.services, self.requests, self.ratings, self.keys)
                }
            }
        }
        self.postsLoadedTotal = endIndex + 1
    }


    
    func getPost(key:String, index:Int, completion: @escaping (_ shouldReload:Bool)->()) {
        var fdbQueryType:String = ""
        if(self.isClient == nil) {
            print("isClient is nil in querying for posts")
        } else if((self.isClient!)) {
            fdbQueryType = "serviceOffer"
        } else if(!(self.isClient!)) {
            fdbQueryType = "clientRequest"
        } else {
            print("fdbQueryType not set to serviceOffer or clientRequest")
        }
        
        var postsLoaded:Int = 0
        
        if(!(self.isClient!)) {
            print("logged in as a service provider")
        }
        
        var ref = Database.database().reference()
        
        if(category == "") {
            ref.child(fdbQueryType).child(self.keys[index]).observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot children count:")
                print(snapshot.childrenCount)
                
                if(snapshot.childrenCount == 0) {
                    self.keys.remove(at: index)
                }
                
                let dict = snapshot.value as? NSDictionary
                
                if(self.isClient!){
                    self.services.append(ServiceOffer.init(
                        category: (dict!["category"] as? String)!,
                        serviceDescription: (dict!["serviceDescription"] as? String)!,
                        askingPrice: (dict!["askingPrice"] as? String)!,
                        location: (dict!["location"] as? String)!,
                        companyName: (dict!["companyName"] as? String)!,
                        contactInfo: (dict!["contactInfo"] as? String)!,
                        userID: (dict!["userID"] as? String)!,
                        timestamp: (dict!["timestamp"] as? Double)!
                        )
                    )
                } else {
                    self.requests.append(ClientRequest.init(
                        serviceDescription: dict!["requestDescription"] as! String,
                        location: dict!["location"] as! String,
                        userID: dict!["userID"] as! String,
                        userName: dict!["userName"] as! String,
                        category: dict!["category"] as! String,
                        timestamp: dict!["timestamp"] as! Double
                        )
                    )
                    
                }
                print("added \(dict)")
                
                // reload table view if this is last element
                print("keys: " + String(self.keys.count))
                /*
                if(snapshot.childrenCount != 0) {
                    self.postsLoadedTemp += 1
                }
                */
                
                self.postsLoadedTemp += 1
                if(self.postsLoadedTemp == self.postsLoadedTotal) {
                    //self.getRatingsReloadTableView()
                    self.getRatingsReloadTableView() { (services, requests, ratings) in
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            })
        } else {
            ref.child(fdbQueryType).queryOrdered(byChild: "category").queryEqual(toValue: self.category, childKey: self.keys[index]).observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot children count:")
                print(snapshot.childrenCount)
                
                print("keys index: " + String(index))
                
                if(snapshot.childrenCount == 0) {
                    self.keys.remove(at: index)
                    completion(false)
                    return
                }
                
                let temp = snapshot.value as? NSDictionary
                
                if(temp == nil) {
                    completion(false)
                    return
                }
                
                let temp2 = temp![temp?.allKeys.first] as! NSDictionary
                var dict:NSDictionary? = nil
                dict = temp2
                
                if(self.isClient!){
                    self.services.append(ServiceOffer.init(
                        category: (dict!["category"] as? String)!,
                        serviceDescription: (dict!["serviceDescription"] as? String)!,
                        askingPrice: (dict!["askingPrice"] as? String)!,
                        location: (dict!["location"] as? String)!,
                        companyName: (dict!["companyName"] as? String)!,
                        contactInfo: (dict!["contactInfo"] as? String)!,
                        userID: (dict!["userID"] as? String)!,
                        timestamp: (dict!["timestamp"] as? Double)!
                        )
                    )
                } else {
                    self.requests.append(ClientRequest.init(
                        serviceDescription: dict!["requestDescription"] as! String,
                        location: dict!["location"] as! String,
                        userID: dict!["userID"] as! String,
                        userName: dict!["userName"] as! String,
                        category: dict!["category"] as! String,
                        timestamp: dict!["timestamp"] as! Double
                        )
                    )
                    
                }
                print("added \(dict)")
                
                // reload table view if this is last element
                print("keys: " + String(self.keys.count))
                
                /*
                if(snapshot.childrenCount != 0) {
                    self.postsLoadedTemp += 1
                }
                */
                
                self.postsLoadedTemp += 1
                if(self.postsLoadedTemp == self.postsLoadedTotal) {
                    //self.getRatingsReloadTableView()
                    self.getRatingsReloadTableView() { (services, requests, ratings) in
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            })
            
        }
    }
    
    func getRatingsReloadTableView(completion: @escaping (_ services:[ServiceOffer],_ requests:[ClientRequest],_ ratings:[String: Double])->()) {
        // there's probably a better way to get ratings for users, so think of one
        // and delete this
        let db:DatabaseWrapper = DatabaseWrapper()
        db.getUsers() { (snapshot) in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                if let dict = rest.value as? NSDictionary {
                    let rating = dict["rating"] as? Double ?? -1
                    //let userID = dict["userID"] as? String ?? ""
                    
                    self.ratings[rest.key] = rating
                } else {
                    print("could not convert snaptshot to dictionary")
                }
            }
            
            // sort by timestamp, most recent posts first
            if(self.isClient)! {
                self.services.sort {
                    $0.timestamp > $1.timestamp
                }
            } else {
                self.requests.sort {
                    $0.timestamp > $1.timestamp
                }
            }
            
            completion(self.services, self.requests, self.ratings)
            
            /*
            DispatchQueue.main.async{
                self.feedTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            */
        }
    }

    func cleanUpData() {
        self.keys.removeAll()
        self.services.removeAll()
        self.requests.removeAll()
        self.ratings.removeAll()
        self.postsLoadedTotal = 0
        self.postsLoadedTemp = 0
        self.loadedAllPosts = false
    }
    
}
