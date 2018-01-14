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

class ServicesRequestsTableViewController: UITableViewController, CLLocationManagerDelegate {

    var postsHelper:PostsHelper? = nil
    
    var category:String = ""

    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String:Double]()
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()
    
    // data for arrays
    var isClient:Bool? = nil
    
    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // clean up
        self.cleanUpData()
        self.tableView.reloadData()
        
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
        
        // so that cell selection remains selected when exiting
        // and returning from categories
        self.clearsSelectionOnViewWillAppear = false
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Getting more posts...")
        refreshControl?.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        //feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        // clean up
        self.cleanUpData()
        self.tableView.reloadData()

        
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
            
            if(user?["serviceType"] as! String == "client") {
                self.isClient = true
                self.title = "Services"
            } else if(user?["serviceType"] as! String == "serviceProvider") {
                self.isClient = false
                self.title = "Requests"
            }
            
            
            // there's probably a better way to get ratings for users, so think of one
            // and delete this
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
                
                self.postsHelper = PostsHelper.init(isClient: self.isClient)
                self.postsHelper?.setCategory(category: self.category)
                
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
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        let db:DatabaseWrapper = DatabaseWrapper()
        
        db.getCurrentUser() {
            (user) in

            if(user == nil) {
                // TODO: throw exception that use is nil after db.getCurrentUser
                print("user is nil in ServicesRequestsTableViewController")
            }
            
            if(user?["serviceType"] as! String == "client") {
                self.isClient = true
                self.title = "Services"
            } else if(user?["serviceType"] as! String == "serviceProvider") {
                self.isClient = false
                self.title = "Requests"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if(self.isClient == nil) {
            return 0
        }
        
        if (self.isClient!) {
            return services.count
        } else {
            return requests.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesServiceCell", for: indexPath) as! CategoriesServiceTableViewCell
        
        if(self.isClient == nil) {
            return UITableViewCell()
        }
        
        if(ratings.count > 0 ) {
        
            if(self.isClient! && services.count > 0) {
                let service = services[indexPath.row]
                let colorScheme = ColorScheme.getColorScheme()
                cell.name?.text = service.companyName
                cell.price?.text = service.askingPrice
                print(ratings)
                
                if(self.ratings.keys.contains(service.userID)){
                    let rating = ratings[service.userID]!

                    if(rating != -1) {
                        cell.rating?.isHidden = false
                        cell.rating?.rating = rating
                        cell.rating?.filledColor = colorScheme
                        cell.rating?.filledBorderColor = colorScheme
                        cell.rating?.emptyBorderColor = colorScheme
                    } else {
                        cell.rating?.isHidden = true
                    }
                }
            } else if (requests.count > 0){
                let request = requests[indexPath.row]
                
                cell.name?.text = request.userName
                cell.price?.text = request.serviceDescription
                cell.rating?.isHidden = true
            } else {
                return UITableViewCell()
            }
        } else {
            return UITableViewCell()
        }
        
        
        
        
        return cell
    }
    
    // MARK: - pull to refresh
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.cleanUpData()
        
        if(self.location == nil) {
            if(LocationHelper.isLocationEnabled()) {
                self.locationManager.requestLocation()
                return
            } else {
                // TODO: display alert view that location must be enabled
                // for the app to get posts
                return
            }
        } else if (self.latitude == nil || self.longitude == nil) {
            LocationHelper.setLocation(location: self.location) { (cityAddress, lat, long) in
                print("got location")
                
                self.cityAddress = cityAddress
                self.latitude = lat
                self.longitude = long
                
                print("set location")
                
                self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                    self.services = services
                    self.requests = requests
                    self.ratings = ratings
                    self.keys = keys
                    
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        } else {
            self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    // checks if user has reached last row to load more
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        var dataArray:[Any] = [Any]()
        if(self.isClient != nil && self.isClient!) {
            dataArray = self.services
        } else if(self.isClient != nil && !(self.isClient!)) {
            dataArray = self.requests
        }
        if ((indexPath.row == (dataArray.count - 1)) && ((indexPath.row) != (self.keys.count - 1))) {
            self.postsHelper?.paginate(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    // TODO: display activity idicator that feed is paginating
                    self.tableView.reloadData()
                    //self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    
    // MARK: - location
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            print("location use authorized")
            locationManager = manager
            // TODO: How does contents of setLocation know locatoin has been updated?
            // seems to work how it is, but why?
            // setLocation()
        } else if status == .denied {
            print("user chose not to authorize locatin")
        } else if status == .restricted {
            print("Access denied - likely parental controls are restricting use in this app.")
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
       
        self.location = didUpdateLocations.last
        
        LocationHelper.setLocation(location: location) { (cityAddress:String?, lat:Double?, long:Double?) in
            print("did update location")
            
            self.cityAddress = cityAddress!
            self.latitude = lat!
            self.longitude = long!
            
            self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed!")
    }
    
    // MARK: - helper functions
    
    
    func cleanUpData() {
        self.services.removeAll()
        self.requests.removeAll()
        self.ratings.removeAll()
        self.keys.removeAll()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

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


}
