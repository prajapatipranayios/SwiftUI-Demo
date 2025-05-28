//
//  EventBookedPopupVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 08/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventBookedPopupVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var ivIcon: UIImageView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!

    @IBOutlet weak var btnOK: UIButton!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

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
        btnOK.layer.cornerRadius = btnOK.frame.size.height / 2
        
    }
    
    
    // MARK: - Button Click Events

    @IBAction func okTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
