//
//  MainViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import MapKit


// enum denoting the current state of the view
// if map is shown the mode is mapshown and vice versa
enum ToggleMode {
    case MapShown
    case MapHidden
}

class MainViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    // toggle mode is initially set to Mapshown
    var toggleMode = ToggleMode.MapShown
    
    
    override func viewDidLoad() {
        
        // First call to toggle map is made, toggle mode is 
        // updated and map is hidden for initial interaction
        toggleMap()
    }
    
    
    // MARK: - IBActions
    @IBAction func createEventButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showEventInformation", sender: nil)
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
