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
        let providerProfileVC = storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
        let clientProfileVC = storyboard?.instantiateViewController(withIdentifier: "clientProfile") as! ClientProfileViewController
        let cl = ifClientProfilePage()
        if(cl){
            self.addChildViewController(clientProfileVC)
            containerView.addSubview(clientProfileVC.view)
            clientProfileVC.view.frame = containerView.bounds
        }else if(!cl){
            self.addChildViewController(providerProfileVC)
            containerView.addSubview(providerProfileVC.view)
            providerProfileVC.view.frame = containerView.bounds
        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func ifClientProfilePage() -> Bool{
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        let ref1:FIRDatabaseReference! = FIRDatabase.database().reference()
        let usersRef = ref1.child("users")
        
        var result: Bool = true;
        
        usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
            let user = snapshot.value as? NSDictionary
            
            let serviceType = user?["serviceType"] as? String ?? ""
            print("ServiceType: \(serviceType)")
            
            //let providerVC = self.storyboard?.instantiateViewController(withIdentifier: "providerProfile") as! ProviderProfileViewController
            
            if serviceType == "serviceProvider" {
                //self.present(providerVC, animated: true, completion: nil)
                result = false
            }
        })
        return result
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
