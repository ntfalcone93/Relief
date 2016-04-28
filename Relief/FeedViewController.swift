//
//  FeedViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, FirebaseChatManager, UITextFieldDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var fakeMessageTextField: UITextField!
    @IBOutlet weak var fakeSendButton: UIButton!
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet var realView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var realSendButton: UIButton!
    
    var event: Event?
    var chatManager: FirebaseChat?
    
    override func viewDidLoad() {
        fakeMessageTextField.inputAccessoryView = realView
        tableview.delegate = self
        messageTextField.delegate = self
        fakeMessageTextField.delegate = self
        configureViewElements()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.keyboardShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.keyboardHidden(_:)), name: UIKeyboardDidHideNotification, object: nil)
        
        if let event = event {
            guard let identifier = event.identifier else { return }
            ThreadController.createThreadWithIdentifier(identifier, delegate: self, completion: { (threadManager) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.chatManager = threadManager
                })
            })
        }
    }
    
    func configureViewElements() {
        self.fakeSendButton.tintColor = UIColor.reliefYellow()
        self.realSendButton.tintColor = UIColor.reliefYellow()
        self.messageTextField.tintColor = UIColor.reliefPlaceHolderYellow()
        self.messageTextField.tintColor = UIColor.reliefPlaceHolderYellow()
        messageTextField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        fakeMessageTextField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
    }
    
    // MARK: - IBActions
    @IBAction func sendButtonTapped(sender: UIButton) {
        let firstName = UserController.sharedInstance.currentUser.firstName
        let lastName = UserController.sharedInstance.currentUser.lastName ?? ""
        chatManager?.messagePosted(messageTextField, username: "- \(firstName.capitalizedString) \(lastName.capitalizedString)")
        textFieldShouldReturn(messageTextField)
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fakeMessageTextField.resignFirstResponder()
        tableViewScrollToBottom()
        fakeMessageTextField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.messageTextField.becomeFirstResponder()
        realView.hidden = false
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        messageTextField.becomeFirstResponder()
        
        realView.hidden = false
        fakeView.hidden = true
        tableViewConstraint.constant = -keyboardFrame.height
        tableViewScrollToBottom()
    }
    
    func keyboardHidden(notification: NSNotification) {
        tableViewConstraint.constant = -fakeView.frame.height
        realView.hidden = true
        fakeView.hidden = false
        messageTextField.text = ""
        fakeMessageTextField.text = ""
        tableViewScrollToBottom()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let chatManager = chatManager, userID = UserController.sharedInstance.currentUser.identifier where chatManager.messages[indexPath.row].senderID != userID else { return }
        
        makeAlert(chatManager.messages[indexPath.row].senderID)
    }
    
    func makeAlert(identifier: String) {
        let alertController = UIAlertController(title: "Block User?", message: "Blocking a user is permanent", preferredStyle: .Alert)
        let alertBlock = UIAlertAction(title: "Block", style: .Destructive) { (_) in
            UserController.blockUser(identifier)
            self.navigationController?.popViewControllerAnimated(true)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alertController.addAction(alertBlock)
        alertController.addAction(alertCancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toEvent" {
            let destinationViewController = segue.destinationViewController as! EventViewController
            destinationViewController.event = event
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatManager?.messages.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as? ChatTableViewCell else { return tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)}
        let message = chatManager?.messages[indexPath.row]
        cell.usernameTextLabel?.text = message?.messageBodyText
        cell.userMessageTextLabel?.text = message?.username
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableViewScrollToBottom() {
        guard let count = chatManager?.messages.count else { return }
        guard count > 0 else { return }
        let indexPath = NSIndexPath(forItem: count - 1, inSection: 0)
        tableview.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
