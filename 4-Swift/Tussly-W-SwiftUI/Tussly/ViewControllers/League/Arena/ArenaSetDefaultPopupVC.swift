//
//  ArenaSetDefaultPopupVC.swift
//  Tussly
//
//  Created by Auxano on 02/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class ArenaSetDefaultPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var tapOk: (()->Void)?
    
    //Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblChar: UILabel!
    @IBOutlet weak var lblStage: UILabel!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        
        btnClose.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        lblChar.text = APIManager.sharedManager.content?.arenaContents?.set_your_defaults?.data?[0].description ?? ""
        lblStage.text = APIManager.sharedManager.content?.arenaContents?.set_your_defaults?.data?[1].description ?? ""
    }
    
    /// 333 - By Pranay
    override func viewWillAppear(_ animated: Bool) {
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
    }
    /// 333 .
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!()
            }
        })
    }
    
}
