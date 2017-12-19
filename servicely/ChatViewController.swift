//
//  ChatViewController.swift
//  servicely
//
//  Created by Andoni Mendoza on 12/18/17.
//  Copyright © 2017 Andoni Mendoza. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    var providerID = ""
    var clientID = ""
    var providerName = ""
    var clientName = ""
    var timestamp = ""
    var threadID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // TODO: look up why JSQMessagesViewController requires these
        self.senderId = "1234"
        self.senderDisplayName = "TEST"
        
        //self.navigationItem.title = "Example Name"
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
