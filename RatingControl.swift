//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Jonalynn Masters on 1/19/2020.
//  Copyright © 2020 Jonalynn Masters. All rights reserved.
//

import UIKit

// Need @IBDesignable so that the Interface Builder can instantiate and draw
// a copy of the controld irectly in the canvas, and the layout engine can
// properly position and size the control. Without it, we get warnings/errors.
@IBDesignable class RatingControl: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    //MARK: Properties
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        // If a rating was changed, update selected state of all buttons.
        didSet {
            self.updateButtonSelectionStates()
        }
    }
    
    // The @IBInspectable annotation lets us set these vlaues in the
    // Attributes inspector on the right sidebar.
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        // If we edit this property, set up the buttons with new values.
        didSet {
            self.setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        // If we edit this property, set up the buttons with new values.
        didSet {
            self.setupButtons()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setupButtons()
    }
    
    //MARK: Private Methods
    
    private func setupButtons() {
        // Clear existing buttons.
        for button in self.ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load button images.
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle,
                                 compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle,
                                 compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle,
                                 compatibleWith: self.traitCollection)
        // Create 5 new buttons.
        for index in 0..<self.starCount {
            let button = UIButton()
            
            // Set button images.
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(
                equalToConstant: self.starSize.height).isActive = true
            button.widthAnchor.constraint(
                equalToConstant: self.starSize.width).isActive = true
            
            // Set accessibility label.
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            // Set button action.
            button.addTarget(self, action:
                #selector(RatingControl.ratingButtonTapped(button:)),
                for: .touchUpInside)
            
            // Add button to the horizontal stack view.
            // This function call adds the view to the list of views managed by
            // RatingControl, which is set on the HorizontalStackView UI object.
            addArrangedSubview(button)
            
            // Add to our array to keep a reference to the button.
            self.ratingButtons.append(button)
        }
        
        self.updateButtonSelectionStates()
    }
    
    //Mark: Button Action
    // Need the @objc annotation so that the method is visible to #selector.
    @objc private func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // Calculate rating of the selected button.
        let selectedRating = index + 1
        
        if selectedRating == self.rating {
            // Reset the rating to 0 if the user pressed the same rating they
            // already pressed.
            self.rating = 0
        } else {
            // Otherwise, set the new rating.
            self.rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // Set the hint string for the currently selected star.
            let hintString: String?
            if self.rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string.
            let valueString: String
            switch (self.rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(self.rating) stars set."
            }
            
            // Assign hint string and value string for accessibility.
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
            
            // If index of a button is less than the rating, that button should
            // be selected.
            button.isSelected = index < self.rating
        }
    }
}
