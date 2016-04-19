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
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    var event: Event?
    var chatManager: FirebaseChat?
    
    override func viewDidLoad() {
        messageTextField.delegate = self
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
        chatManager?.messagePosted(messageTextField, username: "\(firstName) \(lastName)")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatManager?.messages.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)
        let message = chatManager?.messages[indexPath.row]
        
        cell.textLabel?.text = message?.messageBodyText
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
