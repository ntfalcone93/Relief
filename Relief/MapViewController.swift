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

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longGestureRecognizer: UILongPressGestureRecognizer!
    var mapManager: MapController?
    
    // MARK: - Logic Properties
    var count = 0
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
        mapManager = MapController(mapView: self.mapView, viewController: self)
        // First call to toggle map is made, toggle mode is
        // updated and map is hidden for initial interaction
        toggleMap()
        
        // Event Controller Tests begin here.
        // How do we get the event locally?
//        var event: Event? = nil
//        EventController.sharedInstance.createEvent(EventType.Earthquakes, title: "Quake", collectionPoint: "Not where you wanna be", location: CLLocation(latitude: 40.7724692, longitude: -111.9095813)) { (success, eventFromSuccess) in
//            print("create event complete")
//            if let eventFromSuccess = eventFromSuccess {
//                event = eventFromSuccess
//                EventController.sharedInstance.fetchEventWithEventID((event?.identifier)!, completion: { (ayy) in
//                    print(ayy?.title)
//                    EventController.sharedInstance.addNeedToEvent(event!, need: "Bazookas", completion: { (success) in
//                        print("yolo")
//                        EventController.sharedInstance.deleteEvent(event!, completion: { (success) in
//                            print("delete complete")
//                        })
//                    })
//                })
//            }
//        }
    }
    
    // MARK: - Map View Delegate
    
    
    // functions toggles the current view mode and calls the review controller
    // for movement of views. This function also sets the toggleMode to it's
    // new and correct mode that reflects the changes made
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
    
    
    
}






