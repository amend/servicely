//
//  ServiceOfferTableViewCell.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/14/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ServiceOfferTableViewCell: UITableViewCell {

    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var serviceType: UILabel!
    
    @IBOutlet weak var askingPrice: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // define array of key/value pairs to store for this person.
        let serviceOfferRecord = [
            "companyName": companyName.text,
            "serviceType": serviceType.text,
            "askingPrice": askingPrice.text
        ]
        
        // Save to Firebase.
        var ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        

        ref.child("serviceOffer").childByAutoId().setValue(serviceOfferRecord)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
