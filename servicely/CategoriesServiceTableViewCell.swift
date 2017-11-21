//
//  CategoriesServiceTableViewCell.swift
//  servicely
//
//  Created by Brenda Salazar on 11/20/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class CategoriesServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
