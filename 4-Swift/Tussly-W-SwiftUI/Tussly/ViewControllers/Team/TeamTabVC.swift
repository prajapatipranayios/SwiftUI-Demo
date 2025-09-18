//
//  TeamTabVCViewController.swift
//  - Contains information related to Team divided into multiple Tabs.

//  Tussly
//
//  Created by Kishor on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView
import CometChatSDK

class TeamTabVC: UIViewController {

    // MARK: - Variables
    
    var selectedIndex: Int = -1
    var teamDetailsVC: TeamHomeVC?
    var adminToolsVC: AdminToolsVC?
    var manageLeagueRostersVC: ManageLeagueRosterVC?
    var createGroupChatVC: CreateGroupChatVC?
    var chatMessageVC: ChatMessageVC?
    var createEventVC: CreateEventVC?
    var inViteMemberVC: InviteMembersVC?
    
    var teamDetailsNavVC: UINavigationController?
    var adminToolsNavVC: UINavigationController?
    var manageLeagueRostersNavVC: UINavigationController?
    var createGroupChatNavVC: UINavigationController?
    var createEventNavVC: UINavigationController?
    var inViteMemberNavVC: UINavigationController?

    var viewControllersIdetifier = [UIViewController]()
    var userRole: UserRole?
    var teamDetails: Team?
    var players = [Player]()
    var tabName = [String]()
    var selectedTeamId = -1
    
    var tusslyTabVC: (()->TusslyTabVC)?
    
    // MARK: - Controls
    
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cvTeamTabs: CategoryCV!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!

    @IBOutlet weak var ivBanner : UIImageView!
    @IBOutlet weak var viewTeamLogo: UIView!
    @IBOutlet weak var ivTeamLogo : UIImageView!
    @IBOutlet weak var lblTeamName : UILabel!
    @IBOutlet weak var lblTeamDiscription : ExpandableLabel!
    @IBOutlet weak var hightContantView : NSLayoutConstraint!
    @IBOutlet weak var heightCvTab : NSLayoutConstraint!
    @IBOutlet weak var viewRequest: UIView!
    @IBOutlet weak var btnRequest : UIButton!
    @IBOutlet weak var viewshadow: UIView!
    
    // By Pranay
    @IBOutlet weak var lblTeamJoin: UILabel!
    
    var intIdFromSearch : Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tusslyTabVC!().logoLeadingConstant = 16
        tusslyTabVC!().reloadTopBar()
        lblTeamDiscription.collapsed = true
        lblTeamDiscription.delegate = self
        lblTeamDiscription.setLessLinkWith(lessLink: "..Less", attributes: [.font: UIFont.boldSystemFont(ofSize: 15.0),.foregroundColor:UIColor.blue], position: nil)
        lblTeamDiscription.shouldCollapse = true
        lblTeamDiscription.textReplacementType = .word
        lblTeamDiscription.numberOfLines = 2
        lblTeamDiscription.textAlignment = .left
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTab()
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        btnLeft.imageView!.transform = CGAffineTransform(rotationAngle: .pi)
        DispatchQueue.main.async {
            self.hightContantView.constant = self.viewMain.frame.height - 96
            self.ivBanner.layer.cornerRadius = 8.0
            self.viewTeamLogo.layer.cornerRadius = self.viewTeamLogo.frame.height / 2.0
            self.ivTeamLogo.layer.cornerRadius = self.ivTeamLogo.frame.height / 2.0
            
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
        teamDetails = nil
        userRole = nil
        selectedIndex = -1
        viewControllersIdetifier = [UIViewController]()
        players = [Player]()
        tabName = [String]()
        
        /// 143 -  By Pranay - Below code comment by Pranay
//        teamDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamHomeVC") as? TeamHomeVC
//        /// 111 - By Pranay
//        teamDetailsVC?.intIdFromSearch = self.intIdFromSearch
//        /// 111 .
//        teamDetailsVC!.teamTabVC = {
//            return self
//        }
//        teamDetailsNavVC = UINavigationController(rootViewController: teamDetailsVC!)
//        teamDetailsNavVC?.isNavigationBarHidden = true
//        addChild(teamDetailsVC!)
//        teamDetailsVC!.view.frame = contentView.bounds
//        contentView.addSubview(teamDetailsVC!.view)
//        teamDetailsVC!.didMove(toParent: self)
        /// 143 - .
        
//        showAnimation()
        cvTeamTabs.setupCategoryDataSource(items: nil, btnLeft: btnLeft, btnRight: btnRight, isWidthFix: true, isFromPlayer: false, isFromTeams: true)
        setupUI()
        self.getTeamDetail()
    }
    
//    func showAnimation() {
//        btnRight.showAnimatedSkeleton()
//        btnLeft.showAnimatedSkeleton()
//        btnRequest.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        btnRight.hideSkeleton()
//        btnLeft.hideSkeleton()
//        btnRequest.hideSkeleton()
//    }
    
