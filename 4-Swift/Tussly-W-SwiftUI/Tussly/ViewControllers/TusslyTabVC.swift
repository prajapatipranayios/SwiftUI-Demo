//
//  TusslyTabVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK


class TusslyTabVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var viewtransperentLayer: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var labelTitle: [UILabel]!
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var imgBack: UIImageView!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var logoLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var viewStack : UIStackView!
    
    
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var lblChatNotificationCount: UILabel!
    var initialVC: (()->InitialVC)?
    
    // MARK: - Variables
    var settingsUpdated: Bool = false
    var logoLeadingConstant : Int = 16
    
    var totalLeagues = [League]()
    var totalTournaments = [League]()
    var customeView: TLDropDown?
    var transparentView: UIView?
    var tvSideMenu: UITableView?
    let height: CGFloat = 250
//    var menuOptions = ["How It Works", "Create a Team", "Search Players", "Search Teams",
//                       "Active Leagues", "Past Leagues", "Image Recognition Test",
//                       "Register for a League", "Store"]
    
    var menuOptions = ["Create a Team", "Search Players", "Search Teams", "Search Tournaments", "Provide Feedback", "Register for a Tournament"]
    
    var isFromSerchPlayerTournament : Bool = false
    var leagueTournamentId : Int = 0    //  From Search Tournament
    var isLeagueJoinStatus : Bool = true
    var intSearchTeamId : Int = 0
    var tournamentDetail : League?
    var feedbackLink : String = "https://www.google.com/"
    var arrTotalTeams = [Team]()
    var isEnableNotificationTab: Bool = true
    /// .
    
    var headerView: MenuHeaderView?
    var prevSelectedIndex: Int = -1
    var menuSelectedIndex: Int = -1
    var selectedIndex: Int = 0 {
        didSet {
            if icons != nil {
                for index in 0 ..< icons.count {
                    icons[index].image = UIImage(named: index == selectedIndex ? "\(tabIconImgs[selectedIndex])Active" : tabIconImgs[index])
                    if index < 5 {
                        //if index != 3 { //  By Pranay condition only
                            labelTitle[index].textColor = index == selectedIndex ? Colors.black.returnColor() : Colors.gray.returnColor()
                        //}
                    }
                }
            }
        }
    }
    var viewControllers: [UINavigationController]!
    var initialNavVC: UINavigationController?
    var homeNavVC: UINavigationController?
    var scheduleNavVC: UINavigationController?
    var chatNavVC: UINavigationController?
    var notifNavVC: UINavigationController?
    var teamNavVC: UINavigationController?
    var playerCardNavVC: UINavigationController?
    var settingsNavVC: UINavigationController?
    var searchNavVC : UINavigationController?
    var createNavVC : UINavigationController?
    var leagueNavVC: UINavigationController?
    var menuNavVC: UINavigationController?
    var arenaDisputeScoreNavVC: UINavigationController?
    var tabIconImgs = ["Home",
                       "Search1",
                       "Chat",              //"Chat",    //ChatBeta1 - Disable
                       "Notification",      //"Notification", // NotificationBeta1 - Disable
                       "CreateTeam",
                       "Tournament",
                       "LeagueDeactive",
                       "Teams",
                       "PlayerCard",
                       "Settings"
                       ]
    var teamId = -1
    var leagueConsoleId: Int = -1
    var tournamentConsoleId: Int = -1
    var teamConsoleId = -1
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("ChatNotification"), object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOutSideToHideDropDown(_:)))
        viewtransperentLayer.addGestureRecognizer(tap)
        viewtransperentLayer.isHidden = true
        viewTop.addShadow(offset: CGSize(width: 0, height: 5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
        viewBottom.addShadow(offset: CGSize(width: 0, height: -5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
        imgLogo.layer.cornerRadius = imgLogo.frame.size.height/2
        
        self.lblNotificationCount.clipsToBounds = true
        self.lblNotificationCount.layer.cornerRadius = self.lblNotificationCount.frame.height / 2
        
        self.lblChatNotificationCount.clipsToBounds = true
        self.lblChatNotificationCount.layer.cornerRadius = self.lblChatNotificationCount.frame.height / 2
        
        appDelegate.tusslyTabVC = {
            return self
        }
        
        reloadTopBar()
        self.getUserDetails()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActiveTusslyTab),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackgroundTusslyTab),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //remove below line to enable schedule tab
        //buttons[1].isUserInteractionEnabled = false
        
        self.addChatMessageListener()
    }
    
    func addChatMessageListener() {
        //CometChat.removeMessageListener("chatListListener")
        CometChat.removeMessageListener("mainChatListListener")
        CometChat.addMessageListener("mainChatListListener", self)
    }
    
    @objc func appDidBecomeActiveTusslyTab() {
        print("TusslyTab - App moved to active.")
        if appDelegate.isAutoLogin {
            self.getChatUnreadCount()
        }
    }
    
    @objc func appDidEnterBackgroundTusslyTab() {
        print("TusslyTab - App moved to background.")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CometChat.removeMessageListener("mainChatListListener")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tvSideMenu?.updateHeaderViewHeight()
        headerView?.translatesAutoresizingMaskIntoConstraints = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Methods
    
    // By Pranay
    func notificationCount() {
        DispatchQueue.main.async {
            var notificationCount : Int = 0
            if (UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.notificationCount)! is Int {
                notificationCount = UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) as! Int
            }
            if notificationCount == 0 {
                self.lblNotificationCount.isHidden = true
            } else {
                self.lblNotificationCount.text = "\(notificationCount)"
                self.lblNotificationCount.isHidden = false
            }
        }
    }
    
    // By Pranay
    func chatNotificationCount(usersCount: Int = 0, groupsCount: Int = 0, count: Int = 0) {
        DispatchQueue.main.async {
            var chatNotificationCount : Int = 0
//            if (UserDefaults.standard.value(forKey: UserDefaultType.chatNotificationCount) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.chatNotificationCount)! is Int {
//                chatNotificationCount = UserDefaults.standard.value(forKey: UserDefaultType.chatNotificationCount) as! Int
//            }
            
            if count < 1 {
                chatNotificationCount = chatNotificationCount + usersCount + groupsCount
                APIManager.sharedManager.intUnreadChatCount = chatNotificationCount
            }
            else {
                APIManager.sharedManager.intUnreadChatCount -= 1
            }
            
            if APIManager.sharedManager.intUnreadChatCount <= 0 {
                self.lblChatNotificationCount.isHidden = true
            }
            else {
                if chatNotificationCount > 50 {
                    self.lblChatNotificationCount.text = "50+"
                }
                else {
                    self.lblChatNotificationCount.text = "\(APIManager.sharedManager.intUnreadChatCount)"
                }
                self.lblChatNotificationCount.isHidden = false
            }
        }
    }
    
    @objc func tapOutSideToHideDropDown(_ sender: UITapGestureRecognizer? = nil) {
        viewtransperentLayer.isHidden = true
        customeView?.removeFromSuperview()
    }
    
    func reloadTopBar(){
        APIManager.sharedManager.leagueType = ""
        logoLeadingConst.constant = CGFloat(logoLeadingConstant)
        if logoLeadingConstant == 32{
            imgBack.isHidden = false
        } else {
            //selectedIndex = 0
            imgBack.isHidden = true
            lblHeader.text = "Tussly"
            imgLogo.image = UIImage(named: "Default")
        }
    }
    
    func disableTabButtons() {
        for i in 0 ..< buttons.count {
            buttons[i].isEnabled = false
        }
    }
    
    func enableTabButtons() {
        for i in 0 ..< buttons.count {
            buttons[i].isEnabled = true
        }
    }
    
    func getUserDetails() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getUserDetails()
                }
            }
            return
        }
        
        if appDelegate.isAutoLogin {
            APIManager.sharedManager.authToken = UserDefaults.standard.value(forKey: UserDefaultType.accessToken) as? String ?? ""
            
            showLoading()
            // By Pranay
            let param = [
                "timeZoneOffSet" : (TimeZone.current).offsetFromGMT(),
                "deviceId": AppInfo.DeviceId.returnAppInfo(),
                "deviceName": UIDevice.modelName,
                "deviceOS": "iOS",
                "osVersion": UIDevice.current.systemVersion
            ]
            // .
            APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_USER_DETAIL, parameters: param) { (response: ApiResponse?, error) in
                self.hideLoading()
                if response?.status == 1 {
                    APIManager.sharedManager.user = response?.result?.userDetail
                    APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                    APIManager.sharedManager.strChatUserId = "\(response?.result?.userDetail?.id ?? 0)"
                    DispatchQueue.main.async {
                        print(APIManager.sharedManager.strChatUserId)
                        self.loadTabsOfHomeScreen(isUserLoggedIn: appDelegate.isAutoLogin)
                    }
                }
                else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    
                    APIManager.sharedManager.user = nil
                    APIManager.sharedManager.authToken = ""
                    UserDefaults.standard.removeObject(forKey: UserDefaultType.accessToken)
                    UserDefaults.standard.synchronize()
                    
                    //APIManager.sharedManager.intNotificationCount = 0
                    UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
                    self.notificationCount()
                    
                    DispatchQueue.main.async {
                        appDelegate.isAutoLogin = false
                        self.selectedIndex = 0
                        self.leagueConsoleId = -1
                        self.logoLeadingConstant = 16
                        self.hideLoading()
                        self.loadTabsOfHomeScreen(isUserLoggedIn: false)
                    }
                }
            }
        }
        else {
            loadTabsOfHomeScreen(isUserLoggedIn: appDelegate.isAutoLogin)
            APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_LINK, parameters: nil) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    DispatchQueue.main.async {
                        APIManager.sharedManager.registerLeagueUrl = (response?.result?.registerLeagueUrl)!
                    }
                }
            }
        }
    }
    
    func setupTabbar() {
        let initVC = self.storyboard?.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
        initialNavVC = UINavigationController(rootViewController: initVC)
        initialNavVC?.isNavigationBarHidden = true
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        
        homeVC.didSelectLeague = { tournamentDetail in
            let leagueTabVC = self.leagueNavVC!.viewControllers[0] as! LeagueTabVC
            //leagueTabVC.leagueId = consoleId  //  Comment by Pranay.
            leagueTabVC.tournamentDetail = tournamentDetail
            leagueTabVC.isLeagueJoinStatus = true
            //APIManager.sharedManager.gameId = tournamentDetail.gameId
            APIManager.sharedManager.gameSettings?.id = tournamentDetail.gameId
            for i in 0 ..< self.totalLeagues.count {
                if tournamentDetail.id == self.totalLeagues[i].id {
                    //self.setUpTabView(tag: 6,teamId: -1)
                    break
                }
            }
            for i in 0 ..< self.totalTournaments.count {
                if tournamentDetail.id == self.totalTournaments[i].id {
                    self.setUpTabView(tag: 5,teamId: -1)
                    break
                }
            }
            leagueTabVC.setData()
        }
        
        homeVC.didSelectTeam = { teamId in
            let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
            teamTabVC.selectedTeamId = teamId
            teamTabVC.intIdFromSearch = 0
            self.setUpTabView(tag: 7, teamId: teamId)
        }
        
        homeVC.didSelectPlayerCard = {
            self.setUpTabView(tag: 8, teamId: -1)
        }
        
        homeVC.tusslyTabVC = {
            return self
        }
        
        homeNavVC = UINavigationController(rootViewController: homeVC)
        homeNavVC?.isNavigationBarHidden = true
        
        let scheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleVC
        scheduleNavVC = UINavigationController(rootViewController: scheduleVC)
        scheduleNavVC?.isNavigationBarHidden = true
        
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.tusslyTabVC = {
            return self
        }
        chatVC.isBackFromMessage = true
        chatNavVC = UINavigationController(rootViewController: chatVC)
        chatNavVC?.isNavigationBarHidden = true //  */
        
        let teamVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamTabVC") as! TeamTabVC
        teamVC.tusslyTabVC = {
            return self
        }
        teamNavVC = UINavigationController(rootViewController: teamVC)
        teamNavVC?.isNavigationBarHidden = true
        
        let notificationsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        notificationsVC.tusslyTabVC = {
            return self
        }
        notifNavVC = UINavigationController(rootViewController: notificationsVC)
        notifNavVC?.isNavigationBarHidden = true
        
        
        let playerCardVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerCardTabVC") as! PlayerCardTabVC
        playerCardVC.tusslyTabVC = {
            return self
        }
        playerCardNavVC = UINavigationController(rootViewController: playerCardVC)
        playerCardNavVC?.isNavigationBarHidden = true
        
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        settingsVC.tusslyTabVC = {
            return self
        }
        settingsNavVC = UINavigationController(rootViewController: settingsVC)
        settingsNavVC?.isNavigationBarHidden = true
        
        let leagueTabVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueTabVC") as! LeagueTabVC
        leagueTabVC.tusslyTabVC = {
            return self
        }
        leagueNavVC = UINavigationController(rootViewController: leagueTabVC)
        leagueNavVC?.isNavigationBarHidden = true
        
        let searchTabVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        searchTabVC.tusslyTabVC = {
            return self
        }
        // .
        searchNavVC = UINavigationController(rootViewController: searchTabVC)
        searchNavVC?.isNavigationBarHidden = true
        
        let createTeamVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateTeamVC") as! CreateTeamVC
//        createTeamVC.tusslyTabVC = {
//            return self
//        }
        // .
        createNavVC = UINavigationController(rootViewController: createTeamVC)
        createNavVC?.isNavigationBarHidden = true
        
        let disputescoreVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeScoreVC") as! ArenaDisputeScoreVC
        disputescoreVC.tusslyTabVC = {
            return self
        }
        arenaDisputeScoreNavVC = UINavigationController(rootViewController: disputescoreVC)
        arenaDisputeScoreNavVC?.isNavigationBarHidden = true
    }
    
    func setupSideMenu() {
        transparentView = UIView(frame: self.contentView.bounds)
        transparentView?.tag = 10
        transparentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(transparentView!)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        transparentView?.addSubview(blurView)
        transparentView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView?.addGestureRecognizer(tapGesture)
        transparentView?.isHidden = true
        
        tvSideMenu = UITableView(frame: CGRect(x: contentView.frame.size.width, y: 64, width: contentView.frame.size.width * 0.7, height: contentView.frame.size.height - 64 - 16))
        tvSideMenu?.tag = 20
        contentView.addSubview(tvSideMenu!)
        
        self.contentView.bringSubviewToFront(tvSideMenu!)
        
        tvSideMenu?.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMinYCorner, .layerMinXMaxYCorner], arrCornersBelowiOS11: [.topLeft, .bottomLeft])
        tvSideMenu?.clipsToBounds = true
        
        tvSideMenu?.estimatedSectionHeaderHeight = 40.0
        tvSideMenu?.register(UINib(nibName: "MenuItemTVCell", bundle: nil), forCellReuseIdentifier: "MenuItemTVCell")
        tvSideMenu?.separatorStyle = .none
        tvSideMenu?.isScrollEnabled = true
        tvSideMenu?.bounces = false
        tvSideMenu?.alwaysBounceVertical = false
        tvSideMenu?.rowHeight = UITableView.automaticDimension
        tvSideMenu?.estimatedRowHeight = 45.0
        tvSideMenu?.delegate = self
        tvSideMenu?.dataSource = self
    }
    
    func redirectToTeam(teamID: Int) {
        let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
        teamTabVC.selectedTeamId = teamID
        teamId = teamID
        self.setUpTabView(tag: 7, teamId: teamId)
    }
    
    func openSideMenu() {
        if tvSideMenu == nil {
            setupSideMenu()
        } else {
            self.contentView.bringSubviewToFront(self.transparentView!)
            self.contentView.bringSubviewToFront(self.tvSideMenu!)
            tvSideMenu?.reloadData()
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView?.isHidden = false
            self.tvSideMenu?.frame = CGRect(x: self.contentView.frame.size.width * 0.3, y: 64, width: self.contentView.frame.size.width * 0.7, height: self.contentView.frame.size.height - 64 - 16)
        }, completion: nil)
    }
    
    @objc func onClickTransparentView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView?.isHidden = true
            self.tvSideMenu?.frame = CGRect(x: self.contentView.frame.size.width, y: 64, width: self.contentView.frame.size.width * 0.7, height:  self.contentView.frame.size.height - 64 - 16)
            if self.menuSelectedIndex == -1 {
                self.selectedIndex = self.prevSelectedIndex
            }
        }, completion: nil)
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        selectedIndex = 2
        loadTabsOfHomeScreen(isUserLoggedIn: true)
    }
    
    func loadTabsOfHomeScreen(isUserLoggedIn: Bool) {
        setupTabbar()
        if isUserLoggedIn {
            //viewControllers = [homeNavVC!, scheduleNavVC!, chatNavVC!, notifNavVC!, searchNavVC!, leagueNavVC!, leagueNavVC!, teamNavVC!, playerCardNavVC!, settingsNavVC!]
            viewControllers = [homeNavVC!, searchNavVC!, chatNavVC!, notifNavVC!, createNavVC!, leagueNavVC!, leagueNavVC!, teamNavVC!, playerCardNavVC!, settingsNavVC!]
            
            if CometChat.getLoggedInUser() == nil {
                self.cometChatLogin(count: 1)
            }
            
            
        }
        else {
            //viewControllers = [initialNavVC!, scheduleNavVC!, chatNavVC!, notifNavVC!, searchNavVC!, leagueNavVC!, leagueNavVC!, teamNavVC!, playerCardNavVC!, settingsNavVC!]
            viewControllers = [initialNavVC!, searchNavVC!, chatNavVC!, notifNavVC!, createNavVC!, leagueNavVC!, leagueNavVC!, teamNavVC!, playerCardNavVC!, settingsNavVC!]
        }
        buttons[selectedIndex].isSelected = true
        didPressTab(buttons[selectedIndex])
    }
    
    func setUpTabView(tag: Int, teamId: Int = -1, leagueIndex: Int = -1) {
        
        if !((selectedIndex == 5 || selectedIndex == 6) && tag == 4) {
            //if previous tab was tournament/league and current tab is sidemenu then do not hide backbutton from topbar
            logoLeadingConstant = 16
            reloadTopBar()
        }
        
        //current tab is league/tournament and open sidemenu then do not stop timer unless click menu option
        if (selectedIndex == 5 || selectedIndex == 6) && tag != 4 {
            APIManager.sharedManager.timer.invalidate()
            APIManager.sharedManager.timerRPC.invalidate()
            APIManager.sharedManager.timerPopup.invalidate()
        }
        
        if tag == 7 && teamId == -1 {
            return
        }
        
        if selectedIndex == 4 {
            onClickTransparentView()
        }
        prevSelectedIndex = tag == 4 ? selectedIndex : -1
        menuSelectedIndex = tag == 4 ? menuSelectedIndex : -1
        selectedIndex = tag
                
        if tag != 9 {
            let settingsVC = viewControllers[9].topViewController as! SettingsVC
            if settingsVC.isTABPressed != nil {
                settingsVC.isTABPressed!(true, leagueIndex)
            }
        }
        
        if settingsUpdated {
            return
        }
        
//        if tag == 4 {
//            openSideMenu()
//        } else {
            let vc: UINavigationController = viewControllers[tag]
            vc.popToRootViewController(animated: false)
            
            // ✅ Reset stack to only root VC
            if let rootVC = vc.viewControllers.first {
                vc.setViewControllers([rootVC], animated: false)
            }
            
            /// PlayerCard
            if tag == 8 {
                let playerCardVC = self.playerCardNavVC!.viewControllers[0] as! PlayerCardTabVC
                if (tag == 8) && isFromSerchPlayerTournament && ((APIManager.sharedManager.playerData?.id) ?? 0 != (APIManager.sharedManager.user?.id)!) {
                    playerCardVC.intIdFromSearch = (APIManager.sharedManager.playerData?.id)!
                    playerCardVC.isOtherUser = true
                    self.isFromSerchPlayerTournament = false
                }
                else {
                    playerCardVC.intIdFromSearch = 0
                    playerCardVC.isOtherUser = false
                    if APIManager.sharedManager.isPlayerReportsTabOpen {
                        playerCardVC.selectedIndex = 3
                        APIManager.sharedManager.isPlayerReportsTabOpen = false
                    }
                }
            }
            
            if tag == 2 {
                let chatVC = self.chatNavVC!.viewControllers[0] as! ChatVC
                chatVC.isBackFromMessage = true
            }
            
            vc.popToRootViewController(animated: false)
            vc.view.frame = contentView.bounds
            if contentView.subviews.count > 0 {
                for view in contentView.subviews {
                    if view.tag != 10 && view.tag != 20 {
                        view.removeFromSuperview()
                    }
                }
            }
            contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
//        }
    }
    
    func openSearchView(selectedIndex : Int, fromPlayer : Bool, fromTournaments : Bool) {
        menuSelectedIndex = selectedIndex
        let searchTabVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchPlayerVC") as! SearchPlayerVC
        menuNavVC = UINavigationController(rootViewController: searchTabVC)
        menuNavVC?.isNavigationBarHidden = true
        searchTabVC.isFromPlayer = fromPlayer
        searchTabVC.isFromTournaments = fromTournaments
        addChild(menuNavVC!)
        menuNavVC!.view.frame = contentView.bounds
        contentView.addSubview(menuNavVC!.view)
        menuNavVC!.didMove(toParent: self)
        onClickTransparentView()
    }
    
    
    // MARK: - Button Click Events
    
    @IBAction func tapToBack(_ sender: UIButton) {
        //if logoLeadingConstant == 32 {
            tvSideMenu = nil
            logoLeadingConstant = 16
            selectedIndex = 0
            reloadTopBar()
            let vc: UINavigationController = viewControllers[0]
            vc.popToRootViewController(animated: false)
            vc.view.frame = contentView.bounds
            if contentView.subviews.count > 0 {
                for view in contentView.subviews {
                    view.removeFromSuperview()
                }
            }
            contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
        //}
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                }
            }
            return
        }
        
        APIManager.sharedManager.isMainTabTap = true
        if APIManager.sharedManager.user == nil && sender.tag != 0 {
            //return
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.tussly
            dialog.btnYesText = Messages.login
            if sender.tag == 1 {
                dialog.titleText = Messages.search
                dialog.message = Messages.searchMsg
            }
            else if sender.tag == 2 {
                dialog.titleText = Messages.tussly
                dialog.message = Messages.chat
            }
            else if sender.tag == 3 {
                dialog.titleText = Messages.notification
                dialog.message = Messages.notificationMsg
                ////Beta 1 - disable option
                //return
            }
            else if sender.tag == 4 {
                //self.setUpTabView(tag: sender.tag, teamId: teamId)
                //return
                dialog.titleText = Messages.createTeam
                dialog.message = Messages.createTeamMsg
            }
            else if sender.tag == 6 {
                dialog.titleText = Messages.myLeagues
                dialog.message = Messages.notYetRegisterLeagues
                ////Beta 1 - disable option
                return
            }
            else if sender.tag == 7 {
                dialog.titleText = Messages.createTeam
                dialog.message = Messages.createTeamMsg
            }
            else if sender.tag == 8 {
                dialog.titleText = Messages.playerCardInitial
                dialog.message = Messages.playerCardInitialMsg
            }
            else if sender.tag == 9 {
                dialog.titleText = Messages.setting
                dialog.message = Messages.provideFeedbackMsg
                dialog.isMsgCenter = true
            }
            else if sender.tag == 5 {
                
                // By Pranay
                if isFromSerchPlayerTournament {
                    if customeView == nil {
                        self.tournamentTab()
                    }
                    else {
                        self.removeCustomView()
                        self.tournamentTab()
                    }
                }
                return
            }
            dialog.tapOK = {
                NotificationCenter.default.post(name: Notification.Name("onTapLogin"), object: nil)
            }
            dialog.btnNoText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
        else {
            teamId = -1
            if sender.tag == 0 {
                if appDelegate.isAutoLogin {
                    if CometChat.getLoggedInUser() == nil {
                        self.cometChatLogin(count: 1)
                    }
                }
            }
            else if sender.tag == 6 && leagueConsoleId == -1 {
                return
            }
            else if (leagueConsoleId != -1 && sender.tag == 6) {
                return
            }
            else if sender.tag == 5 && tournamentConsoleId == -1 {
                if isFromSerchPlayerTournament {
                    if customeView == nil {
                        self.tournamentTab()
                    } else {
                        self.removeCustomView()
                        self.tournamentTab()
                    }
                    return
                } else {
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.titleText = Messages.tussly
                    dialog.message = Messages.registerTournament
                    dialog.btnYesText = Messages.ok
                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    return
                }
            }
            else if (tournamentConsoleId != -1 && sender.tag == 5) {
                if customeView == nil {
                    self.tournamentTab()
                } else {
                    self.removeCustomView()
                    self.tournamentTab()
                }
                return
            }
            else if sender.tag == 7 && teamConsoleId != -1 {
                /// 343 By Pranay  -  if conditon add by pranay.
                let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
                // By Pranay
                if !isFromSerchPlayerTournament {
                    teamTabVC.selectedTeamId = teamConsoleId
                    teamId = teamConsoleId
                    teamTabVC.intIdFromSearch = 0
                } else {
                    teamTabVC.selectedTeamId = intSearchTeamId
                    teamId = intSearchTeamId
                    teamTabVC.intIdFromSearch = intSearchTeamId
                    isFromSerchPlayerTournament = false
                }
            }
            else if ((sender.tag == 7) && (teamConsoleId == -1)) && isFromSerchPlayerTournament {
                let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
                teamTabVC.selectedTeamId = intSearchTeamId
                teamId = intSearchTeamId
                teamTabVC.intIdFromSearch = intSearchTeamId   // Need to cehck proper way to work.
                isFromSerchPlayerTournament = false
            }
            else if sender.tag == 2 {
                
                let viewControllers: [UIViewController] = self.chatNavVC!.viewControllers
                for aViewController in viewControllers {
                    if aViewController is ChatMessageVC {
                        //aViewController.isPlayerCardChatTap = false
                        //vc.popViewController(animated: false)
                        //self.chatNavVC!.popToRootViewController(animated: false)
                        self.chatNavVC!.popViewController(animated: false)
                        break
                    }
                }
                
                if selectedIndex != sender.tag {
                    selectedIndex = sender.tag
                }
                else {
                    if APIManager.sharedManager.isForChatNotification {
                        APIManager.sharedManager.isForChatNotification = false
                        
                    }
                    else {
                        return
                    }
                }
                //return
            }
            else if sender.tag == 3 {
                //enable notification button from here
                //Beta 1 - disable option
                selectedIndex = sender.tag
                let notificationTabVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
                
                menuNavVC = UINavigationController(rootViewController: notificationTabVC)
                menuNavVC?.isNavigationBarHidden = true
                
                addChild(menuNavVC!)
                menuNavVC!.view.frame = contentView.bounds
                contentView.addSubview(menuNavVC!.view)
                menuNavVC!.didMove(toParent: self)
                //return
            }
            self.setUpTabView(tag: sender.tag, teamId: teamId)
        }
    }
    
    func removeCustomView() {
        self.viewtransperentLayer.isHidden = true
        self.customeView?.removeFromSuperview()
        self.customeView = nil
    }
    
    func leagueTab() {
        var x = 0
        x = Int((self.view.frame.size.width * 0.6) / 5) - 3
        self.customeView = Bundle.main.loadNibNamed("TLDropDown", owner: self, options: nil)![0] as? TLDropDown
        self.customeView!.layer.masksToBounds = false
        self.customeView!.layer.shadowColor = Colors.black.returnColor().cgColor
        self.customeView!.layer.shadowRadius = 2
        self.customeView!.layer.shadowOpacity = 0.3
        self.customeView!.layer.shadowOffset = CGSize.zero
        self.customeView!.layer.cornerRadius = (self.buttons[6].frame.size.width + 8)/2
        self.customeView?.frame = CGRect(x: self.viewStack.frame.origin.x + CGFloat(x), y: self.viewTop.frame.origin.y + 12, width: self.buttons[6].frame.size.width + 8, height: totalLeagues.count >= 3 ? 232 : CGFloat(totalLeagues.count * 60) + 54)
        self.customeView?.type = "LeagueActive"
        self.customeView?.isScroll = totalLeagues.count >= 2 ? true : false
        self.customeView?.setUpCustomeDropDown(leagueData: totalLeagues)
        self.customeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.customeView?.leagues = totalLeagues
        self.customeView?.didSelectLeague = { index in
            self.viewtransperentLayer.isHidden = true
            self.logoLeadingConstant = 32
            self.reloadTopBar()
            self.setUpTabView(tag: 6, leagueIndex: index)
            let leagueTabVC = self.leagueNavVC!.viewControllers[0] as! LeagueTabVC
            //leagueTabVC.leagueId = self.totalLeagues[index].id    //  By Pranay - Comment by Pranay.
            leagueTabVC.tournamentDetail = self.totalLeagues[index]
        }
        self.customeView?.closeDropDown = {
            self.removeCustomView()
        }
    
    self.viewtransperentLayer.isHidden = false
    self.view.addSubview(self.customeView!)
    }
    
    func tournamentTab() {
        // By Pranay
        // need to check condition for move to tournament page
        if isFromSerchPlayerTournament {
            self.isFromSerchPlayerTournament = false
            self.reloadTopBar()
            self.setUpTabView(tag: 5)
            let leagueTabVC = self.leagueNavVC!.viewControllers[0] as! LeagueTabVC
            leagueTabVC.isFromSearchTournament = true
            leagueTabVC.isLeagueJoinStatus = self.isLeagueJoinStatus
            if leagueTabVC.cvLeagueTabs != nil {
                leagueTabVC.cvLeagueTabs.isLeagueJoinStatus = self.isLeagueJoinStatus
                leagueTabVC.cvLeagueTabs.reloadData()
            }
            
            leagueTabVC.tournamentDetail = self.tournamentDetail
            leagueTabVC.tournamentDetail?.id = (self.tournamentDetail?.leagueId ?? 0 == 0) ? self.tournamentDetail?.id ?? 0 : self.tournamentDetail?.leagueId ?? 0
            //APIManager.sharedManager.gameId = self.tournamentDetail?.gameId ?? 0
            APIManager.sharedManager.gameSettings?.id = self.tournamentDetail?.gameId ?? 0
            leagueTabVC.setData()
        } else {    //  .       -   By Pranay  -   put code in else part
            self.customeView = Bundle.main.loadNibNamed("TLDropDown", owner: self, options: nil)![0] as? TLDropDown
            self.customeView!.layer.masksToBounds = false
            self.customeView!.layer.shadowColor = Colors.black.returnColor().cgColor
            self.customeView!.layer.shadowRadius = 2
            self.customeView!.layer.shadowOpacity = 0.3
            self.customeView!.layer.shadowOffset = CGSize.zero
            self.customeView!.layer.cornerRadius = (self.buttons[5].frame.size.width + 8)/2
            self.customeView?.frame = CGRect(x: self.viewStack.frame.origin.x - 4, y: self.viewTop.frame.origin.y + 16, width: self.buttons[5].frame.size.width + 8, height: totalTournaments.count >= 3 ? 232 : CGFloat(totalTournaments.count * 60) + 54)
            self.customeView?.type = "TournamentActive"
            self.customeView?.isScroll = totalTournaments.count >= 2 ? true : false
            self.customeView?.setUpCustomeDropDown(leagueData: totalTournaments)
            self.customeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.customeView?.leagues = totalTournaments
            self.customeView?.didSelectLeague = { index in
                self.viewtransperentLayer.isHidden = true
                self.logoLeadingConstant = 32
                self.reloadTopBar()
                self.setUpTabView(tag: 5, leagueIndex: index)
                let leagueTabVC = self.leagueNavVC!.viewControllers[0] as! LeagueTabVC
                // By Pranay
                leagueTabVC.isFromSearchTournament = false
                leagueTabVC.isLeagueJoinStatus = true
                self.isLeagueJoinStatus = true
                if leagueTabVC.cvLeagueTabs != nil {
                    leagueTabVC.cvLeagueTabs.isLeagueJoinStatus = self.isLeagueJoinStatus
                    leagueTabVC.cvLeagueTabs.reloadData()
                }
                leagueTabVC.tournamentDetail = self.totalTournaments[index]
                
                APIManager.sharedManager.gameSettings?.id = self.totalTournaments[index].gameId
                leagueTabVC.setData()
            }
            self.customeView?.closeDropDown = {
                self.removeCustomView()
            }
            self.viewtransperentLayer.isHidden = false
            self.view.addSubview(self.customeView!)
        }   //  By Pranay
    }
    
    /// 115 By Pranay
    func teamTab() {
        if isFromSerchPlayerTournament {
            self.isFromSerchPlayerTournament = false
            self.viewtransperentLayer.isHidden = true
            self.logoLeadingConstant = 16
            self.reloadTopBar()
            let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
            teamTabVC.selectedTeamId = self.intSearchTeamId
            self.teamId = self.intSearchTeamId
            teamTabVC.intIdFromSearch = self.intSearchTeamId
            self.isFromSerchPlayerTournament = false
            self.setUpTabView(tag: 7, teamId: self.teamId)
        }
        else {
            var x = 0
            x = Int((self.view.frame.size.width * 0.6) / 5)
            self.customeView = Bundle.main.loadNibNamed("TLDropDown", owner: self, options: nil)![0] as? TLDropDown
            self.customeView!.layer.masksToBounds = false
            self.customeView!.layer.shadowColor = Colors.black.returnColor().cgColor
            self.customeView!.layer.shadowRadius = 2
            self.customeView!.layer.shadowOpacity = 0.3
            self.customeView!.layer.shadowOffset = CGSize.zero
            self.customeView!.layer.cornerRadius = (self.buttons[7].frame.size.width + 8)/2
            self.customeView?.frame = CGRect(x: self.viewStack.frame.origin.x + CGFloat(x * 2), y: self.viewTop.frame.origin.y + 12, width: self.buttons[7].frame.size.width + 8, height: arrTotalTeams.count >= 3 ? 232 : CGFloat(arrTotalTeams.count * 60) + 54)
            self.customeView?.type = "TeamsActive"
            self.customeView?.isScroll = arrTotalTeams.count >= 2 ? true : false
            self.customeView?.setUpCustomeDropDown(leagueData: totalTournaments)
            self.customeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.customeView?.arrTotalTeams = arrTotalTeams
            self.customeView?.didSelectLeague = { index in
                self.viewtransperentLayer.isHidden = true
                self.logoLeadingConstant = 16
                self.reloadTopBar()
                let teamTabVC = self.teamNavVC!.viewControllers[0] as! TeamTabVC
                self.teamConsoleId = self.arrTotalTeams[index].id ?? 0
                teamTabVC.selectedTeamId = self.teamConsoleId
                self.teamId = self.teamConsoleId
                teamTabVC.intIdFromSearch = 0
                self.isFromSerchPlayerTournament = false
                self.setUpTabView(tag: 7, teamId: self.teamId)
            }
            self.customeView?.closeDropDown = {
                self.removeCustomView()
            }
            self.viewtransperentLayer.isHidden = false
            self.view.addSubview(self.customeView!)
        }
    }
    
    func cometChatLogin(count: Int = 1)  {
        CometChat.login(UID: APIManager.sharedManager.strChatUserId, authKey: CometAppConstants.AUTH_KEY, onSuccess: { (user) in
            print("CometChat Login successful : " + user.stringValue())
            
            let fcmToken = UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any
            CometChatNotifications.registerPushToken(pushToken: fcmToken as! String, platform: CometChatNotifications.PushPlatforms.FCM_IOS, providerId: CometAppConstants.PROVIDER_ID, onSuccess: { (success) in
              print("Comet chat register PushToken: \(success)")
            }) { (error) in
              print("Comet chat register PushToken: \(error.errorCode) \(error.errorDescription)")
            }
            
        }) { (error) in
            print("CometChat Login failed with error: " + error.errorDescription);
            let temp = count + 1
            if temp < 3 {
                self.cometChatLogin(count: temp)
            }
            else {
                //Utilities.showPopup(title: "Chat service is temporarily unavailable.", type: .error)
                print("Login Error --> \(error.errorCode)")
                print("Login Error --> \(error.errorDescription)")
            }
        }
    }
}

