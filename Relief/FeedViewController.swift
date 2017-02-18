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
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        if let event = event {
            guard let identifier = event.identifier else { return }
            ThreadController.createThreadWithIdentifier(identifier, delegate: self, completion: { (threadManager) in
                DispatchQueue.main.async(execute: { () -> Void in
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
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let firstName = UserController.sharedInstance.currentUser.firstName
        let lastName = UserController.sharedInstance.currentUser.lastName ?? ""
        chatManager?.messagePosted(messageTextField, username: "- \(firstName.capitalized) \(lastName.capitalized)")
        textFieldShouldReturn(messageTextField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        fakeMessageTextField.resignFirstResponder()
        tableViewScrollToBottom()
        fakeMessageTextField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.messageTextField.becomeFirstResponder()
        realView.isHidden = false
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "Message Text", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
    }
    
    func keyboardShown(_ notification: Notification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        
        messageTextField.becomeFirstResponder()
        
        realView.isHidden = false
        fakeView.isHidden = true
        tableViewConstraint.constant = -keyboardFrame.height
        tableViewScrollToBottom()
    }
    
    func keyboardHidden(_ notification: Notification) {
        tableViewConstraint.constant = -fakeView.frame.height
        realView.isHidden = true
        fakeView.isHidden = false
        messageTextField.text = ""
        fakeMessageTextField.text = ""
        tableViewScrollToBottom()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatManager = chatManager, let userID = UserController.sharedInstance.currentUser.identifier, chatManager.messages[indexPath.row].senderID != userID else { return }
        
        makeAlert(chatManager.messages[indexPath.row].senderID)
    }
    
    func makeAlert(_ identifier: String) {
        let alertController = UIAlertController(title: "Block User?", message: "Blocking a user is permanent", preferredStyle: .alert)
        let alertBlock = UIAlertAction(title: "Block", style: .destructive) { (_) in
            UserController.blockUser(identifier)
            self.navigationController?.popViewController(animated: true)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(alertBlock)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatManager?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatTableViewCell else { return tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)}
        let message = chatManager?.messages[indexPath.row]
        cell.usernameTextLabel?.text = message?.messageBodyText
        cell.userMessageTextLabel?.text = message?.username
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableViewScrollToBottom() {
        guard let count = chatManager?.messages.count else { return }
        guard count > 0 else { return }
        let indexPath = IndexPath(item: count - 1, section: 0)
        tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
