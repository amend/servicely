//
//  ChatListTableViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatListTableViewController: UITableViewController {

    var currentUserID:String = ""
    var serviceType:String = ""
    var chatList:[ChatMetadata] = [ChatMetadata]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        // not sure if this is better placed here or in viewWillAppear
        // observeChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        self.chatList.removeAll()
        self.currentUserID = (Auth.auth().currentUser?.uid)!
        observeChats()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func observeChats() {
        let db:DatabaseWrapper = DatabaseWrapper()
        db.getCurrentUser() { (user:NSDictionary?) in
            self.serviceType = user?["serviceType"] as! String
            
            let ref = Database.database().reference()
            
            var userType:String = ""
            if(self.serviceType == "client") {
                userType = "clientID"
            } else if(self.serviceType == "serviceProvider") {
                userType = "providerID"
            } else {
                print("Error, user must be client or serviceProvider")
            }
            
            let chatListQuery = ref.child("threads")
                .queryOrdered(byChild: "details/" + userType)
                .queryEqual(toValue: self.currentUserID)
            
            let newChatsRefHandle = chatListQuery.observe(.childAdded, with: { (snapshot) -> Void in
                print(snapshot)
                print("printed snapshot")
                if(snapshot.childrenCount == 0) {
                    // no converasations, tell them to message other users
                    print("no conversations")
                }
                //let chatData = snapshot.value as! Dictionary<String, String>
                let chatData = snapshot.value as! NSDictionary
                //chatData["details"] as! NSDictionary
                print(chatData)
                print("printed chatData")
                let detailsDict:NSDictionary = chatData["details"] as! NSDictionary
                print(detailsDict)
                print("printed detailsDict")
                
                // what needs to be .init'd:
                //  1. clientID
                //  2. clientName
                //  3. providerID
                //  4. providerName
                //  5. service type
                //  6. pic? stretch goal

                let clientID:String = detailsDict["clientID"] as! String
                let providerID:String = detailsDict["providerID"] as! String
                let serviceType:String = self.serviceType
                let timestamp:String = "12345"
                let category:String = detailsDict["category"] as! String
                let threadID:String = detailsDict["threadID"] as! String
                
                let db:DatabaseWrapper = DatabaseWrapper()
                var targetUserID:String = ""
                if(self.serviceType == "client") {
                    targetUserID = providerID
                } else if(self.serviceType == "serviceProvider") {
                    targetUserID = clientID
                }
                db.getUser(userID: targetUserID) { (targetUser:NSDictionary?) in
                    var clientName:String = ""
                    var providerName:String = ""
                    if(self.serviceType == "client") {
                        clientName = user?["username"] as! String
                        providerName = targetUser?["companyName"] as! String
                    } else if(self.serviceType == "serviceProvider") {
                        clientName = targetUser?["username"] as! String
                        providerName = user?["companyName"] as! String
                    }
                    
                    
                    self.chatList.append(ChatMetadata.init(providerID: providerID , clientID: clientID, providerName: providerName, clientName: clientName, timestamp: timestamp,  serviceType: serviceType, category: category, threadID: threadID))
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! ChatListTableViewCell
    
        if(self.serviceType == "client") {
            cell.nameLabel.text = self.chatList[indexPath.row].providerName
        } else if(self.serviceType == "serviceProvider") {
            cell.nameLabel.text = self.chatList[indexPath.row].clientName
        }
        
        cell.categoryLabel.text = self.chatList[indexPath.row].category
        
        //cell.nameLabel.text = "example1"
        //cell.categoryLabel.text = "example2"
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
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
        
        if segue.identifier == "viewChat" {
            let vc:ChatViewController = segue.destination as! ChatViewController
            let indexPath = self.tableView.indexPathForSelectedRow?.row
            let chat = self.chatList[indexPath!]
            
            vc.providerID = chat.providerID
            vc.clientID = chat.clientID
            vc.providerName = chat.providerName
            vc.clientName = chat.clientName
            vc.timestamp = "123456"
            vc.threadID = chat.threadID
            vc.serviceType = chat.serviceType
            vc.category = chat.category
            
            print("about to segue to chat view")
        }
        
    }
    

}
