//
//  Location.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/7/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {

    
    
    // location
    var locationManager: CLLocationManager!
    var city:String? = nil
    var state:String? = nil
    var country:String? = nil
    var postalCode:String? = nil
    var cityAddress:String? = nil
    var latitude:Double? = nil
    var longitude:Double? = nil
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            print("location use authorized")
            locationManager = manager
            // TODO: How does contents of setLocation know locatoin has been updated?
            // seems to work how it is, but why?
            // setLocation()
        } else if status == .denied {
            print("user chose not to authorize locatin")
        } else if status == .restricted {
            print("Access denied - likely parental controls are restricting use in this app.")
        }
    }
    
    func setLocation(completion: @escaping ()->()) {
        print("in setLocation")
        
        // Get user's current location name and info (city)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.locationManager.location!) { (placemarksArray, error) in
            print("convertion to city location")
            if (placemarksArray?.count)! > 0 {
                let placemark = placemarksArray?.first
                let city:String? = placemark?.locality
                let country:String? = placemark?.country
                let postalCode:String? = placemark?.postalCode
                let state:String? = placemark?.administrativeArea
                
                print("got city: " + city! + " country: " + country! + " postal code: " + postalCode! + " state: " + state!)
                
                self.city = city
                self.state = state
                self.country = country
                self.postalCode = postalCode
                
                // let address = "1 Infinite Loop, Cupertino, CA 95014"
                let address = city! + " " + state! + " " + country! + " " + postalCode!
                
                self.cityAddress = address
                
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
                    
                    // Use location
                    print("lat: " + String(lat))
                    print("long: " + String(long))
                    
                    self.latitude = lat
                    self.longitude = long
                    
                    var addr:String = ""
                    if(self.city != nil) {
                        addr += self.city!
                    }
                    if(self.state != nil){
                        addr += " " + self.state!
                    }
                    if(self.country != nil) {
                        addr += " " + self.country!
                    }
                    if(self.postalCode != nil) {
                        addr += " " + self.postalCode!
                    }
                    
                    print("*** users address: " + addr)
                    print("*** users lat long: " + String(describing: self.latitude) + " " + String(describing: self.longitude))
                    
                    // after we have coors, geofire and firebase db queries to populate
                    // the feed
                    print("got location")
                    completion()
                }
            }
            print("exiting setLocation")
        }
    }

    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        print("did update location")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("location manager failed!")
    }
}
