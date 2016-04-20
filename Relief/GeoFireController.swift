//
//  GeoFireController.swift
//  Relief
//
//  Created by Jake Hardy on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation

let RADIUS_IN_METERS = Double(40)

class GeoFireController {
    
    static let geofire = GeoFire(firebaseRef: FirebaseController.firebase.childByAppendingPath(LOCATION_ENDPOINT))
    
    static func setLocation(eventID: String, location: CLLocation, completion: (success : Bool) -> Void) {
        geofire.setLocation(location, forKey: eventID) { (error) in
            if let error = error {
                print(error)
                completion(success: false)
            }
            completion(success: true)
        }
        
    }
    
    static func queryAroundMe() {
        guard let center = LocationController.sharedInstance.coreLocationManager.location else { return }
        let circleQuery = geofire.queryAtLocation(center, withRadius: RADIUS_IN_METERS)
        
        circleQuery.observeEventType(.KeyEntered) { (eventID, location) in
            EventController.sharedInstance.fetchEventWithEventID(eventID, completion: { (event) in
                NSNotificationCenter.defaultCenter().postNotificationName("NewLocalEvent", object: nil)
            })
        }
        
        circleQuery.observeEventType(.KeyExited) { (eventID, location) in
            NSNotificationCenter.defaultCenter().postNotificationName("NewLocalEvent", object: nil)
        }
    }
}
