//
//  ForgotPasswordViewController.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/20/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var resetPasswordButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.configureViewElements()
    }
    
    // Forgot Password UI
    
    func configureViewElements() {
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.resetPasswordButton.tintColor = UIColor.reliefYellow()
        self.cancelButton.tintColor = UIColor.reliefYellow()
    }
    
    // Text field editing
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    // Text field containing entered text will return
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Text field editing finished
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        }
    }
    
    //Button to reset password through firebase
    
    @IBAction func recoverPasswordButtonTapped(_ sender: AnyObject) {
        let email = emailTextField.text ?? ""
        let ref = Firebase(url:"devmtnrelief.firebaseIO.com")
        ref?.resetPassword(forUser: email, withCompletionBlock: { (error) in
            if error != nil {
                let noEmailAlert = UIAlertController(title: "Email does not exist", message: "It seems there is no such Email in our database, please try again.", preferredStyle: UIAlertControllerStyle.alert)
                noEmailAlert.addAction(UIAlertAction(title: "try Again", style: UIAlertActionStyle.default, handler: nil))
                self.present(noEmailAlert, animated: true, completion: nil)
            } else {
                let passwordResetAlert = UIAlertController(title: "Password Reset", message: "Please check your email", preferredStyle: UIAlertControllerStyle.alert)
                passwordResetAlert.addAction(UIAlertAction(title: "Go to Login", style:  UIAlertActionStyle.cancel, handler: { action in self.dismiss(animated: true, completion: nil)
                }))
                self.present(passwordResetAlert, animated: true, completion: nil)
                return
            }
        })
    }
    
    // Cancel forgot password button
    
    @IBAction func cancelForgotPasswordTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
