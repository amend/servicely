//
//  ViewMyPostsViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/26/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GeoFire

class ViewMyPostsViewController: FeedViewController {
    
    var ref = Database.database().reference()
    
    let db:DatabaseWrapper = DatabaseWrapper()

    //var requests = [ClientRequest]()
    //var services = [ServiceOffer]()
    
    // for deleting posts
    //var selectedIndexPath:IndexPath? = nil
    
    //var isClient:Bool? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.cleanUpData()
        
        db.getCurrentUser() { (user) in
            let serviceType = user?["serviceType"] as! String
            if(serviceType == "serviceProvider") {
                
                self.isClient = false
                
                self.title = "Our Services"
                //self.tableView.rowHeight = 80.0
                
                self.db.getCurrentUsersServices() { (usersServices) in
                    self.services = usersServices
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            } else if(serviceType == "client") {
                
                self.isClient = true
                
                self.title = "My Requests"
                //self.collectionView.rowHeight = 80.0
                
                self.db.getCurrentUsersRequests() {(usersRequests) in
                    print(usersRequests.count)
                    
                    self.requests = usersRequests
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            } else {
                // TODO: error handling
                print("no servicetype while getting current user in ViewMyPostsViewController")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Delete posts
    
    @IBAction func deleteButtonHandler(_ sender: Any) {
        if let cell = (sender as AnyObject).superview??.superview as? PostCollectionViewCell {
            self.selectedIndexPath = self.collectionView?.indexPath(for: cell)
        }
        
        var postType:String = ""
        var postID:String = ""
        var postTypeGeoFire:String = ""
        if(self.isClient!) {
            postType = "clientRequest"
            let request = requests[self.selectedIndexPath!.row]
            postID = request.postID
            postTypeGeoFire = "location-clientRequests"
        } else {
            postType = "serviceOffer"
            let service = services[self.selectedIndexPath!.row]
            postID = service.postID
            postTypeGeoFire = "location-serviceOffers"
        }
        
        
        self.ref.child(postTypeGeoFire).child(postID).removeValue { error, _ in
            if(error != nil) {
                print(error)
            } else {
                // TODO: show popup that says deleted post
                print("deleted post geofire entry")
            }
            self.ref.child(postType).child(postID).removeValue { error, _ in
                if(error != nil) {
                    print(error)
                } else {
                    // TODO: show popup that says deleted post
                    print("deleted post")
                    
                    if(self.isClient!) {
                        self.requests.remove(at: (self.selectedIndexPath?.row)!)
                    } else {
                        self.services.remove(at: (self.selectedIndexPath?.row)!)
                    }
                    
                    DispatchQueue.main.async{
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - override collection view
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print(String(indexPath.row))
        
        if((user != nil)
            && ((user?["serviceType"] as! String) == "client")
            && ((self.requests.count - 1 ) >= indexPath.row)) {
            
            //let cell = tableView.dequeueReusableCell(withIdentifier: "serviceOfferCell", for: indexPath) as! PostCollectionViewCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCellWithDelete", for: indexPath) as! PostCollectionViewCell
            //if(services.count > 0) {
            let request = self.requests[indexPath.row]
            //let colorScheme = ColorScheme.getColorScheme()
            
            //cell.usernameLabel.text = request.userName
            cell.nameLabel.text = request.userName
            cell.categoryLabel.text = request.category
            cell.priceLabel.text = ""
            cell.contactInfoLabel.text = ""
            cell.descriptionLabel.text = request.serviceDescription
            
            cell.request = request
            
            return cell
        } else if((user != nil)
            && ((user?["serviceType"] as! String) == "serviceProvider")
            && ((self.services.count - 1 ) >= indexPath.row)) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCellWithDelete", for: indexPath) as! PostCollectionViewCell
            
            // Configure the cell...
            let service = services[indexPath.row]
            let colorScheme = ColorScheme.getColorScheme()
            //cell.companyName.text = service.companyName
            cell.nameLabel.text = service.companyName
            cell.categoryLabel.text = service.category
            cell.contactInfoLabel.text = service.contactInfo
            //cell.askingPrice.text = service.askingPrice
            cell.priceLabel.text = service.askingPrice
            cell.descriptionLabel.text = service.serviceDescription
            
            cell.service = service
            
            return cell
        } else {
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCellWithDelete", for: indexPath) as! PostCollectionViewCell
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(user != nil) {
            if((self.user?["serviceType"] as! String) == "client") {
                return self.requests.count
            } else if((self.user?["serviceType"] as! String) == "serviceProvider") {
                return self.services.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
