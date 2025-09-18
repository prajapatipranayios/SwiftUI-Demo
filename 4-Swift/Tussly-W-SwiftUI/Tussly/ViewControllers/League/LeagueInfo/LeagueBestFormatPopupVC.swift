//
//  LeagueBestFormatPopupVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import WebKit


class LeagueBestFormatPopupVC: UIViewController {

    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    // MARK: - Controls
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        btnClose.layer.cornerRadius = 15.0
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


