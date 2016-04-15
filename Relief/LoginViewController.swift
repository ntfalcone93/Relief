//
//  LoginViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let base = Firebase(url: "devmtnrelief.firebaseIO.com")
    
    // MARK: - IBOutlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
         super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func createUserButtonTapped(sender: AnyObject) {
        
        if let email = emailTextField.text,
            password = passwordTextField.text
            where email.characters.contains("@") && password.characters.count > 5 {
            
            base.createUser(email, password: password, withValueCompletionBlock: { (error, result) -> Void in
                if let error = error {
                    print("Could not create User due to error\(error.localizedDescription)")
                } else {
                    if let identifier = result["identifier"] {
                        UIAlertControllerStyle.
                    }
                }
            })
        }
    }

    @IBAction func logInButtonTapped(sender: AnyObject) {
    }
}

    func dismissModalViewControllerAnimated(animated: Bool) {
        if UserController.sharedInstance.currentUser != nil{
            dismissModalViewControllerAnimated(true)
        }

    }
}