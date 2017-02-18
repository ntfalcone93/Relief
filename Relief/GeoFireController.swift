//
//  GeoFireController.swift
//  Relief
//
//  Created by Jake Hardy on 4/15/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation

let RADIUS_IN_METERS = Double(160)

class GeoFireController {
    static let geofire = GeoFire(firebaseRef: FirebaseController.firebase?.child(byAppendingPath: LOCATION_ENDPOINT))
    
    static func setLocation(_ eventID: String, location: CLLocation, completion: @escaping (_ success : Bool) -> Void) {
        geofire?.setLocation(location, forKey: eventID) { (error) in
            if let error = error {
                print(error)
                completion(false)
            }
            completion(true)
        }
    }
    
    static func queryAroundMe() {
        guard let center = LocationController.sharedInstance.coreLocationManager.location else { return }
        let circleQuery = geofire?.query(at: center, withRadius: RADIUS_IN_METERS)
        circleQuery?.observe(.keyEntered) { (eventID, location) in
            EventController.sharedInstance.fetchEventWithEventID(eventID!, completion: { (event) in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "NewLocalEvent"), object: nil)
            })
        }
        circleQuery?.observe(.keyExited) { (eventID, location) in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NewLocalEvent"), object: nil)
        }
    }
}
