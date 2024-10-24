//
//  CustomPopupView.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import Foundation
import UIKit

enum PopupType {
    case confirmation
    case text
    case displayMessage
}

class CustomPopupView: UIView {
    
    // Singleton instance
    static let shared = CustomPopupView()
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let textField = UITextField()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let contentView = UIView()
    
    // MARK: - Default Properties
    var popupColor: UIColor = .white
    var titleColor: UIColor = .white
    var messageColor: UIColor = .darkGray
    var confirmButtonColor: UIColor = .white
    var confirmButtonBgColor: UIColor = .systemBlue
    var cancelButtonColor: UIColor = .white
    var cancelButtonBgColor: UIColor = .systemRed
    var titleViewBackgroundColor: UIColor = .systemBlue
        
    
    
    var confirmButtonText: String = "Ok"
    var cancelButtonText: String = "Close"
    
    // Completion handlers for button actions
    private var onConfirm: ((String?) -> Void)?
    private var onCancel: (() -> Void)?
    
    // Private initializer to prevent external instantiation
    private init() {
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func setupView(
        title: String,
        message: String,
        dialogType: DialogType,
        hideCancelButton: Bool,
        popupColor: UIColor?,
        titleColor: UIColor?,
        messageColor: UIColor?,
        confirmButtonColor: UIColor?,
        confirmButtonBgColor: UIColor?,
        cancelButtonColor: UIColor?,
        cancelButtonBgColor: UIColor?,
        titleViewBackgroundColor: UIColor?,
        confirmButtonText: String?,
        cancelButtonText: String?
    ) {
        // Reset the view each time
        self.subviews.forEach { $0.removeFromSuperview() }
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Set the colors and text with user-provided or default values
        self.popupColor = popupColor ?? self.popupColor
        self.titleColor = titleColor ?? self.titleColor
        self.messageColor = messageColor ?? self.messageColor
        self.confirmButtonColor = confirmButtonColor ?? self.confirmButtonColor
        self.confirmButtonBgColor = confirmButtonBgColor ?? self.confirmButtonBgColor
        self.cancelButtonColor = cancelButtonColor ?? self.cancelButtonColor
        self.cancelButtonBgColor = cancelButtonBgColor ?? self.cancelButtonBgColor
        self.titleViewBackgroundColor = titleViewBackgroundColor ?? self.titleViewBackgroundColor
        self.confirmButtonText = confirmButtonText ?? self.confirmButtonText
        self.cancelButtonText = cancelButtonText ?? self.cancelButtonText
        
        // Set up contentView (popup)
        contentView.backgroundColor = self.popupColor
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        // Set dynamic width based on screen size (80% of screen width)
        //let screenWidth = UIScreen.main.bounds.width
        let popupWidth = (UIScreen.main.bounds.width) * 0.8
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            //contentView.widthAnchor.constraint(equalToConstant: 300),
            //contentView.heightAnchor.constraint(equalToConstant: 250)
            contentView.widthAnchor.constraint(equalToConstant: popupWidth)
        ])
        
