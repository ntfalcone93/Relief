//
//  RevealViewController.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

class RevealViewController: SWRevealViewController {
<<<<<<< HEAD
    override func viewDidLoad() {
        super.viewDidLoad()
=======
    
    override func viewDidLoad() {
        super.viewDidLoad()

>>>>>>> develop
        if UserController.sharedInstance.currentUser == nil {
            performSegueWithIdentifier("presentLoginViewController", sender: nil)
        }
    }
    
}