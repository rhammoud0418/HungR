//
//  ShowRestaurantViewController.swift
//  HungR
//
//  Created by Rami Hammoud on 12/4/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ShowRestaurantViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var restaurant: Restaurant?
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Initialize notes label, navbar to show info about
        notesLabel.text = "Notes: \(restaurant!.notes)"
        self.navigationBar.topItem?.title = restaurant!.name
        
        // Configure and add the restaurant annotation to the map
        let restaurantAnnotation = MKPointAnnotation()
        restaurantAnnotation.coordinate = CLLocationCoordinate2D(latitude: restaurant!.latitude, longitude: restaurant!.longitude)
        restaurantAnnotation.title = restaurant!.name
        self.mapView.addAnnotation(restaurantAnnotation)
        
        // Handle display of user
        checkLocationAuthorizationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLocationAuthorizationStatus() {
        // Check that user has authorized location stuff
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // The user's current location + logic to zoom into them
            let restaurantLocation = CLLocationCoordinate2D(latitude: restaurant!.latitude, longitude: restaurant!.longitude)
            let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(restaurantLocation, 500, 500)
            let adjustedRegion = self.mapView.regionThatFits(viewRegion)
            self.mapView.setRegion(adjustedRegion, animated: true)
            // Show the user's location on the map
            mapView.showsUserLocation = true
            
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Dismiss this scene, goes back to table view
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func openInMapsButton(_ sender: Any) {
        
        // Get lat and long from the restaurant object
        let latitude:CLLocationDegrees = self.restaurant!.latitude
        let longitude:CLLocationDegrees = self.restaurant!.longitude
        // Configure the frame the user will see in Apple Maps
        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        // Set up options for Apple Maps(center and the region span)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        // Put the mark down in Apple Maps
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        // Set up the item Apple Maps will display
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.restaurant!.name)"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
}
