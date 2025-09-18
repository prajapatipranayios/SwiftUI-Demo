//
//  TeamTabVCViewController.swift
//  - Contains information related to Team divided into multiple Tabs.

//  Tussly
//
//  Created by Kishor on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK

class PlayerCardTabVC: UIViewController {

    // MARK: - Variables
    var viewControllers: [UINavigationController]!
    var selectedIndex: Int = -1
    var playerDetailsVC: PlayerCardHomeVC?
    var playerFriendVC: PlayerCardFriendVC?
    var friendRequestVC: FriendRequestVC?
    var chatVC: ChatVC?
    var trackerNetworkVC: TrackerNetworkVC?
    var gamerTagVC: GamerTagVC?
    var gamePlayedVC: GamePlayedVC?
    var playerReportsVC: PlayerReportsVC?

    var playerDetailsNavVC: UINavigationController?
    var playerCardFriendNavVC: UINavigationController?
    var friendRequestNavVC: UINavigationController?
    var chatNavVC: UINavigationController?
    var gamerTagNavVC: UINavigationController?
    var gamePlayedNavVC: UINavigationController?
    var trackerNetworkNavVC: UINavigationController?
    var playerReportsNavVC: UINavigationController?
    var friendsCount = 0
    var viewControllersIdetifier = [UIViewController]()
    
    var tusslyTabVC: (()->TusslyTabVC)?
    
    var isOtherUser : Bool = false
    var intIdFromSearch : Int = 0
    
    var isTampTap: Bool = false
    
    // MARK: - Controls
    
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cvPlayerTabs: CategoryCV!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!

    @IBOutlet weak var ivBanner : UIImageView!
    @IBOutlet weak var viewPlayerLogo: UIView!
    @IBOutlet weak var ivPlayerLogo : UIImageView!
    @IBOutlet weak var lblPlayerName : UILabel!
    @IBOutlet weak var lblPlayerDiscription : UILabel!
    @IBOutlet weak var hightContantView : NSLayoutConstraint!
    @IBOutlet weak var heightCvTab : NSLayoutConstraint!
    @IBOutlet weak var viewshadow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tusslyTabVC!().logoLeadingConstant = 16
        tusslyTabVC!().reloadTopBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if intIdFromSearch == 0 {
            print("ViewWillAppear My own playercard >>>>>>>>>>>>")
            lblPlayerName.text = APIManager.sharedManager.user?.displayName
            lblPlayerDiscription.text = APIManager.sharedManager.user?.playerDescription
            
            ivPlayerLogo.setImage(imageUrl: APIManager.sharedManager.user!.avatarImage)
            
            if APIManager.sharedManager.user!.bannerImage != "" {
                ivBanner.setImage(imageUrl: APIManager.sharedManager.user!.bannerImage ?? "", placeHolder: "")
            }
            else {
                ivBanner.image = UIImage(named: "Banner_dummy")
            }
        }
        else {
            print("ViewWillAppear Other playercard >>>>>>>>>>>>")
            lblPlayerName.text = APIManager.sharedManager.playerData!.displayName
            lblPlayerDiscription.text = APIManager.sharedManager.playerData!.playerDescription
            
            ivPlayerLogo.setImage(imageUrl: APIManager.sharedManager.playerData!.avatarImage!)
            
            if APIManager.sharedManager.playerData!.bannerImage != "" {
                ivBanner.setImage(imageUrl: APIManager.sharedManager.playerData!.bannerImage ?? "", placeHolder: "")
            }
            else {
                ivBanner.image = UIImage(named: "Banner_dummy")
            }
        }
        
