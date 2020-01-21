//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jonalynn Masters on 1/19/2020.
//  Copyright © 2020 Jonalynn Masters. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate,
  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    
    // Make these weak to avoid circular dependencies for ARC
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var restaurantTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var hoursTextField: UITextField!
     @IBOutlet weak var foodieReviewTextView: UITextView!
    
    var meal: Meal?
    @IBOutlet var saveButton: UIBarButtonItem!
    
    //MARK: ViewController delegate functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        self.foodTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = self.meal {
            self.navigationItem.title = meal.foodOrdered
            self.foodTextField.text = meal.foodOrdered
            self.restaurantTextField.text = meal.foodOrdered
            self.locationTextField.text = meal.foodOrdered
            self.hoursTextField.text = meal.foodOrdered
            self.photoImageView.image = meal.photo
            self.ratingControl.rating = meal.rating ?? 1
            self.foodTextField.text = meal.foodOrdered
        }
        
        // Enable the save button only if the text field has a valid Meal name.
        self.updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the
        // image. You may want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
                
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button
        // is pressed. First verify that the sender is the saveButton.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let foodOrdered = foodTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let restaurantName = restaurantTextField.text
        let location = locationTextField.text
        let hours = hoursTextField.text
        let foodieReview = foodieReviewTextView.text
        
        // Set the meal to be passed to MealTableViewController after the
        // unwind segue.
        self.meal = Meal(restaurantName: restaurantName ?? "Restaurant", location: location ?? "Some Location", hours: hours ?? "Hours", foodieReview: foodieReview ?? "My Expert Foodie Opinion", foodOrdered: foodOrdered, photo: photo, rating: rating)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push), this view
        // controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            // The NaviationController presents it if it was clicked via Add.
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            // Pop current view controller (the meal detail scene) off the
            // nagivation stack.
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    //MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(
      _ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        foodTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick
        // media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = foodTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

