//
//  RestaurantTableViewController.swift
//  HungR
//
//  Created by Rami Hammoud on 12/2/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RestaurantTableViewController: UITableViewController {
    
    var db: Firestore!
    
    var restaurantModel = RestaurantModel.sharedInstance

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set right bar button to the designated edit button
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        // Configure the database reference object
        db = Firestore.firestore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // For number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantModel.numberOfRestaurants()
    }

    // For displaying each restaurant cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let restaurantCell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)

        if let restaurant = restaurantModel.getRestaurant(at: indexPath.row) {
            restaurantCell.textLabel!.text = restaurant.name
        }
        else {
            restaurantCell.textLabel!.text = "No restaurants yet, try adding one!"
        }
        
        restaurantCell.accessoryType = .disclosureIndicator

        return restaurantCell
    }
    
    // When cell of the table pressed, segue to the ShowRestaurantViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        performSegue(withIdentifier: "ShowRestaurantSegue", sender: index)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the restaurant from the model
            restaurantModel.removeRestaurant(index: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    // Prepare for the 2 segues, AddRestaurantSegue and ShowRestaurantSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Means we need to add a restaurant to the database and in memory
        if segue.identifier == "AddRestaurantSegue", let addViewController = segue.destination as? AddRestaurantViewController {
            addViewController.completionHandler = { name, notes, latitude, longitude in
                let newRestaurant = Restaurant(name: name, notes: notes, latitude: latitude, longitude: longitude)
                self.restaurantModel.addRestaurantToMemoryAndDB(restaurant: newRestaurant)
                self.tableView.reloadData()
            }
        }
        // Means the user pressed on a restaurant cell, and we navigate them to the ShowRestaurantViewController
        else if (segue.identifier == "ShowRestaurantSegue") {
            if let destinationVC = segue.destination as? ShowRestaurantViewController {
                if let index = sender as? Int {
                    let selectedRestaurant = restaurantModel.getRestaurant(at: index)
                    destinationVC.restaurant = selectedRestaurant
                    
                }
            }
           
        }
    }

}
