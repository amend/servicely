//
//  ClientFeedTableViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/14/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import CoreLocation
import GeoFire

class ClientFeedViewController: UIViewController, AuthUIDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let feedTableViewController:UITableViewController = UITableViewController()
    
    @IBOutlet weak var feedTableView: UITableView!
    
    // TODO: make services and requests atomic
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String: Double]()
    var user:NSDictionary? = nil
    
    var isClient:Bool? = nil
    
    // number of posts to paginate through
    //let numberOfPosts:Int = 2
        
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
    
    
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()
    
    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    
    // pull to refresh
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        self.feedTableView.dataSource = self
        self.feedTableView.delegate = self
        self.feedTableViewController.tableView = feedTableView
        self.feedTableViewController.clearsSelectionOnViewWillAppear = false
        
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Getting more posts...")
        //refreshControl.addTarget(self, action: "refresh:", for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        self.title = "Feed"
        
        // clean up
        self.cleanUpData()
        self.feedTableView.reloadData()
        
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        // pagination
        self.postsLoadedTotal = 0
        self.postsLoadedTemp = 0
        self.loadedAllPosts = false
        
        
        checkLoggedIn() {
            
            let db:DatabaseWrapper = DatabaseWrapper()
            db.getCurrentUser() { (user) in
                if(user == nil) {
                    
                    // TODO: this happens bc we're using FirebaseUI for log in
                    // and viewDidLoad continues to execute after we present the
                    // firebaseUI login. the below is a temp fix.
                    // TODO: make custom login view controllers
                    let u = Auth.auth().currentUser?.uid
                    if(u == nil) {
                        print("no user logged in from Auth, returning from viewWillLoad")
                        return
                    }

                    
                    // present service type view controller
                    //let vc = ServiceTypeViewController()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "serviceTypeViewController")
                    self.present(vc!, animated: true, completion: nil)
                    return
                } else {
                    self.user = user
                    
                    if((user?["serviceType"] as! String) == "client") {
                        self.isClient = true
                    } else if((user?["serviceType"] as! String) == "serviceProvider") {
                        self.isClient = false
                    }
                    
                    if(LocationHelper.isLocationEnabled()) {
                        self.locationManager.requestLocation()
                    } else {
                        // display alert view that location must be enabled
                        // for the app to get posts
                        return
                    }
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        checkLoggedIn() {
            
            let db:DatabaseWrapper = DatabaseWrapper()
            db.getCurrentUser() { (user) in
                if(user == nil) {
                    // present service type view controller
                    //let vc = ServiceTypeViewController()
                    
                    // TODO: this happens bc we're using FirebaseUI for log in
                    // and viewDidLoad continues to execute after we present the
                    // firebaseUI login. the below is a temp fix.
                    // TODO: make custom login view controllers
                    let u = Auth.auth().currentUser?.uid
                    if(u == nil) {
                        print("no user logged in from Auth, returning from viewWillLoad")
                        return
                    }
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "serviceTypeViewController")
                    self.present(vc!, animated: true, completion: nil)
                    return
                } else {
                    self.user = user
                    if(self.user!["serviceType"] as! String == "client") {
                        self.isClient = true
                    } else if(self.user!["serviceType"] as! String == "serviceProvider") {
                        self.isClient = false
                    } else {
                        // TODO: error handling here
                    }
                }
            }
        }
    }
    
    // MARK: - Firebase auth
    
    func checkLoggedIn(completion: @escaping ()->()) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                print("user is signed in")
                completion()
            } else {
                // No user is signed in.
                print("user is not signed in")
                self.login() {
                    print("back from login() callback")
                    completion()
                }
            }
        }
    }
    
    func login(completion: @escaping ()->()) {
        // let authUI = FUIAuth.authUI()
        let authUI = FUIAuth.defaultAuthUI()
        
        let fbAppID:String = "1969547683311551"
        let googleClientID:String = "16510907992-1rre0iqk91d75f5sp4jtbe22maomuc7k.apps.googleusercontent.com"
        //let googleProvider = FUIGoogleAuth(clientID: googleClientID)
        //let fbProvider = FUIFacebookAuth(appID: fbAppID)
        //let googleProvider = FUIGoogleAuth(scopes: [googleClientID])
        //let fbProvider = FUIFacebookAuth(permissions: [fbAppID])
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
            ]
        
        authUI?.delegate = self as? FUIAuthDelegate
        //authUI?.signInProviders = [fbProvider!, googleProvider!]
        //authUI?.providers = [fbProvider, googleProvider]
        authUI?.providers = providers
        
        let authViewController = authUI?.authViewController()
        
        self.present(authViewController!, animated: true, completion: {
            print("finished presenting authViewController")
            completion()
        })
        
    }
    
    func authPickerViewController(for authUI: FUIAuth) -> FUIAuthPickerViewController {
        return  ServicelyLogoViewController(authUI: authUI)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            //Problem signing in
            self.login() {
                
            }
        }else {
            //User is in! Here is where we code after signing in
            
        }
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
            self.setLocation {
                self.getData()
            }
        } else {
            self.getData()
        }
    }
    
    func cleanUpData() {
        self.services.removeAll()
        self.requests.removeAll()
        self.ratings.removeAll()
        self.postsLoadedTotal = 0
        self.postsLoadedTemp = 0
        self.loadedAllPosts = false
    }


    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if((user != nil)
            && ((user?["serviceType"] as! String) == "client")
            && ((self.services.count - 1 ) >= indexPath.row)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceOfferCell", for: indexPath) as! ServiceOfferTableViewCell
            //if(services.count > 0) {
                // Configure the cell...
                let service = services[indexPath.row]
                let colorScheme = ColorScheme.getColorScheme()
                cell.companyName.text = service.companyName
                cell.category.text = service.category
                cell.askingPrice.text = service.askingPrice
                cell.service = service
                
                if(ratings.keys.contains(service.userID)) {
                    let rating = ratings[service.userID]!
                    
                    if(rating != -1){
                        cell.ratingBar.rating = rating
                        cell.ratingBar.filledColor = colorScheme
                        cell.ratingBar.filledBorderColor = colorScheme
                        cell.ratingBar.emptyBorderColor = colorScheme
                    }else{
                        cell.ratingBar.isHidden = true
                    }
                }
            //}
            
            return cell
        } else if((user != nil)
        && ((user?["serviceType"] as! String) == "serviceProvider")
            && ((self.requests.count - 1 ) >= indexPath.row)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clientRequestCell", for: indexPath) as! ClientRequestTableViewCell
            let request = self.requests[indexPath.row]
            //let colorScheme = ColorScheme.getColorScheme()
            
            cell.usernameLabel.text = request.userName
            cell.categoryLabel.text = request.category
            return cell
        } else {
            
        }
        
        // TODO: make emtpy cell to show if table view loads cellers before callbacks
        // viewWillAppear populate services or requests arrays
        let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! UITableViewCell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(user != nil) {
            if((self.user?["serviceType"] as! String) == "client") {
                return services.count
            } else if((self.user?["serviceType"] as! String) == "serviceProvider") {
                return requests.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // MARK: - query data, populate table view
    
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
        
        if(!(self.isClient!)) {
            print("logged in as a service provider")
        }
        
        let ref = Database.database().reference()
    
        ref.child(fdbQueryType).child(self.keys[index]).observeSingleEvent(of: .value, with: { snapshot in
            print("snapshot children count:")
            print(snapshot.childrenCount)
            
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
            
            self.postsLoadedTemp += 1
            if(self.postsLoadedTemp == self.postsLoadedTotal) {
                self.getRatingsReloadTableView()
            }
        })
    }
    
    // checks if user has reached last row to load more
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
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
            
            DispatchQueue.main.async{
                self.feedTableView.reloadData()
                self.refreshControl.endRefreshing()
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
        geocoder.reverseGeocodeLocation(self.location!) { (placemarksArray, error) in
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
        self.location = didUpdateLocations.last
        print(self.location?.coordinate.latitude)
        print(self.location?.coordinate.longitude)
        self.setLocation {
            print("did update location")
            self.cleanUpData()
            self.getData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: " + error.localizedDescription)
    }
    
    func getData() {
        self.keys.removeAll()
        
        if(self.isClient == nil) {
            print("isClient is nil in getData")
            return
        }
        
        self.cleanUpData()
        self.getPostsKeys()
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "viewService" || segue.identifier == "viewRequest" {
            let vc:ViewServiceViewController = segue.destination as! ViewServiceViewController
            let indexPath = self.feedTableView.indexPathForSelectedRow?.row
            
            if segue.identifier == "viewService" {
                let service = services[indexPath!]
                
                vc.service = service
                vc.viewingRequest = false
                
                if(ratings.keys.contains(service.userID)) {
                    let rating = ratings[service.userID]!
                    
                    if(rating != -1){
        
                        vc.oldRating = ratings[service.userID]!
                    }else{
                        
                    }
                }

                //vc.oldRating = ratings[service.userID]!
            } else if(segue.identifier == "viewRequest") {
                let request = self.requests[indexPath!]
                
                vc.request = request
                vc.viewingRequest = true
            }
        }
    }

}
