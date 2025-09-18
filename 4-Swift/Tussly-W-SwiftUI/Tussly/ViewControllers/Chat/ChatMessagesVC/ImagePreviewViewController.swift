//
//  ImagePreviewViewController.swift
//  Tussly
//
//  Created by Auxano on 23/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import Foundation
import UIKit

class ImagePreviewViewController: UIViewController {
    
    var imageURL: URL?
    private let imageView = UIImageView()
    let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        if let url = imageURL {
            // Load image async if needed
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = img
                    }
                }
            }
        }
        
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white  // You can change this to .black if image is light
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        closeButton.layer.cornerRadius = 20
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        view.addGestureRecognizer(swipeDown)
        
        view.bringSubviewToFront(closeButton)
    }
    
    @objc func closeTapped() {
        //dismiss(animated: true)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func handleSwipeDown(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        if gesture.state == .changed {
            // Optional: move the view down a bit with user's finger
            if translation.y > 0 {
                self.view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        } else if gesture.state == .ended {
            if translation.y > 100 {
                // If user swiped down enough, dismiss
                //self.dismiss(animated: true)
                self.navigationController?.popViewController(animated: false)
            } else {
                // Not enough swipe, bounce back
                UIView.animate(withDuration: 0.25) {
                    self.view.transform = .identity
                }
            }
        }
    }
}
