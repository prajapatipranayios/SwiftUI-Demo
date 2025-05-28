//
//  SuccessPopupVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 14/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class SuccessPopupVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    // MARK: - Controls
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    
    var titleString = ""
    var tapDone:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 20.0
        
        lblMessage.text = titleString
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true, completion: {
                if self.tapDone != nil {
                    self.tapDone!()
                }
            })
        }
        
    }
    
    
}
