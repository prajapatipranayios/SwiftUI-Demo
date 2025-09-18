//
//  NotificationDetailVC.swift
//  Tussly
//
//  Created by Auxano on 19/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class NotificationDetailVC: UIViewController {

    // MARK: - Controls
    @IBOutlet weak var btnExploreLeague : UIButton!
    @IBOutlet weak var btnLikeUnlike : UIButton!
    // By Pranay
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    // .
    
    // MARK: - Variable
    var notification: UserNotification?
    var onTapLikeDisLike: ((Bool,Int,UserNotification)->Void)?
    var isRead = false
    var selectedIndex = -1
    // By Pranay
    var highlightString = ""
    var notificationContent : NotificationContent?
    var surveyLink : String = ""
    // .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnExploreLeague.layer.cornerRadius = 15
        btnLikeUnlike.isSelected = notification?.isLike == 1 ? true : false
        
        // By Pranay
        //lblTitle.text = strTitle
        //lblDesc.attributedText = strDesc.setAttributedString(boldString: highlightString, fontSize: 16.0)
        self.getNotificationContent()
        // .
    }

    // By Pranay
    func setNotificationDetails() {
        if notification?.action == "welcome_tussly" {
            DispatchQueue.main.async {
                self.btnExploreLeague.setTitle("Close", for: .normal)
                self.lblTitle.text = self.notificationContent?.welcomeNotification?.title
                var desc = self.notificationContent?.welcomeNotification?.desc
                desc = desc?.replacingOccurrences(of: "\\n\\n", with: "\n\n", options: .literal, range: nil)
                self.lblDesc.attributedText = desc!.setAttributedString(boldString: self.highlightString, fontSize: 16.0)
            }
        } else if notification?.action == "end_tournament" {
            DispatchQueue.main.async {
                self.btnExploreLeague.setTitle("Take the Survey", for: .normal)
                self.ivLogo.isHidden = true
                self.lblTitle.text = self.notificationContent?.endTournament?.title
                var desc = self.notificationContent?.endTournament?.desc
                desc = desc?.replacingOccurrences(of: "\\n\\n", with: "\n\n", options: .literal, range: nil)
                self.lblDesc.attributedText = desc!.setAttributedString(boldString: self.highlightString, fontSize: 16.0)
            }
        }
    }
    // .
    
    // MARK: - Button Click Events
    
    @IBAction func onTapExploreLeague(_ sender : UIButton) {
        if onTapLikeDisLike != nil {
            //onTapLikeDisLike!(isRead,selectedIndex,notification!)
        }
        //self.navigationController?.popViewController(animated: true)
        
        if notification?.action == "welcome_tussly" {
            self.navigationController?.popViewController(animated: true)
        } else if notification?.action == "end_tournament" {
            guard let url = URL(string: surveyLink) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func OnTapLikeDisLike(_ sender: UIButton) {
        self.likeDisLikeNotification(likeBtn: sender)
    }
    
    // MARK: - Webservices
    func likeDisLikeNotification(likeBtn: UIButton) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.likeDisLikeNotification(likeBtn: likeBtn)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LIKE_DISLIKE_NOTIFICATION, parameters: ["notificationId":notification?.id as Any,"isLike":likeBtn.isSelected ? 0 : 1]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    likeBtn.isSelected = !likeBtn.isSelected
                    self.notification?.isLike = likeBtn.isSelected ? 1 : 0
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    // By Pranay
    func getNotificationContent() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getNotificationContent()
                }
            }
            return
        }
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_STATIC_CONTENTS, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.notificationContent = response?.result?.contents?.notificationContent
                    self.surveyLink = self.notificationContent?.endTournament?.link ?? ""
                    self.setNotificationDetails()
                }
            } else {
                
            }
        }
    }
    // .
}
