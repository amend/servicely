//
//  EditProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseAuth

class EditProfileViewController: UIViewController, UITextViewDelegate  {

    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedLabel.text = ""
        self.title = "Edit Client Profile"
        aboutMe.delegate = self
        aboutMe.text = "Tell us about yourself...."
        aboutMe.textColor = UIColor.lightGray

        // dismiss keyboards
        self.aboutMe.delegate = self
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
        var about = ""

        if let a = aboutMe.text, !a.isEmpty {
            about = aboutMe.text!
        }
 
        let db:DatabaseWrapper = DatabaseWrapper()
        db.writeToCurrentUser(path: "aboutMe", valueToWrite: about) { (didWrite:Bool) in
            
            var message = ""
            if(didWrite) {
                message = "Saved!"
            } else {
                message = "Couldn't save"
            }

            // this calls main thread for UI updates
            // undefined behavior if attempt to update UI
            // on non-main thread
            DispatchQueue.main.async{
                self.savedLabel.text = message
            }
            
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
