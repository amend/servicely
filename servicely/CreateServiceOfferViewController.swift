//
//  CreateServiceOfferViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/14/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreateServiceOfferViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var serviceTypePickerView: UIPickerView!
    
    @IBOutlet weak var serviceDescription: UITextView!
    
    @IBOutlet weak var askingPrice: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var companyName: UITextField!
    
    @IBOutlet weak var contactInfo: UITextField!
    
    @IBOutlet weak var savedLabel: UILabel!
    
    
    let pickerViewData:[String] = ["Mechanic", "Carpentry", "Tutoring", "Care provider", "Lawn & Garden", "Pet care", "Plumbing", "Other"]
    
    var serviceType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.serviceTypePickerView.dataSource = self
        self.serviceTypePickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Create Service Offer"
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
        // define array of key/value pairs to store for this person.
        let serviceOfferRecord = [
            "companyName": companyName.text!,
            "serviceType": serviceType,
            "serviceDescription": serviceDescription.text!,
            "askingPrice": askingPrice.text!,
            "location": location.text!,
            "contactInfo": contactInfo.text!
        ]
        
        // Save to Firebase.
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        
        ref.child("serviceOffer").childByAutoId().setValue(serviceOfferRecord)
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
