//
//  ToastMessage.swift
//
//  Created by Pranay on 23/10/24.
//

import Foundation
import UIKit

class ToastMessage {
    
    // Singleton instance
    static let shared = ToastMessage()
    
    // Prevent external instantiation
    //private init() {}
    
    enum ToastType {
        case success
        case warning
        case failure
    }
    
    enum ToastPosition {
        case top
        case center
        case bottom
    }
    
    // Default colors
    //private var defaultSuccessBackgroundColor = UIColor.green.withAlphaComponent(0.8)
    private var defaultSuccessBackgroundColor = UIColor(red: 106/255, green: 168/255, blue: 79/255, alpha: 0.8)
    private var defaultWarningBackgroundColor = UIColor.orange.withAlphaComponent(0.7)
    private var defaultFailureBackgroundColor = UIColor.red.withAlphaComponent(0.7)
    
    private var defaultTextColor = UIColor.white
    
    // Show toast function
    func showToast(message: String,
                       type: ToastType,
                       position: ToastPosition = .bottom,  // Default position is bottom
                       backgroundColor: UIColor? = nil,    // Custom background color
                       textColor: UIColor? = nil,          // Custom text color
                       duration: TimeInterval = 3.0,
                       inView view: UIView,
                       animated: Bool = false) {           // Optional animation
        
        // Create the label to show the toast message
        let toastLabel = UILabel()
        toastLabel.backgroundColor = getBackgroundColor(for: type, customColor: backgroundColor)
        toastLabel.textColor = textColor ?? defaultTextColor
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0.0  // Start invisible if animation is true
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        // Calculate the size of the label based on message content
        let maxSize = CGSize(width: view.frame.size.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let expectedSize = toastLabel.sizeThatFits(maxSize)
        toastLabel.frame = CGRect(x: 20, y: 0, width: view.frame.size.width - 40, height: expectedSize.height + 20)
        
        // Set initial position (off-screen if animated)
        setToastInitialPosition(label: toastLabel, position: position, inView: view, animated: animated)
        
        // Add the toastLabel to the view
        view.addSubview(toastLabel)
        
        // Animate the toast appearance
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                // Final position after animation
                self.setToastFinalPosition(label: toastLabel, position: position, inView: view)
                toastLabel.alpha = 1.0
                if position == .center {
                    // Animate the "popup" effect for center position
                    toastLabel.transform = CGAffineTransform.identity
                }
            })
        } else {
            // If no animation, show the toast in the final position
            setToastFinalPosition(label: toastLabel, position: position, inView: view)
            toastLabel.alpha = 1.0
        }
        
        // Animation to fade out the toast message
        UIView.animate(withDuration: 1.0, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            // Set exit animations based on position
            self.setToastExitPosition(label: toastLabel, position: position, inView: view, animated: animated)
        }) { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    }
    
    // Get background color based on toast type
    private func getBackgroundColor(for type: ToastType, customColor: UIColor?) -> UIColor {
        if let customColor = customColor {
            return customColor
        } else {
            switch type {
            case .success:
                return defaultSuccessBackgroundColor
            case .warning:
                return defaultWarningBackgroundColor
            case .failure:
                return defaultFailureBackgroundColor
            }
        }
    }
    
    // Set initial position off-screen for animation
    private func setToastInitialPosition(label: UILabel, position: ToastPosition, inView view: UIView, animated: Bool) {
        if animated {
            switch position {
            case .top:
                label.center = CGPoint(x: view.frame.size.width / 2, y: -label.frame.height)
            case .bottom:
                label.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height + label.frame.height)
            case .center:
                // For center, start with a scaled-down label
                label.center = view.center
                label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        } else {
            // If no animation, set directly to final position
            setToastFinalPosition(label: label, position: position, inView: view)
        }
    }
    
    // Set final position (where the toast will end up)
    private func setToastFinalPosition(label: UILabel, position: ToastPosition, inView view: UIView) {
        switch position {
        case .top:
            label.center = CGPoint(x: view.frame.size.width / 2, y: 80)
        case .center:
            label.center = view.center
        case .bottom:
            label.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height - 100)
        }
    }
    
    // Set exit position for disappearing animation
    private func setToastExitPosition(label: UILabel, position: ToastPosition, inView view: UIView, animated: Bool) {
        if animated {
            switch position {
            case .top:
                label.center = CGPoint(x: view.frame.size.width / 2, y: -label.frame.height) // Slide out to top
            case .bottom:
                label.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height + label.frame.height) // Slide out to bottom
            case .center:
                // Scale down for center position
                label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        }
    }
}
