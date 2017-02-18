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
    fileprivate let CIRCLE_RADIUS = 1000.0
    fileprivate let CIRCLE_ALPHA: CGFloat = 0.7
    fileprivate let CIRCLE_COLOR = UIColor.red
    fileprivate let CIRCLE_STROKE_COLOR = UIColor.black
    fileprivate let CIRCLE_LINE_WIDTH: CGFloat = 1.0
    
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longGestureRecognizer: UILongPressGestureRecognizer!
    
    var mapManager: MapController?
    var toggleMode = ToggleMode.mapShown
    var currentEvent: Event?
    
    enum ToggleMode {
        case mapShown
        case mapHidden
    }
    
    // MARK: - IBActions
    @IBAction func toCurrentLocationTapped(_ sender: UIBarButtonItem) {
        if let location = LocationController.sharedInstance.coreLocationManager.location {
            self.centerMapOnLocation(location)
        }
    }
    
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let location = sender.location(in: mapView)
            let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = DisasterAnnotation()
            annotation.coordinate = locCoord
            let circle = MKCircle(center: locCoord, radius: CIRCLE_RADIUS)
            mapView.add(circle)
            mapView.addAnnotation(annotation)
            mapManager?.currentOverlay = circle
            mapManager?.currentAnnotation = annotation
            makeActionSheet("New Event?", controllerMessage: "Declare a disaster event here", annotation: annotation, overlay: circle)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // consider putting all annotation configuration here
        guard annotation.isKind(of: DisasterAnnotation.self) else {
            return nil
        }
        let identifier = "disasterIdentifier"
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        let button = UIButton(type: UIButtonType.detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // When the user taps on the callout button
        
        // identify the event and segue to the event detail screen

        if let annotation = view.annotation as? DisasterAnnotation {
            for event in EventController.sharedInstance.events {
                if event.identifier == annotation.disasterEventID {
                    self.currentEvent = event
                    self.performSegue(withIdentifier: "toDetailfromMap", sender: nil)
                    return
                }
            }
        }
        // sublcass annotation. Give each annotation an optional identifier that mathces the event ID.
        // When the user creates an event the annotation is assigned an identifier. The annotation will be the current annotation so you can identify it inside class scope.
    }
    
    @IBAction func eventsButtonTapped(_ sender: UIBarButtonItem) {
        // If the events button is tapped, the view will toggle the toggleMode and animate the
        // movement of the views
        toggleMap()
    }
    
    @IBAction func tapGestureFired(_ sender: UITapGestureRecognizer) {
        // toggle mode must be map hidden to allow users to properly interact with the map
        // implementing the tap gesture when the map is hidden allows for quick and easy
        // navigation back to the map from the event table view
        if toggleMode == .mapHidden {
            // if map is hidden, a tap in the map area will toggle the map and
            // animate the movement of the views
            toggleMap()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserController.sharedInstance.currentUser == nil {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let initialLocationCoordinate = LocationController.sharedInstance.coreLocationManager.location {
            centerMapOnLocation(initialLocationCoordinate)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(displayEvents), name: NSNotification.Name(rawValue: "NewLocalEvent"), object: nil)
        self.longGestureRecognizer.delegate = self
        mapManager = MapController(delegate: self)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        GeoFireController.queryAroundMe()
    }
    
    // MARK: - Map View Delegate
    func toggleMap() {
        switch toggleMode {
        case .mapHidden:
            toggleMode = .mapShown
            self.revealViewController().revealToggle(self)
        case .mapShown:
            toggleMode = .mapHidden
            self.revealViewController().revealToggle(self)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
    
    func makeActionSheet(_ controllerTitle: String, controllerMessage: String, annotation: MKAnnotation, overlay: MKOverlay) {
        let actionSheet = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .actionSheet)
        let cancelAlert = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            self.removeAnnotation(annotation, overlay: overlay)
        }
        let createEventAlert = UIAlertAction(title: "Create Event", style: .default) { (_) in
            self.performSegue(withIdentifier: "showCreateEvent", sender: nil)
        }
        actionSheet.addAction(createEventAlert)
        actionSheet.addAction(cancelAlert)
        navigationController?.present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateEvent" {
            let destinationView = segue.destination as! UINavigationController
            let lastView = destinationView.childViewControllers[0] as! CreateEventViewController
            lastView.delegate = self
            lastView.view.backgroundColor = UIColor.reliefAlphaBlack()
        } else if segue.identifier == "toDetailfromMap" {
            let destinationViewController = segue.destination as! UINavigationController
            let lastView = destinationViewController.childViewControllers[0] as! EventViewController
            lastView.event = self.currentEvent!
            lastView.view.backgroundColor = UIColor.reliefAlphaBlack()
        }
    }
    
}







