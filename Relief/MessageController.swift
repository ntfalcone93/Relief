//
//  MessageController.swift
//  SimpleChatFirebaseTest
//
//  Created by Jake Hardy on 4/11/16.
//  Copyright © 2016 NSDesert. All rights reserved.
//

import Foundation

class MessageController {
    
    static func createMessage(threadID: String, bodyText: String, username: String, completion: (success: Bool) -> Void) {
        
//        var message = Message(senderName: username, senderId: <#T##String#>, text: <#T##String#>, identifier: <#T##String?#>, endpoint: <#T##String#>)
//        message.save()
        
        completion(success: true)
    }
    
    static func observeMessagesForThread(threadIdentifier: String, completion: (message: Message) -> Void) {
        FirebaseController.observeChildAtEndPoint("\(messageEndPoint)/\(threadIdentifier)", completion: { (data) in
            guard let data = data as? [String : AnyObject] else { return }
            print(data)
            
            guard let identifier = data[IDENTIFIER_KEY] as? String else { return  }
//            guard let message = Message(json: data, identifier: identifier) else { return }
            
//            completion(message: message)
            
        })
    }
}