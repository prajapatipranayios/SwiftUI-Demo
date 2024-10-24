//
//  PopupHelper.swift
//
//  Created by Pranay on 24/10/24.
//

import Foundation
import UIKit

//enum PopupType {
//    case confirmation
//    case text
//    case displayMessage
//}

class PopupHelper {
    
    static func showPopup(type: PopupType, on viewController: UIViewController, title: String? = nil, message: String? = nil, completion: @escaping (String?) -> Void) {
        
        switch type {
        case .confirmation:
            let alertTitle = title ?? "Confirmation" // Default title for confirmation
            let alertMessage = message ?? "Are you sure you want to proceed?"
            
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                completion("Confirmed")
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completion(nil)
            }))
            
            viewController.present(alert, animated: true, completion: nil)
            
        case .text:
            let alertTitle = title ?? "Enter Text"
            let alertMessage = message ?? "Please input the required text below:"
            
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Type here..."
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let text = alert.textFields?.first?.text
                completion(text)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completion(nil)
            }))
            
            viewController.present(alert, animated: true, completion: nil)
            
        case .displayMessage:
            let alertTitle = title ?? "Message"
            let alertMessage = message ?? "This is a default display message."
            
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion("Displayed")
            }))
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
