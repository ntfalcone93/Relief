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
    // MARK: - IBOutlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var tapGetureRecognizer: UITapGestureRecognizer!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    var logInModeActivate = true
    
    // MARK: - IBActions
    @IBAction func loginButtobTapped(sender: UIButton) {
        if logInModeActivate {
            login()
        } else {
            signUp()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: "UIKeyboardWillHideNotificatin", object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardDidHideNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    func keyboardWasShown(notification:NSNotification) {
        if let info = notification.userInfo! as? NSDictionary {
            let keyboardSize: CGSize = (info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue().size)!
            let buttonOrigin: CGPoint = self.logInButton.frame.origin
            let buttonHeight: CGFloat = self.logInButton.frame.size.height
            let pixelsAboveKeyboard: CGFloat = 25
            var visibleRect: CGRect = self.view.frame
            visibleRect.size.height -= keyboardSize.height
            if !CGRectContainsPoint(visibleRect, buttonOrigin) {
                let scrollPoint: CGPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + pixelsAboveKeyboard)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification:NSNotification) {
        self.scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.emailTextField {
            self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        } else if textField == self.passwordTextField {
            self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        } else if textField == self.firstNameTextField {
            self.firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        } else if textField == self.lastNameTextField {
            self.lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        }
    }
    
    func signUp() {
        // sign up logic
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        guard let firstName = firstNameTextField.text where firstName.isEmpty == false else { return }
        let lastName = lastNameTextField.text ?? ""
        UserController.createUser(firstName, lastName: lastName, email: email, password: password) { (success, user) in
            if success {
                UserController.sharedInstance.currentUser = user
                GeoFireController.queryAroundMe()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func login() {
        // Log in logic
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        FirebaseController.firebase.authUser(email, password: password, withCompletionBlock: { (error, fAuthData) -> Void in
            if error != nil {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch errorCode {
                    case .UserDoesNotExist:
                        self.makeAlert("User Does Not Exist")
                    case FAuthenticationError.InvalidPassword:
                        self.makeAlert("Invalid Password")
                    case FAuthenticationError.InvalidEmail:
                        self.makeAlert("Invalid Email")
                    default:
                        self.makeAlert("Unkown Error, Try Again")
                    }
                }
            } else {
                let uniqueUserID = fAuthData.uid
                UserController.fetchUserWithId(uniqueUserID, completion: { (user) in
                    if let user = user {
                        UserController.sharedInstance.currentUser = user
                        GeoFireController.queryAroundMe()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        })
    }
    
    func toggleViewBasedOnViewMode() {
        if logInModeActivate {
            logInModeActivate = false
            viewForSignUp()
        } else {
            logInModeActivate = true
            viewForLogin()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func viewForLogin() {
        firstNameTextField.hidden = true
        lastNameTextField.hidden = true
        logInButton.setTitle("Login", forState: .Normal)
        createAccountButton.setTitle("Create Account", forState: .Normal)
    }
    
    func viewForSignUp() {
        firstNameTextField.hidden = false
        lastNameTextField.hidden = false
        logInButton.setTitle("Sign Up", forState: .Normal)
        createAccountButton.setTitle("Already have an account?", forState: .Normal)
    }
    
    @IBAction func createAccountButtonTapped(sender: UIButton) {
        toggleViewBasedOnViewMode()
    }
    
    func makeAlert(warningMessage: String) {
        let alertViewController = UIAlertController(title: "Error!", message: warningMessage, preferredStyle: .Alert)
        let alert = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertViewController.addAction(alert)
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewForLogin()
        self.firstNameTextField.becomeFirstResponder()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.deregisterFromKeyboardNotifications()
        super.viewWillDisappear(true)
    }
    
    func dismissKeyboards() {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.tapGetureRecognizer.cancelsTouchesInView = true
        self.tapGetureRecognizer.addTarget(self, action: #selector(self.dismissKeyboards))
        self.view.addGestureRecognizer(self.tapGetureRecognizer)
        self.configureViewElements()
    }
    
    func configureViewElements() {
        self.logInButton.setBackgroundImage(UIImage.init(named: "login"), forState: UIControlState.Normal)
        self.logInButton.tintColor = UIColor.reliefBlack()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toForgotPassword" {
            let destinationViewController = segue.destinationViewController
            destinationViewController.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
    @IBAction func buttonToPrivacyPolicy(sender: AnyObject) {
        performSegueWithIdentifier("toPrivacyPolicy", sender: sender)
    }
    
}