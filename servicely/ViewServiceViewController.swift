//
//  ViewServiceViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 11/20/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewServiceViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var service:ServiceOffer? = nil
    var request:ClientRequest? = nil
    var oldRating: Double = -1.0
    
    var client:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
        self.redView.frame.size.width = self.view.frame.size.width
        self.redView.frame.size.height = 80.00
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colorScheme = ColorScheme.getColorScheme()
        redView.backgroundColor = colorScheme
        submitButton.backgroundColor = colorScheme
        redView.backgroundColor = colorScheme
        ratingBar.filledColor = colorScheme
        ratingBar.filledBorderColor = colorScheme
        ratingBar.emptyBorderColor = colorScheme
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setValues() {
        if(client == false) {
            self.name.text = service?.companyName
            self.serviceDescription.text = service?.serviceDescription
            self.contactNumber.text = service?.contactInfo
            self.price.text = service?.askingPrice
        } else {
            self.name.text = request?.userName
            self.serviceDescription.text = request?.serviceDescription
            self.contactNumber.text = request?.contactInfo
            self.price.text = ""
            self.priceLabel.text = ""
        }
 }
    
    @IBAction func submitRating(_ sender: Any) {
        var newRating = 0.0
        if(oldRating == -1){
            newRating = ratingBar.rating
        }else{
            newRating = (ratingBar.rating + oldRating)/2
        }
        setRating(newRating)
    }
    
    func setRating(_ rating: Double){
        let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
        let string = "users/" + (service?.userID)! + "/rating"
        ref.child(string).setValue(rating)
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
