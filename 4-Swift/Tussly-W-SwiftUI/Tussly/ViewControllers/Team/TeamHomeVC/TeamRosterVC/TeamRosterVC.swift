//
//  TeamRosterVC.swift
//  - Displays list of all the players like Founder, Admin, & Member as well

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK

class TeamRosterVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var tvRoster : UITableView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var ivGameLogo: UIImageView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var viewGameSelection : UIView!
    
    // MARK: - Variables
    var arrPlayer = [Player]()
    var tempArray: [Player]?
    var selectedGame = [Game]()
    var getAllGameData = [Game]()
    var teamData: Team?
    var selectedGameId = -1
    var teamUserRole: UserRole?
    var teamTabVC: (()->TeamTabVC)?
    var tempPlayerSelected: Player?
    
    var tusslyTabVC: (()->TusslyTabVC)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvRoster.delegate = self
        self.tvRoster.dataSource = self
        self.tvRoster.reloadData()
        setupUI()
        tvRoster.register(UINib(nibName: "TeamRosterTVCell", bundle: nil), forCellReuseIdentifier: "TeamRosterTVCell")
        getGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        
        if self.teamTabVC!().selectedIndex == 1 {
            self.teamTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.teamTabVC!().cvTeamTabs.frame.origin.y),animate: true)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Methods
    
