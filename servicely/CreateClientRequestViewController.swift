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

class CreateClientRequestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var serviceTypePickerView: UIPickerView!
    
    @IBOutlet weak var requestDescription: UITextView!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var contactInfo: UITextField!
    
    @IBOutlet weak var savedLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    
    let pickerViewData:[String] = ["Automotive", "Cell/Mobile", "Computer", "Creative", "Event", "Farm + Garden", "Financial", "Household", "Labor/Move", "Legal", "Lessons", "Real Estate", "Skilled Trade", "Trave/Vac", "Mechanic", "Carpentry", "Tutoring", "Care provider", "Lawn & Garden", "Pet care", "Plumbing", "Health & Beauty", "Other"]
    
    var serviceType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.serviceTypePickerView.dataSource = self
        self.serviceTypePickerView.delegate = self
        self.title = "Create Request"
        requestDescription.delegate = self
        requestDescription.text = "Say something about the service you are looking for..."
        requestDescription.textColor = UIColor.lightGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.backgroundColor = ColorScheme.getColorScheme()
        
        // picks the first entry in picker view once view loads, otherwise
        // if user wants first item in pickerview and doesn't need to scroll, no
        // item will be selected
        serviceTypePickerView.selectRow(0, inComponent: 0, animated: false)
        serviceType = pickerViewData[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButton(_ sender: Any) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        let userName = FIRAuth.auth()?.currentUser?.displayName

        // define array of key/value pairs to store for this person.
        let clientRequestRecord = [
            "serviceType": serviceType,
            "location": location.text!,
            "contactInfo": contactInfo.text!,
            "requestDescription": requestDescription.text!,
            "userID": userID,
            "userName": userName
        ]
        
        // Save to Firebase.
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        
        ref.child("clientRequest").childByAutoId().setValue(clientRequestRecord)
        
        savedLabel.text = "saved!"

    }
    
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

