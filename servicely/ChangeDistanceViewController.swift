//
//  ChangeDistanceViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 1/5/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import UIKit

class ChangeDistanceViewController: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        let defaults = UserDefaults.standard
        let dist = defaults.integer(forKey: "distance")
        
        self.distanceLabel.text = String(dist) + " miles"
        self.distanceSlider.value = Float(dist)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let defaults = UserDefaults.standard
        defaults.set(Int(self.distanceSlider.value), forKey: "distance")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        self.distanceLabel.text = String(Int(self.distanceSlider.value)) + " miles"
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