    func setupTeamTabbar() {
        teamDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamHomeVC") as? TeamHomeVC
        teamDetailsVC?.intIdFromSearch = self.intIdFromSearch
        teamDetailsVC!.teamTabVC = {
            return self
        }
        teamDetailsVC!.tusslyTabVC = self.tusslyTabVC
        teamDetailsNavVC = UINavigationController(rootViewController: teamDetailsVC!)
        teamDetailsNavVC?.isNavigationBarHidden = true
        
        adminToolsVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminToolsVC") as? AdminToolsVC
        adminToolsVC!.teamTabVC = {
            return self
        }
        adminToolsNavVC = UINavigationController(rootViewController: adminToolsVC!)
        adminToolsNavVC?.isNavigationBarHidden = true
        
        manageLeagueRostersVC = self.storyboard?.instantiateViewController(withIdentifier: "ManageLeagueRosterVC") as? ManageLeagueRosterVC
        manageLeagueRostersVC!.teamTabVC = {
            return self
        }
        manageLeagueRostersNavVC = UINavigationController(rootViewController: manageLeagueRostersVC!)
        manageLeagueRostersNavVC?.isNavigationBarHidden = true
        
        chatMessageVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
        chatMessageVC!.teamTabVC = {
            return self
        }
        createGroupChatNavVC = UINavigationController(rootViewController: chatMessageVC!)
        createGroupChatNavVC?.isNavigationBarHidden = true //  */
        
        
        createEventVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateEventVC") as? CreateEventVC
        createEventVC!.teamTabVC = {
            return self
        }
        createEventNavVC = UINavigationController(rootViewController: createEventVC!)
        createEventNavVC?.isNavigationBarHidden = true
                
        inViteMemberVC = self.storyboard?.instantiateViewController(withIdentifier: "InviteMembersVC") as? InviteMembersVC
        inViteMemberVC!.teamTabVC = {
            return self
        }
        inViteMemberNavVC = UINavigationController(rootViewController: inViteMemberVC!)
        inViteMemberNavVC?.isNavigationBarHidden = true
    }

    func loadTabsOfTeamScreen() {
        cvTeamTabs.setupCategoryDataSource(items: self.tabName, btnLeft: btnLeft, btnRight: btnRight, isWidthFix: true, isFromPlayer: false, isFromTeams: true)
        updateTab(at: selectedIndex)
    }

    func updateTab(at index: Int) {
        
        //let vc: UINavigationController = teamDetailsNavVC!
        let viewControllers: [UIViewController] = self.teamDetailsNavVC!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ChatMessageVC {
                print("Close ChatMessageVc")
                //self.teamDetailsNavVC!.popViewController(animated: false)
                self.teamDetailsNavVC?.popViewController(animated: false)
                break
            }
        }
        
