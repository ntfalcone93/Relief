//
//  RevealViewController.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

// Login screen presented or not presented dependant on if user has logged in

class RevealViewController: SWRevealViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserController.sharedInstance.currentUser == nil {
            performSegue(withIdentifier: "presentLoginViewController", sender: nil)
        }
    }
    
}
