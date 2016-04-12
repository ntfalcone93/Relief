//
//  MainViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    // MARK: - IBActions
    @IBAction func createEventButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showEventInformation", sender: nil)
    }
    
}
