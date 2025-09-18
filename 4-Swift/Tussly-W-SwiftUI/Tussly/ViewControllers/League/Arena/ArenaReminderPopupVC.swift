//
//  ArenaVC.swift
//  Tussly
//

import UIKit
import Foundation

class ArenaReminderPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var tapOk: (()->Void)?
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var btnCheck : UIButton!
    
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
        
        lblTitle.text = APIManager.sharedManager.content?.arenaContents?.reminder?.heading ?? ""
        lblMessage.text = APIManager.sharedManager.content?.arenaContents?.reminder?.data?.description ?? ""
        
        self.lblMessage.attributedText = (APIManager.sharedManager.content?.arenaContents?.reminder?.data?.description ?? "").setAttributedString(boldString: "DO NOT", fontSize: 16.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnCheck.setImage(UIImage(named: "Uncheck"), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        let ivCheck = UIImage(named: "Select")
        if self.btnCheck.currentImage === ivCheck {
            closeReminder()
        } else {
            self.dismiss(animated: true, completion: {
                if self.tapOk != nil {
                    self.tapOk!()
                }
            })
        }
    }
    
    @IBAction func showAgainTapped(_ sender: UIButton) {
        let ivCheck = UIImage(named: "Select")
        if self.btnCheck.currentImage === ivCheck {
            btnCheck.setImage(UIImage(named: "Uncheck"), for: .normal)
        } else {
            btnCheck.setImage(UIImage(named: "Select"), for: .normal)
        }
    }
}

// MARK: Webservices
extension ArenaReminderPopupVC {
    func closeReminder() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.closeReminder()
                }
            }
            return
        }
        
        showLoading()
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ARENA_REMINDER, parameters: nil){ (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.isReminderOpen = 1
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            self.tapOk!()
                        }
                    })
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
