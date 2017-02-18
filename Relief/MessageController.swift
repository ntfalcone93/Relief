//
//  MessageController.swift
//  SimpleChatFirebaseTest
//
//  Created by Jake Hardy on 4/11/16.
//  Copyright © 2016 NSDesert. All rights reserved.
//

import Foundation

class MessageController {
    
    static func createMessage(_ senderID: String,threadID: String, bodyText: String, username: String, completion: (_ success: Bool) -> Void) {
        
        var message = Message(senderID: senderID, threadID: threadID, username: username, messageBodyText: bodyText, identifier: nil)
        message.save()
        
        completion(true)
    }
    
    static func observeMessagesForThread(_ threadIdentifier: String, completion: @escaping (_ message: Message) -> Void) {
        FirebaseController.observeChildAtEndPoint("\(messageEndPoint)/\(threadIdentifier)", completion: { (data) in
            guard let data = data as? [String : AnyObject] else { return }
            print(data)
            
            guard let identifier = data[IDENTIFIER_KEY] as? String else { return  }
            guard let message = Message(json: data, identifier: identifier) else { return }
            
            completion(message)
            
        })
    }
}
