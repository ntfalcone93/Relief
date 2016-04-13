//
//  Message.swift
//  SimpleChatFirebaseTest
//
//  Created by Jake Hardy on 4/11/16.
//  Copyright © 2016 NSDesert. All rights reserved.
//

import Foundation

class Message: FirebaseType {
    
    var username: String
    var messageBodyText: String
    
    var identifier: String?
    var threadID: String
    
    var endpoint = messageEndPoint
    
    var jsonValue: [String : AnyObject] {
        get {
            return [
                USERNAME_KEY : username,
                MESSAGE_TEXT_KEY : messageBodyText,
                THREAD_KEY : threadID,
                IDENTIFIER_KEY : identifier ?? ""
                
            ]
        }
    }
    
    init(threadID: String, username: String, messageBodyText: String, identifier: String?) {
        self.username = username
        self.messageBodyText = messageBodyText
        self.identifier = identifier
        self.threadID = threadID
        self.endpoint = "\(messageEndPoint)/\(threadID)"
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let messageBodyText = json[MESSAGE_TEXT_KEY] as? String else { return nil }
        guard let username = json[USERNAME_KEY] as? String else { return nil }
        guard let threadID = json[THREAD_KEY] as? String else { return nil }
        
        self.threadID = threadID
        self.endpoint = "\(messageEndPoint)/\(threadID)"
        self.messageBodyText = messageBodyText
        self.username = username
        self.identifier = identifier
        
    }
    
}