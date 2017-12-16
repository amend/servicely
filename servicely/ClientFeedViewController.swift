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

class ClientFeedViewController: UIViewController, FIRAuthUIDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String: Double]()
    
    // number of posts to paginate through
    let numberOfPosts:Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.feedTableView.dataSource = self
        self.feedTableView.delegate = self
        self.title = "Feed"
        checkLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        if(userID == nil) {
            checkLoggedIn()
            //var userID = FIRAuth.auth()?.currentUser?.uid
            return
        }

        let db:Database = Database()
        
        db.getCurrentUser(userID: userID) { (user) in
            if(user == nil) {
                // present service type view controller
                //let vc = ServiceTypeViewController()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "serviceTypeViewController")
                self.present(vc!, animated: true, completion: nil)
            }
            self.services.removeAll()
            
            db.getServicesOffered() { (snapshot) in
                print(snapshot.childrenCount) // I got the expected number of items
                for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                    print("adding to services array...")
                    
                    if let dict = rest.value as? NSDictionary {
                        //let postContent = dict["companyName"] as? String
                        
                        self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                        
                        print("added \(rest.value)")
                    } else {
                        print("could not convert snapshot to dictionay")
                    }
                }
                
                db.getUsers() { (snapshot) in
                    print(snapshot.childrenCount)
                    for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        if let dict = rest.value as? NSDictionary {
                            let rating = dict["rating"] as? Double ?? -1
                            //let userID = dict["userID"] as? String ?? ""
                            
                            self.ratings[rest.key] = rating
                        } else {
                            print("could not convert snaptshot to dictionary")
                        }
                    }
                    DispatchQueue.main.async{
                        self.feedTableView.reloadData()
                    }
                }
            }
        }
    }

    func getRatings(){
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let userRef = ref.child("users")
        
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                if let dict = rest.value as? NSDictionary {
                    let rating = dict["rating"] as? Double ?? -1
                    let userID = dict["userID"] as? String ?? ""
                    self.ratings[userID] = rating
                } else {
                    print("could not convert snaptshot to dictionary")
                }
            }
            DispatchQueue.main.async{
                self.feedTableView.reloadData()
            }
        })
    }
    
    // MARK: - Firebase auth
    
    func checkLoggedIn() {
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
            } else {
                // No user is signed in.
                self.login()
            }
        }
    }
    
    func login() {
        let authUI = FIRAuthUI.authUI()
        
        let fbAppID:String = "1969547683311551"
        let googleClientID:String = "16510907992-1rre0iqk91d75f5sp4jtbe22maomuc7k.apps.googleusercontent.com"
        let googleProvider = FIRGoogleAuthUI(clientID: googleClientID)
        let fbProvider = FIRFacebookAuthUI(appID: fbAppID)
        
        authUI?.delegate = self
        authUI?.signInProviders = [fbProvider!, googleProvider!]
        let authViewController = authUI?.authViewController()
        
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    func authPickerViewController(for authUI: FIRAuthUI) -> FIRAuthPickerViewController {
        return  ServicelyLogoViewController(authUI: authUI)
    }

    func authUI(_ authUI: FIRAuthUI, didSignInWith user: FIRUser?, error: Error?) {
        if error != nil {
            //Problem signing in
            self.login()
        }else {
            //User is in! Here is where we code after signing in
            
        }
    }


    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceOfferCell", for: indexPath) as! ServiceOfferTableViewCell
        if(services.count > 0) {
            // Configure the cell...
            let service = services[indexPath.row]
            let colorScheme = ColorScheme.getColorScheme()
            cell.companyName.text = service.companyName
            cell.serviceType.text = service.serviceType
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
            
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    /*
    @IBAction func tempSignOutButton(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
    }
 */
    
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

    @IBAction func postItem(_ sender: Any) {
        let defaults = UserDefaults.standard
        let serviceType:String = defaults.string(forKey: "serviceType" )!
        if(serviceType == "serviceProvider") {
            
        } else if(serviceType == "client") {
            
        } else {
            
        }
    }

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
        if segue.identifier == "viewService" {
            let vc:ViewServiceViewController = segue.destination as! ViewServiceViewController
                
            let indexPath = self.feedTableView.indexPathForSelectedRow?.row
            let service = services[indexPath!]
                
            vc.service = service
            vc.client = false
            
            if(ratings.keys.contains(service.userID)) {
                let rating = ratings[service.userID]!
                
                if(rating != -1){
    
                    vc.oldRating = ratings[service.userID]!
                }else{
                    
                }
            }

            //vc.oldRating = ratings[service.userID]!
        
        }
    }

}