// MARK: UITableViewDelegate

extension TusslyTabVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = Bundle.main.loadNibNamed("MenuHeaderView", owner: self, options: nil)?[0] as? MenuHeaderView
        
        //headerView?.frame.size = (headerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))!
        headerView?.ivUser.setImage(imageUrl: APIManager.sharedManager.user?.avatarImage ?? "")
        headerView?.lblUserName.text = APIManager.sharedManager.user?.displayName
        headerView?.frame.size = CGSize(width: (headerView?.frame.width)!, height: ((headerView?.ivUser.frame.height)! + (headerView?.lblUserName.frame.height)! + 64.0))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTVCell", for: indexPath) as! MenuItemTVCell
        cell.lblMenuItem.text = menuOptions[indexPath.row]
        // By Pranay Condition change
        if indexPath.row == 5 {
            //.
            cell.lblMenuItem.textColor = Colors.border.returnColor()
        } else {
            cell.lblMenuItem.textColor = Colors.black.returnColor()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if current tab is league/tournament and open sidemenu and click on below options then stop timer
        APIManager.sharedManager.timer.invalidate()
        APIManager.sharedManager.timerRPC.invalidate()
        APIManager.sharedManager.timerPopup.invalidate()
        
        if APIManager.sharedManager.user == nil {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.tussly
            dialog.btnYesText = Messages.login
            if indexPath.row == 0 {
                dialog.titleText = Messages.createTeam
                dialog.message = Messages.createTeamMsg
            } else if (indexPath.row == 1) || (indexPath.row == 2) || (indexPath.row == 3) {
                dialog.titleText = Messages.search
                dialog.message = Messages.searchMsg
                dialog.arrHighlightString = ["Players:", "Teams:", "Tournaments:"]
            } else if indexPath.row == 4 {
                dialog.titleText = Messages.provideFeedback
                dialog.message = Messages.provideFeedbackMsg
                dialog.isMsgCenter = true
            }
            dialog.tapOK = {
                self.onClickTransparentView()
                NotificationCenter.default.post(name: Notification.Name("onTapLogin"), object: nil)
            }
            dialog.btnNoText = Messages.close
            if indexPath.row != 5 {
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }
        }
        else {
            if indexPath.row == 0 {
                menuSelectedIndex = indexPath.row
                let searchTabVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateTeamVC") as! CreateTeamVC
                menuNavVC = UINavigationController(rootViewController: searchTabVC)
                menuNavVC?.isNavigationBarHidden = true
                
                addChild(menuNavVC!)
                menuNavVC!.view.frame = contentView.bounds
                contentView.addSubview(menuNavVC!.view)
                menuNavVC!.didMove(toParent: self)
            }
            else if indexPath.row == 4 {
                menuSelectedIndex = selectedIndex
                onClickTransparentView()
                DispatchQueue.main.async {
                    guard let url = URL(string: self.feedbackLink) else { return }
                    UIApplication.shared.open(url)
                }
            }
            else if indexPath.row == 5 {
            }
            else {
                if indexPath.row == 1 {
                    self.openSearchView(selectedIndex: indexPath.row, fromPlayer: true, fromTournaments: false)
                } else if indexPath.row == 2 {
                    self.openSearchView(selectedIndex: indexPath.row, fromPlayer: false, fromTournaments: false)
                } else if indexPath.row == 3 {
                    self.openSearchView(selectedIndex: indexPath.row, fromPlayer: false, fromTournaments: true)
                }
            }
        }
    }
}

