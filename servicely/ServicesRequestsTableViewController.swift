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

    var category:String = ""
    var client:Bool = false
    
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String:Double]()
    
    // data for arrays
    var isClient:Bool? = nil
    
    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()
    
    // location
    var locationManager: CLLocationManager!
    var city:String? = nil
    var state:String? = nil
    var country:String? = nil
    var postalCode:String? = nil
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // clean up
        self.services.removeAll()
        self.requests.removeAll()
        self.tableView.reloadData()
        
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        let db:DatabaseWrapper = DatabaseWrapper()
        
        self.isClient = !self.client
        
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
            
            if(self.client) {
                self.requests.removeAll()
            } else {
                self.services.removeAll()
            }
            
            if CLLocationManager.locationServicesEnabled() {
                print("requesting location")
                self.locationManager.requestLocation();
                print("done requesting locatin")
            } else {
                print("location services not enabled, ask user to enable")
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
        if (client == false) {
            return services.count
        } else {
            return requests.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesServiceCell", for: indexPath) as! CategoriesServiceTableViewCell
        
        if(ratings.count > 0 ) {
        
            if(self.client == false && services.count > 0) {
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
    
    // MARK: - populate table view data source arrays
    
    func getPostsKeys() {
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
            
            self.paginate()
            
            print("All initial data has been loaded and events have been fired!")
        })
    }
    
    func paginate() {
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
            getPost(key: self.keys[i], index:i, targetLoadCount:self.postsLoadedTotal+endIndex)
        }
        
        self.postsLoadedTotal = endIndex + 1
    }
    
    func getPost(key:String, index:Int, targetLoadCount:Int) {
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
        
        let ref = Database.database().reference()
        ref.child(fdbQueryType).child(self.keys[index]).observeSingleEvent(of: .value, with: { snapshot in
            print("snapshot children count:")
            print(snapshot.childrenCount)
            
            let dict = snapshot.value as? NSDictionary
            
            if(self.isClient!){
                if(self.category == (dict!["category"] as? String)!) {
                
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
                }
            } else {
                if(self.category == (dict!["category"] as? String)!) {
                    
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
            }
            print("added \(dict)")
            
            // reload table view if this is last element
            print("keys: " + String(self.keys.count))
            if(self.isClient)! {
                print("services count: " + String(self.services.count))
            } else {
                print("requests count: " + String(self.requests.count))
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
            
            self.postsLoadedTemp += 1
            if(self.postsLoadedTemp == self.postsLoadedTotal) {
                // self.postsLoadedTemp = 0
                if(self.isClient!) {
                    self.getRatingsReloadTableView()
                } else {
                    self.getRatingsReloadTableView()
                }
            }
        })
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
            self.paginate()
        }
    }
    
    func getRatingsReloadTableView() {
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
            DispatchQueue.main.async{
                //self.feedTableView.reloadData()
                self.tableView.reloadData()
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
    
    func setLocation(completion: @escaping ()->()) {
        print("in setLocation")
        
        print("going to use location")
        // Get user's current location name and info (city)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.locationManager.location!) { (placemarksArray, error) in
            print("convertion to city location")
            if (placemarksArray?.count)! > 0 {
                let placemark = placemarksArray?.first
                let city:String? = placemark?.locality
                let country:String? = placemark?.country
                let postalCode:String? = placemark?.postalCode
                let state:String? = placemark?.administrativeArea
                
                print("got city: " + city! + " country: " + country! + " postal code: " + postalCode! + " state: " + state!)
                
                self.city = city
                self.state = state
                self.country = country
                self.postalCode = postalCode
                
                // let address = "1 Infinite Loop, Cupertino, CA 95014"
                let address = city! + " " + state! + " " + country! + " " + postalCode!
                
                self.cityAddress = address
                
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location,
                        let lat:Double =  location.coordinate.latitude,
                        let long:Double = location.coordinate.longitude
                        else {
                            // handle no location found
                            print("could not convert address to lat and long")
                            return
                    }
                    
                    // Use location
                    print("lat: " + String(lat))
                    print("long: " + String(long))
                    
                    self.latitude = lat
                    self.longitude = long
                    
                    var addr:String = ""
                    if(self.city != nil) {
                        addr += self.city!
                    }
                    if(self.state != nil){
                        addr += " " + self.state!
                    }
                    if(self.country != nil) {
                        addr += " " + self.country!
                    }
                    if(self.postalCode != nil) {
                        addr += " " + self.postalCode!
                    }
                    
                    print("*** users address: " + addr)
                    print("*** users lat long: " + String(describing: self.latitude) + " " + String(describing: self.longitude))
                    
                    // after we have coors, geofire and firebase db queries to populate
                    // the feed
                    print("got location")
                    completion()
                }
            }
            print("exiting setLocation")
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        self.setLocation {
            print("did update location")
            self.getPostsKeys()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed!")
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
            if(self.client == false) {
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
