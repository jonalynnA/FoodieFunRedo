//
//  Meal.swift
//  FoodTracker
//
//  Created by Jonalynn Masters on 1/19/2020.
//  Copyright © 2020 Jonalynn Masters. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject, NSCoding {
    
    //Mark: Properties
    var restaurantName: String
    var location: String
    var hours: String?
    var foodieReview: String?
    var foodOrdered: String
    var photo: UIImage?
    var rating: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    
    struct PropertyKey {
        static let foodOrdered = "food ordered"
        static let restaurantName = "Restaurant Name"
        static let location = "location"
        static let hours = "hours"
        static let foodieReview = "foodie review"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    //Mark: Initialization
    
    init?(restaurantName: String, location: String, hours: String?, foodieReview: String?, foodOrdered: String, photo: UIImage?, rating: Int) {
        // The name must not be empty.
        guard !foodOrdered.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively.
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.foodOrdered = foodOrdered
        self.restaurantName = restaurantName
        self.location = location
        self.hours = hours
        self.photo = photo
        self.rating = rating
        self.foodieReview = foodieReview
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(foodOrdered, forKey: PropertyKey.foodOrdered)
        aCoder.encode(restaurantName, forKey: PropertyKey.restaurantName)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(hours, forKey: PropertyKey.hours)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    // A secondary initializaer, must call a designated initailizer from the
    // same class.
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let foodOrdered = aDecoder.decodeObject(forKey: PropertyKey.foodOrdered) as? String else {
            os_log("Unable to decode the food ordered for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let hours = aDecoder.decodeObject(forKey: PropertyKey.hours) as? String else {
            os_log("Unable to decode the hours for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let foodieReview = aDecoder.decodeObject(forKey: PropertyKey.foodieReview) as? String else {
                  os_log("Unable to decode the foodieReview for a Meal object.", log: OSLog.default, type: .debug)
                  return nil
              }
        let restaurantName = aDecoder.decodeObject(forKey: PropertyKey.restaurantName)
        let location = aDecoder.decodeObject(forKey: PropertyKey.location)
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer.
        self.init(restaurantName: restaurantName as! String, location: location as! String, hours: hours, foodieReview: foodieReview as! String, foodOrdered: foodOrdered, photo: photo, rating: rating)
    }
}
