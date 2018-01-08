//
//  ViewServiceViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 11/20/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseDatabase
import FirebaseAuth

class ViewServiceViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    
    var service:ServiceOffer? = nil
    var request:ClientRequest? = nil
    var oldRating: Double = -1.0
    
    var viewingRequest:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
        self.redView.frame.size.width = self.view.frame.size.width
        self.redView.frame.size.height = 80.00
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colorScheme = ColorScheme.getColorScheme()
        redView.backgroundColor = colorScheme
        submitButton.backgroundColor = colorScheme
        redView.backgroundColor = colorScheme
        ratingBar.filledColor = colorScheme
        ratingBar.filledBorderColor = colorScheme
        ratingBar.emptyBorderColor = colorScheme
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setValues() {
        if(self.viewingRequest) {            
            self.name.text = request?.userName
            self.serviceDescription.text = request?.serviceDescription
            // if client or client-type post from categories, then these labels shouldnt show
            self.contactNumber.text = ""
            self.contactNumberLabel.text = ""
            self.price.text = ""
            self.priceLabel.text = ""
            self.ratingBar.isHidden = true
            self.submitButton.isHidden = true

        } else {
            self.name.text = service?.companyName
            self.serviceDescription.text = service?.serviceDescription
            self.contactNumber.text = service?.contactInfo
            self.price.text = service?.askingPrice
        }
 }
    
    @IBAction func submitRating(_ sender: Any) {
        var newRating = 0.0
        if(oldRating == -1){
            newRating = ratingBar.rating
        }else{
            newRating = (ratingBar.rating + oldRating)/2
        }
        
        var userID:String = ""
        if(self.viewingRequest) {
            userID = (request?.userID)!
        } else {
            userID = (service?.userID)!
        }
        
        let db:DatabaseWrapper = DatabaseWrapper()
        db.writeRatingOfUser(userID: userID, path: "rating", valueToWrite: newRating) { (didWrite: Bool) in
            if(!didWrite) {
                print("could not save rating")
            } else {
                print("updated rating")
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "viewServiceToChatSegue") {
            // TODO: Make ViewRequestVieController
            if let chatVC = segue.destination as? ChatViewController{

                if(self.viewingRequest) {
                    chatVC.serviceType = "serviceProvider"
                    chatVC.category = (self.request?.category)!
                    
                    chatVC.clientName = (self.request?.userName)!
                    chatVC.clientID = (self.request?.userID)!
                    
                    if let currentUser = Auth.auth().currentUser {
                        chatVC.providerID = currentUser.uid
                        let db:DatabaseWrapper = DatabaseWrapper()
                        db.getCurrentUser() { (user:NSDictionary?) in
                            chatVC.providerName = user?["companyName"] as! String
                        }
                    }

                    
                    
                } else {
                    chatVC.serviceType = "client"
                    chatVC.category = (self.service?.category)!
                    
                    chatVC.providerName = (self.service?.companyName)!
                    chatVC.providerID = (self.service?.userID)!
                    
                    if let currentUser = Auth.auth().currentUser {
                        chatVC.clientID = currentUser.uid
                    }
                    let db:DatabaseWrapper = DatabaseWrapper()
                    db.getCurrentUser() { (user:NSDictionary?) in
                        chatVC.clientName = user?["username"] as! String
                    }
                }
                
                print("exiting prepare for segue")
            }
        }
    }
 

}
