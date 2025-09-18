
//
//  ArenaVC.swift
//  Tussly
//
//  Created by Auxano on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import Foundation

class ArenaScoreConfirmPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var winnerId = 0
    var isOpponentBlock = false
    var playerDetail = [Any]()
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewPlayer1 : UIView!
    @IBOutlet weak var viewPlayer2 : UIView!
    @IBOutlet weak var lblWinner1 : UILabel!
    @IBOutlet weak var lblWinner2 : UILabel!
    @IBOutlet weak var lblSecondMessage : UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        
        btnProceed.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        imgPlayer1.layer.cornerRadius = imgPlayer1.frame.size.height / 2
        imgPlayer2.layer.cornerRadius = imgPlayer2.frame.size.height / 2
        
        viewPlayer1.layer.cornerRadius = 8
        viewPlayer2.layer.cornerRadius = 8
        
        viewPlayer1.layer.borderWidth = 1.0
        viewPlayer1.layer.borderColor = Colors.gray.returnColor().cgColor
        
        viewPlayer2.layer.borderWidth = 1.0
        viewPlayer2.layer.borderColor = Colors.gray.returnColor().cgColor
        
        lblWinner1.isHidden = true
        lblWinner2.isHidden = true
                
        if self.winnerId == 0 {
            self.viewPlayer1.layer.borderColor = UIColor.systemGreen.cgColor
            self.lblWinner1.isHidden = false
        } else {
            self.viewPlayer2.layer.borderColor = UIColor.systemGreen.cgColor
            self.lblWinner2.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        if self.isOpponentBlock {
            //other player is blocked so this player is winner automatically
            lblPlayer1Name.text = playerDetail[0] as? String
            imgPlayer1.setImage(imageUrl: playerDetail[2] as? String ?? "")
            imgPlayer2.setImage(imageUrl: playerDetail[3] as? String ?? "")
            lblPlayer2Name.text = playerDetail[1] as? String
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - UI Method
    @objc func willResignActive() {
        self.dismiss(animated: true, completion: nil)
    }
        
    // MARK: - Button Click Events
    @IBAction func submitTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
