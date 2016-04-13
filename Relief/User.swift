//
//  User.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    private let identifierKey = "identifier"
    private let eventIdsKey = "eventIds"
    private let endpointKey = "endpoint"
    private let jsonValueKey = "jsonValue"
    
    var firstName: String
    var lastName: String?
    var identifier: String?
    var eventIds: [String]
    var endpoint = "events"
    
    var jsonValue: [String:AnyObject] {
        
        let unwrappedLastName = lastName
        let unwrappedIdentifier = identifier {
            if identifier = String {
            
            return [firstNameKey: firstName, identifierKey: unwrappedIdentifier, eventIdsKey: eventIds.toDic()]
        
            } else if unwrappedLastName = String {
        
        return [firstNameKey: firstName, lastNameKey: lastName, identifierKey: unwrappedIdentifier, eventIdsKey: eventIds.toDic()]
        
        }
    }
}
    
    init(firstName: String, lastName: String?, identifier: String, eventIds: [String], endpoint: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier
        self.eventIds = eventIds
        self.endpoint = endpoint
    }
    
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let firstName = dictionary[firstNameKey] as? String,
            let lastName = dictionary[lastNameKey] as? String,
            let identifier = dictionary[identifierKey] as? String,
            let eventIds = dictionary[eventIdsKey] as? [String],
            let endpoint = dictionary[endpointKey] as? String else {
                
                return nil
                
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier
        self.eventIds = eventIds
        self.endpoint = endpoint
    }
}

extension Array {
    func toDic() -> [String : AnyObject] {
        var dicToReturn = [String : AnyObject]()
        for item in self {
            dicToReturn.updateValue(true, forKey: String(item))
        }
        return dicToReturn
    }
}