//
//  User.swift
//  Relief
//
//  Created by Kaelin Osmun on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

class User: FirebaseType {
    
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
        
        return [firstNameKey: firstName, lastNameKey: lastName ?? "", identifierKey: identifier ?? "", eventIdsKey: eventIds.toDic()]
    }

    init(firstName: String, lastName: String?, identifier: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier
        self.eventIds = []
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let firstName = json[firstNameKey] as? String,
            let lastName = json[lastNameKey] as? String,
            let eventIds = json[eventIdsKey] as? [String],
            let endpoint = json[endpointKey] as? String else {
                
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