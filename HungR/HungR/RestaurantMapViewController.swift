//
//  RestaurantMapViewController.swift
//  HungR
//
//  Created by Rami Hammoud on 12/2/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

class RestaurantMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var db: Firestore!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var namesToRestaurants = [String: Restaurant]()
    
    let restaurantModel = RestaurantModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize locationManger
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.mapView.delegate = self
        db = Firestore.firestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Load the annotations every time this view shows up, to account for newly added locations
        self.loadAnnotations()
        self.checkLocationAuthorizationStatus()
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let restaurant = namesToRestaurants[(view.annotation?.title!)!] {
            self.performSegue(withIdentifier: "ShowRestaurantFromMapSegue", sender: restaurant)
        }
    }
    
    func checkLocationAuthorizationStatus() {
        // Check if user has authorized us to get their location
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // Logic for zooming into the user's view
            let userLocation: CLLocationCoordinate2D = locationManager.location!.coordinate
            let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation, 500, 500)
            let adjustedRegion = self.mapView.regionThatFits(viewRegion)
            self.mapView.setRegion(adjustedRegion, animated: true)
            // Show the user
            mapView.showsUserLocation = true
            
        }
        // Ask user for location
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Loads annotations for restaurants
    func loadAnnotations() {
        // Clear the initial annotations first
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        // Retrieve restaurants, add annotaiton for each of them
        let restaurants = restaurantModel.getRestaurants()
        for restaurant in restaurants {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            annotation.title = restaurant.name
            self.namesToRestaurants[restaurant.name] = restaurant
            mapView.addAnnotation(annotation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ShowRestaurantViewController {
            if let restaurant = sender as? Restaurant {
                destinationVC.restaurant = restaurant
            }
        }
    }

}
