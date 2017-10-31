//
//  ProviderProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProviderProfileViewController: UIViewController {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var aboutUs: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewOurServicesButton: UIButton!
    @IBOutlet weak var viewMyRequestsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Provider Profile"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let colorScheme = ColorScheme.getColorScheme()
        headerView.backgroundColor = colorScheme
        viewMyRequestsButton.backgroundColor = colorScheme
        viewOurServicesButton.backgroundColor = colorScheme
        loadInfo()
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
            
            self.aboutUs.text = about
        })
        
        DispatchQueue.main.async {
            self.view.reloadInputViews()
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
