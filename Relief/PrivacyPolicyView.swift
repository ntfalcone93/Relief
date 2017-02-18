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
    
    override func viewDidAppear(_ animated: Bool) {
        privacyPolicyScrollView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func thankYouButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
