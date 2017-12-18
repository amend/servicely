//
//  EditProviderViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditProviderViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var aboutUs: UITextView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedLabel.text = ""
        self.title = "Edit Provider Profile"
        aboutUs.delegate = self
        aboutUs.text = "Tell us about your company..."
        aboutUs.textColor = UIColor.lightGray

        // dismiss keyboards
        self.aboutUs.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colorScheme = ColorScheme.getColorScheme()
        saveButton.backgroundColor = colorScheme
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
    
    @IBAction func saveButton(_ sender: Any) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let userRef = ref1.child("users")
        
        var about = ""
        
        if let a = aboutUs.text, !a.isEmpty {
            about = aboutUs.text!
        }
        
        userRef.child("\(userID!)/aboutUs").setValue(about)
        
        savedLabel.text = "Saved!"
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
