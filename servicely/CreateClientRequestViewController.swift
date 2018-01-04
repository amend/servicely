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


class CreateClientRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var serviceTypePickerView: UIPickerView!
    @IBOutlet weak var requestDescription: UITextView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    let pickerViewData:[String] = ["Automotive", "Cell/Mobile", "Computer", "Creative", "Event", "Farm + Garden", "Financial", "Household", "Labor/Move", "Legal", "Lessons", "Real Estate", "Skilled Trade", "Trave/Vac", "Mechanic", "Carpentry", "Tutoring", "Care provider", "Lawn & Garden", "Pet care", "Plumbing", "Health & Beauty", "Other"]
    
    var serviceType:String = ""
    
    var locationManager: CLLocationManager!
    var location:CLLocation? = nil
    
    var city:String? = nil
    var state:String? = nil
    var country:String? = nil
    var postalCode:String? = nil
    var cityAddress:String? = nil
    var latitude:Double? = nil
    var longitude:Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.serviceTypePickerView.dataSource = self
        self.serviceTypePickerView.delegate = self
        self.title = "Create Request"
        requestDescription.delegate = self
        requestDescription.text = "Say something about the service you are looking for..."
        requestDescription.textColor = UIColor.lightGray
        
        // dismiss text field keyboards
        // uses functions: textFieldShouldReturn and textView
        self.requestDescription.delegate = self
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
        serviceType = pickerViewData[0]
        
        // core location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        let userName = Auth.auth().currentUser?.displayName

        if(addressLabel.text == "" || addressLabel.text == nil) {
            savedLabel.text = "Getting city location... Please wait"
            return
        }
        
        // define array of key/value pairs to store for this person.
        let clientRequestRecord = [
            "category": serviceType,
            "requestDescription": requestDescription.text!,
            "userID": userID,
            "userName": userName,
            "location": self.cityAddress!,
            "latitude": self.latitude!,
            "longitude": self.longitude!
            ] as [String : Any]
        
        // Save to Firebase.
        let ref:DatabaseReference! = Database.database().reference()

        let postID = ref.child("clientRequest").childByAutoId()
            postID.setValue(clientRequestRecord)
        
        let geoFireRef:DatabaseReference! = Database.database().reference().child("location-clientRequests")
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
            serviceType = pickerViewData[row]
        }
    }
    
    // core location
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            print("location use authorized")
            locationManager = manager
            setLocation()
        } else if status == .denied {
            print("user chose not to authorize locatin")
        } else if status == .restricted {
            print("Access denied - likely parental controls are restricting use in this app.")
        }
    }
    
    func setLocation() {
        print("in setLocation")
        
        // Get user's current location name
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
                        let locationTemp = placemarks.first?.location,
                        let lat:Double =  locationTemp.coordinate.latitude,
                        let long:Double = locationTemp.coordinate.longitude
                        else {
                            // handle no location found
                            print("could not convert address to lat and long")
                            return
                    }
                    
                    self.location = locationTemp
                    
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
                    
                    self.addressLabel.text = addr
                    self.savedLabel.text = ""
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

