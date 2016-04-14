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
    case AnimalAndInsectInfestation = "Animal And Insect Infestation"
    case Earthquakes
    case DryMassMovement = "Dry Mass Movement"
    case Tsunamis
    case VolcanicEruptions = "Volcanic Eruptions"
    case Drought
    case ExtremeTemperatues = "Extreme Temperatures"
    case WildfiresAndUrbanFires = "Wild Fires And Urban Fires"
    case Floods
    case WetMassMovement = "Wet Mass Movement"
    case TropicalStormsHurricanesTyphoonsAndCyclones = "Tropical Storms Hurricane Typhoons And Cyclones"
    case StormsAndTidalWaves = "Storms And Tidal Waves"
    case IndustrialAccidents = "Industrial Accidents"
    case TransportAccidents = "Transport Accidents"
    case ComplexEmergencies = "Complex Emergencies"
    case FamineOrFoodInsecurity = "Famine Or Food Insecurity"
    case DisplacedPopulations = "Displaced Populations"
}

class Event {
    
    private let titleKey = "title"
    private let collectionPointKey = "collectionPoint"
    private let membersKey = "memberCount"
    private let needsKey = "memberCount"
    private let identifierKey = "identifier"
    private let endpointKey = "endpoint"
    private let jsonValueKey = "jsonValue"
    private let eventTypeKey = "eventTypeKey"
    
    var title: String
    var collectionPoint: String
    var members = [String]()
    var needs: [String]
    var identifier: String?
    var endpoint = "events"
    var type: EventType.RawValue
    
    var jsonValue: [String:AnyObject] {
        
        return [titleKey: title, eventTypeKey: type, collectionPointKey: collectionPoint, membersKey: members.toDic(), needsKey: needs.toDic()]
        
    }
    
    init(title: String, collectionPoint: String, members: [String], needs: [String], identifier: String?, endpoint: String, eventType: EventType) {
        self.title = title
        self.collectionPoint = collectionPoint
        self.members = members
        self.needs = needs
        self.identifier = identifier
        self.endpoint = endpoint
        self.type = eventType.rawValue
    }
    
    
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let title = dictionary[titleKey] as? String,
            let collectionPoint = dictionary[collectionPointKey] as? String,
            let members = dictionary[membersKey] as? [String],
            let needs = dictionary[needsKey] as? [String],
            let endpoint = dictionary[endpointKey] as? String,
            let eventType = dictionary[eventTypeKey] as? String else {
                
                return nil
                
        }
        
        self.title = title
        self.collectionPoint = collectionPoint
        self.members = members
        self.endpoint = endpoint
        self.needs = needs
        self.type = eventType
        
    }
    
    init(title: String, type: EventType, collectionPoint: String) {
        self.title = title
        self.type = type.rawValue
        self.collectionPoint = collectionPoint
        self.needs = []
        self.identifier = nil
    }
}
