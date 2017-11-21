//
//  DeleteAccountViewController.swift
//  servicely
//
//  Created by Dana Vaziri on 10/31/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class DeleteAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerView.backgroundColor = ColorScheme.getColorScheme()
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        if(!(passwordTextField.text?.isEmpty)!){
            errorLabel.text = ""
            let user = FIRAuth.auth()?.currentUser
            let credential: FIRAuthCredential = FIREmailPasswordAuthProvider.credential(withEmail: (user?.email)!, password: passwordTextField.text!)
                
            user?.reauthenticate(with: credential) { error in
                if let error = error {
                    // An error happened.
                    print("reauthenticate error happend")
                    if(error.localizedDescription == "The password is invalid or the user does not have a password."){
                        self.errorLabel.text = "The password provided does not match the account."
                    }
                } else {
                    // User re-authenticated.
                    user?.delete(completion: nil)
                    //Show the Sign Up page
                    //UIViewController.present(<#T##UIViewController#>)
                }
            }
        }else{
            errorLabel.text = "Please enter your password"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
