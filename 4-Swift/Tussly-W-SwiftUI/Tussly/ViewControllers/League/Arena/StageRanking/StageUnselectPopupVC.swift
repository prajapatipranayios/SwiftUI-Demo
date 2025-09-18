//
//  StageUnselectPopupVC.swift
//  Tussly
//
//  Created by Auxano on 02/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class StageUnselectPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var arrSelectedStageIndex = [Int]()
    var tapOk: (()->Void)?
    var isTapClose = false
    
    //Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = APIManager.sharedManager.content?.arenaContents?.unselect_to_select?.heading
        lblMessage.text = APIManager.sharedManager.content?.arenaContents?.unselect_to_select?.data?.description
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        
        btnClose.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.isTapClose == false {
                self.isTapClose = true
                self.dismiss(animated: true, completion: {
                    if self.tapOk != nil {
                        self.tapOk!()
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        isTapClose = true
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!()
            }
        })
    }
}
