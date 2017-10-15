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

class ClientFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    var services = [ServiceOffer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.feedTableView.dataSource = self
        self.feedTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        services.removeAll()
        
        // get serviceOffers from Firebase.
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let serviceOfferRef = ref.child("serviceOffer")
        
        serviceOfferRef.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                print("adding to services array...")
                
                if let dict = rest.value as? NSDictionary {
                    //let postContent = dict["companyName"] as? String
                    
                    self.services.append(ServiceOffer.init(serviceType: (dict["serviceType"] as? String)!, serviceDescription: (dict["serviceDescription"] as? String)!, askingPrice: (dict["askingPrice"] as? String)!, location: (dict["location"] as? String)!, companyName: (dict["companyName"] as? String)!, contactInfo: (dict["contactInfo"] as? String)!))
                    print("added \(rest.value)")
                } else {
                    print("could not convert snapshot to dictionay")
                }
            }
            // readload feedTableView on main thrread after finish getting
            // serviceOffers from firebase
            DispatchQueue.main.async{
                self.feedTableView.reloadData()
            }
        })
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceOfferCell", for: indexPath) as! ServiceOfferTableViewCell
        
        // Configure the cell...
        cell.companyName.text = services[indexPath.row].companyName
        cell.serviceType.text = services[indexPath.row].serviceType
        cell.askingPrice.text = services[indexPath.row].askingPrice
        cell.service = services[indexPath.row]
        
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