        if viewControllersIdetifier.count > 0 {
            //if ((self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN") ? index : index + 1) > viewControllersIdetifier.count
            if (index > -1 && (self.tabName[index] == "Leave Team"))
            {
                //Beta 1 - apply below condition if reset 'add video' options
                //if index == viewControllersIdetifier.count + ((self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN") ? 2 : 1)
                //if index == viewControllersIdetifier.count + ((self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN") ? 1 : 0)
                //{
                if self.userRole?.role == "FOUNDER"
                {
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.titleText = Messages.leaveTeam
                    dialog.message = Messages.ownerLeaveTeam
                    dialog.tapOK = {
                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
                        objVC.didSelectItem = { selectedFriend in
                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                            dialog.modalPresentationStyle = .overCurrentContext
                            dialog.modalTransitionStyle = .crossDissolve
                            dialog.titleText = Messages.confirmNewFounder
                            dialog.message = "Do you want to make '\(selectedFriend[0].displayName ?? "")' the new founder of this team? By doing this you will become just a player and have the ability to leave the team."
                            dialog.highlightString = selectedFriend[0].displayName ?? ""
                            dialog.tapOK = {
                                self.changeRole(playerId: selectedFriend[0].id!)
                            }
                            dialog.tapCancel = {
                                self.cvTeamTabs.selectedIndex = self.selectedIndex
                                self.cvTeamTabs.reloadData()
                                self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                            }
                            dialog.btnYesText = Messages.confirmAndLeave
                            dialog.btnNoText = Messages.cancel
                            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                        }
                        objVC.titleString = Messages.founderSelection
                        objVC.buttontitle = Messages.makeNewFounder
                        objVC.placeHolderString = Messages.searchForPlayers
                        objVC.arrFriendsList = self.players
                        objVC.isFromFounder = true
                        objVC.modalPresentationStyle = .overCurrentContext
                        objVC.modalTransitionStyle = .crossDissolve
                        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
                    }
                    dialog.tapCancel = {
                        self.selectedIndex = -1
                        self.cvTeamTabs.selectedIndex = -1
                        self.cvTeamTabs.reloadData()
                    }
                    dialog.btnYesText = Messages.assignNewFounder
                    dialog.btnNoText = Messages.cancel
                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                }
                else
                {
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.titleText = Messages.leaveTeam
                    dialog.message = Messages.sureWantToLeave
                    dialog.btnYesText = Messages.leave
                    dialog.btnNoText = Messages.cancel
                    dialog.tapOK = {
                        self.cvTeamTabs.selectedIndex = self.selectedIndex
                        self.cvTeamTabs.reloadData()
                        self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                        self.leaveTeam()
                    }
                    dialog.tapCancel = {
                        self.cvTeamTabs.selectedIndex = self.selectedIndex
                        self.cvTeamTabs.reloadData()
                        self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                }
                //}
                //else
                //{
                    ////Beta 1 - remove add video options from tab
//                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
//                    objVC.uploadYoutubeVideo = { videoCaption,videoLink,thumbUrl,duration,viewCount in
//                        self.uploadTeamVideo(videoLink: videoLink, caption: videoCaption, thumbUrl: thumbUrl, duration: duration, viewCount: viewCount)
//                    }
//                    objVC.cancelVideo = {
//                        self.cvTeamTabs.selectedIndex = self.selectedIndex
//                        self.cvTeamTabs.reloadData()
//                        self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
//                    }
//                    objVC.titleString = "Team Highlight Video"
//                    objVC.isEdit = false
//                    objVC.modalPresentationStyle = .overCurrentContext
//                    objVC.modalTransitionStyle = .crossDissolve
//                    self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
                //}
            }
            /*else if (self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN") && index == 2
            {
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = Messages.registerForLeague
                dialog.message = Messages.registrationPageYourBrowser
                dialog.btnYesText = Messages.ok
                dialog.btnNoText = Messages.cancel
                dialog.tapOK = {
                    self.cvTeamTabs.selectedIndex = self.selectedIndex
                    self.cvTeamTabs.reloadData()
                    self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                    if let link = URL(string: APIManager.sharedManager.registerLeagueUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(link)
                        } else {
                            // Fallback on earlier versions
                            UIApplication.shared.openURL(link)
                        }
                    }
                }
                
                dialog.tapCancel = {
                    self.cvTeamTabs.selectedIndex = self.selectedIndex
                    self.cvTeamTabs.reloadData()
                    self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
                }
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }   //  */
            else if ((self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN" || self.userRole?.role == "MEMBER") && index == 1) || (!([4].contains((self.userRole?.id)!)) && index == 0)
            {
                /// Pass the CometChat user id for chat
                self.showLoading()
                let vc: UINavigationController = teamDetailsNavVC!
                CometChat.getConversation(conversationWith: self.teamDetails?.chatId ?? "", conversationType: .group) { conversation in
                    print("success \(String(describing: conversation?.stringValue()))")
                    //self.openChatConvorsation(conversation: conversation!, type: .user)
                    
                    DispatchQueue.main.async {
                        let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
                        
                        messagesVC.isFromTeamCard = true
                        messagesVC.teamTabVC = {
                            return self
                        }
                        
                        messagesVC.objConversation = conversation
                        messagesVC.senderId = APIManager.sharedManager.strChatUserId
                        messagesVC.receiverId = self.teamDetails?.chatId ?? ""
                        //(conversation.conversationWith as? CometChatSDK.User)?.tags
                        messagesVC.tusslyTabVC = self.tusslyTabVC
                        
                        self.hideLoading()
                        vc.pushViewController(messagesVC, animated: true)
                    }
                } onError: { error in
                    print("error \(String(describing: error?.errorDescription))")
                    Utilities.showPopup(title: "\((error?.errorDescription)!)", type: .error)
                    self.hideLoading()
                }
                self.hideLoading()
            }
            else
            {
                //print("Tap to change tab >>>> 1")
                //print("Tap to change tab >>>> 1 -- Index >>>> \(index)")
                let tmpIndex = index
                //if self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN" {
                //    //tmpIndex = index > 2 ? (index-1) : index
                //    tmpIndex = index
                //}
                
                let vc: UINavigationController = teamDetailsNavVC!
                if (teamDetailsNavVC?.viewControllers.contains((tmpIndex < 0 ? teamDetailsVC! : viewControllersIdetifier[tmpIndex])))! {
                    //print("Tap to change tab >>>> 2")
                    //print("Tap to change tab >>>> 2 --- tmpIndex >>>> \(tmpIndex)")
                    vc.popToViewController((tmpIndex < 0 ? teamDetailsVC! : viewControllersIdetifier[tmpIndex]), animated: tmpIndex > -1)
                }
                else {
                    //print("Tap to change tab >>>> 3")
                    //print("Tap to change tab >>>> 3 --- tmpIndex >>>> \(tmpIndex)")
                    vc.pushViewController((tmpIndex < 0 ? teamDetailsVC! : viewControllersIdetifier[tmpIndex]), animated: tmpIndex > -1)
                }
                //print("Tap to change tab >>>> 4")
                addChild(vc)
                vc.view.frame = contentView.bounds
                contentView.addSubview(vc.view)
                vc.didMove(toParent: self)
            } 
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapSendCancelRequest(_sender : UIButton) {
        if self.teamDetails?.teamMemberStatus == 0 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "JoinRequestPopupVC") as! JoinRequestPopupVC
            objVC.onTapSendRequestPopUp = { index in
                self.teamDetails?.teamMemberStatus = 1
                self.btnRequest.setTitle("Cancel", for: .normal)
                self.btnRequest.backgroundColor = UIColor.black
                self.btnRequest.setImage(UIImage(named: "Cancel_team_request"), for: .normal)
            }
            //objVC.id = self.teamDetails!.id
            objVC.id = self.teamDetails!.id ?? 0
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        } else {
            //self.cancelTeamRequest(id: self.teamDetails!.id)
            self.cancelTeamRequest(id: self.teamDetails!.id ?? 0)
        }
    }
    
    // MARK: - Webservices
    func getTeamDetail() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamDetail()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_PAGE_DETAIL, parameters: ["teamId" : selectedTeamId]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.cvTeamTabs.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
//                    self.hideAnimation()
                    self.userRole = (response?.result?.userRoles)!
                    self.teamDetails = (response?.result?.teamDetail)!
                    self.ivBanner.setImage(imageUrl: self.teamDetails!.teamBanner ?? "",placeHolder: "Banner_dummy")
                    self.ivTeamLogo.setImage(imageUrl: self.teamDetails!.teamLogo!)
                    self.lblTeamName.text = self.teamDetails?.teamName
                    self.lblTeamDiscription.text = self.teamDetails?.teamDescription
                    
                    //if (self.userRole?.role != "NOT MEMBER") && (self.userRole?.role != nil) {  //  Change Condition - By Pranay
                    if self.teamDetails?.teamMemberStatus == 2 {
                        self.viewRequest.isHidden = true
                        self.setupTeamTabbar()
                        
                        //if guest user
                        if self.userRole?.id == 0 {
                            self.heightCvTab.constant = 0
                            self.btnLeft.isHidden = true
                            self.btnRight.isHidden = true
                            self.viewControllersIdetifier.append(self.adminToolsVC!)
                            self.loadTabsOfTeamScreen()
                            self.getPlayers()
                        }
                        else {
                            //self.heightCvTab.constant = 96    //  By Pranay - Comment code
                            self.heightCvTab.constant = 77      // By Pranay
                            self.btnLeft.isHidden = false
                            self.btnRight.isHidden = false
                            if self.userRole?.canAdminTools == 1 {
                                self.tabName.append("Admin Tools")
                                self.viewControllersIdetifier.append(self.adminToolsVC!)
                            }
                            
                            if self.userRole?.canCreateGroupChat == 1 {
                                //self.tabName.append("Create Group Chat")   //  By Pranay - comment
                                self.tabName.append("Group Chat")   //  By Pranay - added
                                self.viewControllersIdetifier.append(self.chatMessageVC!)
                            }
                            
                            /*if self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN" {
                                //self.tabName.append("Register for League")   //  By Pranay - comment
                                self.tabName.append("Register")   //  By Pranay - added
                            }   //  */
                            
                            if self.userRole?.canInvitePlayer == 1 {
                                self.tabName.append("Invite Members")
                                self.viewControllersIdetifier.append(self.inViteMemberVC!)
                            }
                            
                            //self.tabName.append("Add Video")
                            self.tabName.append("Leave Team")
                            self.cvTeamTabs.intTeamRole = (self.userRole?.id)!
                            self.cvTeamTabs.didSelect = { index in
                                var isTabSetup = false
                                if self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN" {
                                    if index == 4 {
                                        isTabSetup = true
                                        self.updateTab(at: index)
                                    }
                                }
                                
                                if !isTabSetup {
                                    if ((self.userRole?.role == "FOUNDER" || self.userRole?.role == "CAPTAIN" || self.userRole?.role == "ADMIN") ? index : index + 1) > self.viewControllersIdetifier.count {
                                        self.updateTab(at: index)
                                    }else {
                                        self.selectedIndex = index
                                        self.updateTab(at: self.selectedIndex)
                                    }
                                }
                            }
                            self.loadTabsOfTeamScreen()
                            self.getPlayers()
                        }
                    }
                    else {
                        self.viewRequest.isHidden = false
                        
                        // By Pranay
                        self.lblTeamJoin.text = "Request to join this team"
                        // .
                        
                        self.heightCvTab.constant = 50
                        self.btnRequest.layer.cornerRadius = self.btnRequest.frame.size.height / 2
                        self.btnLeft.isHidden = true
                        self.btnRight.isHidden = true
                        
                        self.teamDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamHomeVC") as? TeamHomeVC
                        // By Pranay
                        self.teamDetailsVC?.intIdFromSearch = self.intIdFromSearch
                        // .
                        self.teamDetailsVC!.teamTabVC = {
                            return self
                        }
                        self.teamDetailsNavVC = UINavigationController(rootViewController: self.teamDetailsVC!)
                        self.teamDetailsNavVC?.isNavigationBarHidden = true
                        self.addChild(self.teamDetailsVC!)
                        self.teamDetailsVC!.view.frame = self.contentView.bounds
                        self.contentView.addSubview(self.teamDetailsVC!.view)
                        self.teamDetailsVC!.didMove(toParent: self)
                        
                        if self.teamDetails?.teamMemberStatus == 0 {
                            self.btnRequest.setTitle("Join Team", for: .normal)
                            self.btnRequest.backgroundColor = Colors.theme.returnColor()
                            self.btnRequest.setImage(UIImage(named: "Join_team"), for: .normal)
                        } else if self.teamDetails?.teamMemberStatus == 1 {
                            self.btnRequest.setTitle("Cancel", for: .normal)
                            self.btnRequest.backgroundColor = UIColor.black
                            self.btnRequest.setImage(UIImage(named: "Cancel_team_request"), for: .normal)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
//                    self.hideAnimation()
                    self.cvTeamTabs.setupCategoryDataSource(items: self.tabName, btnLeft: self.btnLeft, btnRight: self.btnRight, isWidthFix: true, isFromPlayer: false, isFromTeams: true)
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func uploadTeamVideo(videoLink: String,caption: String,thumbUrl : String,duration:String, viewCount: String) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadTeamVideo(videoLink: videoLink, caption: caption, thumbUrl: thumbUrl, duration: duration,viewCount: viewCount)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["videoLink": videoLink,"videoCaption" :caption,"moduleId":teamDetails?.id as Any,"moduleType":"TEAM","thumbnail":thumbUrl,"duration":duration, "viewCount": viewCount] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.UPLOAD_VIDEO, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
                self.cvTeamTabs.selectedIndex = self.selectedIndex
                self.cvTeamTabs.reloadData()
                self.cvTeamTabs.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
            if response?.status == 1 {
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func leaveTeam() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.leaveTeam()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LEAVE_TEAM, parameters: ["teamId":teamDetails?.id as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.view.tusslyTabVC.selectedIndex = 0
                    self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getPlayers() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayers()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_MEMBER, parameters: ["teamId":teamDetails?.id as Any]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.players = (response?.result?.teamMembers)!
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func changeRole(playerId : Int) { // For Make Founder
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changeRole(playerId: playerId)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_TEAM_ROLE, parameters: ["teamId":teamDetails?.id as Any,"playerId":playerId,"roleId":4]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.view.tusslyTabVC.selectedIndex = 0
                    self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func cancelTeamRequest(id : Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.cancelTeamRequest(id: id)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CANCEL_TEAM_REQUEST, parameters: ["teamId":id]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.teamDetails?.teamMemberStatus = 0
                    self.btnRequest.setTitle("Join Team", for: .normal)
                    self.btnRequest.backgroundColor = Colors.theme.returnColor()
                    self.btnRequest.setImage(UIImage(named: "Join_team"), for: .normal)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension TeamTabVC: ExpandableLabelDelegate {
    func willExpandLabel(_ label: ExpandableLabel) {
        print("")
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        lblTeamDiscription.collapsed = false
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        print("")
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        lblTeamDiscription.collapsed = true
    }
}
