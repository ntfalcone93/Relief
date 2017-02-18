//
//  LocationController.swift
//  Relief
//
//  Created by Dylan Slade on 4/14/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController {
    static let sharedInstance = LocationController()
    var coreLocationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    
    // MARK: - Core Location
    func setUpCoreLocation() {
        self.coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest // use the highest level of accuracy
        self.coreLocationManager.requestWhenInUseAuthorization()
        self.coreLocationManager.startUpdatingLocation()
    }
    
    init() {
        setUpCoreLocation()
    }
    
    // Enter address to get Location for Event
    func getCoordinatesFromCity(_ address: String, completion: @escaping (_ longitude: CLLocationDegrees?, _ latitude: CLLocationDegrees?) -> Void ) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion(nil, nil)
            } else {
                if let placemarks = placemarks, let firstPlacemark = placemarks.first, let location = firstPlacemark.location {
                    completion(location.coordinate.longitude, location.coordinate.latitude)
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
}
