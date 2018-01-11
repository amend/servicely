//
//  Location.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/10/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper {
    
    static func isLocationEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            return true
        } else {
            return false
        }
    }
    
}
