//
//  ServiceOfferTableViewCell.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/14/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseDatabase

class ServiceOfferTableViewCell: UITableViewCell {

    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var askingPrice: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    
    var service:ServiceOffer? = nil
    var rating: Double = -1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
     }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
