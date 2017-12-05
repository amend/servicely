//
//  MyRequetsTableViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 12/5/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MyRequetsTableViewController: UITableViewController {
    
    var requests = [ClientRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Requests"
        self.tableView.rowHeight = 80.0
        getRequests()

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
        return requests.count
    }

    func getRequests() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let requestOfferRef = ref.child("clientRequest")
        
        requestOfferRef.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to requests array...")
                
                if let dict = rest.value as? NSDictionary {
                    let _userID = (dict["userID"] as? String)!
                    if (_userID == userID!) {
                        self.requests.append(ClientRequest.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["requestDescription"] as? String)!, location: (dict["location"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!, userID: (dict["userID"] as? String)!, userName: (dict["userName"] as? String)!))
                    }
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionary")
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesServiceCell", for: indexPath) as! CategoriesServiceTableViewCell

        let request = requests[indexPath.row]
        cell.name?.text = request.userName
        cell.price?.text = request.contactInfo
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
