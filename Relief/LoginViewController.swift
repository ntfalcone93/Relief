//
//  LoginViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var tapGetureRecognizer: UITapGestureRecognizer!
    
    var logInModeActivate = true
    
    // MARK: - IBActions
    @IBAction func loginButtobTapped(sender: UIButton) {
        // check fields
        // authuser
        // handle errors
        // set Current User
        // dismiss view in completion
        if logInModeActivate {
            login()
        } else {
            signUp()
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(sender: AnyObject) {
        
        
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
        createAccountButton.setTitle("Log In", forState: .Normal)
        
    }
    
    @IBAction func createAccountButtonTapped(sender: UIButton) {
        toggleViewBasedOnViewMode()
    }
    
    @IBAction func forgotButtonTapped(sender: UIButton) {
        
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
    }
    
    func dismissKeyboards() {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapGetureRecognizer.cancelsTouchesInView = true
        self.tapGetureRecognizer.addTarget(self, action: #selector(self.dismissKeyboards))
        self.view.addGestureRecognizer(self.tapGetureRecognizer)
    }
    
}