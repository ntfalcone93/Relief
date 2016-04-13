//
//  EventController.swift
//  Relief
//
//  Created by Jake Hardy on 4/13/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import CoreLocation

let EVENT_ENDPOINT = "events"
let LOCATION_ENDPOINT = "location"


class EventController {
    
    static let sharedInstance = EventController()
    
    var events = [Event]()
    var localEvents = [Event]()
    
    func fetchEventWithEventID(eventID: String, completion: (event: Event?) -> Void) {
        
        let endpoint = "\(EVENT_ENDPOINT)/\(eventID)"
        
        FirebaseController.dataAtEndPoint(endpoint) { (data) in
            guard let json = data as? [String : AnyObject] else { completion(event: nil) ; return }
            guard let event = Event(dictionary: json) else { completion(event: nil) ; return }
            
            completion(event: event)
            
        }
        
    }
    
    func fetchEventsForUser(user: User, completion: (success: Bool) -> Void) {
        
        var events = [Event]()
        
        let group = dispatch_group_create()
        
        for eventID in user.eventIds {
            dispatch_group_enter(group)
            fetchEventWithEventID(eventID, completion: { (event) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let event = event {
                        events.append(event)
                    }
                    dispatch_group_leave(group)
                })
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.events = events
            completion(success: true)
        }
    }
    
    func fetchEventsInArea(location: CLLocation, completion: (success : Bool) -> Void) {
        
    }
    
    func createEvent(eventType: EventType, title: String, collectionPoint: String, location: CLLocation, completion: (success: Bool) -> Void) {
        let event = Event(title: title, type: eventType, collectionPoint: collectionPoint)
        
        FirebaseController.firebase.childByAppendingPath(EVENT_ENDPOINT).childByAutoId().setValue(event.jsonValue) { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }

        
        // Do stuff with geofire here
        
        completion(success: true)
    }
    
    func deleteEvent(event: Event, completion: (success: Bool) -> Void) {
        let userIDArray = event.members
        guard let eventID = event.identifier else { completion(success: false) ; return }
        
        let groupOne = dispatch_group_create()
        
        dispatch_group_enter(groupOne)
        
        deleteEventForUsers(eventID, userIdentifiers: userIDArray) { (success) in
            if success {
                dispatch_group_leave(groupOne)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: false)
                    return
                })
            }
        }
        
        dispatch_group_notify(groupOne, dispatch_get_main_queue()) {
            
            let groupTwo = dispatch_group_create()
            
            dispatch_group_enter(groupTwo)
            self.deleteLocationForIdentifier(eventID, completion: { (success) in
                if success {
                    dispatch_group_leave(groupTwo)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(success: false)
                        return
                    })
                }
                
            })
            
            dispatch_group_notify(groupTwo, dispatch_get_main_queue(), { 
                self.deleteEventFromFirebase(eventID, completion: { (success) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(success: true)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(success: false)
                        })
                    }
                })
            })
        }
    }
    
    func deleteEventForUsers(eventID: String, userIdentifiers: [String], completion: (success: Bool) -> Void) {
        
        let group = dispatch_group_create()
        
        
        for userIdentifier in userIdentifiers {
            dispatch_group_enter(group)
            // UserController.fetchUserForIdentifier()
            // let user = user
            // user.events.remove event match eventID
            // save users
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(success: true)
        }
        
        
    }
    
    func deleteLocationForIdentifier(eventIdentifier: String, completion: (success : Bool) -> Void) {
        
        let location = "\(LOCATION_ENDPOINT)/\(eventIdentifier)"
        
        FirebaseController.firebase.childByAppendingPath(location).removeValueWithCompletionBlock { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }
        
    }
    
    func deleteEventFromFirebase(eventIdentifier: String, completion: (success : Bool) -> Void) {
        
        let firebaseLocation = "\(EVENT_ENDPOINT)/\(eventIdentifier)"
        
        FirebaseController.firebase.childByAppendingPath(firebaseLocation).removeValueWithCompletionBlock { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }
        
    }
    
    func addNeedToEvent(event: Event, need: String, completion: (success: Bool) -> Void) {
        guard let eventID = event.identifier else { completion(success: false) ; return }
        event.needs.append(need)
        FirebaseController.firebase.childByAppendingPath("\(EVENT_ENDPOINT)/\(eventID)").setValue(event.jsonValue) { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }
        
    }
}