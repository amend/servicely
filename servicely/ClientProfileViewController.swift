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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
        constraints()

        // Do any additional setup after loading the view.
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
    }
    
    func constraints() {
        self.nameView.frame.size.width = self.view.frame.size.width
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
