//
//  MapViewController.swift
//  MapKit Play
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Dylan Slade. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longGestureRecognizer: UILongPressGestureRecognizer!
    
    // MARK: - Logic Properties
    var annotationAdded = false
    var annotationSecondCheck = true
    var currentAnnotation: MKAnnotation?
    var currentOverlay: MKOverlay?
    var count = 0
    // toggle mode is initially set to Mapshown
    var toggleMode = ToggleMode.MapShown
    
    enum ToggleMode {
        case MapShown
        case MapHidden
    }
    
    // MARK: - IBActions
    @IBAction func mapLongPressed(sender: UILongPressGestureRecognizer) {
        let location = sender.locationInView(self.mapView)
        let locCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "title \(count)"
        annotation.subtitle = "subtitle"
        let circle = MKCircle(centerCoordinate: locCoord, radius: 1000)
        self.mapView.addOverlay(circle)
        self.mapView.addAnnotation(annotation)
        count = count + 1
        
        // Goofy logic is a duct tape fix for double annotation firing
        // Remove one annotation checks if an annotation has been previously added, if it has it removes the last annotation added
        removeOneAnnotation(annotation, overlay: circle)
        
        // Checks annotation second check: Default value of false
        if annotationSecondCheck {
            // sets annotationadded to true to remove the second annotation added
            self.annotationAdded = true
        }
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
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.longGestureRecognizer.delegate = self
        self.setMapWithInitialLocation(CLLocation(latitude: 21.282778, longitude: -157.829444))
        // First call to toggle map is made, toggle mode is
        // updated and map is hidden for initial interaction
        toggleMap()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(removeAnnotationFromCancel), name: "cancelEvent", object: nil)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.purpleColor()
        circle.fillColor = UIColor.redColor()
        circle.lineWidth = 1
        circle.alpha = 0.6
        return circle
    }
    
    // MARK: - Helper Methods
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 3.0, regionRadius * 3.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removeOneAnnotation(annotation: MKAnnotation, overlay: MKOverlay) {
        // The first time remove annotation is checked in a cycle this will fail and annotationSecondCheck will be set to true
        if annotationAdded {
            self.mapView.removeAnnotation(annotation)
            self.mapView.removeOverlay(overlay)
            // During the second iteration annotation added is set to false and annotationsecond check is returned to ground state
            annotationAdded = false
            annotationSecondCheck = false
            makeActionSheet("EVENT", controllerMessage: "Want to create a disaster event?", annotation: currentAnnotation!, overlay: currentOverlay!)
        } else {
            // In the event annotation added is false, annotation secondcheck must be true to check for second iteration of annotation adding
            currentOverlay = overlay
            currentAnnotation = annotation
            annotationSecondCheck = true
        }
    }
    
    func setMapWithInitialLocation(location: CLLocation) {
        self.centerMapOnLocation(location)
    }
    
    func removeAnnotation(annotation:MKAnnotation, overlay: MKOverlay) {
        self.mapView.removeAnnotation(annotation)
        self.mapView.removeOverlay(overlay)
    }
    
    @objc func removeAnnotationFromCancel() {
        guard let annotation = self.currentAnnotation, overlay = self.currentOverlay else { return }
        self.mapView.removeAnnotation(annotation)
        self.mapView.removeOverlay(overlay)
    }
    
    func makeActionSheet(controllerTitle: String, controllerMessage: String, annotation: MKAnnotation, overlay: MKOverlay) {
        let actionSheet = UIAlertController(title: controllerTitle, message: controllerMessage, preferredStyle: .ActionSheet)
        let cancelAlert = UIAlertAction(title: "Cancel", style: .Destructive) { (_) in
            self.removeAnnotation(annotation, overlay: overlay)
        }
        let createEventAlert = UIAlertAction(title: "Create Event", style: .Default) { (_) in
            self.performSegueWithIdentifier("showEventInformation", sender: nil)
        }
        actionSheet.addAction(createEventAlert)
        actionSheet.addAction(cancelAlert)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
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






