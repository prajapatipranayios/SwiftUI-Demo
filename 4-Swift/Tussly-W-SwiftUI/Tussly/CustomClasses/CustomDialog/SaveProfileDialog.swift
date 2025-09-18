//
//  CustomDialog.swift
//  Tussly
//
//  Created by Jaimesh Patel on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SaveProfileDialog: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnNotSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    // MARK: - Variables
    
    var tapSave: (()->Void)?
    var tapNotSave: (()->Void)?
    var tapCancel: (()->Void)?
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        btnSave.layer.cornerRadius = 15.0
        btnNotSave.layer.cornerRadius = 15.0
        btnCancel.layer.cornerRadius = 15.0

    }
    
    // MARK: - Button Click Events
    
    @IBAction func yesTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapSave != nil {
                self.tapSave!()
            }
        })
    }
    
    @IBAction func donotSaveTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapNotSave != nil {
                self.tapNotSave!()
            }
        })
    }
    
    @IBAction func noTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapCancel != nil {
                self.tapCancel!()
            }
        })
    }
}
