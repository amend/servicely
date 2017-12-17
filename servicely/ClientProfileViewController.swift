//
//  ClientProfileViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 10/29/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseDatabase
import FirebaseAuth
//import FirebaseAuthUI
//import FirebaseStorage

class ClientProfileViewController: UIViewController{

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var aboutMe: UILabel!
    @IBOutlet weak var viewMyRequestsButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var loadingPicLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
        self.title = "Client Profile"

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let colorScheme = ColorScheme.getColorScheme()
        nameView.backgroundColor = colorScheme
        viewMyRequestsButton.backgroundColor = colorScheme
        
        let user = FIRAuth.auth()?.currentUser
        if user != nil {
            displayName.text = user?.displayName
        } else {
            print("no user logged in")
        }
        
        let db:Database = Database()
        
        db.getCurrentUser() { (user: NSDictionary?) in
            let about = user?["aboutMe"] as? String ?? ""
            
            self.aboutMe.text = about
            
            let profilePicURL = user?["profilePic"] as? String ?? ""
            
            if(profilePicURL != "") {
                self.loadingPicLabel.text = "Loading profile pic..."
                db.retrieveImage(profilePicURL) { (image: UIImage) in
                    self.profilePicImageView.image = image
                    self.loadingPicLabel.text = ""
                }
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
