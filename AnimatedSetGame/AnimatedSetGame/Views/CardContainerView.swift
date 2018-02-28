//
//  CardContainerView.swift
//  GraphicalSetGamee
//
//  Created by Tiago Maia Lopes on 09/02/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The view responsible for holding and displaying the cardButtons.
class CardContainerView: UIView {
  
  // MARK: Properties
  
  /// The translated deck frame used by the dealing animation.
  /// - Note: This frame is the origin and size for all added buttons.
  ///         When the deal animation takes place, all cards will fly from
  ///         this frame to each destination.
  var deckFrame: CGRect!
  
  /// The translated matched deck frame used by the removal animation.
  /// - Note: This frame is the origin and size for all added buttons.
  ///         When the deal animation takes place, all cards will fly from
  ///         this frame to each destination.
  var matchedDeckFrame: CGRect!
  
  /// The contained buttons.
  private(set) var buttons = [SetCardButton]()
  
  /// The grid in charge of generating the calculated
  /// frame of each contained button.
  private(set) var grid = Grid(layout: Grid.Layout.aspectRatio(3/2))
  
  /// The centered rect in which the buttons are going to be positioned.
  private var centeredRect: CGRect {
    get {
      return CGRect(x: bounds.size.width * 0.025,
                    y: bounds.size.height * 0.025,
                    width: bounds.size.width * 0.95,
                    height: bounds.size.height * 0.95)
    }
  }

  // MARK: View life cycle
  
  override func layoutSubviews() {
    super.layoutSubviews()

    grid.frame = centeredRect
    
    for (i, button) in buttons.enumerated() {
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                     delay: 0,
                                                     options: .allowUserInteraction,
                                                     animations: {
                                                      if let frame = self.grid[i] {
                                                        button.frame = frame
                                                      }
      })
    }
  }
  
  // MARK: Imperatives
  
  /// Adds new buttons to the UI.
  /// - Parameter byAmount: The number of buttons to be added.
  func addCardButtons(byAmount numberOfButtons: Int = 3) {
    let cardButtons = (0..<numberOfButtons).map { _ in SetCardButton() }
    
    for button in cardButtons {
      addSubview(button)
      button.frame = deckFrame
    }

    grid.cellCount += cardButtons.count
    grid.frame = centeredRect
    
    // Deal animation.
    var dealAnimationDelay = 0.15
    // TODO: use DynamicAnimator to deal cards.
    for (i, button) in cardButtons.enumerated() {
      UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                     delay: dealAnimationDelay,
                                                     options: .allowUserInteraction,
                                                     animations: {
                                                      if let frame = self.grid[i] {
                                                        button.frame = frame
                                                      }
      })
      
      dealAnimationDelay += 0.2
    }
    
    buttons += cardButtons
    
    setNeedsLayout()
  }
  
  /// Removes n buttons from the button container.
  func removeCardButtons(byAmount numberOfCards: Int) {
    guard buttons.count >= numberOfCards else { return }
  
    for index in 0..<numberOfCards {
      let button = buttons[index]
      button.removeFromSuperview()
    }
    
    buttons.removeSubrange(0..<numberOfCards)
    grid.cellCount = buttons.count
    
    setNeedsLayout()
  }
  
  /// Animates the passed buttons out of the table and on
  /// to the pile of matched cards.
  ///
  /// - Note: The animation takes place in three steps:
  ///         * A scale transformation is applied
  ///         * The buttons are concentrated in the center of this view
  ///         * The cards are flipped
  ///         * The cards are put in the matched pile
  func animateMatchedCardButtonsOut(_ buttons: [SetCardButton]) {
    guard matchedDeckFrame != nil else { return }
    
    for button in buttons {
      // Creates the button copy used to be animated.
      let buttonCopy = button.copy(with: nil) as! SetCardButton
      addSubview(buttonCopy)
      
      // Hides the original button.
      button.alpha = 0
      
      // Starts animating by scaling each button.
      UIViewPropertyAnimator.runningPropertyAnimator(
        withDuration: 0.1,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          
          buttonCopy.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
          
        }, completion: { position in
          
          // Animates each card to the center of the container view.
          UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
              
              buttonCopy.center = self.center
              
            }, completion: { position in
              
              // Flips each card down
              buttonCopy.flipCard() { button in
                
                // Animates each card to the matched deck.
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2,
                                                               delay: 0.2,
                                                               options: .curveEaseInOut,
                                                               animations: {
                                                                button.frame = self.matchedDeckFrame
                })
              }
            }
          )
        }
      )
    }
  }
  
  /// Removes all buttons from the container.
  func clearCardContainer() {
    buttons = []
    grid.cellCount = 0
    removeAllSubviews()
    setNeedsLayout()
  }

}

extension UIView {
  
  /// Removes all subviews.
  func removeAllSubviews() {
    for subview in subviews {
      subview.removeFromSuperview()
    }
  }
  
}
