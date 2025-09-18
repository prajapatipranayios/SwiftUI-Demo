//
//  NotificationsVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import SwipeCellKit

class NotificationsVC: UIViewController {
    
    // MARK: - Variables.
    var hasMore = -1
    var arrNotification: [UserNotification]?
    var arrOldNotification: [UserNotification]?
    
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var page: Int = 1
    var isLoadMore: Bool = false
    var lastContentOffset: CGFloat = 0
    var isNotificationPageActive: Bool = true
    var isNotificationTap: Bool = false
    
    
    // MARK: - Controls
    @IBOutlet weak var viewCount : UIView!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var viewNewCount : UIView!
    @IBOutlet weak var lblNewCount : UILabel!
    
    @IBOutlet weak var tvNotification : UITableView!
    @IBOutlet weak var heightTVNotification: NSLayoutConstraint!
    
    @IBOutlet weak var tvOldNotification : UITableView!
    @IBOutlet weak var heightTVOldNotification: NSLayoutConstraint!
    @IBOutlet weak var heightTVNotificationTopView: NSLayoutConstraint!
    
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var constraintTblBottomToActivity: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewActivityIndicator: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrlView.delegate = self
        self.tvNotification.delegate = self
        self.tvNotification.dataSource = self
        self.tvOldNotification.delegate = self
        self.tvOldNotification.dataSource = self
        self.viewActivityIndicator.isHidden = true
        
        
        viewCount.layer.cornerRadius = 3.0
        viewNewCount.layer.cornerRadius = 3.0
        tvNotification.register(UINib(nibName: "NotificationsCell", bundle: nil), forCellReuseIdentifier: "NotificationsCell")
        tvOldNotification.register(UINib(nibName: "NotificationsCell", bundle: nil), forCellReuseIdentifier: "NotificationsCell")
        
        if APIManager.sharedManager.guideLine == 1 {
            DispatchQueue.main.async {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationIntroVC") as! NotificationIntroVC
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
            }
        }
        
        tvNotification.rowHeight = UITableView.automaticDimension
        tvNotification.estimatedRowHeight = 100.0
        
        tvOldNotification.rowHeight = UITableView.automaticDimension
        tvOldNotification.estimatedRowHeight = 100.0
        tvNotification.separatorStyle = .none
        tvOldNotification.separatorStyle = .none
        
        self.activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvNotification.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvOldNotification.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        self.isNotificationPageActive = true    //  By Pranay
        self.isNotificationTap = false
        
