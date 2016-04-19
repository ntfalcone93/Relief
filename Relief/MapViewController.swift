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

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, MapUpdating {
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
        if sender.state == UIGestureRecognizerState.Began {
            let location = sender.locationInView(mapView)
            let locCoord = mapView.convertPoint(location, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locCoord
            annotation.title = "title"
            annotation.subtitle = "subtitle"
            let circle = MKCircle(centerCoordinate: locCoord, radius: 1000)
            mapView.addOverlay(circle)
            mapView.addAnnotation(annotation)
            mapManager?.currentOverlay = circle
            mapManager?.currentAnnotation = annotation
            
            makeActionSheet("New Event?", controllerMessage: "Declare a disaster event here?", annotation: annotation, overlay: circle)
        }
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserController.sharedInstance.currentUser == nil {
            performSegueWithIdentifier("toLogin", sender: nil)
        } else {
            self.displayEventsForCurrentUser()
        }
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displayEvents), name: "NewLocalEvent", object: nil)
        
        
        self.longGestureRecognizer.delegate = self
        mapManager = MapController(delegate: self)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        // First call to toggle map is made, toggle mode is
        // updated and map is hidden for initial interaction
        toggleMap()
        
        
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.purpleColor()
        circle.fillColor = UIColor.redColor()
        circle.lineWidth = 1
        circle.alpha = 0.6
        print("FIRED IN MAPVIEW OVERLAY")
        return circle
    }
    
    
    func displayEventsForCurrentUser() {
        
        let user = UserController.sharedInstance.currentUser
        EventController.sharedInstance.events = []
        EventController.sharedInstance.localEvents = []
        EventController.sharedInstance.fetchEventsForUser(user, completion: { (success) in
            if success {
                GeoFireController.queryAroundMe({
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.removeOverlays(self.mapView.overlays)
                    for event in EventController.sharedInstance.localEvents {
                        self.mapManager?.addEventToMap(event)
                    }
                    for event in EventController.sharedInstance.events {
                        self.mapManager?.addEventToMap(event)
                    }
                })
            }
        })
    }
    
    func displayEvents() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        for event in EventController.sharedInstance.localEvents {
            self.mapManager?.addEventToMap(event)
        }
        for event in EventController.sharedInstance.events {
            self.mapManager?.addEventToMap(event)
        }
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







