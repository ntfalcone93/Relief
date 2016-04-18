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
    // Instantiate Shared Instance to allow access to particular events more easily
    static let sharedInstance = EventController()
    var delegate: EventsUpdating?
    // Total events a user subscribes to
    var events = [Event]() {
        didSet {
            delegate?.updateNewEvent()
        }
    }
    
    // events within a radius of distance from users current location
    var localEvents = [Event]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("NewLocalEvent", object: nil)
        }
    }
    
    // MARK: - Fetch Event Functions
    // Grabs a particular event with identifier -> Completes with event
    func fetchEventWithEventID(eventID: String, completion: (event: Event?) -> Void) { ////////// Need to fix this
        // Endpoint constructed from event endpoints and passed in event ID
        let endpoint = "\(EVENT_ENDPOINT)/\(eventID)"
        // grabs data at specified endpoint and initializes (attempts) an Event object
        FirebaseController.dataAtEndPoint(endpoint) { (data) in
            guard let json = data as? [String : AnyObject] else { completion(event: nil) ; return }
            guard let event = Event(dictionary: json, identifier: eventID) else { completion(event: nil) ; return }
            self.events.append(event)
            // Complete with initialized event
            completion(event: event)
        }
    }
    
    // Grabs a particular event with identifier -> Completes with event
    func fetchLocalEventWithEventID(eventID: String, completion: (event: Event?) -> Void) { ////////// Need to fix this
        // Endpoint constructed from event endpoints and passed in event ID
        let endpoint = "\(EVENT_ENDPOINT)/\(eventID)"
        // grabs data at specified endpoint and initializes (attempts) an Event object
        FirebaseController.dataAtEndPoint(endpoint) { (data) in
            guard let json = data as? [String : AnyObject] else { completion(event: nil) ; return }
            guard let event = Event(dictionary: json, identifier: eventID) else { completion(event: nil) ; return }
            self.localEvents.append(event)
            // Complete with initialized event
            completion(event: event)
        }
    }
    
    // Grabs all events for specified user -> Completes with bool
    func fetchEventsForUser(user: User, completion: (success: Bool) -> Void) {
        // Initialize events array to hold all events to be fetched
        var events = [Event]()
        // due to the asynchronous nature of the firebase calls, create a group to maintain
        //  execution order
        let group = dispatch_group_create()
        // Loop through users eventIDs and fetch each event.
        for eventID in user.eventIds {
            // Enter group inside of loop for each async call
            dispatch_group_enter(group)
            // fetch each event, if event is instantiable, append it to events array
            fetchEventWithEventID(eventID, completion: { (event) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let event = event {
                        events.append(event)
                    }
                    // regardless of event instantiation success, leave dispatch group
                    dispatch_group_leave(group)
                })
            })
        }
        // Once all async calls have finished. notifiy group.
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            // set shared instances events to returned events; complete true
            self.events = events
            completion(success: true)
        }
    }
    
    // Function will query a particular radius for disaster events -> completes with success
    func fetchEventsInArea(location: CLLocation, completion: (success : Bool) -> Void) {
        // TODO: Implement geoFire
        GeoFireController.queryAroundMe()
        completion(success: true)
    }
    
    // Function creates an event -> Completes with Bool
    func createEvent(eventType: EventType, title: String, collectionPoint: String, location: CLLocation, completion: (success: Bool, event: Event?) -> Void) {
        // POSSIBLY DO CHECK ON COLLECTION POINT STRING
        
        // Instantiate an event with passed in attributes
        let event = Event(title: title, type: eventType, collectionPoint: collectionPoint, latitude: location.coordinate.latitude, longitude:  location.coordinate.longitude)
        event.members.append(UserController.sharedInstance.currentUser.identifier!)
        // If fetching events in area this could very well be redundant  
        self.events.append(event)
        // Save event to firebase; if error return false or complete true
        FirebaseController.firebase.childByAppendingPath(EVENT_ENDPOINT).childByAutoId().setValue(event.jsonValue) { (error, firebase) in
            if let error = error {
                print(error)
                completion(success: false, event: nil)
                return
            }
            // We need to append the event to the array on the shared instance locally //// From EventController Test /////
            GeoFireController.setLocation(firebase.key, location: location, completion: { (success) in
                if success {
                    UserController.sharedInstance.currentUser.eventIds.append(firebase.key)
                    UserController.sharedInstance.currentUser.save()
                    event.identifier = firebase.key
                    completion(success: true, event: event)
                } else {
                    completion(success: false, event: nil)
                }
            })
        }
    }
    
    // Deletes an event from firebase, from all users, and its location -> Completes with success
    func deleteEvent(event: Event, completion: (success: Bool) -> Void) {
        // Creates an array from an events members identifiers; if event does not have identifier complete false
        let userIDArray = event.members
        guard let eventID = event.identifier else { completion(success: false) ; return }
        // Create group to maintain function execution order
        let groupOne = dispatch_group_create()
        // Enter group prior to async call
        dispatch_group_enter(groupOne)
        // Deletes events from all users. Pass in userID array and event ID
        deleteEventForUsers(eventID, userIdentifiers: userIDArray) { (success) in
            // if successful, leave group otherwise complete false and return
            if success {
                dispatch_group_leave(groupOne)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: false)
                    return
                })
            }
        }
        // Once first async call has finished notify main queue
        dispatch_group_notify(groupOne, dispatch_get_main_queue()) {
            // Create second group to maintain function execution order
            let groupTwo = dispatch_group_create()
            // Enter group prior to async call
            dispatch_group_enter(groupTwo)
            // Delete location with pass in eventID
            self.deleteLocationForIdentifier(eventID, completion: { (success) in
                // If success leave group otherwise complete false and return
                if success {
                    dispatch_group_leave(groupTwo)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(success: false)
                        return
                    })
                }
            })
            // Once async call has finished, call main queue for final async call
            dispatch_group_notify(groupTwo, dispatch_get_main_queue(), {
                // deletes event from firebase with passed in eventID
                self.deleteEventFromFirebase(eventID, completion: { (success) in
                    // If successful, call main queue and complete true, otherwise complete false
                    if success {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // we need to make an equatable protocol so we can remove from the local array at the discovered index ///////////////////
                            for (index, element) in self.events.enumerate() {
                                if element == event {
                                    self.events.removeAtIndex(index)
                                }
                            }
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
    
    // Function deletes events from all users passed who have the given eventID in their array -> Completes with Bool
    func deleteEventForUsers(eventID: String, userIdentifiers: [String], completion: (success: Bool) -> Void) {
        // Creates group to maintain function order because of async calls to come
        let group = dispatch_group_create()
        // For each identifier in passed in array, grab user from firebase and remove event
        for userIdentifier in userIdentifiers {
            // Enter group for each async call
            dispatch_group_enter(group)
            UserController.fetchUserWithId(userIdentifier, completion: { (user) in
                if var user = user {
                    for (index, event) in user.eventIds.enumerate() {
                        if eventID == event {
                            user.eventIds.removeAtIndex(index)
                            user.save()
                        }
                    }
                }
                dispatch_group_leave(group)
            })
        }
        // Once async calls have completed, notify main queue and complete true
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(success: true)
        }
    }
    
    // Deletes location of passed in event ID -> Completes with Bool
    func deleteLocationForIdentifier(eventIdentifier: String, completion: (success : Bool) -> Void) {
        // assemble location endpoint with local endpoint and particular ID
        let location = "\(LOCATION_ENDPOINT)/\(eventIdentifier)"
        // Removes value, completes false if error or true if none present
        FirebaseController.firebase.childByAppendingPath(location).removeValueWithCompletionBlock { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }
    }
    
    // Deletes specified event from firebase
    func deleteEventFromFirebase(eventIdentifier: String, completion: (success : Bool) -> Void) {
        // Assembles endpoint via event endpoint and its unique ID
        let firebaseLocation = "\(EVENT_ENDPOINT)/\(eventIdentifier)"
        // Sets value to false; completes false if error prevalent otherwise completes true
        FirebaseController.firebase.childByAppendingPath(firebaseLocation).removeValueWithCompletionBlock { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
                return
            }
            completion(success: true)
        }
    }
    
    // Adds a need to an event; requires an event and a need -> Completes with Bool
    func addNeedToEvent(event: Event, need: String, completion: (success: Bool) -> Void) {
        // Make sure eventID exists
        guard let eventID = event.identifier else { completion(success: false) ; return }
        // append need to events needs array
        event.needs.append(need)
        // Save event to firebase. If error complete false, otherwise complete true
        FirebaseController.firebase.childByAppendingPath("\(EVENT_ENDPOINT)/\(eventID)").setValue(event.jsonValue) { (error, _) in
            if let error = error {
                print(error)
                completion(success: false)
            }
            completion(success: true)
        }
    }
    
}


protocol EventsUpdating {
    weak var tableView: UITableView! { get }
    func updateNewEvent()
}

extension EventsUpdating {
    func updateNewEvent() {
        tableView.reloadData()
    }
}



