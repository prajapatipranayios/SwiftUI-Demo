//
//  FFPopupVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class FFPopupVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    // MARK: - Controls

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnRetry: UIButton!

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
        btnRetry.layer.cornerRadius = btnRetry.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
    
    @IBAction func retryTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
//            if self.tapOK != nil {
//                self.tapOK!()
//            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
