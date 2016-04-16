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
    
    var annotationAdded = false
    var annotationSecondCheck = true
    var currentAnnotation: MKAnnotation?
    var currentOverlay: MKOverlay?
    
    var delegate: MapUpdating
    
    init(delegate: MapUpdating) {
        self.delegate = delegate
        super.init()
        delegate.mapView.delegate = self
        delegate.mapView.showsUserLocation = true
        delegate.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(removeAnnotationFromCancel), name: "cancelEvent", object: nil)
        
        if let initialLocationCoordinate = LocationController.sharedInstance.coreLocationManager.location {
            delegate.centerMapOnLocation(initialLocationCoordinate)
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
        let location = sender.locationInView(delegate.mapView)
        let locCoord = delegate.mapView.convertPoint(location, toCoordinateFromView: delegate.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "title"
        annotation.subtitle = "subtitle"
        let circle = MKCircle(centerCoordinate: locCoord, radius: 1000)
        
        delegate.addEventOnMap(circle, annotation: annotation)
        
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
        delegate.centerMapOnLocation(location)
    }
    
    func addEventToMap(event: Event) {
        let latitude = event.latitude
        let longitude = event.longitude
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = event.title
        annotation.subtitle = event.type
        
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: 1000)
        delegate.addEventOnMap(circle, annotation: annotation)
    }
    
    func removeOneAnnotation(annotation: MKAnnotation, overlay: MKOverlay) {
        // The first time remove annotation is checked in a cycle this will fail and annotationSecondCheck will be set to true
        if annotationAdded {
            delegate.removeAnnotation(annotation, overlay: overlay)
            // During the second iteration annotation added is set to false and annotationsecond check is returned to ground state
            annotationAdded = false
            annotationSecondCheck = false
            delegate.makeActionSheet("EVENT", controllerMessage: "Want to create a disaster event?", annotation: currentAnnotation!, overlay: currentOverlay!)
        } else {
            // In the event annotation added is false, annotation secondcheck must be true to check for second iteration of annotation adding
            currentOverlay = overlay
            currentAnnotation = annotation
            annotationSecondCheck = true
        }
    }
    
    func removeAnnotation(annotation:MKAnnotation, overlay: MKOverlay) {
        delegate.removeAnnotation(annotation, overlay: overlay)
    }
    
    @objc func removeAnnotationFromCancel() {
        guard let annotation = self.currentAnnotation, overlay = self.currentOverlay else { return }
        delegate.removeAnnotation(annotation, overlay: overlay)
    }
}

protocol MapUpdating {
    var mapView: MKMapView! { get }
    var navigationController: UINavigationController? { get }
    
    func centerMapOnLocation(location: CLLocation)
    func addEventOnMap(circle: MKCircle, annotation: MKPointAnnotation)
    func removeOneAnnotation(currentAnnotation: MKAnnotation, currentOverlay: MKOverlay, annotation: MKAnnotation, overlay: MKOverlay)
    func makeActionSheet(controllerTitle: String, controllerMessage: String, annotation: MKAnnotation, overlay: MKOverlay)
    func removeAnnotation(annotation:MKAnnotation, overlay: MKOverlay)
    
}

extension MapUpdating {
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 3.0, regionRadius * 3.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addEventOnMap(circle: MKCircle, annotation: MKPointAnnotation) {
        mapView.addOverlay(circle)
        mapView.addAnnotation(annotation)
    }
    
    func removeOneAnnotation(currentAnnotation: MKAnnotation, currentOverlay: MKOverlay, annotation: MKAnnotation, overlay: MKOverlay) {
        // The first time remove annotation is checked in a cycle this will fail and annotationSecondCheck will be set to true
        mapView.removeAnnotation(annotation)
        mapView.removeOverlay(overlay)
        // During the second iteration annotation added is set to false and annotationsecond check is returned to ground state
        
        makeActionSheet("EVENT", controllerMessage: "Want to create a disaster event?", annotation: currentAnnotation, overlay: currentOverlay)
    }
    
    func removeAnnotation(annotation:MKAnnotation, overlay: MKOverlay) {
        mapView.removeAnnotation(annotation)
        mapView.removeOverlay(overlay)
    }
    
    
}

func ==(lhs: MapController, rhs: MapController) -> Bool {
    return true
}



