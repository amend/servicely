//
//  ChangeColorSchemeViewController.swift
//  servicely
//
//  Created by Dana Vaziri on 10/30/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit

class ChangeColorSchemeViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerView.backgroundColor = ColorScheme.getColorScheme()
    }
    
    @IBAction func colorChosen(_ sender: UIButton) {
        let color = sender.backgroundColor
        headerView.backgroundColor = color
        let colorID = Int(sender.titleLabel!.text!)
        ColorScheme.setColorScheme(colorID: colorID!)
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
