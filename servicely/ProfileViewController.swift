//
//  ProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCorrectProfilePage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCorrectProfilePage() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            let serviceType = user?["serviceType"] as? String ?? ""
            print("ServiceType: \(serviceType)")
            
            let clientVC = self.storyboard?.instantiateViewController(withIdentifier: "clientProfile") as! ClientProfileViewController
            let providerVC = self.storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
            
            if serviceType == "client" {
                self.present(clientVC, animated: true, completion: nil)
            }
            if serviceType == "serviceProvider" {
                self.present(providerVC, animated: true, completion: nil)
            }
        })
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