        print("Notification flag - \(self.tusslyTabVC!().isEnableNotificationTab)")
        if self.tusslyTabVC!().isEnableNotificationTab {
            self.tusslyTabVC!().isEnableNotificationTab = false
            //tvNotification.reloadData()
            //tvOldNotification.reloadData()
            getNotification()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.isNotificationPageActive = false    //  By Pranay
        
        if self.tvNotification?.observationInfo != nil {
            tvNotification.removeObserver(self, forKeyPath: "contentSize")
        }
        
        if self.tvOldNotification?.observationInfo != nil {
            tvOldNotification.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.heightTVNotification.constant = tvNotification.contentSize.height
        self.heightTVOldNotification.constant = tvOldNotification.contentSize.height
    }
    
    // MARK: - UI Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            self.updateViewConstraints()
        }
    }
    
    // MARK: - Webservices
    
    func getNotification() {
        //showLoading()
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getNotification()
                }
            }
            return
        }
        
        let param = ["timeZone" : APIManager.sharedManager.timezone,
                     "page": page] as [String : Any]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_NOTIFICATION, parameters: param) { (response: ApiResponse?, error) in
            //self.hideLoading()
            if self.isNotificationPageActive {
                if response?.status == 1 {
                    DispatchQueue.main.async {
                        self.tusslyTabVC!().isEnableNotificationTab = true /// 333 - By Pranay - prevent user to tap multiple time on notification tab.
                        var arrTempNotification: [UserNotification]?
                        var arrTempOldNotification: [UserNotification]?
                        arrTempNotification = (response?.result?.unReadNotification)!
                        arrTempOldNotification = (response?.result?.readNotification)!
                        self.hasMore = (response?.result?.hasMore)!
                        
                        if self.hasMore == 1 {
                            DispatchQueue.main.async {
                                self.constraintTblBottomToActivity.priority = .required
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.constraintTblBottomToActivity.priority = .defaultLow
                            }
                        }
                        
                        if self.isLoadMore {
                            self.isLoadMore = false
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.arrNotification?.append(contentsOf: arrTempNotification!)
                            self.arrOldNotification?.append(contentsOf: arrTempOldNotification!)
                        }
                        else {
                            self.arrNotification = arrTempNotification
                            self.arrOldNotification = arrTempOldNotification
                        }
                        self.lblCount.text = "\(self.arrNotification!.count)"
                        self.lblNewCount.text = "\(self.arrOldNotification!.count)"
                        
                        if self.arrNotification!.count > 0 {
                            self.heightTVNotificationTopView.constant = 0
                            self.viewCount.isHidden = false
                        }
                        else {
                            self.heightTVNotificationTopView.constant = 70
                            self.viewCount.isHidden = true
                        }
                        
                        if self.arrOldNotification!.count > 0 {
                            self.viewNewCount.isHidden = false
                        }
                        else {
                            self.viewNewCount.isHidden = true
                        }
                        self.tvNotification.reloadData()
                        self.tvOldNotification.reloadData()
                        
                        // By Pranay
                        self.view!.tusslyTabVC.lblNotificationCount.isHidden = true
                        UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
                        self.view!.tusslyTabVC.notificationCount()
                        //UIApplication.shared.applicationIconBadgeNumber = 0
                        // .
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.tusslyTabVC!().isEnableNotificationTab = true /// 333 - By Pranay - prevent user to tap multiple time on notification tab.
                        Utilities.showPopup(title: response?.message ?? "", type: .error)
                        self.arrNotification = [UserNotification]()
                        self.arrOldNotification = [UserNotification]()
                        self.tvNotification.reloadData()
                        self.tvOldNotification.reloadData()
                    }
                }
            }
            else {
                self.tusslyTabVC!().isEnableNotificationTab = true
            }
        }
    }
    
    
    func getTournamentDetail(matchId: Int = 0, leagueId: Int = 0, isArenaTabOpen: Bool = false) {
        showLoading()
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTournamentDetail(matchId: matchId, leagueId: leagueId, isArenaTabOpen: isArenaTabOpen)
                }
            }
            return
        }
        
        let param = ["matchId": matchId,
                     "leagueId": leagueId,
                     "timeZone": APIManager.sharedManager.timezone] as [String : Any]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REDIRECT_TO_ARENA_INFO, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    ///For view league info.
                    self.tusslyTabVC!().isFromSerchPlayerTournament = true
                    self.tusslyTabVC!().leagueTournamentId = response?.result?.leagues![0].id ?? 0
                    self.tusslyTabVC!().tournamentDetail = response?.result?.leagues![0]
                    self.tusslyTabVC!().isLeagueJoinStatus = (response?.result?.leagues![0].joinStatus ?? 1) == 1 ? true : false
                    APIManager.sharedManager.isArenaTabOpen = isArenaTabOpen
                    self.tusslyTabVC!().didPressTab(self.view.tusslyTabVC.buttons[5])
                }
            }
            else {  }
        }
    }
    
    
    func deleteNotification(notificationId: Int,isNew: Bool,index: Int) {
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_NOTIFICATION, parameters: ["notificationId":notificationId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.showLoading()
                    self.getNotification()
//                    if isNew {
//                        self.arrNotification!.remove(at: index)
//                        self.tvNotification.reloadData()
//                    } else {
//                        self.arrOldNotification!.remove(at: index)
//                        self.tvOldNotification.reloadData()
//                    }
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func acceptRejectNotification(notificationId: Int,actionType: String,index: Int,isNew: Bool) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.acceptRejectNotification(notificationId: notificationId, actionType: actionType, index: index, isNew: isNew)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.NOTIFICATION_ACTION, parameters: ["notificationId":notificationId,"actionType":actionType]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if response?.result?.redirectUrl == "" {
                        if isNew {
                            if self.arrNotification?.count ?? 0 > index
                            {
                                self.arrNotification![index].isActionDone = 1
                                self.tvNotification.reloadData()
                            }
                        }
                        else {
                            if self.arrOldNotification?.count ?? 0 > index {
                                self.arrOldNotification![index].isActionDone = 1
                                self.tvOldNotification.reloadData()
                            }
                        }
                    }
                    else {
                        if let link = URL(string: (response?.result?.redirectUrl)!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(link)
                            } else {
                                UIApplication.shared.openURL(link)
                            }
                        }
                    }
                    self.getNotification()
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension NotificationsVC {
    func onPressLike(index: Int) {
        
    }
    
    func onPressNext(index: Int) {
        
    }
}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tvNotification {
            return arrNotification?.count ?? 0  //default 5 to 0 - By Pranay
        }
        else {
            return arrOldNotification?.count ?? 0   //default 5 to 0 - By Pranay
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
//        if (notificationList[position].action == "splash") {
//            holder.llCards.visibility = View.VISIBLE
//        } else {
//            holder.llCards.visibility = View.GONE
//        }
        if arrNotification != nil || arrOldNotification != nil {
//            cell.hideAnimation()
            cell.delegate = self
            cell.leadingContainer.constant = 0
            cell.viewContainer.addShadow(offset: CGSize(width: -5, height: 0), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
            
            // Commanet by pranay
            //cell.ivNotification.setImage(imageUrl:  tableView == tvNotification ? arrNotification![indexPath.section].senderImage! : arrOldNotification![indexPath.section].senderImage!)
            
            // By Pranay - Update image in notification
            cell.ivNotification.setImage(imageUrl:  tableView == tvNotification ? (arrNotification![indexPath.section].attachmentUrl! != "" ? arrNotification![indexPath.section].attachmentUrl! : arrNotification![indexPath.section].senderImage!) : (arrOldNotification![indexPath.section].attachmentUrl! != "" ? arrOldNotification![indexPath.section].attachmentUrl! : arrOldNotification![indexPath.section].senderImage!))
            // .
            
            cell.lblTitle.text = tableView == tvNotification ? arrNotification![indexPath.section].title : arrOldNotification![indexPath.section].title
            cell.lblDiscription.attributedText = tableView == tvNotification ? arrNotification![indexPath.section].description!.htmlToAttributedString : arrOldNotification![indexPath.section].description!.htmlToAttributedString
            cell.lblTime.text = tableView == tvNotification ? arrNotification![indexPath.section].notificationTime : arrOldNotification![indexPath.section].notificationTime
            
            cell.btnAccept.isHidden = true
            cell.btnDecline.isHidden = true
            cell.heightBtn.constant = 0
            cell.bottomBtn.constant = 0
            
            if (tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action) == "splash" {
                cell.btnAccept.isHidden = false
                cell.btnDecline.isHidden = false
                cell.heightBtn.constant = 30
                cell.bottomBtn.constant = 16
                cell.btnAccept.setTitle(tableView == tvNotification ? arrNotification![indexPath.section].positiveText : arrOldNotification![indexPath.section].positiveText, for: .normal)
                cell.btnDecline.setTitle(tableView == tvNotification ? arrNotification![indexPath.section].negativeText : arrOldNotification![indexPath.section].negativeText, for: .normal)
            }
            
            if (tableView == tvNotification ? arrNotification![indexPath.section].isActionDone : arrOldNotification![indexPath.section].isActionDone) == 0 {
                //cell.btnAccept.isHidden = false
                //cell.btnDecline.isHidden = false
                //cell.heightBtn.constant = 30
                //cell.bottomBtn.constant = 16
                //cell.btnAccept.setTitle(tableView == tvNotification ? arrNotification![indexPath.section].positiveText : arrOldNotification![indexPath.section].positiveText, for: .normal)
                //cell.btnDecline.setTitle(tableView == tvNotification ? arrNotification![indexPath.section].negativeText : arrOldNotification![indexPath.section].negativeText, for: .normal)
            }
            
            cell.btnLikeUnlike.isHidden = true
            if tableView == tvNotification {
                cell.btnLikeUnlike.isHidden = arrNotification![indexPath.section].isLike == 1 ? false : true
            }
            else {
                cell.btnLikeUnlike.isHidden = arrOldNotification![indexPath.section].isLike == 1 ? false : true
            }
            
            cell.btnNext.isHidden = true
            /*if (tableView == tvNotification ? arrNotification![indexPath.section].isDetailView : arrOldNotification![indexPath.section].isDetailView) == 1 {
                cell.btnNext.isHidden = false
            }   //  */
            
            cell.index = indexPath.section
            cell.lblTitle.sizeToFit()
            
            cell.onTapAccept = { index in
                self.acceptRejectNotification(notificationId: (tableView == self.tvNotification ? self.arrNotification![indexPath.section].id : self.arrOldNotification![indexPath.section].id)!, actionType: "POSITIVE", index: index, isNew: tableView == self.tvNotification ? true : false)
                //            self.arrOldNotification[index].isActionDone = 0
                //            self.tvOldNotification.reloadData()
            }
            
            cell.onTapReject = { index in
                self.acceptRejectNotification(notificationId: (tableView == self.tvNotification ? self.arrNotification![indexPath.section].id : self.arrOldNotification![indexPath.section].id)!, actionType: "NEGATIVE", index: index, isNew: tableView == self.tvNotification ? true : false)
            }
            
            /*cell.didPressNext = { index in
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailVC") as! NotificationDetailVC
                objVC.notification = tableView == self.tvNotification ? self.arrNotification![indexPath.section] : self.arrOldNotification![indexPath.section]
                objVC.isRead = tableView == self.tvNotification ? true : false
                objVC.selectedIndex = indexPath.section
                // 21 By Pranay
                //objVC.surveyLink = self.view!.tusslyTabVC.feedbackLink
                // 21 .
                objVC.onTapLikeDisLike = { isRead,index,notification in
                    if isRead {
                        self.arrNotification![index] = notification
                        self.tvNotification.reloadData()
                    } else {
                        self.arrOldNotification![index] = notification
                        self.tvOldNotification.reloadData()
                    }
                }
                self.navigationController?.pushViewController(objVC, animated: true)
            }   /// */
        }
        else {
            cell.btnAccept.setTitle("", for: .normal)
            cell.btnDecline.setTitle("", for: .normal)
//            cell.showAnimation()
        }
        return cell
    }
    
    /// 441 - By Pranay
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == tvNotification ? arrNotification![indexPath.section].isDetailView : arrOldNotification![indexPath.section].isDetailView) == 1 {
            
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailVC") as! NotificationDetailVC
            objVC.notification = tableView == self.tvNotification ? self.arrNotification![indexPath.section] : self.arrOldNotification![indexPath.section]
            objVC.isRead = tableView == self.tvNotification ? true : false
            objVC.selectedIndex = indexPath.section
            objVC.onTapLikeDisLike = { isRead,index,notification in
                if isRead {
                    self.arrNotification![index] = notification
                    self.tvNotification.reloadData()
                } else {
                    self.arrOldNotification![index] = notification
                    self.tvOldNotification.reloadData()
                }
            }
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        /*else if (tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action) == "upcoming_match" {
            let tempObj = tableView == tvNotification ? arrNotification![indexPath.section] : arrOldNotification![indexPath.section]
            if tempObj.moduleId ?? 0 != 0 {
                self.getTournamentDetail(matchId: tempObj.moduleId ?? 0, isArenaTabOpen: true)
            }
        }   //  */
        else if ["upcoming_match", "check_in", "schedule_removed"].contains((tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action)) {
            let tempObj = tableView == tvNotification ? arrNotification![indexPath.section] : arrOldNotification![indexPath.section]
            
            let strValue = (tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action)
            
            if tempObj.moduleId ?? 0 != 0 {
                
                switch strValue {
                case "upcoming_match":
                    self.getTournamentDetail(matchId: tempObj.moduleId ?? 0, isArenaTabOpen: true)
                default:
                    self.getTournamentDetail(leagueId: tempObj.moduleId ?? 0)
                }
            }
        }
        /*else if (tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action) == "check_in" {
            let tempObj = tableView == tvNotification ? arrNotification![indexPath.section] : arrOldNotification![indexPath.section]
            if tempObj.moduleId ?? 0 != 0 {
                //self.getTournamentDetail(matchId: 6760)
                self.getTournamentDetail(leagueId: tempObj.moduleId ?? 0)
            }
        }   //  */
        else if (tableView == tvNotification ? arrNotification![indexPath.section].action : arrOldNotification![indexPath.section].action) == "report_generated" {
            
            self.isNotificationTap = true
            APIManager.sharedManager.isPlayerCardOpen = true
            APIManager.sharedManager.isPlayerReportsTabOpen = true
            self.tusslyTabVC!().didPressTab(self.view.tusslyTabVC.buttons[8])
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        let cell = tableView.cellForRow(at: indexPath!) as! NotificationsCell
        cell.leadingContainer.constant = 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        
        let cell = tableView.cellForRow(at: indexPath) as! NotificationsCell
        cell.leadingContainer.constant = 10
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, index in
            self.deleteNotification(notificationId: (tableView == self.tvNotification ? self.arrNotification![indexPath.section].id : self.arrOldNotification![indexPath.section].id)!, isNew: tableView == self.tvNotification ? true : false, index: index.section)
            
        }
        deleteAction.image = UIImage(named: "Delete_prohibited_line")
        deleteAction.backgroundColor = UIColor.clear
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        options.backgroundColor = UIColor.white
        options.minimumButtonWidth = 150.0
        return options
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        view.backgroundColor = Colors.gray.returnColor()
        return view
    }   //  */
}

extension NotificationsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset == 0)
        {
            // then we are at the top
        }
        else if ((scrollOffset + scrollViewHeight) == scrollContentSizeHeight)
        {
            // then we are at the end
            if !self.isLoadMore && self.hasMore == 1 {
                self.isLoadMore = true
                self.page += 1
                self.activityIndicator.isHidden = false
                self.viewActivityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                self.getNotification()
            }
        }
    }
}
