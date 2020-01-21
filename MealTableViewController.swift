//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Jonalynn Masters on 1/19/2020.
//  Copyright © 2020 Jonalynn Masters. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {

    //MARK: Properties
    
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        // Need to implement delegates (lower in the file).
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            self.meals += savedMeals
        } else {
            // Load the sample data.
            self.loadSampleMeals()
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell
        // identifier.
        let cellIdentifier = "MealTableViewCell"

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath)
            as? MealTableViewCell else {
                fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        let meal = meals[indexPath.row]

        cell.nameLabel.text = meal.foodOrdered
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating ?? 1

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the table view and the data source.
            self.meals.remove(at: indexPath.row)
            self.saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // Rearrange the meals in the meals array to reflect this move.
        let element = self.meals.remove(at: fromIndexPath.row)
        self.meals.insert(element, at: to.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return true because we allow all meals to be reorderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
     
        let id = segue.identifier ?? ""
        switch(id) {
        case "AddItem":
            os_log("Adding a nea meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = self.meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected Segue Identifier; \(id)")
        }
    
    }

    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as?
            MealViewController, let meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new meal, compute where the new cell should be added.
                let newIndexPath = IndexPath(row: self.meals.count, section: 0)
                self.meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the meals.
            self.saveMeals()
        }
        
    }
    
    //MARK: Private Methods
    
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")

        guard let meal1 = Meal(restaurantName: "Buona Forchetta", location: "Liberty Station", hours: "4-10p", foodieReview: "Delicious", foodOrdered: "Caprese", photo: photo1, rating: 0)
            else {
                fatalError("Unable to instantiate meal1")
        }

        guard let meal2 = Meal(restaurantName: "Chicken Joint", location: "Somewhere", hours: "", foodieReview: "Best damn chicken ever", foodOrdered: "Chicken and Potatoes", photo: photo2, rating: 5)
            else {
                fatalError("Unable to instantiate meal2")
        }

        guard let meal3 = Meal(restaurantName: "Noodles and Noodles", location: "My Kitchen", hours: "24/7", foodieReview: "Obviousy Amazing", foodOrdered: "Spaghetti and Meatballs", photo: photo3, rating: 5)
            else {
                fatalError("Unable to instantiate meal3")
        }

        self.meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals saved successfully.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals.", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
}
