//
//  ToastView.swift
//  GEClone-UI
//
//  Created by Auxano on 23/10/24.
//

import Foundation
import UIKit
import SwiftUI

enum ToastType {
    case success
    case warnnnig
    case failure
}

enum ToastPosition {
    case top
    case bottom
}

class ToastView: UIView {
    
    private let messageLabel = UILabel()
    
    init(message: String, type: ToastType, position: ToastPosition = .bottom) {
        super.init(frame: .zero)
        self.setupView(message: message, type: type, position: position)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(message: String, type: ToastType, position: ToastPosition) {
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        
        // Configure background and text color based on Toast type
        switch type {
            
        case .success:
            self.backgroundColor = UIColor.systemGreen
            messageLabel.textColor = UIColor.white
        case .warnnnig:
            self.backgroundColor = UIColor.systemOrange
            messageLabel.textColor = UIColor.white
        case .failure:
            self.backgroundColor = UIColor.systemRed
            messageLabel.textColor = UIColor.white
        }
        
        // Layout constraints for the label
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
        ])
        
        // Rounded corners
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    // Function to display the toast message
    func showToast(on parentView: UIView, duration: TimeInterval = 2.0, position: ToastPosition = .bottom) {
        parentView.addSubview(self)
        
        // Set the initial frame and position
//        if position == .bottom {
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
                self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
                self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50)
            ])
//        }
//        else {
//            NSLayoutConstraint.activate([
//                self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
//                self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
//                self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 20),
//            ])
//        }
        
        // Initial state
        self.alpha = 0.0
        
        // Animation to show the toast
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { _ in
            // Hide after delay
            UIView.animate(withDuration: 0.3, delay: duration,options: .curveEaseOut, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
    
    static func showToast(message: String, type: ToastType, on parentView: UIView, duration: TimeInterval = 2.0) {
        let toast = ToastView(message: message, type: type)
        toast.showToast(on: parentView, duration: duration)
    }
}
