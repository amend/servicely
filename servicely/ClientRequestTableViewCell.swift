//
//  ClientRequestTableViewCell.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/23/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class ClientRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var request:ClientRequest? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
