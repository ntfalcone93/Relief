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
    
    func configureViewElements() {
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.resetPasswordButton.tintColor = UIColor.reliefYellow()
        self.cancelButton.tintColor = UIColor.reliefYellow()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == emailTextField {
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        }
    }
    
    @IBAction func recoverPasswordButtonTapped(sender: AnyObject) {
        let email = emailTextField.text ?? ""
        let ref = Firebase(url:"devmtnrelief.firebaseIO.com")
        ref.resetPasswordForUser(email, withCompletionBlock: { (error) in
            if error != nil {
                let noEmailAlert = UIAlertController(title: "Email does not exist", message: "It seems there is no such Email in our database, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                noEmailAlert.addAction(UIAlertAction(title: "try Again", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(noEmailAlert, animated: true, completion: nil)
            } else {
                let passwordResetAlert = UIAlertController(title: "Password Reset", message: "Please check your email", preferredStyle: UIAlertControllerStyle.Alert)
                passwordResetAlert.addAction(UIAlertAction(title: "Go to Login", style:  UIAlertActionStyle.Cancel, handler: { action in self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(passwordResetAlert, animated: true, completion: nil)
                return
            }
        })
    }
    
    @IBAction func cancelForgotPasswordTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}