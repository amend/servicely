//
//  ClientProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/29/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class ClientProfileViewController: UIViewController{

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var aboutMe: UILabel!
    @IBOutlet weak var viewMyRequestsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCorrectProfilePage()
        constraints()
        self.title = "Client Profile"

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let colorScheme = ColorScheme.getColorScheme()
        nameView.backgroundColor = colorScheme
        viewMyRequestsButton.backgroundColor = colorScheme
        loadInfo()
        loadCorrectProfilePage()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInfo() {
        let user = FIRAuth.auth()?.currentUser
        if user != nil {
            displayName.text = user?.displayName
        }
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            let about = user?["aboutMe"] as? String ?? ""
            
            self.aboutMe.text = about
        })
        
        DispatchQueue.main.async {
            self.view.reloadInputViews()
        }
    }
    
    func constraints() {
        self.nameView.frame.size.width = self.view.frame.size.width
    }
    
    func loadCorrectProfilePage() {
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            let serviceType = user?["serviceType"] as? String ?? ""
            print("ServiceType: \(serviceType)")
            
            let providerVC = self.storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
            
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
