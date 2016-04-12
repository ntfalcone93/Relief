//
//  Event.swift
//  Relief
//
//  Created by Nathan on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

enum EventType: String {
    case Epidemic
    case AnimalAndInsectInfestation
    case Earthquakes
    case DryMassMovement
    case Tsunamis
    case VolcanicEruptions
    case Drought
    case ExtremeTemperatues
    case WildfiresAndUrbanFires
    case Floods
    case WetMassMovement
    case TropicalStormsHurricanesTyphoonsAndCyclones
    case StormsAndTidalWaves
    case IndustrialAccidents
    case TransportAccidents
    case ComplexEmergencies
    case FamineOrFoodInsecurity
    case DisplacedPopulations
}

class Event {
    
    private let titleKey = "title"
    private let collectionPointKey = "collectionPoint"
    private let memberCountKey = "memberCount"
    private let needsKey = "memberCount"
    private let identifierKey = "identifier"
    private let endpointKey = "endpoint"
    private let jsonValueKey = "jsonValue"
    private let eventTypeKey = "eventTypeKey"
    
    var title: String
    var collectionPoint: String
    var memberCount: Int
    var needs: [String]
    var identifier: String?
    var endpoint = "events"
    var type: EventType.RawValue
    
    var jsonValue: [String:AnyObject] {

        return [titleKey: title, eventTypeKey: type, collectionPointKey: collectionPoint, memberCountKey: memberCount, needsKey: needs.toDic()]
    
    }
    
    init(title: String, collectionPoint: String, memberCount: Int, needs: [String], identifier: String?, endpoint: String, eventType: EventType) {
    self.title = title
    self.collectionPoint = collectionPoint
    self.memberCount = memberCount
    self.needs = needs
    self.identifier = identifier
    self.endpoint = endpoint
    self.type = eventType.rawValue
    }
    
    
    init?(dictionary: Dictionary<String, AnyObject>) {
    guard let title = dictionary[titleKey] as? String,
    let collectionPoint = dictionary[collectionPointKey] as? String,
    let memberCount = dictionary[memberCountKey] as? Int,
    let needs = dictionary[needsKey] as? [String],
    let endpoint = dictionary[endpointKey] as? String,
    let eventType = dictionary[eventTypeKey] as? String else {
    
    return nil
    
    }
    
    self.title = title
    self.collectionPoint = collectionPoint
    self.memberCount = memberCount
    self.endpoint = endpoint
    self.needs = needs
    self.type = eventType
    
    }
    
    init(title: String, type: EventType, collectionPoint: String) {
    self.title = title
    self.type = type.rawValue
    self.collectionPoint = collectionPoint
    self.memberCount = 1
    self.needs = []
    self.identifier = nil
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
