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
    
    static func setLocation(location:CLLocation?, completion: @escaping (_ cityAddress:String?, _ latitude:Double?, _ longitude:Double?)->()) {
        
        print("in setLocation")
        
        print("going to use location:CLLocation?")
        
        // Get user's current location name and info (city)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location!) { (placemarksArray, error) in
            print("convertion to city location")
            if (placemarksArray?.count)! > 0 {
                let placemark = placemarksArray?.first
                let city:String? = placemark?.locality
                let country:String? = placemark?.country
                let postalCode:String? = placemark?.postalCode
                let state:String? = placemark?.administrativeArea
                
                print("got city: " + city! + " country: " + country! + " postal code: " + postalCode! + " state: " + state!)
                
                // let address = "1 Infinite Loop, Cupertino, CA 95014"
                let address = city! + " " + state! + " " + country! + " " + postalCode!
                
                let cityAddress = address
                
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location,
                        let lat:Double =  location.coordinate.latitude,
                        let long:Double = location.coordinate.longitude
                        else {
                            // handle no location found
                            print("could not convert address to lat and long")
                            return
                        }
                    
                    print("got location")
                    completion(cityAddress, lat, long)
                }
            }
            print("exiting setLocation")
        }
    }
    
}