//    func showAnimation() {
//        ivGameLogo.showAnimatedSkeleton()
//        lblTeamName.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivGameLogo.hideSkeleton()
//        lblTeamName.hideSkeleton()
//    }
    
    func setupUI() {
        tvRoster.rowHeight = UITableView.automaticDimension
        tvRoster.estimatedRowHeight = 100.0
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
    }
    
    func searchContent(string: String) {
        if string != "" {
            tempArray = arrPlayer.filter({ (data) -> Bool in
                return ("\(data.displayName ?? "")").lowercased().contains(string.lowercased())
            })
            tvRoster.reloadData()
        }
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        txtSearch.text = ""
        tempArray = arrPlayer
        tvRoster.reloadData()
    }
    
    @IBAction func onTapSelectGame(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectItem = { arrSelected in
            self.selectedGame = arrSelected
            self.ivGameLogo.setImage(imageUrl: arrSelected[0].gameLogo ?? arrSelected[0].gameImage)
            self.lblTeamName.text = arrSelected[0].gameName
            self.selectedGameId = arrSelected[0].id!
            self.getTeamRoster(gameId: arrSelected[0].id!)
        }
        objVC.arrGameList = getAllGameData
        objVC.arrSelected = self.selectedGame
        objVC.isSingleSelection = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    
    func getGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGame()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_GAME, parameters: ["teamId":teamData?.id as Any]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.getAllGameData = (response?.result?.teamGames)!
                if self.getAllGameData.count > 0 {
                    DispatchQueue.main.async {
                        self.viewGameSelection.isHidden = false
//                        self.hideAnimation()
                        self.getAllGameData.insert(self.getAllGameData[0], at: 1)
                        self.getAllGameData[0].id = 0
                        self.getAllGameData[0].gameName = "All"
                        self.getAllGameData[0].gameLogo = ""
                        self.getTeamRoster(gameId: 0)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.viewGameSelection.isHidden = true
//                    self.hideAnimation()
                    self.tempArray = [Player]()
                    self.tvRoster.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getTeamRoster(gameId: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamRoster(gameId: gameId)
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_ROSTER, parameters: ["teamId":teamData?.id as Any, "gameId" : gameId]) { (response: ApiResponse?, error) in
            
//            self.hideAnimation()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrPlayer = (response?.result?.teamRosters)!
                    self.tempArray = self.arrPlayer
                    self.tvRoster.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.tempArray = [Player]()
                    self.tvRoster.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func sendFriendRequest(id : Int,index: Int) {
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
                    let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.tempArray![index].id})
                    if mainIndex != nil {
                        self.arrPlayer[mainIndex!].friendStatus = 1
                    }
                    self.tempArray![index].friendStatus = 1
                    self.tvRoster.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func cancelfriendRequest(id : Int,index: Int) {
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
                    let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.tempArray![index].id})
                    if mainIndex != nil {
                        self.arrPlayer[mainIndex!].friendStatus = 0
                    }
                    self.tempArray![index].friendStatus = 0
                    self.tvRoster.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension TeamRosterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray?.count ?? 0    //default 10 to 0 - By Pranay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamRosterTVCell", for: indexPath) as! TeamRosterTVCell
        
        if tempArray != nil {
//            cell.hideAnimation()
            
            cell.constraintTrailBtnRightToSuperView.priority = .required
            cell.btnRight.isHidden = true
            if tempArray![indexPath.row].friendStatus == 0 {
                cell.btnRight.setImage(UIImage(named: "User_request"), for: .normal)
                cell.btnRight.isHidden = false
            }
            else if tempArray![indexPath.row].friendStatus == 1 {
                cell.btnRight.setImage(UIImage(named: "Cancel_user_request"), for: .normal)
                cell.btnRight.isHidden = false
            }
            else if tempArray![indexPath.row].friendStatus == 2 {
                cell.btnRight.setImage(UIImage(named: "User_chat"), for: .normal)
                cell.btnRight.isHidden = false
            }
            
            if APIManager.sharedManager.user?.id == tempArray![indexPath.row].id {
                cell.btnRight.isHidden = true
            }
            
            cell.index = indexPath.row
            cell.onTapBtn = { index in
                if self.tempArray![index].friendStatus == 0 {
                    self.sendFriendRequest(id: self.tempArray![index].id!, index: index)
                } else if self.tempArray![index].friendStatus == 1 {
                    self.cancelfriendRequest(id: self.tempArray![index].id!, index: index)
                } else if self.tempArray![index].friendStatus == 2 {
                    self.tempPlayerSelected = self.tempArray![index]
                    self.openChat(id: "\(self.tempPlayerSelected?.id ?? 0)")
                }
            }
            cell.lblName.text = tempArray![indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: tempArray![indexPath.row].avatarImage!)
            cell.lblRole.text = Utilities.getRoleName(roleId: tempArray![indexPath.row].role ?? 0)
        } else {
//            cell.showAnimation()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (APIManager.sharedManager.user?.id)! != (tempArray?[indexPath.row].id)! {
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
        }
    }
    
    func openChat(id: String, type: CometChat.ConversationType = .user) {
        /// Pass the CometChat user id for chat
        self.showLoading()
        CometChat.getConversation(conversationWith: id, conversationType: type) { conversation in
            self.openTeamPlayerChatConvorsation(conversation: conversation!, type: type, receiverId: id)
        } onError: { error in
            print("\(error?.errorDescription ?? "")")
            self.hideLoading()
            
            if let cometChatError = error {
                if (cometChatError.errorCode == "ERR_CONVERSATION_NOT_ACCESSIBLE") || ((error?.errorDescription ?? "").contains("does not exists")) {
                    self.openTeamPlayerChatConvorsation(conversation: nil, type: type, receiverId: id)
                }
                else {
                    if (error?.errorCode ?? "") == "ERROR_USER_NOT_LOGGED_IN" {
                        //Utilities.showPopup(title: "User not register with chat.", type: .error)
                        Utilities.showPopup(title: "Chat login failed. Messaging features will be unavailable, but the rest of the application is unaffected.", type: .error)
                    }
                }
            }
        }
    }
    
    fileprivate func openTeamPlayerChatConvorsation(conversation: Conversation?, type: CometChat.ConversationType, receiverId: String) {
        DispatchQueue.main.async {
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
            
            messagesVC.isFromTeamCard = true
            messagesVC.teamTabVC = self.teamTabVC
            messagesVC.tusslyTabVC = self.tusslyTabVC
            
            messagesVC.objConversation = conversation
            messagesVC.senderId = APIManager.sharedManager.strChatUserId
            messagesVC.receiverId = receiverId
            
            messagesVC.strUserName = self.tempPlayerSelected?.displayName ?? ""
            messagesVC.strUserAvatar = self.tempPlayerSelected?.avatarImage ?? ""
            
            self.hideLoading()
            
            self.navigationController?.pushViewController(messagesVC, animated: true)
        }
    }
}


// MARK: - UITextFieldDelegate

extension TeamRosterVC : UITextFieldDelegate {
    
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
            btnSearchAssesory.isSelected = false
            tempArray = arrPlayer
            tvRoster.reloadData()
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
