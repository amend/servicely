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
import FirebaseStorage

class ProviderProfileViewController: UIViewController {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var aboutUs: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewOurServicesButton: UIButton!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var loadingPicLabel: UILabel!
    
    
    
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
        viewOurServicesButton.backgroundColor = colorScheme
        
        let user = FIRAuth.auth()?.currentUser
        if user != nil {
            displayName.text = user?.displayName
        } else {
            print("no user logged in")
        }
        
        let db:Database = Database()
        
        db.getCurrentUser() { (user: NSDictionary?) in
            let about = user?["aboutUs"] as? String ?? ""
            
            self.aboutUs.text = about
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
