//
//  ServicesRequestsTableViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 11/19/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GeoFire

class ServicesRequestsTableViewController: FeedViewController {

    
    //var postsHelper:PostsHelper? = nil
    
    var category:String = ""

    /*
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String:Double]()
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()
    */
    // data for arrays
    //var isClient:Bool? = nil
    
    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    
    /*
    // location
    var locationManager: CLLocationManager!
    //var city:String? = nil
    //var state:String? = nil
    //var country:String? = nil
    //var postalCode:String? = nil
    var cityAddress:String? = nil
    var latitude:Double? = nil
    var longitude:Double? = nil
    var location:CLLocation? = nil
    */
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.rowHeight = 80.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // clean up
        self.cleanUpData()
        //self.tableView.reloadData()
        
        /*
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        } else {
            // TODO: display alert that approving locaiotn use is
            // required for getting posts
            print("location use not approved, cant get posts")
        }
         */
        
        // so that cell selection remains selected when exiting
        // and returning from categories
        //self.clearsSelectionOnViewWillAppear = false
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Getting more posts...")
        refreshControl?.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        //feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        // clean up
        self.cleanUpData()
        //self.tableView.reloadData()

        
        let db:DatabaseWrapper = DatabaseWrapper()
        
        db.getCurrentUser() {
            (user) in
            
            if(user == nil) {
                // TODO: throw exception that use is nil after db.getCurrentUser
                print("user is nil in ServicesRequestsTableViewController")
                
                // TODO: this happens bc we're using FirebaseUI for log in
                // and viewDidLoad continues to execute after we present the
                // firebaseUI login. the below is a temp fix.
                // TODO: make custom login view controllers
                let u = Auth.auth().currentUser?.uid
                if(u == nil) {
                    print("no user logged in from Auth, returning from viewWillLoad")
                    return
                }
            }
            
            /*
            if(user?["serviceType"] as! String == "client") {
                self.isClient = true
                self.title = "Services"
            } else if(user?["serviceType"] as! String == "serviceProvider") {
                self.isClient = false
                self.title = "Requests"
            }
             */
            
            
            // there's probably a better way to get ratings for users, so think of one
            // and delete this
            db.getUsers() { (snapshot) in
                print(snapshot.childrenCount)
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    if let dict = rest.value as? NSDictionary {
                        let rating = dict["rating"] as? Double ?? -1
                        //let userID = dict["userID"] as? String ?? ""
                        
                        //self.ratings[rest.key] = rating
                    } else {
                        print("could not convert snaptshot to dictionary")
                    }
                }
                
                //self.postsHelper = PostsHelper.init(isClient: self.isClient)
                //self.postsHelper?.setCategory(category: self.category)
                
                if CLLocationManager.locationServicesEnabled() {
                    print("requesting location")
                    self.locationManager.requestLocation();
                } else {
                    // TODO: display alert that approving locaiotn use is
                    // required for getting posts
                    print("location use not approved, cant get posts")
                    print("location services not enabled, ask user to enable")
                }
            }
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        */
        
        let db:DatabaseWrapper = DatabaseWrapper()
        
        db.getCurrentUser() {
            (user) in

            if(user == nil) {
                // TODO: throw exception that use is nil after db.getCurrentUser
                print("user is nil in ServicesRequestsTableViewController")
            }
            
            
            
            if(user?["serviceType"] as! String == "client") {
                super.isClient = true
                self.title = "Services"
            } else if(user?["serviceType"] as! String == "serviceProvider") {
                super.isClient = false
                self.title = "Requests"
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - message button handler

    @IBAction func messageButtonHandlerCategories(_ sender: Any) {
        if let cell = (sender as AnyObject).superview??.superview as? PostCollectionViewCell {
            super.selectedIndexPath = self.collectionView?.indexPath(for: cell)
        }
    }
    
    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "viewService" {
            if(self.isClient!) {
                let vc:ViewServiceViewController = segue.destination as! ViewServiceViewController
            
                let indexPath = self.tableView.indexPathForSelectedRow?.row
                let service = services[indexPath!]
            
                vc.service = service
                vc.viewingRequest = false
                if(ratings.keys.contains(service.userID)) {
                    vc.oldRating = ratings[service.userID]!
                }
            } else {
                let vc:ViewServiceViewController = segue.destination as! ViewServiceViewController
                
                let indexPath = self.tableView.indexPathForSelectedRow?.row
                let request = requests[indexPath!]
                
                vc.request = request
                vc.viewingRequest = true
            }
        }
        
    }
    */

}
