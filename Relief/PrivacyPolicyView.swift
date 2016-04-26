//
//  PrivacyPolicyView.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/26/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation

class PrivacyPolicyView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var privacyPolicyScrollView: UIScrollView!
    
    override func viewDidLoad() {
        privacyPolicyScrollView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        privacyPolicyScrollView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func thankYouButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}