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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserController.sharedInstance.currentUser == nil {
            performSegueWithIdentifier("presentLoginViewController", sender: nil)
        }
    }
    
}