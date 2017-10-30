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
                return UIColor.init(red: 0, green: 122, blue: 255, alpha: 1)
            case 2:
                return UIColor.init(red: 254, green: 91, blue: 95, alpha: 1)
            case 3:
                return UIColor.init(red: 102, green: 255, blue: 102, alpha: 1)
            default:
                return UIColor.init(red: 254, green: 91, blue: 95, alpha: 1)
        }
    }
}
