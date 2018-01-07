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
//import FirebaseAuth

class ServicesRequestsTableViewController: UITableViewController {

    var category:String = ""
    var client:Bool = false
    
    var services = [ServiceOffer]()
    var requests = [ClientRequest]()
    var ratings = [String:Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {

        // users for ratings
        // if self.client then get clientRequests
        // else get serviceOffers
        
        let db:DatabaseWrapper = DatabaseWrapper()
        
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

                db.getRequestsOfCategory(category: self.category) { (requestsOfCategory) in
                    self.requests = requestsOfCategory
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.services.removeAll()

                db.getServicesOfCategory(category: self.category) { (servicesOfCategory) in
                    self.services = servicesOfCategory
                
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
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
