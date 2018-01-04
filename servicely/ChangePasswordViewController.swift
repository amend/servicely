//
//  ChangePasswordViewController.swift
//  servicely
//
//  Created by Dana Vaziri on 10/31/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.reenterPasswordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colorScheme = ColorScheme.getColorScheme()
        headerView.backgroundColor = colorScheme
        changePasswordButton.backgroundColor = colorScheme
    }
    
    /*
    @IBAction func changePassword(_ sender: Any) {
        self.view.endEditing(true)
        if(allTextFieldsFull()){
            errorLabel.text = ""
            if(ifPasswordsMatch()){
                errorLabel.text = ""
                let user = Auth.auth().currentUser
                let credential: AuthCredential = FIREmailPasswordAuthProvider.credential(withEmail: (user?.email)!, password: currentPasswordTextField.text!)
        
                user?.reauthenticate(with: credential) { error in
                    if let error = error {
                        // An error happened.
                        print("reauthenticate error happend")
                        if(error.localizedDescription == "The password is invalid or the user does not have a password."){
                            self.errorLabel.text = "The password provided does not match the account."
                        }
                    } else {
                        // User re-authenticated.
                        user?.updatePassword(self.newPasswordTextField.text! , completion: nil)
                        self.resultLabel.text = "Password Changed!"
                    }
                }
            }else{
                errorLabel.text = "Password don't match!"
            }
        }else{
            errorLabel.text = "Please fill out all the fields"
        }
    }
     */
    
    func allTextFieldsFull() -> Bool {
        return !(currentPasswordTextField.text?.isEmpty)! && !(newPasswordTextField.text?.isEmpty)! && !(reenterPasswordTextField.text?.isEmpty)!
    }
    
    func ifPasswordsMatch() -> Bool {
        return newPasswordTextField.text! == reenterPasswordTextField.text!
    }
    
    func textFieldShouldReturn(_ currentPasswordTextField: UITextField) -> Bool {
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
