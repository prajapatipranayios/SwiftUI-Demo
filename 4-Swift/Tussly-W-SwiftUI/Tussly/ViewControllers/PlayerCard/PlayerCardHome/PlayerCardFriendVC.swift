//
//  TeamRosterVC.swift
//  - Displays list of all the players like Founder, Admin, & Member as well

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import Foundation
import CometChatSDK
import DropDown

class PlayerCardFriendVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var tvRoster : UITableView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var lblNoData : UILabel!
    
    @IBOutlet weak var viewTabBar : UIView!
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var viewBottomLine: UIView!
    @IBOutlet weak var constraintTopTVRosterToViewTabBar: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewSearchToViewBack: NSLayoutConstraint!
    @IBOutlet weak var constraintLblNoDataToViewBack: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterYLblNoData: NSLayoutConstraint!
    
    
    // MARK: - Variables
    var selectedIndex: Int = 0 {
        didSet {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: {
                self.viewBottomLine.frame = CGRect(x: self.btnTabs[self.selectedIndex].frame.origin.x - 15 + 2, y: self.btnTabs[self.selectedIndex].frame.size.height - 1, width: self.selectedIndex == 2 ? self.btnTabs[self.selectedIndex].frame.size.width + 15 : self.btnTabs[self.selectedIndex].frame.size.width, height: self.viewBottomLine.frame.size.height)
            }) { finished in
                
            }
        }
    }
    
    var arrPlayer = [Player]()
    var tempArray: [Player]?
    var selectedGame = [Game]()
    var getAllGameData = [Game]()
    var teamData: Team?
    var selectedGameId = -1
    var playerTabVC: (()->PlayerCardTabVC)?
    var tempPlayerSelected: Player?
    var tusslyTabVC: (()->TusslyTabVC)?
    
    var isChatBtnTap: Bool = false
    
    var arrSentFriendRequest: [FriendRequest]?
    var arrFriendRequest: [FriendRequest]?
    var arrTempRequest: [FriendRequest]?
    
    var isFriends: Bool = true
    var isSentRequest: Bool = false
    var isReceiveRequest: Bool = false
    
    var intIdFromSearch : Int = 0
    var isSentRequestCancel: Bool = false
    var isReceiveRequestAcceptReject: Bool = false
    
    let btnAddFriend: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Friend", for: .normal)
        button.backgroundColor = Colors.theme.returnColor()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    let dropDownMenu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Remove Friend"
        ]
        return menu
    }()
    //private var dropdownView: CustomDropdownView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoData.isHidden = true
        
        tvRoster.register(UINib(nibName: "TeamRosterTVCell", bundle: nil), forCellReuseIdentifier: "TeamRosterTVCell")
        tvRoster.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tvRoster.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "FriendRequestCell")
        
        self.tvRoster.delegate = self
        self.tvRoster.dataSource = self
        self.tvRoster.reloadData()
        setupUI()
        
        DispatchQueue.main.async {
            self.lblCount.isHidden = true
            self.lblCount.backgroundColor = Colors.theme.returnColor()
            self.lblCount.layer.cornerRadius = self.lblCount.frame.height / 2
            self.lblCount.clipsToBounds = true
            self.lblCount.textColor = .white
        }
        
        selectedIndex = 0
        didPressTab(btnTabs[selectedIndex])
        //self.getFriend() // Comment - By Pranay
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playerTabVC!().playerDetailsNavVC?.isNavigationBarHidden = true
        
        DropDown.startListeningToKeyboard()
        
        self.btnAddFriend.isHidden = true
        
        if self.playerTabVC!().selectedIndex == 0 {
            self.playerTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.playerTabVC!().cvPlayerTabs.frame.origin.y),animate: true)
        }
        
        self.constraintLblNoDataToViewBack.constant = 80
        
        if intIdFromSearch == 0 {
            self.isFriends = true
            self.isSentRequest = false
            self.isReceiveRequest = false
            
            selectedIndex = 0
            self.constraintTopTVRosterToViewTabBar.priority = .defaultLow
            self.constraintTopViewSearchToViewBack.priority = .defaultLow
            
            self.showLoading()
            self.getFriend()
            //self.getFriendRequest()
        }
        else {
            if APIManager.sharedManager.playerData?.playerStatus ?? 0 != 2 {
                self.lblNoData.isHidden = false
                self.lblNoData.text = "You cannot view this player’s friend list. Add them as a friend."
                self.viewSearchContainer.isHidden = true
                self.viewTabBar.isHidden = true
                
                self.showAddFriendBtn()
            }
            else {
                self.viewTabBar.clipsToBounds = true
                self.viewTabBar.isHidden = true
                self.constraintTopTVRosterToViewTabBar.priority = .defaultLow
                self.constraintTopViewSearchToViewBack.priority = .required
                self.lblNoData.text = "No data found"
                self.getFriend()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func showAddFriendBtn() {
        
        self.constraintLblNoDataToViewBack.constant = 40
        
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
            self.btnAddFriend.topAnchor.constraint(equalTo: self.lblNoData.bottomAnchor, constant: 20),
            self.btnAddFriend.centerXAnchor.constraint(equalTo: self.lblNoData.centerXAnchor),
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
    func setupUI() {
        tvRoster.rowHeight = UITableView.automaticDimension
        tvRoster.estimatedRowHeight = 100.0
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
    }
    
    func searchContent(string: String) {
        if self.isFriends {
            if string != "" {
                tempArray = arrPlayer.filter({ (data) -> Bool in
                    return ("\(data.displayName ?? "")").lowercased().contains(string.lowercased())
                })
                tvRoster.reloadData()
            }
        }
        else if self.isSentRequest {
            if string != "" {
                self.arrTempRequest = (self.arrSentFriendRequest ?? []).filter({ (data) -> Bool in
                    return ("\(data.displayName ?? "")").lowercased().contains(string.lowercased())
                })
                tvRoster.reloadData()
            }
        }
        else if self.isReceiveRequest {
            print("Is receive request")
        }
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        txtSearch.text = ""
        tempArray = arrPlayer
        tvRoster.reloadData()
    }
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
        playerTabVC!().cvPlayerTabs.selectedIndex = -1
        playerTabVC!().cvPlayerTabs.reloadData()
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        if (sender.tag == 0) && (selectedIndex != sender.tag) {
            selectedIndex = sender.tag
            self.lblNoData.isHidden = true
            
            self.isFriends = true
            self.isSentRequest = false
            self.isReceiveRequest = false
            
            self.showLoading()
            self.getFriend()
            self.constraintTopTVRosterToViewTabBar.priority = .defaultLow
        }
        else if ((sender.tag == 1) && (selectedIndex != sender.tag)) || self.isSentRequestCancel {
            self.isSentRequestCancel = false
            selectedIndex = sender.tag
            self.lblNoData.isHidden = true
            
            self.isFriends = false
            self.isSentRequest = true
            self.isReceiveRequest = false
            
            self.showLoading()
            self.arrTempRequest?.removeAll()
            self.getSentFriendRequest()
            self.constraintTopTVRosterToViewTabBar.priority = .defaultLow
        }
        else if ((sender.tag == 2) && (selectedIndex != sender.tag)) || self.isReceiveRequestAcceptReject {
            self.isReceiveRequestAcceptReject = false
            selectedIndex = sender.tag
            self.lblNoData.isHidden = true
            
            self.isFriends = false
            self.isSentRequest = false
            self.isReceiveRequest = true
            
            print("Button Clicked ... - 1")
            self.showLoading()
            self.arrTempRequest?.removeAll()
            self.getFriendRequest()
            self.constraintTopTVRosterToViewTabBar.priority = .required
        }
    }
    
    func displayReceivedFriendRequest(count: Int = 0) {
        self.lblCount.text = "\(count)"
        
        if count > 99 {
            self.lblCount.text = "99+"
        }
        
        if count <= 0 {
            self.lblCount.isHidden = true
        }
        else {
            self.lblCount.isHidden = false
        }
    }
    
    // MARK: - Webservices
    
    func getFriend() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFriend()
                }
            }
            return
        }
        
        let params = ["otherUserId": intIdFromSearch]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIENDS, parameters: params) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                //DispatchQueue.main.async {
                    self.arrPlayer = (response?.result?.friends)!
                    self.tempArray = self.arrPlayer
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.lblNoData.isHidden = true
                    self.tvRoster.reloadData()
                    self.displayReceivedFriendRequest(count: response?.result?.receivedCount ?? 0)
                    
                    if self.arrPlayer.isEmpty {
                        self.lblNoData.text = response?.message ?? ""
                        self.lblNoData.isHidden = false
                        self.tempArray = [Player]()
                        self.tvRoster.reloadData()
                        self.constraintTopTVRosterToViewTabBar.priority = .required
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.lblNoData.text = response?.message ?? ""
                    self.lblNoData.isHidden = false
                    self.tempArray = [Player]()
                    self.tvRoster.reloadData()
                    self.constraintTopTVRosterToViewTabBar.priority = .required
                }
            }
        }
    }
    
    func getSentFriendRequest() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getSentFriendRequest()
                }
            }
            return
        }
        
        let params = ["isSent": 1]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIEND_REQUEST, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if response?.status == 1 {
                    self.arrSentFriendRequest = (response?.result?.friendRequests)!
                    self.arrTempRequest = (response?.result?.friendRequests)!
                    self.lblNoData.isHidden = true
                    
                    if (self.arrSentFriendRequest ?? []).isEmpty {
                        self.constraintTopTVRosterToViewTabBar.priority = .required
                        self.lblNoData.isHidden = false
                        self.lblNoData.text = response?.message ?? ""
                    }
                    self.tvRoster.reloadData()
                }
                else {
                    self.arrSentFriendRequest = [FriendRequest]()
                    self.arrTempRequest = self.arrSentFriendRequest
                    self.constraintTopTVRosterToViewTabBar.priority = .required
                    self.tvRoster.reloadData()
                    self.lblNoData.isHidden = false
                    self.lblNoData.text = response?.message ?? ""
                }
            }
        }
    }
    
    func getFriendRequest() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFriendRequest()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIEND_REQUEST, parameters: nil) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                print("CAll from -- 1")
                if response?.status == 1 {
                    self.arrFriendRequest = response?.result?.friendRequests
                    self.arrTempRequest = response?.result?.friendRequests
                    self.lblCount.text = "\((self.arrFriendRequest ?? []).count)"
                    
                    self.hideLoading()
                    self.lblNoData.isHidden = true
                    self.lblCount.isHidden = false
                    self.displayReceivedFriendRequest(count: self.arrTempRequest?.count ?? 0)
                    
                    if (self.arrFriendRequest ?? []).isEmpty {
                        self.lblNoData.isHidden = false
                        self.lblNoData.text = response?.message ?? ""
                    }
                    self.tvRoster.reloadData()
                }
                else {
                    print("CAll from -- 2")
                    self.hideLoading()
                    print("Get count of requst else ---")
                    self.arrFriendRequest = [FriendRequest]()
                    self.arrTempRequest = self.arrFriendRequest
                    self.tvRoster.reloadData()
                    self.lblNoData.text = response?.message ?? ""
                    self.lblCount.isHidden = true
                    self.lblNoData.isHidden = false
                }
            }
        }
    }
    
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
                        let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.tempArray![index].id})
                        if mainIndex != nil {
                            self.arrPlayer[mainIndex!].friendStatus = 1
                        }
                        self.tempArray![index].friendStatus = 1
                        self.tvRoster.reloadData()
                    }
                    else {
                        APIManager.sharedManager.playerData?.playerStatus = 1
                        self.btnAddFriend.setTitle("Cancel", for: .normal)
                        self.btnAddFriend.backgroundColor = Colors.black.returnColor()
                    }
                }
            }
            else {
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
                        if self.isFriends {
                            let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.tempArray![index].id})
                            if mainIndex != nil {
                                self.arrPlayer[mainIndex!].friendStatus = 0
                            }
                            self.tempArray![index].friendStatus = 0
                            self.tvRoster.reloadData()
                        }
                        else if self.isSentRequest {
                            self.isSentRequestCancel = true
                            self.didPressTab(self.btnTabs[1])
                        }
                    }
                    else {
                        APIManager.sharedManager.playerData?.playerStatus = 0
                        self.btnAddFriend.setTitle("Add Friend", for: .normal)
                        self.btnAddFriend.backgroundColor = Colors.theme.returnColor()
                    }
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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
                    self.isReceiveRequestAcceptReject = true
                    self.didPressTab(self.btnTabs[2])
                    if status == 2 {
                        self.acceptRejectNotification(notificationId: self.arrFriendRequest![index].notificationId ?? 0, actionType: "POSITIVE", index: index,status: "Accept")
                    }
                    else {
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
//                        if status == "Accept" {
//                            
//                        }
//                        self.arrFriendRequest![index].status = status
//                        self.tvRoster.reloadData()
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
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func removeFriendConfirmationPopup(friendId: Int, index: Int) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.removeFriendTitle
        dialog.message = Messages.removeFriendMsg
        dialog.tapOK = {
            self.removeFriend(friendId: friendId, index: index)
        }
        dialog.btnYesText = Messages.yes
        dialog.btnNoText = Messages.cancel
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    func removeFriend(friendId: Int, index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removeFriend(friendId: friendId, index: index)
                }
            }
            return
        }
        
        let params = ["id": friendId]
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_FRIEND, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if response?.status == 1 {
                    //self.removeChatConversation(friendId: self.tempArray?[index].id ?? 0)
                    self.tempArray?.remove(at: index)
                    self.tvRoster.reloadData()
                }
                else {
                }
            }
        }
    }
    
    /*func removeChatConversation(friendId: Int, index: Int = 0) {
        CometChat.deleteConversation(conversationWith: "\(friendId)", conversationType: .user) { message in
            print("Conversation with friend >>>>>>>>>>> \(friendId) deleted.")
        } onError: { error in
            if index < 3 {
                self.removeChatConversation(friendId: friendId, index: index + 1)
            }
            else {
                print("Conversation with friend >>>>>>>>>>> \(friendId) fail to delete.")
            }
        }
    }   //  */
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension PlayerCardFriendVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFriends {
            return self.tempArray?.count ?? 0
        }
        else if self.isSentRequest {
            return (self.arrTempRequest ?? []).count
        }
        else if self.isReceiveRequest {
            return (self.arrTempRequest ?? []).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isFriends {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRosterTVCell", for: indexPath) as! TeamRosterTVCell
            
            cell.constraintTrailBtnRightToSuperView.priority = .required
            cell.btnRight.isUserInteractionEnabled = true
            if tempArray![indexPath.row].friendStatus == 0 {
                cell.btnRight.setImage(UIImage(named: "User_request"), for: .normal)
            }
            else if tempArray![indexPath.row].friendStatus == 1 {
                cell.btnRight.setImage(UIImage(named: "Cancel_user_request"), for: .normal)
            }
            else if tempArray![indexPath.row].friendStatus == 2 {
                cell.btnRight.setImage(UIImage(named: "User_chat"), for: .normal)
                cell.constraintTrailBtnRightToSuperView.priority = .defaultLow
            }
            else if tempArray![indexPath.row].friendStatus == 3 {
                ////Beta 1 - disable chat
                //cell.btnRight.setImage(UIImage(named: "ChatBeta1"), for: .normal)
                cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                cell.btnRight.isUserInteractionEnabled = false
            }
            
            if APIManager.sharedManager.user?.id == tempArray![indexPath.row].id {
                cell.btnRight.isHidden = true
                cell.constraintTrailBtnRightToSuperView.priority = .required
            }
            else {
                cell.btnRight.isHidden = false
            }
            
            cell.index = indexPath.row
            cell.onTapBtn = { index in
                if self.tempArray![index].friendStatus == 0 {
                    self.sendFriendRequest(id: self.tempArray![index].id!, index: index)
                }
                else if self.tempArray![index].friendStatus == 1 {
                    self.cancelfriendRequest(id: self.tempArray![index].id!, index: index)
                }
                else if self.tempArray![index].friendStatus == 2 {
                    if !self.isChatBtnTap {
                        self.isChatBtnTap = true
                        self.tempPlayerSelected = self.tempArray![index]
                        self.openPlayerConvorsation(id: "\(self.tempPlayerSelected?.id ?? 0)", type: .user)
                    }
                }
            }
            
            cell.onTapOptionBtn = { index in
                print("Dropdown list tap.")
                self.dropDownMenu.anchorView = cell.btnOption
                self.dropDownMenu.bottomOffset = CGPoint(x: 0, y: cell.btnOption.bounds.height)
                self.dropDownMenu.tag = index
                self.dropDownMenu.direction = .any
                self.dropDownMenu.selectionAction = {[weak self] (selectedIndex: Int, selectedItem: String) in
                    print("Selected item: \(selectedItem) at index: \(selectedIndex)")
                    // 👉 Perform action here
                    if selectedItem == "Remove Friend" {
                        print("Remove friedn tap >>>>>>>>> \(self?.tempArray![self?.dropDownMenu.tag ?? 0].friendId ?? 0)")
                        self?.removeFriendConfirmationPopup(friendId: self?.tempArray![self?.dropDownMenu.tag ?? 0].friendId ?? 0, index: self?.dropDownMenu.tag ?? 0)
                    }
                }
                self.dropDownMenu.show()
            }
            
            cell.lblName.text = tempArray?[indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: tempArray?[indexPath.row].avatarImage ?? "")
            cell.lblRole.text = "" //Utilities.getRoleName(roleId: tempArray![indexPath.row].role ?? 0)
            
            return cell
        }
        else if self.isSentRequest {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            cell.btnAdd.isHidden = false
            
            cell.lblTeamName.text = ""
            cell.lblPlayerName.text = self.arrTempRequest?[indexPath.row].displayName ?? ""
            cell.lblPlayerName.font = Fonts.Regular.returnFont(size: 16.0)
            cell.ivProfile.setImage(imageUrl: self.arrTempRequest?[indexPath.row].avatarImage ?? "")
            
            if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 0 {
                cell.btnAdd.setTitle("Add Friend", for: .normal)
                cell.btnAdd.backgroundColor = Colors.theme.returnColor()
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
            }
            else if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 1 {
                cell.btnAdd.setTitle("Cancel", for: .normal)
                cell.btnAdd.backgroundColor = Colors.black.returnColor()
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
            }
            else if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 2 {
                cell.btnAdd.setTitle("Added", for: .normal)
                cell.btnAdd.setTitleColor(Colors.black.returnColor(), for: .normal)
                cell.btnAdd.backgroundColor = Colors.lightGray.returnColor()
            }
            else if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 3 {
                cell.btnAdd.setTitle("Declined", for: .normal)
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
                cell.btnAdd.backgroundColor = Colors.disableButton.returnColor()
            }
            
            cell.onTapBtn = { index in
                if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 0 {
                    self.sendFriendRequest(id: (self.arrTempRequest?[index].userId ?? 0), index: index)
                }
                else if (self.arrTempRequest?[indexPath.row].friendStatus ?? 0) == 1 {
                    self.cancelfriendRequest(id: (self.arrTempRequest?[index].userId ?? 0), index: index)
                }
            }
            
            return cell
        }
        else if self.isReceiveRequest {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as! FriendRequestCell
            
            if self.arrTempRequest != nil && (self.arrTempRequest!.count > 0) {
                cell.ivNotification.setImage(imageUrl: self.arrTempRequest?[indexPath.row].avatarImage ?? "")
                cell.lblTitle.text = self.arrTempRequest?[indexPath.row].displayName ?? ""
                cell.lblTime.text = self.arrTempRequest?[indexPath.row].requestOn ?? ""
                
                cell.btnAccept.isHidden = false
                cell.btnDecline.isHidden = false
                cell.heightAcceptView.constant = 42
                cell.viewStatus.backgroundColor = UIColor.white
                
                cell.btnAccept.setTitle("Accept", for: .normal)
                cell.btnDecline.setTitle("Decline", for: .normal)
                
                cell.lblDiscription.text = "Has sent you a friend request."
                
                cell.index = indexPath.item
                
                cell.onTapAccept = { index in
                    self.acceptRejectRequest(index: index, status: 2)
                    //self.arrFriendRequest[index].isActionDone = 0
                    //self.tvOldNotification.reloadData()
                }
                
                cell.onTapReject = { index in
                    self.acceptRejectRequest(index: index, status: 3)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*guard let cell = tableView.cellForRow(at: indexPath) else {
            return // Ignore touches not hitting a real cell
        }
        
        // Optional: More precise point checking
        let location = tableView.panGestureRecognizer.location(in: tableView)
        if let tappedIndexPath = tableView.indexPathForRow(at: location),
           tappedIndexPath == indexPath {
            // Proceed with selection
            print("Selected cell: \(indexPath.row)")
        }
        else {
            return
        }   //  */
        
        //if (APIManager.sharedManager.user?.id)! != (tempArray?[indexPath.row].id)! {
        self.view.tusslyTabVC.isFromSerchPlayerTournament = true
        var playerData = PlayerData()
        playerData.id = tempArray?[indexPath.row].id
        playerData.displayName = tempArray?[indexPath.row].displayName
        playerData.avatarImage = tempArray?[indexPath.row].avatarImage
        playerData.playerDescription = tempArray?[indexPath.row].playerDescription
        playerData.bannerImage = tempArray?[indexPath.row].bannerImage
        playerData.playerStatus = tempArray?[indexPath.row].friendStatus
        
        APIManager.sharedManager.playerData = playerData
        self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[8])
        //}
    }
    
    
    /// Open Chat from Player Card.
    func openPlayerConvorsation(id: String, type: CometChat.ConversationType) {
        CometChat.getConversation(conversationWith: id, conversationType: type) { conversation in
          print("success \(String(describing: conversation?.stringValue()))")
            self.openPlayerChatConvorsation(conversation: conversation!, type: type, receiverId: id)
        } onError: { error in
            print("error \((error?.errorDescription)!)")
            //if (error.code == "ERR_CONVERSATION_NOT_FOUND" || e.message?.contains("does not exists", ignoreCase = true) == true)
            if let cometChatError = error {
                if (cometChatError.errorCode == "ERR_UID_NOT_FOUND") {
                    Utilities.showPopup(title: "The user you're trying to reach does not exist. Please check the user ID and try again.", type: .error)
                    self.isChatBtnTap = false
                }
                else if (cometChatError.errorCode == "ERR_CONVERSATION_NOT_ACCESSIBLE") || ((error?.errorDescription ?? "").contains("does not exists")) {
                    self.openPlayerChatConvorsation(conversation: nil, type: type, receiverId: id)
                }
                else {
                    if (error?.errorCode ?? "") == "ERROR_USER_NOT_LOGGED_IN" {
                        //Utilities.showPopup(title: "User not register with chat.", type: .error)
                        Utilities.showPopup(title: "Chat login failed. Messaging features will be unavailable, but the rest of the application is unaffected.", type: .error)
                        self.isChatBtnTap = false
                    }
                }
            }
        }
    }
    
    fileprivate func openPlayerChatConvorsation(conversation: Conversation?, type: CometChat.ConversationType, receiverId: String) {
        DispatchQueue.main.async {
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
            
            messagesVC.isFromPlayerCard = true
            messagesVC.playerTabVC = self.playerTabVC
            messagesVC.tusslyTabVC = self.tusslyTabVC
            
            
            messagesVC.objConversation = conversation
            messagesVC.senderId = APIManager.sharedManager.strChatUserId
            messagesVC.receiverId = receiverId
            
            messagesVC.strUserName = self.tempPlayerSelected?.displayName ?? ""
            messagesVC.strUserAvatar = self.tempPlayerSelected?.avatarImage ?? ""
            
            self.isChatBtnTap = false
            
            self.navigationController?.pushViewController(messagesVC, animated: true)
        }
    }
}


// MARK: - UITextFieldDelegate

extension PlayerCardFriendVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 0 {
            btnSearchAssesory.isSelected = true
        } else {
            if self.isFriends {
                btnSearchAssesory.isSelected = false
                tempArray = arrPlayer
                tvRoster.reloadData()
            }
            else if self.isSentRequest {
                btnSearchAssesory.isSelected = false
                self.arrTempRequest = self.arrSentFriendRequest
                tvRoster.reloadData()
            }
        }
        if newString.length > 2 {
            searchContent(string: newString as String)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
}

extension PlayerCardFriendVC {
    
}
