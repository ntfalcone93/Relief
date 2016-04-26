//
//  CreateEventViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import CoreLocation

class CreateEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet var typePickerView: UIPickerView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    var currentEventType: EventType?
    var delegate: MapViewController?
    
    // MARK: - IBActions
    @IBAction func confirmButtonTapped(sender: UIButton) {
        guard let eventType = currentEventType else {
            let alertController = UIAlertController(title: "Cannot Create Event Without an Event Type", message: "Please select an Event Type before creating an event", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } // Fire alert
        guard let collectionPoint = addressTextField.text where !collectionPoint.isEmpty else {
            let alertController = UIAlertController(title: "Cannot Create Event Without an Address", message: "Please add an address before creating an event", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } // Fire alert (do check for valid)
        guard let coordinate = delegate?.mapManager?.currentAnnotation?.coordinate else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) // Fire alert
        EventController.sharedInstance.createEvent(eventType, title: "Title Now Disabled", collectionPoint: collectionPoint, location: location) { (success, event) in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName("createEventFinished", object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                // Fire alert
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("createEventFinished", object: nil)
    }
    
    var pickerViewDataSource = [
        EventType.AnimalAndInsectInfestation,
        EventType.ComplexEmergencies,
        EventType.DisplacedPopulations,
        EventType.Drought,
        EventType.DryMassMovement,
        EventType.Earthquakes,
        EventType.Epidemic,
        EventType.ExtremeTemperatues,
        EventType.FamineOrFoodInsecurity,
        EventType.Floods,
        EventType.IndustrialAccidents,
        EventType.StormsAndTidalWaves,
        EventType.TransportAccidents,
        EventType.TropicalStormsHurricanesTyphoonsAndCyclones,
        EventType.Tsunamis,
        EventType.VolcanicEruptions,
        EventType.WetMassMovement,
        EventType.WildfiresAndUrbanFires
    ]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.deregisterFromKeyboardNotifications()
        super.viewWillDisappear(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.updateTextFieldWithAnnotationAddress(self.addressTextField, annotation: (self.delegate?.mapManager?.currentAnnotation)!)
        self.typePickerView.selectRow(5, inComponent: 0, animated: false)
    }
    
    func updateTextFieldWithAnnotationAddress(textField: UITextField, annotation: MKAnnotation) {
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        delegate?.mapManager?.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil && placemarks?.count > 0 {
                let placemark = placemarks?.last
                guard let thoroughfare = placemark?.thoroughfare,
                    postalCode = placemark?.postalCode,
                    locality = placemark?.locality else {
                        return
                }
                textField.text = "\(thoroughfare), \(postalCode) \(locality)"
            }
        })
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: "UIKeyboardWillShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: "UIKeyboardWillHideNotificatin", object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardDidHideNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    func keyboardWasShown(notification:NSNotification) {
        if let info = notification.userInfo! as? NSDictionary {
            let keyboardSize: CGSize = (info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue().size)!
            let buttonOrigin: CGPoint = self.confirmButton.frame.origin
            let buttonHeight: CGFloat = self.confirmButton.frame.size.height
            let pixelsAboveKeyboard: CGFloat = 25
            var visibleRect: CGRect = self.view.frame
            visibleRect.size.height -= keyboardSize.height
            if !CGRectContainsPoint(visibleRect, buttonOrigin) {
                let scrollPoint: CGPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + pixelsAboveKeyboard)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification:NSNotification) {
        self.scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewDataSource.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerViewDataSource[row].rawValue
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentEventType = pickerViewDataSource[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        addressTextField.delegate = self
        self.configureView()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.addressTextField {
            self.addressTextField.attributedPlaceholder = NSAttributedString(string: "Collection Address", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        }
    }
    
    func configureView() {
        self.addressTextField.attributedPlaceholder = NSAttributedString(string: "Collection Address", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.confirmButton.setBackgroundImage(UIImage(named: "login"), forState: UIControlState.Normal)
        self.confirmButton.tintColor = UIColor.reliefBlack()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
