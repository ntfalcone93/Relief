//
//  Event.swift
//  Relief
//
//  Created by Nathan on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

enum Type {
    case
    
}

class Event {
    
    private let titleKey = "title"
    private let collectionPointKey = "collectionPoint"
    private let memberCountKey = "memberCount"
    private let needsKey = "memberCount"
    private let identifierKey = "identifier"
    private let endpointKey = "endpoint"
    private let jsonValueKey = "jsonValue"
    
    var title: String
    var collectionPoint: String
    var memberCount: Int
    var needs: [String]
    var identifier: String?
    var endpoint: String
    var jsonValue: [String:AnyObject]

    init(title: String, collectionPoint: String, memberCount: Int, needs: [String], identifier: String?, endpoint: String, jsonValue: [String: AnyObject]) {
        self.title = title
        self.collectionPoint = collectionPoint
        self.memberCount = memberCount
        self.needs = needs
        self.identifier = identifier
        self.endpoint = endpoint
        self.jsonValue = jsonValue
    }


    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let title = dictionary[titleKey] as? String,
            let collectionPoint = dictionary[collectionPointKey] as? String,
            let memberCount = dictionary[memberCountKey] as? Int,
            let endpoint = dictionary[endpointKey] as? String else {

                return nil
                
        }
        
        self.title = ""
        self.collectionPoint = ""
        self.memberCount = memberCount
        self.endpoint = ""
        
    }
    
    init(title: String, type: Type, collectionPoint: String) {
        self.title = title
        
        self.collectionPoint = collectionPoint

}
}