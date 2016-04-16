//
//  MapViewController.swift
//  MapKit Play
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Dylan Slade. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MapUpdating {
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longGestureRecognizer: UILongPressGestureRecognizer!
    var mapManager: MapController?
    
    // MARK: - Logic Properties
    
    
    // toggle mode is initially set to Mapshown
    var toggleMode = ToggleMode.MapShown
    
    enum ToggleMode {
        case MapShown
        case MapHidden
    }
    
    // MARK: - IBActions
    @IBAction func mapLongPressed(sender: UILongPressGestureRecognizer) {
        mapManager?.mapPressed(sender)
        // toggles gesture recognizer (hack)
        sender.enabled = false
        sender.enabled = true
    }
    
    @IBAction func eventsButtonTapped(sender: UIBarButtonItem) {
        // If the events button is tapped, the view will toggle the toggleMode and animate the
        // movement of the views
        toggleMap()
    }
    
    @IBAction func tapGestureFired(sender: UITapGestureRecognizer) {
        // toggle mode must be map hidden to allow users to properly interact with the map
        // implementing the tap gesture when the map is hidden allows for quick and easy
        // navigation back to the map from the event table view
        if toggleMode == .MapHidden {
            
            // if map is hidden, a tap in the map area will toggle the map and
            // animate the movement of the views
            toggleMap()
        }
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.longGestureRecognizer.delegate = self
        mapManager = MapController(delegate: self)
        // First call to toggle map is made, toggle mode is
        // updated and map is hidden for initial interaction
        toggleMap()
        self.displayEventsForCurrentUser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateWithLastEvent), name: "NewLocalEvent", object: nil)
    }
    
    // MARK: - Map View Delegate
    func toggleMap() {
        switch toggleMode {
        case .MapHidden:
            toggleMode = .MapShown
            self.revealViewController().revealToggle(self)
        case .MapShown:
            toggleMode = .MapHidden
            self.revealViewController().revealToggle(self)
        }
    }
    
    func displayEventsForCurrentUser() {
        
        UserController.fetchUserWithId("1234") { (user) in
            guard let user = user else { return  }
            
            UserController.sharedInstance.currentUser = user
            EventController.sharedInstance.fetchEventsForUser(user, completion: { (success) in
                if success {
                    print("IT WORKED DYLAN")
                    print(EventController.sharedInstance.localEvents.count)
                    print(EventController.sharedInstance.events.count)
                    for event in EventController.sharedInstance.events {
                        self.mapManager?.addEventToMap(event)
                    }
                    for event in EventController.sharedInstance.localEvents {
                        self.mapManager?.addEventToMap(event)
                    }
                }
            })
        }
    }
    
    func updateWithLastEvent() {
        guard let latestEvent = EventController.sharedInstance.events.last else { return }
        self.mapManager?.addEventToMap(latestEvent)
    }
    
    func makeActionSheet(controllerTitle: String, controllerMessage: String, annotation: MKAnnotation, overlay: MKOverlay) {
        let actionSheet = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .ActionSheet)
        let cancelAlert = UIAlertAction(title: "Cancel", style: .Destructive) { (_) in
            self.removeAnnotation(annotation, overlay: overlay)
        }
        let createEventAlert = UIAlertAction(title: "Create Event", style: .Default) { (_) in
            self.performSegueWithIdentifier("showCreateEvent", sender: nil)
        }
        actionSheet.addAction(createEventAlert)
        actionSheet.addAction(cancelAlert)
        navigationController?.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCreateEvent" {
            print(segue.destinationViewController)
            let destinationView = segue.destinationViewController as? UINavigationController
            let lastView = destinationView?.childViewControllers[0] as? CreateEventViewController
            lastView?.delegate = self
        }
    }
    
}







