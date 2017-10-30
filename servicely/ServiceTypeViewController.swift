//
//  ServiceTypeViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 10/29/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ServiceTypeViewController: UIViewController {
    
    @IBOutlet weak var serviceTypeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        var serviceType = ""
        if(serviceTypeSegmentedControl.selectedSegmentIndex == 0) {
            print("selected service provider")
            serviceType = "serviceProvider"
        } else if(serviceTypeSegmentedControl.selectedSegmentIndex == 1) {
            print("selected client")
            serviceType = "client"
        } else {
            print("Error. Service type segmented control in ServiceTypeViewController did not have a selected index")
        }
        
        usersRef.child(userID!).setValue(["serviceType":serviceType])
     
        print("exiting prepare for segue")
    }


}
