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
    
    var postsHelper:PostsHelper? = nil
    
    // TODO: make services and requests atomic
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String: Double]()
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    var keys:[String] = [String]()
    
    var user:NSDictionary? = nil
    
    var isClient:Bool? = nil
    
    // number of posts to paginate through
    //let numberOfPosts:Int = 2
        
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
    
    
    // keys will contian keys returned by geofire query
    // TODO: make keys atomic. update: seems to work fine for mass posts without being atomic. is something happening so that it's already thread-safe?
    //var keys:[String] = [String]()
    
    /*
    // pagination
    var postsPerBatch = 20
    var postsLoadedTotal = 0
    var postsLoadedTemp = 0
    var loadedAllPosts = false
    */
    
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
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        self.title = "Feed"
        
        // clean up
        self.cleanUpData()
        self.feedTableView.reloadData()
        /*
        self.services.removeAll()
        self.requests.removeAll()
        self.ratings.removeAll()
         */
        
        //self.feedTableView.reloadData()
        
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
        
        self.feedTableViewController.clearsSelectionOnViewWillAppear = false
        
        // pagination
        //self.postsLoadedTotal = 0
        //self.postsLoadedTemp = 0
        //self.loadedAllPosts = false
        
        //self.postsHelper = PostsHelper.init()
        
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
                    
                    self.postsHelper = PostsHelper.init(isClient: self.isClient)
                    
                    if(LocationHelper.isLocationEnabled()) {
                        self.locationManager.requestLocation()
                    } else {
                        // TODO: display alert view that location must be enabled
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
            LocationHelper.setLocation(location: self.location) { (cityAddress, lat, long) in
                print("got location")
                
                self.cityAddress = cityAddress
                self.latitude = lat
                self.longitude = long
                
                print("set location")
                
                //self.getData()
                self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                    self.services = services
                    self.requests = requests
                    self.ratings = ratings
                    self.keys = keys
                    
                    DispatchQueue.main.async{
                        self.feedTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        } else {
            //self.getData()
            self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    self.feedTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
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
            //self.paginate() { (services, requests, ratings) in
            self.postsHelper?.paginate(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    // TODO: display activity idicator that feed is paginating
                    self.feedTableView.reloadData()
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
        print(self.location?.coordinate.latitude)
        print(self.location?.coordinate.longitude)
        LocationHelper.setLocation(location: self.location) { (cityAddress, lat, long) in
            print("did update location")
            
            self.cityAddress = cityAddress
            self.latitude = lat
            self.longitude = long
            
            //self.cleanUpData()
            //self.getData()
            
            self.postsHelper?.getData(latitude: self.latitude!, longitude: self.longitude!) { (services, requests, ratings, keys) in
                self.services = services
                self.requests = requests
                self.ratings = ratings
                self.keys = keys
                
                DispatchQueue.main.async{
                    self.feedTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed with error: " + error.localizedDescription)
    }
    
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
