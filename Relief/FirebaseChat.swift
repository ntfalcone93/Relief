//
//  FirebaseChat.swift
//  SimpleChatFirebaseTest
//
//  Created by Jake Hardy on 4/11/16.
//  Copyright © 2016 NSDesert. All rights reserved.
//

import Foundation
import UIKit



class FirebaseChat {
    
    var messages = [Message]()
    
    var delegate: FirebaseChatManager
    var threadID: String
    
    init?(delegate: FirebaseChatManager, threadIdentifier: String) {
        
        self.delegate = delegate
        self.threadID = threadIdentifier
        
        observeChat()
    }
    
    func observeChat() {
        MessageController.observeMessagesForThread(threadID) { (message) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate.insertMessageIntoTableview(message)
            })
        }
    }
    
    func messagePosted(textField: UITextField, username: String) {
        guard let bodyText = textField.text where bodyText.isEmpty == false else { return }
        MessageController.createMessage("1", threadID: threadID, bodyText: bodyText, username: username) { (succes) in
            if succes {
                print("Oh snap Mr. Lewis")
                // Change this function - complete with success bool param
            }
        }
    }
}


protocol FirebaseChatManager {
    
    var chatManager: FirebaseChat? { get }
    weak var tableview: UITableView! { get }
    weak var messageTextField: UITextField! { get }
    
    func insertMessageIntoTableview(message: Message)
    
}

extension FirebaseChatManager {
    
    func insertMessageIntoTableview(message: Message) {
        guard let chatManager = self.chatManager else { return }
        chatManager.messages.append(message)
        
        tableview.beginUpdates()
        let indexPath = NSIndexPath(forRow: chatManager.messages.count - 1, inSection: 0)
        tableview.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableview.endUpdates()
    }
    
    
}