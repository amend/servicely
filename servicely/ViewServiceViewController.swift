//
//  ViewServiceViewController.swift
//  servicely
//
//  Created by Brenda Salazar on 11/20/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class ViewServiceViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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