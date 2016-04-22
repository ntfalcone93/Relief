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
        
        messageTextField.delegate = self
        fakeMessageTextField.delegate = self
        
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
    
    // MARK: - IBActions
    @IBAction func sendButtonTapped(sender: UIButton) {
        let firstName = UserController.sharedInstance.currentUser.firstName
        let lastName = UserController.sharedInstance.currentUser.lastName ?? ""
        chatManager?.messagePosted(messageTextField, username: "\(firstName)\(lastName)")
        textFieldShouldReturn(messageTextField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fakeMessageTextField.resignFirstResponder()
        tableViewScrollToBottom()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.messageTextField.becomeFirstResponder()
        realView.hidden = false
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
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatManager?.messages.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath) as? ChatTableViewCell else { return tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)}
        let message = chatManager?.messages[indexPath.row]
        cell.usernameTextLabel?.text = message?.username
        cell.userMessageTextLabel?.text = message?.messageBodyText
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
