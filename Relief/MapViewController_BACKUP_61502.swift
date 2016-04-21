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
    private let CIRCLE_RADIUS = 1000.0
    private let CIRCLE_ALPHA: CGFloat = 0.7
    private let CIRCLE_COLOR = UIColor.redColor()
    private let CIRCLE_STROKE_COLOR = UIColor.blackColor()
    private let CIRCLE_LINE_WIDTH: CGFloat = 1.0
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longGestureRecognizer: UILongPressGestureRecognizer!
    
    var mapManager: MapController?
    var toggleMode = ToggleMode.MapShown
    var currentEvent: Event?
    
    enum ToggleMode {
        case MapShown
        case MapHidden
    }
    
    // MARK: - IBActions
    @IBAction func toCurrentLocationTapped(sender: UIBarButtonItem) {
        if let location = LocationController.sharedInstance.coreLocationManager.location {
            self.centerMapOnLocation(location)
        }
    }
    
    @IBAction func mapLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let location = sender.locationInView(mapView)
            let locCoord = mapView.convertPoint(location, toCoordinateFromView: mapView)
            let annotation = DisasterAnnotation()
            annotation.coordinate = locCoord
            let circle = MKCircle(centerCoordinate: locCoord, radius: CIRCLE_RADIUS)
            mapView.addOverlay(circle)
            mapView.addAnnotation(annotation)
            mapManager?.currentOverlay = circle
            mapManager?.currentAnnotation = annotation
            makeActionSheet("New Event?", controllerMessage: "Declare a disaster event here", annotation: annotation, overlay: circle)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // consider putting all annotation configuration here
        guard annotation.isKindOfClass(DisasterAnnotation) else {
            return nil
        }
        
        let identifier = "disasterIdentifier"
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.enabled = true
        annotationView.canShowCallout = true
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
<<<<<<< HEAD
=======
        // When the user taps on the callout button
        
>>>>>>> develop
        // identify the event and segue to the event detail screen

        if let annotation = view.annotation as? DisasterAnnotation {
            for event in EventController.sharedInstance.events {
                if event.identifier == annotation.disasterEventID {
                    self.currentEvent = event
                    self.performSegueWithIdentifier("toDetailfromMap", sender: nil)
                    return
                }
            }
        }
        // sublcass annotation. Give each annotation an optional identifier that mathces the event ID.
        // When the user creates an event the annotation is assigned an identifier. The annotation will be the current annotation so you can identify it inside class scope.
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
        }
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoFireController.queryAroundMe()
        
        if let initialLocationCoordinate = LocationController.sharedInstance.coreLocationManager.location {
            centerMapOnLocation(initialLocationCoordinate)
        }
        
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
        circle.strokeColor = CIRCLE_STROKE_COLOR
        circle.fillColor = CIRCLE_COLOR
        circle.lineWidth = CIRCLE_LINE_WIDTH
        circle.alpha = CIRCLE_ALPHA
        return circle
    }
    
    func displayEventsForCurrentUser() {
    
    }
    
    func displayEvents() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        for event in EventController.sharedInstance.events {
            mapManager?.addEventToMap(event)
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
            let destinationView = segue.destinationViewController as! UINavigationController
            let lastView = destinationView.childViewControllers[0] as! CreateEventViewController
            lastView.delegate = self
            lastView.view.backgroundColor = UIColor.reliefAlphaBlack()
        } else if segue.identifier == "toDetailfromMap" {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let lastView = destinationViewController.childViewControllers[0] as! EventViewController
            lastView.event = self.currentEvent!
            lastView.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
}







