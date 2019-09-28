//
//  ViewController.swift
//  HungR
//
//  Created by Rami Hammoud on 11/26/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    var db: Firestore!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logInSegmentedControl: UISegmentedControl!
    @IBOutlet weak var logInLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    let restaurantModel = RestaurantModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text fields to have delegate of self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Set up logInLabel to "Sign In" to start
        logInLabel.text = "Sign In"
        self.errorMessageLabel.text = ""
        
        // Sign in button disable to start
        signInButton.isEnabled = false
        self.signInButton.backgroundColor = UIColor.lightGray
        
        // Initialize database object
        self.db = Firestore.firestore()
    }
    
    // Logic for log in button press
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        // Retrieve email and password from text fields
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        // Get the index from the segmented control
        let index = logInSegmentedControl.selectedSegmentIndex
        
        // Sign in
        if logInSegmentedControl.titleForSegment(at: index) == "Sign In" {
            
            // Auth method to sign in the user
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                // Call back closure
                // No errors
                if error == nil && user != nil {
                    
                    // Retrieve the user id from the newly signed in user
                    let uid = user!.user.uid
                    
                    // Configure the singleton's user id
                    self.restaurantModel.setUserId(uid: uid)
                    
                    // Retrieve all the restaurants from the databse, store them in the user restaurantModel singleton
                    self.db.collection("restaurants").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        }
                        else {
                            // Iterate through all returned documents, construct restaurant to add to the database model
                            for document in querySnapshot!.documents {
                                let restaurantDict = document.data()
                                let name = restaurantDict["name"] as! String
                                let notes = restaurantDict["notes"] as! String
                                let latitude = restaurantDict["latitude"] as! Double
                                let longitude = restaurantDict["longitude"] as! Double
                                let restaurantFromDB = Restaurant(name: name, notes: notes, latitude: latitude, longitude: longitude)
                                self.restaurantModel.addRestaurant(restaurant: restaurantFromDB)
                            }
                            // Finally segue to next secreen
                            self.performSegue(withIdentifier: "LogInSegue", sender: self)
                        }
                        
                    }
                    
                }
                // Got an error!
                else {
                    
                    // display error for the user
                    self.errorMessageLabel.text = error!.localizedDescription
                    
                }
            }
            
        }
        // Create user
        else {
            // Auth method to create a user
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                // Closure for callback
                // No errors
                if error == nil && user != nil {
                    // Configure singleton's user id
                    self.restaurantModel.setUserId(uid: user!.user.uid)
                    // Segue into the map scene
                    self.performSegue(withIdentifier: "LogInSegue", sender: self)
                    
                }
                // Got an error!
                else {
                    // display error for user
                    self.errorMessageLabel.text = error!.localizedDescription
                }
            }
        }
    }
    // Dismiss keyboard when outside touches occur
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Bring up keyboard on edit
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    // Called as text is being typed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            // If statements to check which text field is being modified
            if textField == emailTextField {
                // Check if sign in button should be enabled
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                enableSignInButton(emailText: updatedText, passwordText: passwordTextField.text!)
            }
            else {
                // Check if sign in button should be enabled
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                enableSignInButton(emailText: emailTextField.text!, passwordText: updatedText)
            }
            self.errorMessageLabel.text = ""
        }
        return true;
        
    }
    
    // Dismiss keyboard when return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Check if the sign in button should be enabled, and if so enable it
    func enableSignInButton(emailText: String, passwordText: String) {
        // Will be true if button should be enabled
        self.signInButton.isEnabled = emailText.count > 0 && passwordText.count > 0
        // If button is disabled, make sure it is gray so user knows it is disabled
        if self.signInButton.isEnabled == false {
            self.signInButton.backgroundColor = UIColor.lightGray
        }
        // If button is enabled, make srue it is enabled
        else {
            self.signInButton.backgroundColor = UIColor(red: 235/255.0, green: 92/255.0, blue: 96/255.0, alpha: 1)
        }
    }
    
    // Toggle Sign in/ Create User for segmented control
    @IBAction func segmentedControlPressed(_ sender: Any) {
        // Change logInLabel and signInButton to the appropriate text based on Sign in / Create User mode
        let index = self.logInSegmentedControl.selectedSegmentIndex
        if self.logInSegmentedControl.titleForSegment(at: index) == "Sign In" {
            self.logInLabel.text = "Sign In"
            self.signInButton.setTitle("Sign In", for: .normal)
        }
        else {
            self.logInLabel.text = "Create Account"
            self.signInButton.setTitle("Create Account", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