        // Set up titleLabel
        titleLabel.text = title
        titleLabel.textColor = self.titleColor
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = self.titleViewBackgroundColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Set up messageLabel or textField
        if dialogType == .textInputDialog {
            textField.placeholder = "Type here"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(textField)
            
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                textField.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            messageLabel.text = message
            messageLabel.textColor = self.messageColor
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(messageLabel)
            
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
            ])
        }
        
        // Add button constraints
        self.setupButtonConstraints(dialogType: dialogType, hideCancelButton: hideCancelButton, popupWidth: popupWidth)
        
        // Adjust height dynamically based on content
        self.adjustContentViewHeight(dialogType: dialogType, message: message)
        
        /*// Set up confirmButton
        confirmButton.setTitle(self.confirmButtonText, for: .normal)
        confirmButton.setTitleColor(self.confirmButtonColor, for: .normal)
        confirmButton.backgroundColor = self.confirmButtonBgColor
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmButton)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            confirmButton.widthAnchor.constraint(equalToConstant: 80),
            confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Set up cancelButton (Hide for Display Message)
        if dialogType != .displayMessageDialog {
            cancelButton.setTitle(self.cancelButtonText, for: .normal)
            cancelButton.setTitleColor(self.cancelButtonColor, for: .normal)
            cancelButton.backgroundColor = self.cancelButtonBgColor
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(cancelButton)
            
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                cancelButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -15), // Half width minus spacing
                cancelButton.heightAnchor.constraint(equalToConstant: 40),
                
                confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                confirmButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -15), // Half width minus spacing
                confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 10), // Equal spacing between buttons
                confirmButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            // Update confirmButton to fill entire width if no cancel button
            NSLayoutConstraint.activate([
                confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                confirmButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }   //  */
    }
    
    // MARK: - Setup Buttons and Constraints
    private func setupButtonConstraints(dialogType: DialogType, hideCancelButton: Bool, popupWidth: CGFloat) {
        
        // Set up confirmButton
        confirmButton.setTitle(self.confirmButtonText, for: .normal)
        confirmButton.setTitleColor(self.confirmButtonColor, for: .normal)
        confirmButton.backgroundColor = self.confirmButtonBgColor
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 10
        confirmButton.clipsToBounds = true
        
        contentView.addSubview(confirmButton)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            confirmButton.widthAnchor.constraint(equalToConstant: 80),
            confirmButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Set up cancelButton (Hide for Display Message)
        if dialogType != .displayMessageDialog {
            cancelButton.setTitle(self.cancelButtonText, for: .normal)
            cancelButton.setTitleColor(self.cancelButtonColor, for: .normal)
            cancelButton.backgroundColor = self.cancelButtonBgColor
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.layer.cornerRadius = 10
            cancelButton.clipsToBounds = true
            
            contentView.addSubview(cancelButton)
            
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                cancelButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -15), // Half width minus spacing
                cancelButton.heightAnchor.constraint(equalToConstant: 40),
                
                confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                confirmButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -15), // Half width minus spacing
                confirmButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 10), // Equal spacing between buttons
                confirmButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            // Update confirmButton to fill entire width if no cancel button
            NSLayoutConstraint.activate([
                confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                confirmButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    // MARK: - Adjust Height Based on Content
    private func adjustContentViewHeight(dialogType: DialogType, message: String) {
        // Calculate the intrinsic content size of the message label or text input field
        var contentHeight: CGFloat = 40 // Initial height for the title label
        
        
        
        if dialogType == .textInputDialog {
            contentHeight += 50 // Add fixed height for the text field
        } else {
            //let messageSize = messageLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude))
            
            var requiredHeight: CGFloat {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                label.font = UIFont.systemFont(ofSize: 19)
                label.text = message
                label.sizeToFit()
                return label.frame.height
            }
            
            //contentHeight += messageSize.height
            contentHeight += requiredHeight
        }
        
        // Add space for the buttons and padding
        contentHeight += 90 // Space for buttons and bottom padding
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
    }
    
    // MARK: - Show Popup
    func show(
        title: String,
        message: String,
        dialogType: DialogType,
        hideCancelButton: Bool = false,
        popupColor: UIColor? = nil,
        titleColor: UIColor? = nil,
        messageColor: UIColor? = nil,
        confirmButtonColor: UIColor? = nil,
        cancelButtonColor: UIColor? = nil,
        titleViewBackgroundColor: UIColor? = nil,
        confirmButtonText: String? = nil,
        cancelButtonText: String? = nil,
        onConfirm: ((String?) -> Void)?,
        onCancel: (() -> Void)?
    ) {
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        
        // Ensure only one instance of the popup is displayed at a time
        if let window = UIApplication.shared.keyWindow {
            setupView(
                title: title,
                message: message,
                dialogType: dialogType,
                hideCancelButton: hideCancelButton,
                popupColor: popupColor,
                titleColor: titleColor,
                messageColor: messageColor,
                confirmButtonColor: confirmButtonColor,
                confirmButtonBgColor: confirmButtonBgColor,
                cancelButtonColor: cancelButtonColor,
                cancelButtonBgColor: cancelButtonBgColor,
                titleViewBackgroundColor: titleViewBackgroundColor,
                confirmButtonText: confirmButtonText,
                cancelButtonText: cancelButtonText
            )
            window.addSubview(self)
        }
    }
    
    // MARK: - Button Actions
    @objc private func confirmButtonTapped() {
        if textField.isDescendant(of: contentView) {
            onConfirm?(textField.text ?? "")
        } else {
            onConfirm?("Confirm")
        }
        removeFromSuperview()
    }
    
    @objc private func cancelButtonTapped() {
        onCancel?()
        removeFromSuperview()
    }
    
    // MARK: - Dialog Types
    enum DialogType {
        case confirmationDialog
        case textInputDialog
        case displayMessageDialog
    }
}
