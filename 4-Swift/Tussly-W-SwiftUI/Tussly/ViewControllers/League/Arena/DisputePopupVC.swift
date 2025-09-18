//
//  DisputePopupVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 20/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class DisputePopupVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblMessage1: UILabel!
    @IBOutlet weak var lblMessage2: UILabel!
    @IBOutlet weak var lblMessage3: UILabel!

    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var viewContainer: UIView!

    var tapOK: (()->Void)?
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)

        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func setupUI() {
        btnCapture.layer.cornerRadius = 15.0
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
    }
    
    @objc func willResignActive() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Button Click Events
    
    @IBAction func captureTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapOK != nil {
                self.tapOK!()
            }
        })
    }
    
}
