//
//  NotificationsVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import SwipeCellKit

class FriendRequestVC: UIViewController {
    
    // MARK: - Variables.
    var arrFriendRequest: [FriendRequest]?
    var playerTabVC: (()->PlayerCardTabVC)?
    
    // MARK: - Controls
    @IBOutlet weak var viewCount : UIView!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var tvFriendrequest : UITableView!
    @IBOutlet weak var lblNotFound : UILabel!
    
    var intIdFromSearch : Int = 0
    let btnAddFriend: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Friend", for: .normal)
        button.backgroundColor = Colors.theme.returnColor()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.lblNotFound.isHidden = true
        self.viewCount.isHidden = true
        
        tvFriendrequest.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "FriendRequestCell")
        tvFriendrequest.register(UINib(nibName: "TeamRosterTVCell", bundle: nil), forCellReuseIdentifier: "TeamRosterTVCell")
        
        tvFriendrequest.rowHeight = UITableView.automaticDimension
        tvFriendrequest.estimatedRowHeight = 100.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvFriendrequest.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //tvFriendrequest.reloadData()  //  Comment - By Pranay
        
        //getFriendRequest()
        
        // By Pranay
        if intIdFromSearch == 0 {
            getFriendRequest()
        }
        else {
            if (APIManager.sharedManager.playerData?.playerStatus)! != 2 {
                self.showAddFriendBtn()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.tvFriendrequest!.observationInfo != nil {
            tvFriendrequest.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    func showAddFriendBtn() {
        
        self.btnAddFriend.isUserInteractionEnabled = true
        
        if APIManager.sharedManager.playerData?.playerStatus ?? 0 == 0 {
            self.btnAddFriend.setTitle("Add Friend", for: .normal)
            self.btnAddFriend.backgroundColor = Colors.theme.returnColor()
        }
        else if APIManager.sharedManager.playerData?.playerStatus ?? 0 == 1 {
            self.btnAddFriend.setTitle("Cancel", for: .normal)
            self.btnAddFriend.backgroundColor = Colors.black.returnColor()
        }
        else if APIManager.sharedManager.playerData?.playerStatus ?? 0 == 3 {
            self.btnAddFriend.setTitle("Decline", for: .normal)
            self.btnAddFriend.backgroundColor = Colors.black.returnColor()
            self.btnAddFriend.isUserInteractionEnabled = false
        }
        
        self.view.addSubview(btnAddFriend)
        
        self.btnAddFriend.isHidden = false
        self.btnAddFriend.addTarget(self, action: #selector(btnAddFriendTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Button below the label
            self.btnAddFriend.topAnchor.constraint(equalTo: self.lblNotFound.bottomAnchor, constant: 20),
            self.btnAddFriend.centerXAnchor.constraint(equalTo: self.lblNotFound.centerXAnchor),
            self.btnAddFriend.widthAnchor.constraint(equalToConstant: 120),
            self.btnAddFriend.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func btnAddFriendTapped() {
        if APIManager.sharedManager.playerData?.playerStatus ?? 0 == 0 {
            self.sendFriendRequest(id: intIdFromSearch, index: 0, isFriend: false)
        }
        else {
            self.cancelfriendRequest(id: intIdFromSearch, index: 0, isFriend: false)
        }
    }
    
    // MARK: - UI Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            self.updateViewConstraints()
        }
    }
    
    // MARK: - IB Actions
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
        playerTabVC!().cvPlayerTabs.selectedIndex = -1
        playerTabVC!().cvPlayerTabs.reloadData()
    }
    
    // MARK: - Webservices
    
    func getFriendRequest() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFriendRequest()
                }
            }
            return
        }
        
        //let params = ["isSent": 1]
        
        //APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIEND_REQUEST, parameters: params) { (response: ApiResponse?, error) in
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIEND_REQUEST, parameters: nil) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                if response?.status == 1 {
                    
                    self.arrFriendRequest = (response?.result?.friendRequests)!
                    self.lblCount.text = "\(self.arrFriendRequest!.count)"
                    self.lblNotFound.isHidden = true
                    
                    if self.arrFriendRequest!.count > 0 {
                        self.viewCount.isHidden = false
                        self.viewCount.layer.cornerRadius = 5.0
                        self.viewCount.clipsToBounds = true
                    }
                    else {
                        self.viewCount.isHidden = true
                        self.lblNotFound.text = response?.message ?? ""
                        //self.lblNotFound.isHidden = false
                    }
                    self.tvFriendrequest.reloadData()
                } else {
        //                Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.arrFriendRequest = [FriendRequest]()
                    self.tvFriendrequest.reloadData()
                    self.lblNotFound.text = response?.message ?? ""
                    self.viewCount.isHidden = true
                    //self.lblNotFound.isHidden = false
                }
            }
        }
    }
    
    func acceptRejectRequest(index: Int, status: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.acceptRejectRequest(index: index,status: status)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FRIEND_REQUEST, parameters: ["otherUserId":self.arrFriendRequest![index].userId ?? 0,"status":status]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if status == 2 {
                        self.acceptRejectNotification(notificationId: self.arrFriendRequest![index].notificationId ?? 0, actionType: "POSITIVE", index: index,status: "Accept")
                    } else {
                        self.acceptRejectNotification(notificationId: self.arrFriendRequest![index].notificationId ?? 0, actionType: "NEGATIVE", index: index, status: "Reject")
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    func acceptRejectNotification(notificationId: Int,actionType: String,index: Int, status: String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.acceptRejectNotification(notificationId: notificationId, actionType: actionType, index: index, status: status)
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
                        if status == "Accept" {
//                            let contact = ALContact()
//                            contact.userId = "\(self.arrFriendRequest![index].userId ?? 0)"
//                            contact.displayName = self.arrFriendRequest![index].displayName
//                            let contactService = ALContactService()
//                            contactService.addList(ofContacts: [contact])
                        }
                        self.arrFriendRequest![index].status = status
                        self.tvFriendrequest.reloadData()
                    } else {
                        if let link = URL(string: (response?.result?.redirectUrl)!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(link)
                            } else {
                                UIApplication.shared.openURL(link)
                            }
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension FriendRequestVC {
    func onPressLike(index: Int) {
        
    }
    
    func onPressNext(index: Int) {
        
    }
    
    /// By Pranay
    func sendFriendRequest(id : Int,index: Int, isFriend: Bool = true) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendFriendRequest(id: id, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FRIEND_REQUEST, parameters: ["otherUserId":id,"status":1]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if isFriend {
                        APIManager.sharedManager.playerData?.playerStatus = 1
                        self.tvFriendrequest.reloadData()
                    }
                    else {
                        APIManager.sharedManager.playerData?.playerStatus = 1
                        self.btnAddFriend.setTitle("Cancel", for: .normal)
                        self.btnAddFriend.backgroundColor = Colors.black.returnColor()
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func cancelfriendRequest(id : Int,index: Int, isFriend: Bool = true) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.cancelfriendRequest(id: id, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CANCEL_FRIEND_REQUEST, parameters: ["playerId":id]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if isFriend {
                        APIManager.sharedManager.playerData?.playerStatus = 0
                        self.tvFriendrequest.reloadData()
                    }
                    else {
                        APIManager.sharedManager.playerData?.playerStatus = 0
                        self.btnAddFriend.setTitle("Add Friend", for: .normal)
                        self.btnAddFriend.backgroundColor = Colors.theme.returnColor()
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    /// .
}

extension FriendRequestVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // By Pranay
        if intIdFromSearch == 0 {
            return arrFriendRequest?.count ?? 0 //  By Pranay - default value 10 to 0
        } else {
            return (APIManager.sharedManager.playerData?.playerStatus)! != 2 ? 1 : 0
        }
        // .
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if intIdFromSearch == 0 {   ///  This condition  By Pranay
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell
            
            if arrFriendRequest != nil {
//                cell.hideAnimation()
                cell.ivNotification.setImage(imageUrl: arrFriendRequest![indexPath.row].avatarImage!)
                cell.lblTitle.text = arrFriendRequest![indexPath.item].displayName
                cell.lblTime.text = arrFriendRequest![indexPath.item].requestOn
                
                cell.btnAccept.isHidden = false
                cell.btnDecline.isHidden = false
                cell.heightAcceptView.constant = 42
                cell.viewStatus.backgroundColor = UIColor.white
                
                cell.btnAccept.setTitle("Accept", for: .normal)
                cell.btnDecline.setTitle("Decline", for: .normal)
                
                if arrFriendRequest![indexPath.item].status == "Accept" || arrFriendRequest![indexPath.item].status == "Reject" {
                    cell.btnAccept.isHidden = true
                    cell.btnDecline.isHidden = true
                    cell.heightAcceptView.constant = 0
                    if arrFriendRequest![indexPath.item].status == "Accept" {
                        cell.lblDiscription.text = "Request Accepted."
                        cell.viewStatus.backgroundColor = Colors.theme.returnColor()
                    }
                    else {
                        cell.lblDiscription.text = "Request Declined."
                        cell.viewStatus.backgroundColor = Colors.black.returnColor()
                    }
                }else {
                    cell.lblDiscription.text = "Has sent you a friend request."
                }
                
                cell.index = indexPath.item
                
                cell.onTapAccept = { index in
                    self.acceptRejectRequest(index: index, status: 2)
                    //self.arrFriendRequest[index].isActionDone = 0
                    //self.tvOldNotification.reloadData()
                }
                
                cell.onTapReject = { index in
                    self.acceptRejectRequest(index: index, status: 3)
                }
                
            } else {
                cell.btnAccept.setTitle("", for: .normal)
                cell.btnDecline.setTitle("", for: .normal)
//                cell.showAnimation()
            }
            return cell
            
        /// 332 By Pranay
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRosterTVCell", for: indexPath) as! TeamRosterTVCell
            
            cell.lblName.text = (APIManager.sharedManager.playerData?.displayName)!
            cell.ivProfile.setImage(imageUrl: APIManager.sharedManager.playerData?.avatarImage ?? "")
            cell.lblRole.text = ""
            
            cell.btnRight.isHidden = false
            if (APIManager.sharedManager.playerData?.playerStatus)! == 0 {
                cell.btnRight.setImage(UIImage(named: "User_request"), for: .normal)
            } else if (APIManager.sharedManager.playerData?.playerStatus)! == 1 {
                cell.btnRight.setImage(UIImage(named: "Cancel_user_request"), for: .normal)
            } else {
                cell.btnRight.isHidden = true
            }
            
            cell.index = indexPath.row
            cell.onTapBtn = { index in
                if (APIManager.sharedManager.playerData?.playerStatus)! == 0 {
                    self.sendFriendRequest(id: (APIManager.sharedManager.playerData?.id)!, index: index)
                } else if (APIManager.sharedManager.playerData?.playerStatus)! == 1 {
                    self.cancelfriendRequest(id: (APIManager.sharedManager.playerData?.id)!, index: index)
                }
            }
            return cell
        }
        /// 332 .
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
