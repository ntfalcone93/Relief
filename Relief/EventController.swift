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
    
    // MARK: - Fetch Event Functions
    // Grabs a particular event with identifier -> Completes with event
    func fetchEventWithEventID(_ eventID: String, completion: @escaping (_ event: Event?) -> Void) {
        // Endpoint constructed from event endpoints and passed in event ID
        let endpoint = "\(EVENT_ENDPOINT)/\(eventID)"
        // grabs data at specified endpoint and initializes (attempts) an Event object
        FirebaseController.dataAtEndPoint(endpoint) { (data) in
            guard let json = data as? [String : AnyObject] else { completion(nil) ; return }
            guard let event = Event(dictionary: json, identifier: eventID) else { completion(nil) ; return }
            self.events.append(event)
            // Complete with initialized event
            completion(event)
        }
    }
    
    // Grabs all events for specified user -> Completes with bool
    func fetchEventsForUser(_ user: User, completion: @escaping (_ success: Bool) -> Void) {
        // Initialize events array to hold all events to be fetched
        var events = [Event]()
        // due to the asynchronous nature of the firebase calls, create a group to maintain
        //  execution order
        let group = DispatchGroup()
        // Loop through users eventIDs and fetch each event.
        for eventID in user.eventIds {
            // Enter group inside of loop for each async call
            group.enter()
            // fetch each event, if event is instantiable, append it to events array
            fetchEventWithEventID(eventID, completion: { (event) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if let event = event {
                        events.append(event)
                    }
                    // regardless of event instantiation success, leave dispatch group
                    group.leave()
                })
            })
        }
        // Once all async calls have finished. notifiy group.
        group.notify(queue: DispatchQueue.main) {
            // set shared instances events to returned events; complete true
            self.events = events
            completion(true)
        }
    }
    
    // Function will query a particular radius for disaster events -> completes with success
    func fetchEventsInArea(_ location: CLLocation, completion: (_ success : Bool) -> Void) {
        // TODO: Implement geoFire
        GeoFireController.queryAroundMe()
    }
    
    // Function creates an event -> Completes with Bool
    func createEvent(_ eventType: EventType, title: String, collectionPoint: String, location: CLLocation, completion: @escaping (_ success: Bool, _ event: Event?) -> Void) {
        
        // Instantiate an event with passed in attributes
        let event = Event(title: title, type: eventType, collectionPoint: collectionPoint, latitude: location.coordinate.latitude, longitude:  location.coordinate.longitude)
        event.members.append(UserController.sharedInstance.currentUser.identifier!)
        // If fetching events in area this could very well be redundant
        
        // Save event to firebase; if error return false or complete true
        FirebaseController.firebase?.child(byAppendingPath: EVENT_ENDPOINT).childByAutoId().setValue(event.jsonValue) { (error, firebase) in
            if let error = error {
                print(error)
                completion(false, nil)
                return
            }
            GeoFireController.setLocation((firebase?.key)!, location: location, completion: { (success) in
                if success {
                    completion(true, event)
                    print("finished true")
                } else {
                    completion(false, event)
                }
            })
        }
    }
    
    func joinEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        guard let identifier = UserController.sharedInstance.currentUser.identifier else { return }
        event.members.append(identifier)
        FirebaseController.firebase?.child(byAppendingPath: "\(EVENT_ENDPOINT)/\(event.identifier!)").setValue(event.jsonValue) { (error, firebase) in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            UserController.sharedInstance.currentUser.eventIds.append(event.identifier!)
            UserController.sharedInstance.currentUser.save()
            completion(true)
        }
    }
    
    func leaveEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        guard let eventID = event.identifier else { completion(false) ; return }
        guard let userID = UserController.sharedInstance.currentUser.identifier else { completion(false) ; return }
        
        for (index, member) in event.members.enumerated() {
            if member == userID {
                event.members.remove(at: index)
            }
        }
        
        FirebaseController.firebase?.child(byAppendingPath: "\(EVENT_ENDPOINT)/\(event.identifier!)").setValue(event.jsonValue) { (error, firebase) in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            for (index, event) in UserController.sharedInstance.currentUser.eventIds.enumerated() {
                if event == eventID {
                    UserController.sharedInstance.currentUser.eventIds.remove(at: index)
                }
            }
            
            UserController.sharedInstance.currentUser.save()
            completion(true)
        }
        
    }
    
    // Deletes an event from firebase, from all users, and its location -> Completes with success
    func deleteEvent(_ event: Event, completion: @escaping (_ success: Bool) -> Void) {
        
        for (index, nextEvent) in self.events.enumerated() {
            if nextEvent == event {
                self.events.remove(at: index)
            }
        }

        // Creates an array from an events members identifiers; if event does not have identifier complete false
        let userIDArray = event.members
        guard let eventID = event.identifier else { completion(false) ; return }
        // Create group to maintain function execution order
        let groupOne = DispatchGroup()
        // Enter group prior to async call
        groupOne.enter()
        // Deletes events from all users. Pass in userID array and event ID
        deleteEventForUsers(eventID, userIdentifiers: userIDArray) { (success) in
            // if successful, leave group otherwise complete false and return
            if success {
                groupOne.leave()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(false)
                    return
                })
            }
        }
        // Once first async call has finished notify main queue
        groupOne.notify(queue: DispatchQueue.main) {
            // Create second group to maintain function execution order
            let groupTwo = DispatchGroup()
            // Enter group prior to async call
            groupTwo.enter()
            // Delete location with pass in eventID
            self.deleteLocationForIdentifier(eventID, completion: { (success) in
                // If success leave group otherwise complete false and return
                if success {
                    groupTwo.leave()
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(false)
                        return
                    })
                }
            })
            // Once async call has finished, call main queue for final async call
            groupTwo.notify(queue: DispatchQueue.main, execute: {
                // deletes event from firebase with passed in eventID
                self.deleteEventFromFirebase(eventID, completion: { (success) in
                    // If successful, call main queue and complete true, otherwise complete false
                    if success {
                        DispatchQueue.main.async(execute: { () -> Void in
                            // we need to make an equatable protocol so we can remove from the local array at the discovered index ///////////////////
                            for (index, element) in self.events.enumerated() {
                                if element == event {
                                    self.events.remove(at: index)
                                }
                            }
                            completion(true)
                        })
                    } else {
                        DispatchQueue.main.async(execute: { () -> Void in
                            completion(false)
                        })
                    }
                })
            })
        }
    }
    
    // Function deletes events from all users passed who have the given eventID in their array -> Completes with Bool
    func deleteEventForUsers(_ eventID: String, userIdentifiers: [String], completion: @escaping (_ success: Bool) -> Void) {
        // Creates group to maintain function order because of async calls to come
        let group = DispatchGroup()
        // For each identifier in passed in array, grab user from firebase and remove event
        for userIdentifier in userIdentifiers {
            // Enter group for each async call
            group.enter()
            UserController.fetchUserWithId(userIdentifier, completion: { (user) in
                if var user = user {
                    for (index, event) in user.eventIds.enumerated() {
                        if eventID == event {
                            user.eventIds.remove(at: index)
                            user.save()
                        }
                    }
                }
                group.leave()
            })
        }
        // Once async calls have completed, notify main queue and complete true
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    // Deletes location of passed in event ID -> Completes with Bool
    func deleteLocationForIdentifier(_ eventIdentifier: String, completion: @escaping (_ success : Bool) -> Void) {
        // assemble location endpoint with local endpoint and particular ID
        let location = "\(LOCATION_ENDPOINT)/\(eventIdentifier)"
        // Removes value, completes false if error or true if none present
        FirebaseController.firebase?.child(byAppendingPath: location).removeValue { (error, _) in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // Deletes specified event from firebase
    func deleteEventFromFirebase(_ eventIdentifier: String, completion: @escaping (_ success : Bool) -> Void) {
        // Assembles endpoint via event endpoint and its unique ID
        let firebaseLocation = "\(EVENT_ENDPOINT)/\(eventIdentifier)"
        // Sets value to false; completes false if error prevalent otherwise completes true
        FirebaseController.firebase?.child(byAppendingPath: firebaseLocation).removeValue { (error, _) in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // Adds a need to an event; requires an event and a need -> Completes with Bool
    func addNeedToEvent(_ event: Event, need: String, completion: @escaping (_ success: Bool) -> Void) {
        // Make sure eventID exists
        guard let eventID = event.identifier else { completion(false) ; return }
        // append need to events needs array
        event.needs.append(need)
        // Save event to firebase. If error complete false, otherwise complete true
        FirebaseController.firebase?.child(byAppendingPath: "\(EVENT_ENDPOINT)/\(eventID)").setValue(event.jsonValue) { (error, _) in
            if let error = error {
                print(error)
                completion(false)
            }
            completion(true)
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



