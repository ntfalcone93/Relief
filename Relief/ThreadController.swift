//
//  ThreadController.swift
//  SimpleChatFirebaseTest
//
//  Created by Jake Hardy on 4/11/16.
//  Copyright © 2016 NSDesert. All rights reserved.
//

import Foundation
import UIKit

class ThreadController {
    
    static func createThread(_ threadName: String, delegate: FirebaseChatManager, completion: (_ thread: Thread, _ threadManager: FirebaseChat?) -> Void) {
        var thread = Thread(threadName: threadName)
        thread.save()
        
        guard let currentThreadID = thread.identifier else { return }
        let chatManager = FirebaseChat(delegate: delegate, threadIdentifier: currentThreadID)
        
        completion(thread, chatManager)
    }
    
    // Creates a chat at an endpoint specified by a user. Consolidates endpoints (Used for Relief April 12, 2016)
    static func createThreadWithIdentifier(_ threadIdentifier: String, delegate: FirebaseChatManager, completion: (_ threadManager: FirebaseChat?) -> Void) {
        
        let threadManager = FirebaseChat(delegate: delegate, threadIdentifier: threadIdentifier)
        
        completion(threadManager)
    }
    
}
