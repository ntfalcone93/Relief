//
//  Event.swift
//  Relief
//
//  Created by Nathan on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import UIKit

// Disaster/Event Types

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

// Disaster/Event type keys

class Event {
    fileprivate let titleKey = "title"
    fileprivate let collectionPointKey = "collectionPoint"
    fileprivate let membersKey = "member"
    fileprivate let needsKey = "needs"
    fileprivate let identifierKey = "identifier"
    fileprivate let endpointKey = "endpoint"
    fileprivate let jsonValueKey = "jsonValue"
    fileprivate let eventTypeKey = "eventType"
    fileprivate let latitudeKey = "latitude"
    fileprivate let longitudeKey = "longitude"
    
    // Declarations
    
    var title: String
    var collectionPoint: String
    var members = [String]()
    var needs: [String]
    var identifier: String?
    var endpoint = "events"
    var type: EventType.RawValue
    var latitude: Double
    var longitude: Double
    
    // Convert to Array
    
    var jsonValue: [String:AnyObject] {
        return [titleKey: title as AnyObject, eventTypeKey: type as AnyObject, collectionPointKey: collectionPoint as AnyObject, membersKey: members.toDic() as AnyObject, needsKey: needs.toDic() as AnyObject, latitudeKey : latitude as AnyObject, longitudeKey : longitude as AnyObject]
    }
    
    // Initialize json
    
    init(title: String, collectionPoint: String, members: [String], needs: [String], identifier: String?, endpoint: String, eventType: EventType, latitude: Double, longitude: Double) {
        self.title = title
        self.collectionPoint = collectionPoint
        self.members = members
        self.needs = needs
        self.identifier = identifier
        self.endpoint = endpoint
        self.type = eventType.rawValue
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Dictionary with keys
    
    init?(dictionary: Dictionary<String, AnyObject>, identifier: String) {
        guard let title = dictionary[titleKey] as? String,
            let collectionPoint = dictionary[collectionPointKey] as? String,
            let eventType = dictionary[eventTypeKey] as? String,
            let longitude = dictionary[longitudeKey] as? Double,
            let latitude = dictionary[latitudeKey] as? Double else {
                return nil
        }
        if let members = dictionary[membersKey] as? [String: Bool] {
            self.members = []
            for member in members {
                self.members.append(member.0)
            }
        } else {
            self.members = []
        }
        if let needs = dictionary[needsKey] as? [String: Bool] {
            self.needs = []
            for need in needs {
                self.needs.append(need.0)
            }
        } else {
            self.needs = []
        }
        self.title = title
        self.collectionPoint = collectionPoint
        self.type = eventType
        self.latitude = latitude
        self.longitude = longitude
        self.identifier = identifier
    }
    
    init(title: String, type: EventType, collectionPoint: String, latitude: Double, longitude: Double) {
        self.title = title
        self.type = type.rawValue
        self.collectionPoint = collectionPoint
        self.needs = []
        self.longitude = longitude
        self.latitude = latitude
        self.identifier = nil
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.identifier == rhs.identifier
}