        print("Selected Tab -- \(self.selectedIndex)")
        reloadTab()
        getFriend()
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        btnLeft.imageView!.transform = CGAffineTransform(rotationAngle: .pi)
        DispatchQueue.main.async {
            self.hightContantView.constant = self.viewMain.frame.height - 96
            self.ivBanner.layer.cornerRadius = 8.0
            self.viewPlayerLogo.layer.cornerRadius = self.viewPlayerLogo.frame.height / 2.0
            self.ivPlayerLogo.layer.cornerRadius = self.ivPlayerLogo.frame.height / 2.0
            
            self.viewshadow.layer.cornerRadius = self.viewshadow.frame.size.width / 2
            self.viewshadow.layer.shadowColor = UIColor.black.cgColor
            self.viewshadow.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            self.viewshadow.layer.shadowOpacity = 0.2
            self.viewshadow.layer.shadowRadius = 5.0
            self.viewshadow.layer.masksToBounds = false
            
            self.view.layoutIfNeeded()
        }
    }
    
    func setContentSize(newContentOffset: CGPoint,animate : Bool) {
        scrlView.setContentOffset(newContentOffset, animated: animate)
    }

    func reloadTab() {
        scrlView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        //selectedIndex = APIManager.sharedManager.isPlayerCardOpen ? 4 : -1
        playerDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerCardHomeVC") as? PlayerCardHomeVC
        playerDetailsVC!.playerTabVC = {
            return self
        }
        playerDetailsNavVC = UINavigationController(rootViewController: playerDetailsVC!)
        playerDetailsNavVC?.isNavigationBarHidden = true
        addChild(playerDetailsVC!)
        playerDetailsVC!.view.frame = contentView.bounds
        contentView.addSubview(playerDetailsVC!.view)
        playerDetailsVC!.didMove(toParent: self)
        setupUI()
        
        self.cvPlayerTabs.isOtherUser = self.isOtherUser
        
        self.cvPlayerTabs.didSelect = { index in
            self.selectedIndex = index
            self.updateTab(at: index)
        }
        
        setupPlayerTabbar()
    }
    
    func setupPlayerTabbar() {
        
        playerDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerCardHomeVC") as? PlayerCardHomeVC
        playerDetailsVC!.playerTabVC = {
            return self
        }
        playerDetailsVC?.intIdFromSearch = self.intIdFromSearch
        playerDetailsNavVC = UINavigationController(rootViewController: playerDetailsVC!)
        playerDetailsNavVC?.isNavigationBarHidden = true
        
        
        playerFriendVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerCardFriendVC") as? PlayerCardFriendVC
        playerFriendVC?.intIdFromSearch = self.intIdFromSearch
        playerFriendVC?.tusslyTabVC = self.tusslyTabVC
        playerFriendVC!.playerTabVC = {
            return self
        }
        playerCardFriendNavVC = UINavigationController(rootViewController: playerFriendVC!)
        playerCardFriendNavVC?.isNavigationBarHidden = true
        
        
        friendRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendRequestVC") as? FriendRequestVC
        friendRequestVC?.intIdFromSearch = self.intIdFromSearch
        friendRequestVC!.playerTabVC = {
            return self
        }
        friendRequestNavVC = UINavigationController(rootViewController: friendRequestVC!)
        friendRequestNavVC?.isNavigationBarHidden = true
        
        
        gamerTagVC = self.storyboard?.instantiateViewController(withIdentifier: "GamerTagVC") as? GamerTagVC
        gamerTagVC!.playerTabVC = {
            return self
        }
        gamerTagNavVC = UINavigationController(rootViewController: gamerTagVC!)
        gamerTagNavVC?.isNavigationBarHidden = true

        
        gamePlayedVC = self.storyboard?.instantiateViewController(withIdentifier: "GamePlayedVC") as? GamePlayedVC
        gamePlayedVC?.intIdFromSearch = self.intIdFromSearch
        gamePlayedVC!.playerTabVC = {
            return self
        }
        gamePlayedNavVC = UINavigationController(rootViewController: gamePlayedVC!)
        gamePlayedNavVC?.isNavigationBarHidden = true
        
        
        chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        chatVC?.isFromPlayerCard = true
        chatVC?.isBackFromMessage = true
        chatVC?.isPlayerCardChatTap = true
        chatVC!.playerTabVC = {
            return self
        }
        chatVC?.tusslyTabVC = self.tusslyTabVC
        chatNavVC = UINavigationController(rootViewController: chatVC!)
        chatNavVC?.isNavigationBarHidden = true
        
        trackerNetworkVC = self.storyboard?.instantiateViewController(withIdentifier: "TrackerNetworkVC") as? TrackerNetworkVC
        trackerNetworkVC!.playerTabVC = {
            return self
        }
        trackerNetworkNavVC = UINavigationController(rootViewController: trackerNetworkVC!)
        trackerNetworkNavVC?.isNavigationBarHidden = true

        
        playerReportsVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerReportsVC") as? PlayerReportsVC
        playerReportsVC!.playerTabVC = {
            return self
        }
        playerReportsVC?.intUserId = self.isOtherUser ? self.intIdFromSearch : (APIManager.sharedManager.user?.id ?? 0)
        playerReportsVC?.strBaseUrl = APIManager.sharedManager.baseUrl
        playerReportsNavVC = UINavigationController(rootViewController: playerReportsVC!)
        playerReportsNavVC?.isNavigationBarHidden = true
        
        if intIdFromSearch == 0 {
            print("My own playercard >>>>>>>>>>>>")
            self.viewControllersIdetifier = [ self.playerFriendVC!,
                                              //self.friendRequestVC!,
                                              self.chatVC!,
                                              self.playerReportsVC!,
                                              self.gamePlayedVC!]
            
        }
        else {
            print("Other playercard >>>>>>>>>>>>")
            self.viewControllersIdetifier = [ self.playerFriendVC!,
                                              self.friendRequestVC!,
                                              //self.chatVC!,
                                              self.playerReportsVC!,
                                              self.gamePlayedVC!]
        }
        loadTabsOfPlayerScreen()
    }
    
    func loadTabsOfPlayerScreen() {
        self.cvPlayerTabs.setupCategoryDataSource(items: [ "Friends",
                                                           //"Friend Requests",
                                                           "Chat",
                                                           "Edit Card",
                                                           "Player Reports",
                                                           "Games Played" ],
                                                  btnLeft: self.btnLeft,
                                                  btnRight: self.btnRight,
                                                  isWidthFix: true,
                                                  isFromPlayer: true,
                                                  isFromTeams: false)
        
        if APIManager.sharedManager.isPlayerCardOpen {
            self.cvPlayerTabs.selectedIndex = self.selectedIndex
            self.cvPlayerTabs.reloadData()
            APIManager.sharedManager.isPlayerCardOpen = false
        }
        else {
            self.selectedIndex = -1
        }
        
        self.updateTab(at: selectedIndex)
    }

    func updateTab(at index: Int) {
        //if viewControllers != nil {
        
        let viewControllers: [UIViewController] = self.playerCardFriendNavVC!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ChatMessageVC {
                //aViewController.isPlayerCardChatTap = false
                self.playerCardFriendNavVC!.popViewController(animated: false)
                break
            }
        }
        
        let viewControllers1: [UIViewController] = self.playerDetailsNavVC!.viewControllers
        for aViewController in viewControllers1 {
            print(aViewController)
            if aViewController is ChatMessageVC {
                //aViewController.isPlayerCardChatTap = false
                self.playerDetailsNavVC!.popViewController(animated: false)
                break
            }
        }
        
        if index == 2 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "CreatPlayerCardVC") as! CreatPlayerCardVC
            selectedIndex = -1
            cvPlayerTabs.selectedIndex = -1
            cvPlayerTabs.reloadData()
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        else {
            if self.intIdFromSearch == 0 {
                self.navigateToVC(at: index)
            }
            else {
                if ((APIManager.sharedManager.playerData?.playerStatus)! == 2) && (index == 1) {
                    self.openPlayerConvorsation(id: "\(self.intIdFromSearch)", type: .user)
                }
                else {
                    self.navigateToVC(at: index)
                }
            }
        }
    }
    
    func navigateToVC(at index: Int) {
        let vc: UINavigationController = playerDetailsNavVC!
        
        if (playerDetailsNavVC?.viewControllers.contains(index < 0 ? playerDetailsVC! : viewControllersIdetifier[index > 2 ? index-1 : index]))! {
            vc.popToViewController(index < 0 ? playerDetailsVC! : viewControllersIdetifier[index > 2 ? index-1 : index], animated: false)
        }
        else {
            vc.popViewController(animated: false)
            vc.pushViewController(index < 0 ? playerDetailsVC! : viewControllersIdetifier[index > 2 ? index-1 : index], animated: false)
        }
        
        addChild(vc)
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParent: self)
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
                }
                else if (cometChatError.errorCode == "ERR_CONVERSATION_NOT_ACCESSIBLE") || ((error?.errorDescription ?? "").contains("does not exists")) {
                    self.openPlayerChatConvorsation(conversation: nil, type: type, receiverId: id)
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
    
    fileprivate func openPlayerChatConvorsation(conversation: Conversation?, type: CometChat.ConversationType, receiverId: String) {
        DispatchQueue.main.async {
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
            
            messagesVC.isFromPlayerCard = true
            messagesVC.playerTabVC = {
                return self
            }
            messagesVC.tusslyTabVC = self.tusslyTabVC
            
            messagesVC.objConversation = conversation
            messagesVC.senderId = APIManager.sharedManager.strChatUserId
            messagesVC.receiverId = receiverId
            
            messagesVC.strUserName = APIManager.sharedManager.playerData!.displayName ?? ""
            messagesVC.strUserAvatar = APIManager.sharedManager.playerData!.avatarImage!
            
            //self.navigationController?.pushViewController(messagesVC, animated: true)
            
            let vc: UINavigationController = self.playerDetailsNavVC!
            
            vc.popViewController(animated: false)
            vc.pushViewController(messagesVC, animated: false)
            
            self.addChild(vc)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
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
                DispatchQueue.main.async {
                    self.friendsCount = response?.result?.friends?.count ?? 0
                    
                    if self.friendsCount > 0 {
                        self.cvPlayerTabs.setupCategoryDataSource(items: [ "Friends (\(self.friendsCount))",
                                                                           //"Friend Requests",
                                                                           "Chat",
                                                                           "Edit Card",
                                                                           "Player Reports",
                                                                           "Games Played"],
                                                                  btnLeft: self.btnLeft,
                                                                  btnRight: self.btnRight,
                                                                  isWidthFix: true,
                                                                  isFromPlayer: true,
                                                                  isFromTeams: false)
                        self.cvPlayerTabs.selectedIndex = self.selectedIndex
                        self.cvPlayerTabs.reloadData()
                    }
                }
            }
        }
    }
}

