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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getServices()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            return 0
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
                        self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!))
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesServiceCell", for: indexPath) as! CategoriesServiceTableViewCell
        
        let service = services[indexPath.row]
        
        cell.name?.text = service.companyName
        cell.price?.text = service.askingPrice
        
        // Configure the cell...

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
