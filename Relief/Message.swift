//
//  Message.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

class Message {
    
    private let senderNameKey = "senderName"
    private let senderIdKey = "senderId"
    private let textKey = "text"
    private let identifierKey = "identifier"
    private let endpointKey = "endpoint"
    private let jsonValueKey = "jsonValue"
    
    var senderName: String
    var senderId: String
    var text: String
    var identifier: String?
    var endpoint = "message"
    
    var jsonValue: [String: AnyObject] {
        guard let unwrappedIdentifier as? String {
            
                else {

        return [senderNameKey: senderName, senderIdKey: senderId, textKey: text, identifierKey: unwrappedIdentifier]

    } else {
    
    return [senderNameKey: senderName, senderIdKey: senderId, textKey: text]
    
    }
        
    }
    
    }
    
    
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let senderName = dictionary[senderNameKey] as? String,
            let senderId = dictionary[senderIdKey] as? String,
            let text = dictionary[textKey] as? String,
            let identifier = dictionary[identifierKey] as? String,
            let endpoint = dictionary[endpointKey] as? String else {
                
                return nil
        }
        
        self.senderName = senderName
        self.senderId = senderId
        self.text = text
        self.identifier = identifier
        self.endpoint = endpoint
        
    }
    
    init(senderName: String, senderId: String, text: String, identifier: String?, endpoint: String) {
        
        self.senderName = senderName
        self.senderId = senderId
        self.text = text
        self.identifier = identifier
        self.endpoint = endpoint
        
    }
        
}