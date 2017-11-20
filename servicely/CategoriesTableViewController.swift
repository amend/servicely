//
//  CategoriesTableViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 11/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    @IBOutlet weak var typeDisplay: UISegmentedControl!
    
    let categories:[String] = ["Automotive", "Cell/Mobile", "Computer", "Creative", "Event", "Farm + Garden", "Financial", "Household", "Labor/Move", "Legal", "Lessons", "Real Estate", "Skilled Trade", "Trave/Vac", "Mechanic", "Carpentry", "Tutoring", "Care provider", "Lawn & Garden", "Pet care", "Plumbing", "Health & Beauty", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Services"

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
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.detailTextLabel?.text = category
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "serviceRequestController" {
            let vc:ServicesRequestsTableViewController = segue.destination as! ServicesRequestsTableViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow?.row
            vc.category = categories[indexPath!]
            
            if self.typeDisplay.selectedSegmentIndex == 0 {
                vc.client = false
            } else {
                vc.client = true
            }
        }
    }
 

}
