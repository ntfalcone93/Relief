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
    
    // User data keys
    
    fileprivate let firstNameKey = "firstName"
    fileprivate let lastNameKey = "lastName"
    fileprivate let identifierKey = "identifier"
    fileprivate let eventIdsKey = "eventIds"
    fileprivate let endpointKey = "endpoint"
    fileprivate let jsonValueKey = "jsonValue"
    fileprivate let blockedIDsKey = "blockedIDs"
    
    // User data declaration
    
    var firstName: String
    var lastName: String?
    var identifier: String?
    var eventIds: [String]
    var blockedUserIDs: [String]
    var endpoint = "users"
    
    // Array conversion
    
    var jsonValue: [String:AnyObject] {
        
        return [firstNameKey: firstName as AnyObject, lastNameKey: lastName as AnyObject? ?? "" as AnyObject, identifierKey: identifier as AnyObject? ?? "" as AnyObject, eventIdsKey: eventIds.toDic() as AnyObject, blockedIDsKey : blockedUserIDs.toDic() as AnyObject]
    }

    // Initialize
    
    init(firstName: String, lastName: String?, identifier: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier
        self.eventIds = []
        self.blockedUserIDs = []
    }
    
    // Initialize json
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let firstName = json[firstNameKey] as? String,
            let lastName = json[lastNameKey] as? String else {
                
                return nil
                
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier
        
        if let blockedDic = json[blockedIDsKey] as? [String : AnyObject] {
            let blockedKeys = Array(blockedDic.keys)
            self.blockedUserIDs = blockedKeys
        } else {
            self.blockedUserIDs = []
        }
        
        if let eventDic = json[eventIdsKey] as? [String : AnyObject]  {
            let eventKeys = Array(eventDic.keys)
            self.eventIds = eventKeys
            
        } else {
            self.eventIds = []
        }
    }
}

// Extension to turn array to firebase dictionary

extension Array {
    func toDic() -> [String : AnyObject] {
        var dicToReturn = [String : AnyObject]()
        for item in self {
            dicToReturn.updateValue(true as AnyObject, forKey: String(describing: item))
        }
        return dicToReturn
    }
}
