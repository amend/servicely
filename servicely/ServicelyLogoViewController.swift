//
//  ServicelyLogoViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/19/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation
import FirebaseAuthUI

class ServicelyLogoViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageHeight:Int = 160
        let imageWidth:Int = 160
        let imageX:Int = Int(Int(UIScreen.main.bounds.size.width/2) - imageWidth/2)
        let imageY:Int = Int(UIScreen.main.bounds.size.height/8)
        let imageViewBackground = UIImageView(frame: CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight))
        imageViewBackground.image = UIImage(named: "logo")
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        let labelHeight:Int = 35
        let label = UILabel(frame: CGRect(x: imageX, y: imageY + imageHeight + 20, width: imageWidth, height: labelHeight))
        label.center = CGPoint(x: Int(UIScreen.main.bounds.size.width/2), y: imageY + 160 + 20)
        label.textAlignment = .center
        label.text = "Servicely"
        label.font = label.font.withSize(30)
        
        self.view.insertSubview(imageViewBackground, at: 0)
        self.view.insertSubview(label, at: 0)
    }
}
