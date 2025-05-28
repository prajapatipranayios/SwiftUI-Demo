//
//  CancelTicketPopupVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 14/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class CancelTicketPopupVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    // MARK: - Controls

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var subTitleTopConstraint: NSLayoutConstraint!

    var yesString = ""
    var noString = ""
    var titleString = ""
    var subTitleString = ""
    
    var tapYes:(()->Void)?
    var tapNo:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        
        lblTitle.text = titleString
        if subTitleString == "" {
            lblSubTitle.isHidden = true
            subTitleTopConstraint.constant = 0.0
            
        }else {
            lblSubTitle.isHidden = false
            subTitleTopConstraint.constant = 16.0
            lblSubTitle.text = subTitleString
        }
        
        self.view.layoutIfNeeded()
        
        btnYes.setTitle(yesString, for: .normal)
        btnCancel.setTitle(noString, for: .normal)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 20.0
        btnYes.layer.cornerRadius = btnYes.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
        
    @IBAction func yesTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapYes != nil {
                self.tapYes!()
            }
        })
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapNo != nil {
                self.tapNo!()
            }
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