extension TusslyTabVC: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        print("TusslyTab Text message received")
        self.getChatUnreadCount()
        self.messageMarkAsDelivered(baseMessage: textMessage)
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        print("TusslyTab Media message received")
        self.getChatUnreadCount()
        self.messageMarkAsDelivered(baseMessage: mediaMessage)
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        print("TusslyTab Custom message received")
    }
    
    func messageMarkAsDelivered(baseMessage: BaseMessage) {
        CometChat.markAsDelivered(baseMessage : baseMessage, onSuccess: {
            print("TusslyTab markAsDelivered Succces")
        }, onError: {(error) in
            print("TusslyTab markAsDelivered error message",error?.errorDescription)
        })
    }
    
    func getChatUnreadCount() {
        DispatchQueue.main.async {
            CometChat.getUnreadMessageCountForAllUsers { dictUnreadCount in
                if let tempUreadCount = dictUnreadCount as? [String: Int] {
                    //self.intUsersUnreadCount = tempUreadCount.values.reduce(0, +)
                    self.intUsersUnreadCount = tempUreadCount.keys.count
                    
                    self.chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                    
                }
            } onError: { error in
                print("\(error?.errorCode ?? "")")
            }
            
            CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount in
                if let tempUreadCount = dictUnreadCount as? [String: Int] {
                    self.intGroupsUnreadCount = tempUreadCount.keys.count
                    
                    self.chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                }
            } onError: { error in
                print("\(error?.errorCode ?? "")")
            }
        }
    }
}
