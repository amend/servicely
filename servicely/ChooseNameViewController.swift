//
//  ChooseNameViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/20/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController {

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var nameLabel: UITextField!
    
    var nameKey:String = ""
    var nameValue:String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let db:Database = Database()
        
        db.getCurrentUser() { (user:NSDictionary?) in
            let serviceType:String = user?["serviceType"] as! String
            if(serviceType == "serviceProvider") {
                self.nameKey = "companyName"
                self.instructionsLabel.text = "Enter your company's name:"
            } else if(serviceType == "client") {
                self.nameKey = "username"
                self.instructionsLabel.text = "Enter your username:"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButton(_ sender: Any) {
        self.nameValue = (self.nameLabel.text)!
        
        let db:Database = Database()
        
        db.writeToCurrentUser(path: self.nameKey, valueToWrite: self.nameValue) { (didWrite: Bool) in
            if(!didWrite) {
                print("could not save serviceType to user")
            } else {
                let defaults = UserDefaults.standard
                defaults.set(self.nameKey, forKey: self.nameValue)
                defaults.synchronize()
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
