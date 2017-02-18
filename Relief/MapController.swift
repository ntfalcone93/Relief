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

class MapController: NSObject {
    var currentAnnotation: DisasterAnnotation?
    var currentOverlay: MKOverlay?
    var delegate: MapUpdating
    var geoCoder = CLGeocoder()
    
    init(delegate: MapUpdating) {
        self.delegate = delegate
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnnotation), name: NSNotification.Name(rawValue: "createEventFinished"), object: nil)
    }
    
    // MARK: - Helper Methods
    func addEventToMap(_ event: Event) {
        let latitude = event.latitude
        let longitude = event.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let annotation = DisasterAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = event.type
        annotation.subtitle = "\(event.needs.count) Needs"
        annotation.disasterEventID = event.identifier
        let circle = MKCircle(center: location.coordinate, radius: 1000)
        delegate.addEventOnMap(circle, annotation: annotation)
    }
    
    func removeAnnotation() {
        guard let currentAnnotation = currentAnnotation, let currentOverlay = currentOverlay else { return }
        delegate.removeAnnotation(currentAnnotation, overlay: currentOverlay)
    }
}

protocol MapUpdating {
    var mapView: MKMapView! { get }
    var navigationController: UINavigationController? { get }
    func centerMapOnLocation(_ location: CLLocation)
    func addEventOnMap(_ circle: MKCircle, annotation: MKPointAnnotation)
    func removeAnnotation(_ annotation:MKAnnotation, overlay: MKOverlay)
}

extension MapUpdating {
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 3.0, regionRadius * 3.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addEventOnMap(_ circle: MKCircle, annotation: MKPointAnnotation) {
        mapView.add(circle)
        mapView.addAnnotation(annotation)
    }
    
    func removeAnnotation(_ annotation:MKAnnotation, overlay: MKOverlay) {
        mapView.removeAnnotation(annotation)
        mapView.remove(overlay)
    }
    
}

func ==(lhs: MapController, rhs: MapController) -> Bool {
    return true
}



