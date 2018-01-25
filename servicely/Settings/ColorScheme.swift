//
//  ColorScheme.swift
//  servicely
//
//  Created by Dana Vaziri on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import Foundation
import UIKit

class ColorScheme{
    var _colorScheme = UIColor.init(red:0 , green:0 , blue:0 , alpha: 1)
    
    class func setColorScheme(colorID: Int){
        let defaults = UserDefaults.standard
        defaults.set(colorID, forKey: "colorScheme")
        defaults.synchronize()
    }
    
    class func getColorScheme() -> UIColor{
        let defaults = UserDefaults.standard
        let colorID = defaults.integer(forKey: "colorScheme")
        switch colorID {
            case 1:
                return UIColor.init(red: 25/255.0, green: 148/255.0, blue: 252/255.0, alpha: 1.0)
            case 2:
                return UIColor.init(red: 251/255.0, green: 93/255.0, blue: 99/255.0, alpha: 1.0)
            case 3:
                return UIColor.init(red: 120/255.0, green: 248/255.0, blue: 127/255.0, alpha: 1.0)
            default:
                return UIColor.init(red: 251/255.0, green: 93/255.0, blue: 99/255.0, alpha: 1.0)
        }
    }
}
