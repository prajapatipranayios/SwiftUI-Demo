//
//  ViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func btnShowToastTap(_ sender: UIButton) {
        //let toast = ToastMessage()
        //toast.showToast(message: "Success!", type: .success, inView: self.view)
        //toast.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.orange, textColor: UIColor.black, inView: self.view)
        //toast.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
        
        ToastMessage.shared.showToast(message: "Success!", type: .success, inView: self.view)
        ToastMessage.shared.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.yellow, textColor: UIColor.black, inView: self.view)
        ToastMessage.shared.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
    }
    
    @IBAction func btnDisplayConfirmationDialogTap(_ sender: UIButton) {
        CustomPopupView.shared.show(title: "Test Title...", message: "Message for test custom popup. Message for test custom popup. Message for test custom popup. ", dialogType: .textInputDialog) { strValue in
            print("Confirmed --> \(strValue ?? "")")
        } onCancel: { }

    }
    
    @IBAction func btnDisplayInputDialogTap(_ sender: UIButton) {
        let popup = PopupType()
        
    }
    
    @IBAction func btnDisplayMessageDialogTap(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Example: Show default confirmation dialog
//        PopupHelper.showPopup(type: .confirmation, on: self) { result in
//            if let result = result {
//                print("Popup result: \(result)")
//            } else {
//                print("Popup was cancelled")
//            }
//        }
    }
    
    // Helper to display the popup with animation
    private func showPopup(_ popup: CustomPopupView) {
        popup.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popup)
        
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 300),
            popup.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Animate the popup appearance
        popup.alpha = 0
        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1
        }
    }
}

