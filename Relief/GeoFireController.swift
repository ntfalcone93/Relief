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
                print("Error in \(#function) - \(error.localizedDescription)")
                completion(success: false)
                return
            }
            completion(success: true)
        }
    }
    
    static func queryAroundMe(completion: () -> Void) {
        // initiate an array to hold all shedIDs which query will find
        var eventIDs = EventController.sharedInstance.events.flatMap({$0.identifier})
        guard let center = LocationController.sharedInstance.coreLocationManager.location else { return }
        // Create circle query based on current position and meter radius
        // Append shedIDs returned to shedIDs array
        let circleQuery = geofire.queryAtLocation(center, withRadius: RADIUS_IN_METERS)
        circleQuery.observeEventType(.KeyEntered, withBlock: { (string, location) -> Void in
            print("CirclQueryFiredWithoutString")
            if !eventIDs.contains(string) {
                // initialize a new event and append it to the eventController
                eventIDs.append(string)
                print("CirclQueryFiredWithString")
                EventController.sharedInstance.fetchLocalEventWithEventID(string, completion: { (success) in
                })
            }
        })
        print("I'm Finished!")
    }
}
