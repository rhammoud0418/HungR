//
//  AddRestaurantViewController.swift
//  HungR
//
//  Created by Rami Hammoud on 12/2/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddRestaurantViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var submitButton: UIButton!
    
    var completionHandler: ((_ name: String, _ notes: String, _ latitude: Double, _ longitutde: Double) -> Void)?
    
    var locationManager = CLLocationManager()
    let newRestaurantPin = MKPointAnnotation()
    var restaurantPinDropped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize locationManager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Disable submitButton to start(nothing inputted yet)
        submitButton.isEnabled = false
        
        // Set border width and color for textField and textView
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.borderWidth = 1.0
        nameTextField.delegate = self
        notesTextView.text = "Notes"
        notesTextView.textColor = UIColor.lightGray
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.delegate = self
        
        // Dismiss on outsideTap
        let outsideTap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        outsideTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(outsideTap)
        
        // Detect long press on map, call mapLongPress() when this happens
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(AddRestaurantViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPress)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //  Disable submit button
        self.submitButton.backgroundColor = UIColor.lightGray
        self.submitButton.isEnabled = false
        self.restaurantPinDropped = false
        checkLocationAuthorizationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss on cancel button press
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Dismiss on submit button press
    @IBAction func submitPressed(_ sender: Any){
        // Check that fields are filled
        if let name = nameTextField.text, let notes = notesTextView.text, let completionHandler = self.completionHandler {
                // Complete pass coordinates, name, notes to table view, which will add the new restaurant
                completionHandler(name, notes, newRestaurantPin.coordinate.latitude, newRestaurantPin.coordinate.longitude)
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    // Add a pin when the user long presses on the map view
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        // Location that they touched at
        let touchedAt = recognizer.location(in: self.mapView)
        let touchedAtCoordinate: CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
        newRestaurantPin.coordinate = touchedAtCoordinate
        // Actually add a pin if they haven't done so already
        if self.restaurantPinDropped == false {
            mapView.addAnnotation(newRestaurantPin)
            self.restaurantPinDropped = true
            enableSubmitButton(nameText: nameTextField.text!, notesText: notesTextView.text!)
        }
    }
    
    func checkLocationAuthorizationStatus() {
        // Check that user has authorized location stuff
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // The user's current location + logic to zoom into them
            let userLocation: CLLocationCoordinate2D = locationManager.location!.coordinate
            let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation, 500, 500)
            let adjustedRegion = self.mapView.regionThatFits(viewRegion)
            self.mapView.setRegion(adjustedRegion, animated: true)
            // Show the user's location on the map
            mapView.showsUserLocation = true
            
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Bring up keyboard on edit
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    // Update the text when user types something
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            enableSubmitButton(nameText: updatedText, notesText: notesTextView.text!)
        }
        print("edit")
        return true;
        
    }
    
    // When return pressed, resign first responder
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    // Update text in textView when the user types stuff in it
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let text = textView.text, let textRange = Range(range, in: text) {
            
            let updatedText = text.replacingCharacters(in: textRange, with: text)
            enableSubmitButton(nameText: nameTextField.text!, notesText: updatedText)
            
        }
        
        return true;
        
    }
    
    // Bring up keyboard on edit
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // Resign the textView keyboard when they are done
    func textViewDidEndEditing(_ textView: UITextView) {
        
        textView.resignFirstResponder()
        
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGray
        }
        
    }

    
    
    
    func enableSubmitButton(nameText: String, notesText: String) {
        self.submitButton.isEnabled = nameText.count > 0 && notesText.count > 0 && restaurantPinDropped == true
        if self.submitButton.isEnabled == false {
            self.submitButton.backgroundColor = UIColor.lightGray
        }
        else {
            self.submitButton.backgroundColor = UIColor(red: 235/255.0, green: 92/255.0, blue: 96/255.0, alpha: 1)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
