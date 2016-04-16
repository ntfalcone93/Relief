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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCreateEvent" {
            print(segue.destinationViewController)
            let destinationView = segue.destinationViewController as? UINavigationController
            let lastView = destinationView?.childViewControllers[0] as? CreateEventViewController
            lastView?.delegate = self
        }
    }
    
}







