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
import FirebaseAuth

class ServicesRequestsTableViewController: UITableViewController {

    var category:String = ""
    var client:Bool = false
    
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String:Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        getRatings()
        if(client) {
            getRequets()
        } else {
            getServices()
        }
         */

        self.tableView.rowHeight = 80.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {

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
            
            if(self.client) {
                
                self.requests.removeAll()
                
                let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
                let serviceOfferRef = ref.child("clientRequest")
                
                serviceOfferRef.observeSingleEvent(of: .value, with: { snapshot in
                    print(snapshot.childrenCount)
                    for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        print("adding to services array...")
                        
                        if let dict = rest.value as? NSDictionary {
                            let serviceType = (dict["serviceType"] as? String)!
                            if (serviceType == self.category) {
                                self.requests.append(ClientRequest.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["requestDescription"] as? String)!, location: (dict["location"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!, userName: (dict["userName"] as? String)!))
                                
                                /*
                                 self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!))
                                 */
                            }
                            print("added \(rest.value)")
                        } else {
                            print("could not convert snaptshot to dictionary")
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
                
            } else {
                
                self.services.removeAll()
                
                let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
                let serviceOfferRef = ref.child("serviceOffer")
                
                serviceOfferRef.observeSingleEvent(of: .value, with: { snapshot in
                    print(snapshot.childrenCount)
                    for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        print("adding to services array...")
                        
                        if let dict = rest.value as? NSDictionary {
                            let serviceType = (dict["serviceType"] as? String)!
                            if (serviceType == self.category) {
                                self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                            }
                            print("added \(rest.value)")
                        } else {
                            print("could not convert snaptshot to dictionary")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        })
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

    func getServices() {
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let serviceOfferRef = ref.child("serviceOffer")
        
        serviceOfferRef.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to services array...")
                
                if let dict = rest.value as? NSDictionary {
                    let serviceType = (dict["serviceType"] as? String)!
                    if (serviceType == self.category) {
                        self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!))
                    }
                    print("added \(rest.value)")
                } else {
                    print("could not convert snaptshot to dictionary")
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func getRequets() {
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let serviceOfferRef = ref.child("clientRequest")
        
        serviceOfferRef.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to services array...")
                
                if let dict = rest.value as? NSDictionary {
                    let serviceType = (dict["serviceType"] as? String)!
                    if (serviceType == self.category) {
                        self.requests.append(ClientRequest.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["requestDescription"] as? String)!, location: (dict["location"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!, userName: (dict["userName"] as? String)!))
                        
                        /*
                        self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!))
                        */
                    }
                    print("added \(rest.value)")
                } else {
                    print("could not convert snaptshot to dictionary")
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesServiceCell", for: indexPath) as! CategoriesServiceTableViewCell
        
        if(ratings.count > 0 ) {
        
            if(self.client == false && services.count > 0) {
                let service = services[indexPath.row]
                let colorScheme = ColorScheme.getColorScheme()
                
                cell.name?.text = service.companyName
                cell.price?.text = service.askingPrice
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
            }
        }
        return cell
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
                vc.client = client
                if(ratings.keys.contains(service.userID)) {
                    vc.oldRating = ratings[service.userID]!
                }
            } else {
                let vc:ViewServiceViewController = segue.destination as! ViewServiceViewController
                
                let indexPath = self.tableView.indexPathForSelectedRow?.row
                let request = requests[indexPath!]
                
                vc.request = request
                vc.client = client
            }
        }
    }


}
