//
//  Restaurant.swift
//  HungR
//
//  Created by Rami Hammoud on 12/2/18.
//  Copyright © 2018 Rami Hammoud. All rights reserved.
//

import Foundation

struct Restaurant {
    
    var name: String
    var notes: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, notes: String, latitude: Double, longitude: Double) {
        self.name = name
        self.notes = notes
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
}
