//
//  CreateServiceOrRequestViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/6/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateServiceOrRequestViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestVC = storyboard?.instantiateViewController(withIdentifier: "createClientRequestView") as! CreateClientRequestViewController
        let serviceVC = storyboard?.instantiateViewController(withIdentifier: "createServiceOfferView") as! CreateServiceOfferViewController
        
        ifCreateRequest(requestVC, serviceVC)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ifCreateRequest(_ requestVC: UIViewController, _ providerVC: UIViewController) {
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
                self.showCreateView(providerVC)
            }else{
                self.showCreateView(requestVC)
            }
        })
        
    }
    
    func showCreateView(_ vc: UIViewController){
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
