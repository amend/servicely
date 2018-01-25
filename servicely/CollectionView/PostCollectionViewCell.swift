//
//  PostCollectionViewCell.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/15/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import UIKit
import FirebaseAuth

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var service:ServiceOffer? = nil
    var request:ClientRequest? = nil
    
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        
        /*
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height/3))
        textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
         */
    }
     */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        self.layer.backgroundColor = UIColor.white.cgColor
        //self.layer.borderWidth = 7
        //self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
        //self.layer.borderColor = UIColor.black.cgColor
        //self.layer.borderColor = UIColor(displayP3Red: 254, green: 91, blue: 95, alpha: 1.0) as! CGColor
        //self.layer.borderColor = CGColor.init(red: 254, green: 91, blue: 95, alpha: 1.0)
        //self.layer.borderColor = UIColor.init(red: 254/255.0, green: 91/255.0, blue: 95/255.0, alpha: 1.0).cgColor
            self.layer.masksToBounds = true
        
        /*
         imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
         imageView.contentMode = UIViewContentMode.ScaleAspectFit
         contentView.addSubview(imageView)
         
         textLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height/3))
         textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
         textLabel.textAlignment = .Center
         contentView.addSubview(textLabel)
         */
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "viewServiceToChatSegue") {
            // TODO: Make ViewRequestVieController
            if let chatVC = segue.destination as? ChatViewController{
                
                if(self.request != nil) {
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
