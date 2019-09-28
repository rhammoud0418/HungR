//
//  RestaurantModel.swift
//  HungR
//
//  Created by Rami Hammoud on 12/2/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import Foundation
import FirebaseFirestore

class RestaurantModel {
    
    private var restaurants: [Restaurant]
    public var uid: String
    
    static let sharedInstance = RestaurantModel()
    
    init() {
        
        self.restaurants = []
        self.uid = ""
    }
    
    func clearRestaurants() {
        self.restaurants = []
    }
    
    func numberOfRestaurants() -> Int {
        return self.restaurants.count
    }
    
    func getRestaurants() -> [Restaurant] {
        return self.restaurants
    }
    
    func getRestaurant(at index: Int) -> Restaurant? {
        if index >= 0 && index < self.restaurants.count {
            return self.restaurants[index]
        }
        else {
            return nil;
        }
    }
    
    func addRestaurant(restaurant: Restaurant) {
        self.restaurants.append(restaurant)
    }
    
    // Writes restaurants to array and to Firebase
    func addRestaurantToMemoryAndDB(restaurant: Restaurant) {
        // Construct db object
        let db: Firestore = Firestore.firestore()
        db.collection("restaurants").document().setData([
            "uid": self.uid,
            "name": restaurant.name,
            "notes": restaurant.notes,
            "latitude": restaurant.latitude,
            "longitude": restaurant.longitude
        ])
        self.restaurants.append(restaurant)
    }
    
    func removeRestaurant(index: Int) {
        if index >= 0 && index < self.restaurants.count {
            // Create the database object
            let restaurant = self.restaurants[index]
            let db: Firestore = Firestore.firestore()
            db.collection("restaurants")
                .whereField("uid", isEqualTo: self.uid)
                .whereField("name", isEqualTo: restaurant.name)
                .whereField("notes", isEqualTo: restaurant.notes).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    // Iterate through all returned documents, construct restaurant to add to the database model
                    for document in querySnapshot!.documents {
                        db.collection("restaurants").document(document.reference.documentID).delete()
                    }
                }
                
            }
            // Remove from restaurants array in memory
            self.restaurants.remove(at: index)
        }
    }
    
    func setUserId(uid: String) {
        self.uid = uid
    }
    
    func getUserId() -> String {
        return self.uid
    }
}
