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
    @IBAction func loginButtobTapped(_ sender: UIButton) {
        if logInModeActivate {
            login()
        } else {
            signUp()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotificatin"), object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardDidHideNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }
    
    func keyboardWasShown(_ notification:Notification) {
        if let info = notification.userInfo! as? NSDictionary? {
            let keyboardSize: CGSize = ((info!.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size)
            let buttonOrigin: CGPoint = self.logInButton.frame.origin
            let buttonHeight: CGFloat = self.logInButton.frame.size.height
            let pixelsAboveKeyboard: CGFloat = 25
            var visibleRect: CGRect = self.view.frame
            visibleRect.size.height -= keyboardSize.height
            if !visibleRect.contains(buttonOrigin) {
                let scrollPoint: CGPoint = CGPoint(x: 0.0, y: buttonOrigin.y - visibleRect.size.height + buttonHeight + pixelsAboveKeyboard)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification:Notification) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        guard let firstName = firstNameTextField.text, firstName.isEmpty == false else { return }
        let lastName = lastNameTextField.text ?? ""
        UserController.createUser(firstName, lastName: lastName, email: email, password: password) { (success, user) in
            if success {
                UserController.sharedInstance.currentUser = user
                GeoFireController.queryAroundMe()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func login() {
        // Log in logic
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        FirebaseController.firebase?.authUser(email, password: password, withCompletionBlock: { (error, fAuthData) -> Void in
            if error != nil {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch errorCode {
                    case .userDoesNotExist:
                        self.makeAlert("User Does Not Exist")
                    case FAuthenticationError.invalidPassword:
                        self.makeAlert("Invalid Password")
                    case FAuthenticationError.invalidEmail:
                        self.makeAlert("Invalid Email")
                    default:
                        self.makeAlert("Unkown Error, Try Again")
                    }
                }
            } else {
                let uniqueUserID = fAuthData?.uid
                UserController.fetchUserWithId(uniqueUserID!, completion: { (user) in
                    if let user = user {
                        UserController.sharedInstance.currentUser = user
                        GeoFireController.queryAroundMe()
                        self.dismiss(animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func viewForLogin() {
        firstNameTextField.isHidden = true
        lastNameTextField.isHidden = true
        logInButton.setTitle("Login", for: UIControlState())
        createAccountButton.setTitle("Create Account", for: UIControlState())
    }
    
    func viewForSignUp() {
        firstNameTextField.isHidden = false
        lastNameTextField.isHidden = false
        logInButton.setTitle("Sign Up", for: UIControlState())
        createAccountButton.setTitle("Already have an account?", for: UIControlState())
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        toggleViewBasedOnViewMode()
    }
    
    func makeAlert(_ warningMessage: String) {
        let alertViewController = UIAlertController(title: "Error!", message: warningMessage, preferredStyle: .alert)
        let alert = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertViewController.addAction(alert)
        present(alertViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewForLogin()
        self.firstNameTextField.becomeFirstResponder()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        self.logInButton.setBackgroundImage(UIImage.init(named: "login"), for: UIControlState())
        self.logInButton.tintColor = UIColor.reliefBlack()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.firstNameTextField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.lastNameTextField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toForgotPassword" {
            let destinationViewController = segue.destination
            destinationViewController.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
    @IBAction func buttonToPrivacyPolicy(_ sender: AnyObject) {
        performSegue(withIdentifier: "toPrivacyPolicy", sender: sender)
    }
    
}
