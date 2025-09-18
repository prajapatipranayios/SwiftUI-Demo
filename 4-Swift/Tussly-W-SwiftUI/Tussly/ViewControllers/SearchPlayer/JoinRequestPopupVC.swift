//
//  JoinRequestPopupVC.swift
//  - Designed custom popup for Join Request.

//  Tussly
//
//  Created by Auxano on 28/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class JoinRequestPopupVC: UIViewController, UITextViewDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var lblCaptionError: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtCaption: TLTextView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var constraintHeightTxtCaption: NSLayoutConstraint!
    @IBOutlet weak var constraintTopAddCustomMessage: NSLayoutConstraint!
    @IBOutlet weak var constraintTopBtnSend: NSLayoutConstraint!
    
    // MARK: - Variable
    var onTapSendRequestPopUp: ((Int)->Void)?
    var index = -1
    var id = -1
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        btnSend.layer.cornerRadius = 15.0
        txtCaption.layer.borderWidth = 1.0
        txtCaption.layer.borderColor = Colors.border.returnColor().cgColor
        txtCaption.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        lblHeader.isHidden = true
        txtCaption.isHidden = true
        lblCaptionError.isHidden = true
        constraintTopAddCustomMessage.constant = 0
        constraintHeightTxtCaption.constant = 0
        constraintTopBtnSend.constant = 0
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapSendRequest(_ sender: UIButton) {
        joinTeamRequest(id: id)
    }
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextView Delegate
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        lblHeader.text = "Add custom message (\(0 > (100 - numberOfChars) ? 0 : (100 - numberOfChars)))"
        return numberOfChars <= 100    // 100 Limit Value
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtCaption.text.count > 0 {
            
        } else {
            DispatchQueue.main.async {
                self.lblHeader.text = "Add custom message (100)"
            }
            
        }
    }
    
    
    // MARK: Webservices
    
    func joinTeamRequest(id : Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.joinTeamRequest(id: id)
                }
            }
            return
        }
        
        self.showLoading()
        //["teamId":id,"requestMessage":txtCaption.text!]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.TEAM_JOIN_REQUEST, parameters: ["teamId":id,"requestMessage":"test"]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    if self.onTapSendRequestPopUp != nil {
                        self.onTapSendRequestPopUp!(self.index)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
