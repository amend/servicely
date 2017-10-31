//
//  EditProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditProfileViewController: UIViewController {

    @IBOutlet weak var aboutMe: UITextView!
    @IBOutlet weak var savedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedLabel.text = ""

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let userID = FIRAuth.auth()?.currentUser?.uid
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let userRef = ref1.child("users")
        
        var about = ""

        if let a = aboutMe.text, !a.isEmpty {
            about = aboutMe.text!
        }
 
        userRef.child(userID!).setValue(["aboutMe":about])
        
        savedLabel.text = "Saved!"
        
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
