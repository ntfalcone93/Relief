//
//  CreateEventViewController.swift
//  Relief
//
//  Created by Dylan Slade on 4/12/16.
//  Copyright © 2016 Relief Group. All rights reserved.
//

import UIKit
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CreateEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    // MARK: - IBOutlets
    @IBOutlet var typePickerView: UIPickerView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    var currentEventType: EventType?
    var delegate: MapViewController?
    
    // MARK: - IBActions
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let eventType = currentEventType else {
            let alertController = UIAlertController(title: "Cannot Create Event Without an Event Type", message: "Please select an Event Type before creating an event", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        } // Fire alert
        guard let collectionPoint = addressTextField.text, !collectionPoint.isEmpty else {
            let alertController = UIAlertController(title: "Cannot Create Event Without an Address", message: "Please add an address before creating an event", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        } // Fire alert (do check for valid)
        guard let coordinate = delegate?.mapManager?.currentAnnotation?.coordinate else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) // Fire alert
        EventController.sharedInstance.createEvent(eventType, title: "Title Now Disabled", collectionPoint: collectionPoint, location: location) { (success, event) in
            if success {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "createEventFinished"), object: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                // Fire alert
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "createEventFinished"), object: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.deregisterFromKeyboardNotifications()
        super.viewWillDisappear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.updateTextFieldWithAnnotationAddress(self.addressTextField, annotation: (self.delegate?.mapManager?.currentAnnotation)!)
        self.typePickerView.selectRow(5, inComponent: 0, animated: false)
    }
    
    func updateTextFieldWithAnnotationAddress(_ textField: UITextField, annotation: MKAnnotation) {
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        delegate?.mapManager?.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil && placemarks?.count > 0 {
                let placemark = placemarks?.last
                guard let thoroughfare = placemark?.thoroughfare,
                    let postalCode = placemark?.postalCode,
                    let locality = placemark?.locality else {
                        return
                }
                textField.text = "\(thoroughfare), \(postalCode) \(locality)"
            }
        })
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotificatin"), object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardDidHideNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }
    
    func keyboardWasShown(_ notification:Notification) {
        if let info = notification.userInfo! as? NSDictionary {
            let keyboardSize: CGSize = ((info.object(forKey: UIKeyboardFrameBeginUserInfoKey) as AnyObject).cgRectValue.size)
            let buttonOrigin: CGPoint = self.confirmButton.frame.origin
            let buttonHeight: CGFloat = self.confirmButton.frame.size.height
            let pixelsAboveKeyboard: CGFloat = 25
            var visibleRect: CGRect = self.view.frame
            visibleRect.size.height -= keyboardSize.height
            if !visibleRect.contains(buttonOrigin) {
                let scrollPoint: CGPoint = CGPoint(x: 0.0, y: buttonOrigin.y - visibleRect.size.height + buttonHeight + pixelsAboveKeyboard)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification:Notification) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewDataSource.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = pickerViewDataSource[row].rawValue
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentEventType = pickerViewDataSource[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        addressTextField.delegate = self
        self.configureView()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.addressTextField {
            self.addressTextField.attributedPlaceholder = NSAttributedString(string: "Collection Address", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        }
    }
    
    func configureView() {
        self.addressTextField.attributedPlaceholder = NSAttributedString(string: "Collection Address", attributes: [NSForegroundColorAttributeName: UIColor.reliefPlaceHolderYellow()])
        self.confirmButton.setBackgroundImage(UIImage(named: "login"), for: UIControlState())
        self.confirmButton.tintColor = UIColor.reliefBlack()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
