//
//  MapController.swift
//  Relief
//
//  Created by Dylan Slade on 4/14/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapController: NSObject, MKMapViewDelegate {
    var mapView: MKMapView
    var annotationAdded = false
    var annotationSecondCheck = true
    var currentAnnotation: MKAnnotation?
    var currentOverlay: MKOverlay?
    var viewController: MapViewController
    
    init(mapView: MKMapView, viewController: MapViewController) {
        self.mapView = mapView
        self.viewController = viewController
        super.init()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(removeAnnotationFromCancel), name: "cancelEvent", object: nil)
        if let initialLocationCoordinate = LocationController.sharedInstance.coreLocationManager.location {
            self.setMapWithInitialLocation(initialLocationCoordinate)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.purpleColor()
        circle.fillColor = UIColor.redColor()
        circle.lineWidth = 1
        circle.alpha = 0.6
        return circle
    }
    
    func mapPressed(sender: UILongPressGestureRecognizer) {
        let location = sender.locationInView(self.mapView)
        let locCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "title"
        annotation.subtitle = "subtitle"
        let circle = MKCircle(centerCoordinate: locCoord, radius: 1000)
        self.mapView.addOverlay(circle)
        self.mapView.addAnnotation(annotation)

        // Logic is a duct tape fix for double annotation firing
        // Remove one annotation checks if an annotation has been previously added, if it has it removes the last annotation added
        removeOneAnnotation(annotation, overlay: circle)
        // Checks annotation second check: Default value of false
        if annotationSecondCheck {
            // sets annotationadded to true to remove the second annotation added
            self.annotationAdded = true
        }
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
            self.viewController.performSegueWithIdentifier("showEventInformation", sender: nil)
        }
        actionSheet.addAction(createEventAlert)
        actionSheet.addAction(cancelAlert)
        self.viewController.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
}

func ==(lhs: MapController, rhs: MapController) -> Bool {
    return true
}



