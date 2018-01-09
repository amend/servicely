//
//  CreateServiceOfferViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/14/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import GeoFire

class CreateServiceOfferViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var serviceTypePickerView: UIPickerView!
    @IBOutlet weak var serviceDescription: UITextView!
    @IBOutlet weak var askingPrice: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var contactInfo: UITextField!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    let pickerViewData:[String] = ["Automotive", "Cell/Mobile", "Computer", "Creative", "Event", "Farm + Garden", "Financial", "Household", "Labor/Move", "Legal", "Lessons", "Real Estate", "Skilled Trade", "Trave/Vac", "Mechanic", "Carpentry", "Tutoring", "Care provider", "Lawn & Garden", "Pet care", "Plumbing", "Health & Beauty", "Other"]
    
    var category:String = ""
    
    // location
    var locationManager: CLLocationManager!
    var city:String? = nil
    var state:String? = nil
    var country:String? = nil
    var postalCode:String? = nil
    var cityAddress:String? = nil
    var latitude:Double? = nil
    var longitude:Double? = nil
    var location:CLLocation? = nil
    var updatedLocation:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.serviceTypePickerView.dataSource = self
        self.serviceTypePickerView.delegate = self
        self.title = "Create Service Offer"
        serviceDescription.delegate = self
        serviceDescription.text = "Say something about the service you are offering..."
        serviceDescription.textColor = UIColor.lightGray
        
        // dismiss text field keyboards
        // uses functions: textFieldShouldReturn and textView
        self.serviceDescription.delegate = self
        self.askingPrice.delegate = self
        //self.location.delegate = self
        self.companyName.delegate = self
        self.contactInfo.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.backgroundColor = ColorScheme.getColorScheme()
        // picks the first entry in picker view once view loads, otherwise
        // if user wants first item in pickerview and doesn't need to scroll, no
        // item will be selected
        serviceTypePickerView.selectRow(0, inComponent: 0, animated: false)
        category = pickerViewData[0]
        
        locationManager = CLLocationManager()
        self.isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        if CLLocationManager.locationServicesEnabled() {
            print("requesting location")
            self.locationManager.requestLocation();
            print("done requesting locatin")
        } else {
            print("location services not enabled, ask user to enable")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func submitButton(_ sender: Any) {
        let userID = Auth.auth().currentUser?.uid
        
        if(!self.updatedLocation || addressLabel.text == "" || addressLabel.text == nil) {
            savedLabel.text = "Getting city location... Please wait"
            return
        }
        
        // define array of key/value pairs to store for this person.
        let serviceOfferRecord = [
            "companyName": companyName.text!,
            "category": self.category,
            "serviceDescription": serviceDescription.text!,
            "askingPrice": askingPrice.text!,
            "location": self.cityAddress!,
            "latitude": self.latitude!,
            "longitude": self.longitude!,
            "contactInfo": contactInfo.text!,
            "userID": userID,
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        
        // Save to Firebase.
        let ref:DatabaseReference! = Database.database().reference()
        
        //ref.child("serviceOffer").childByAutoId().setValue(serviceOfferRecord)
        let postID = ref.child("serviceOffer").childByAutoId()
        postID.setValue(serviceOfferRecord)

        
        let geoFireRef:DatabaseReference! = Database.database().reference().child("location-serviceOffers")
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        geoFire?.setLocation(CLLocation(latitude: self.latitude!, longitude: self.longitude!), forKey: postID.key) { (error) in
            if (error != nil) {
                self.savedLabel.text = "Error - not saved"
                
                print("An error occured: \(error)")
            } else {
                self.savedLabel.text = "saved!"
                
                print("Saved location successfully!")
            }
        }
        
        // update ui
        //savedLabel.text = "saved!"
    }
    
    // picker view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0) {
            return pickerViewData.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0) {
            return pickerViewData[row]
        } else {
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0) {
            self.category = pickerViewData[row]
        }
    }
    
    // MARK: - location
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
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
        
        print("going to use location")
        // Get user's current location name and info (city)
        let geocoder = CLGeocoder()
        
        if(self.location == nil) {
            print("didUpdateLocation did not assign self.locatoin")
            if CLLocationManager.locationServicesEnabled() {
                print("requesting location")
                self.locationManager.requestLocation();
                print("done requesting locatin")
            } else {
                print("location services not enabled, ask user to enable")
            }
            return
        }
        
        geocoder.reverseGeocodeLocation(self.location!) { (placemarksArray, error) in
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
                    
                    self.addressLabel.text = addr
                    self.savedLabel.text = ""
                    
                    print("got location")
                    completion()
                }
            }
            print("exiting setLocation")
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        self.location = didUpdateLocations.last
        self.setLocation {
            print("did update location")
            self.updatedLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed!")
    }
    
    // keyboard dismiss
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about your company..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
