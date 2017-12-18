//
//  ProfileViewController.swift
//  servicely
//
//  Created by Dana Vaziri on 11/21/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let providerProfileVC = storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
        let clientProfileVC = storyboard?.instantiateViewController(withIdentifier: "clientProfile") as! ClientProfileViewController
        ifClientProfilePage(clientProfileVC, providerProfileVC)
        self.title = "Your Profile"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func ifClientProfilePage(_ clientVC: UIViewController, _ providerVC: UIViewController){
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            let serviceType = user?["serviceType"] as? String ?? ""
            print("ServiceType: \(serviceType)")
            
            //let providerVC = self.storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
            
            if serviceType == "serviceProvider" {
                //self.present(providerVC, animated: true, completion: nil)
                self.showProfile(providerVC)
            }else{
                self.showProfile(clientVC)
            }
        })
    }
    
    func showProfile(_ vc: UIViewController){
        self.addChildViewController(vc)
        containerView.addSubview(vc.view)
        vc.view.frame = containerView.bounds
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
