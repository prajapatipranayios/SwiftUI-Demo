//
//  LeagueTabVC.swift
//  - Designed League Tab screen to manage different features available within League Module

//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import ShipBookSDK
import CometChatSDK
import PostHog

protocol refreshTabDelegate {
    func reloadTab()
}

protocol openTeamPageDelegate {
    func openTeamFromTournament()
}

class LeagueTabVC: UIViewController {
    
    // MARK: - Variables
    
    var selectedIndex: Int = 0 {
        didSet {
            
        }
    }
    var previousSectedIndex: Int = 0
    var delegate: refreshTabDelegate?
    var delegateTeam: openTeamPageDelegate?
    var tusslyTabVC: (()->TusslyTabVC)?
    var matchDetail: Match?
    var standingsNavVC: UINavigationController?
    var lobbyNavVC: UINavigationController?
    var headlinesNavVC: UINavigationController?
    var resultsNavVC: UINavigationController?
    var scheduleNavVC: UINavigationController?
    var mvpRaceNavVC: UINavigationController?
    var leaderBoardNavVC: UINavigationController?
    var highlightNavVC: UINavigationController?
    var manageRosterNavVC: UINavigationController?
    var stepOneNavVC: UINavigationController?
    var leagueInfoNavVC: UINavigationController?
    var enterBalltleIdNavVC: UINavigationController?
    var viewBattleIdNavVC: UINavigationController?
    var connectCodeNavVC: UINavigationController?
    var charSelectionNavVC: UINavigationController?
    var rpcNavVC: UINavigationController?
    var waitNavVC: UINavigationController?
    var stagePickNavVC: UINavigationController?
    var roundNavVC: UINavigationController?
    var statusNav: UINavigationController?
    var bothReadyNavVC: UINavigationController?
    var arenaDisputeScoreNavVC: UINavigationController?
    var tournamentBracketNavVC: UINavigationController?
    var nextRoundNavVC: UINavigationController?
    var groupChatNavVC: UINavigationController?
    var chatNavVC: UINavigationController?
    var lobbyVC = ArenaLobbyTournamentVC()
    var arenaStepOneVC = ArenaStepOneVC()
    var rpcVC = ArenaRockPaperScisierVC()
    var bracketVC = BracketTabVC()
    var scoreVC = ArenaRoundResultVC()
    var nextRoundVC = ArenaNextRoundStepVC()
    var chatVC = ChatVC()
    var isTBD = false
    var viewControllers: [UINavigationController]!
    var arrLeagueIcon = [Team]()
    var userRole: UserRole?
    var currentWeek = -1
    var teamName = ""
    var teamId = -1
    var gameDetails: Game?
    //var leagueId = -1 //  By Pranay - Comment by Pranay.
    let db = Firestore.firestore()
    var doc:DocumentSnapshot?
    var playerChar : Characters?
    var playerStage = [Int]()
    var isBackToArena = false
    var isArenaClsoe = false
    
    var isFromSearchTournament : Bool = false
    var isLeagueJoinStatus : Bool = true
    var tournamentInviteLink : String = "https://www.google.com/"
    var isFromGetLeagueMatch : Bool = false
    var leagueRegistrationStatus : Int? = 1
    var leagueMatchStatus : Int? = 0
    var tournamentDetail : League?
    var isNewMatch : Bool = false
    var isDisputeNotificationApiCall : Bool = false
    var matchResetNavVC: UINavigationController?
    var discordLink : String = ""
    var getLeagueMatches: GetLeagueMatches?
    var isStageRank: Bool = false
    var arrSelectedStageIndex = [Int]()
    var arrStagePicked = [Int]()
    var isRefreshBtnTap: Bool = false
//    fileprivate let log = ShipBook.getLogger(LeagueTabVC.self)
    var isFromOutSideArena: Bool = false
    
    var onChatUnreadUpdate: ((Bool) -> Void)?  // true = show red dot, false = hide
    var showUnreadCount: Bool = false
    
    
    // MARK: - Controls
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cvLeagueTabs: CategoryCV!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblTireName : UILabel!
    @IBOutlet weak var ivGameLogo : UIImageView!
    @IBOutlet weak var socialMediaView: UIView!
    @IBOutlet weak var ivSocialMedia1 : UIImageView!
    @IBOutlet weak var ivSocialMedia2 : UIImageView!
    @IBOutlet weak var lblSocialMediaCount : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var hightContantView : NSLayoutConstraint!
    @IBOutlet weak var socialViewHeight : NSLayoutConstraint!
    @IBOutlet weak var viewshadow: UIView!
    @IBOutlet weak var headerView : UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PostHogSDK.shared.stopSessionRecording()
        //PostHogSDK.shared.optOut()
        //PostHogSDK.shared.startSessionRecording()
        //PostHogSDK.shared.optIn()
        //PostHogSDK.shared.capture("iOS-Tussly-Events")
        //PostHogSDK.shared.screen("LeagueTabVC", properties: [:])
        
        scrlView.isScrollEnabled = false
        cvLeagueTabs.tag = 555
        ivGameLogo.layer.cornerRadius = ivGameLogo.frame.size.height / 2
        cvLeagueTabs.setupCategoryDataSource(items: nil, btnLeft: btnLeft, btnRight: btnRight, isFromPlayer: false, isFromTeams: false)
        btnLeft.imageView!.transform = CGAffineTransform(rotationAngle: .pi)
        cvLeagueTabs.didSelect = { index in
            if index != self.selectedIndex {
                //continue arena flow after back from another tab
                if index == 1 && self.selectedIndex != 1 {
                    /// Set flag true for active timer
                    APIManager.sharedManager.isMatchRefresh = true
                    self.isBackToArena = true
                    self.previousSectedIndex = self.selectedIndex
                    self.selectedIndex = index
                    if self.isNewMatch {
                        self.setData()
                        print("If condition >>>>> true")
                    }
                    else {
                        self.getStatus()
                        print("If condition >>>>> false")
                    }
                }
                else {
                    if self.statusNav == self.stepOneNavVC! && self.arenaStepOneVC.isTap {
                        //do not open other tab if player has just enter arena
                        print(self.selectedIndex)
                        self.cvLeagueTabs.selectedIndex = self.selectedIndex
                        self.cvLeagueTabs.reloadData()
                        return
                    }
                    self.previousSectedIndex = self.selectedIndex
                    self.selectedIndex = index
                    self.updateTab(at: self.selectedIndex)
                }
            }
        }
        
    }
    
    func setContentSize(newContentOffset: CGPoint,animate : Bool) {
        scrlView.setContentOffset(newContentOffset, animated: animate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cvLeagueTabs.selectedIndex = 0
        DispatchQueue.main.async {
            self.cvLeagueTabs.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            self.tusslyTabVC!().logoLeadingConstant = 32
            self.tusslyTabVC!().reloadTopBar()
        }
        self.socialMediaView.isHidden = true
        selectedIndex = 0
        self.scrlView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        //remove previous league data from displaying
        ivGameLogo.image = nil
        ivLogo.image = nil
        self.lblTireName.text =  ""
        self.lblDesc.text = ""
        self.viewControllers = nil
        if contentView.subviews.count > 0 {
            for view in contentView.subviews {
                view.removeFromSuperview()
            }
        }
        
//        ivLogo.isSkeletonable = true
//        lblTireName.isSkeletonable = true
//        lblDesc.isSkeletonable = true
//        view.isSkeletonable = true
//        ivGameLogo.isSkeletonable = true
        
        self.setupLeagueTabbar()
        self.statusNav = self.stepOneNavVC!
        self.loadTabsOfLeagueScreen()   // By Pranay
        cvLeagueTabs.isLeagueJoinStatus = self.isLeagueJoinStatus
        cvLeagueTabs.reloadData()
        //self.teamId = (leagueDetail?.leagueMatch?.teamId)!
        self.isFromOutSideArena = false
        
        DispatchQueue.main.async {
            self.hightContantView.constant = self.viewMain.frame.height - 74
            
            CometChat.addMessageListener("leagueChatMsgListener", self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("View will disappear -- League Tab VC")
        CometChat.removeMessageListener("leagueChatMsgListener")
        
        //PostHogSDK.shared.stopSessionRecording()
        //PostHogSDK.shared.optOut()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //view.layoutSkeletonIfNeeded()
    }
    
    // MARK: - UI Methods
    func navigateToBracket(matchId: Int, matchNo: Int) {
        self.selectedIndex = 2
        self.cvLeagueTabs.selectedIndex = self.selectedIndex
        self.cvLeagueTabs.reloadData()
        bracketVC.scrollMatchID = matchId
        bracketVC.scrollmatchNo = matchNo
        bracketVC.isScrollAsSchedule = true
        self.updateTab(at: self.selectedIndex)
    }
    
    
    func setData() {
        self.getTournamentContent()
        DispatchQueue.main.async {
            print("Call - 3")
            self.cvLeagueTabs.isLeagueJoinStatus = self.isLeagueJoinStatus
            self.cvLeagueTabs.reloadData()
        }
    }
    
    func setupLeagueTabbar() {
        let standVC = self.storyboard?.instantiateViewController(withIdentifier: "StandingsVC") as! StandingsVC
        standVC.tusslyTabVC = self.tusslyTabVC
        standVC.leagueTabVC = {
            return self
        }
        standingsNavVC = UINavigationController(rootViewController: standVC)
        standingsNavVC?.isNavigationBarHidden = true
        
        let headlineVC = self.storyboard?.instantiateViewController(withIdentifier: "HeadLineVC") as! HeadLineVC
        headlineVC.tusslyTabVC = self.tusslyTabVC
        headlineVC.leagueTabVC = {
            return self
        }
        headlinesNavVC = UINavigationController(rootViewController: headlineVC)
        headlinesNavVC?.isNavigationBarHidden = true
        
        let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
        resultVC.tusslyTabVC = self.tusslyTabVC
        resultVC.leagueTabVC = {
            return self
        }
        resultsNavVC = UINavigationController(rootViewController: resultVC)
        resultsNavVC?.isNavigationBarHidden = true
        
        let leaderBoardVC = self.storyboard?.instantiateViewController(withIdentifier: "LeaderboardVC") as! LeaderboardVC
        leaderBoardVC.tusslyTabVC = self.tusslyTabVC
        leaderBoardVC.leagueTabVC = {
            return self
        }
        leaderBoardNavVC = UINavigationController(rootViewController: leaderBoardVC)
        leaderBoardNavVC?.isNavigationBarHidden = true
        
        let scheduleVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueScheduleVC") as! LeagueScheduleVC
        scheduleVC.tusslyTabVC = self.tusslyTabVC
        scheduleVC.leagueTabVC = {
            return self
        }
        scheduleNavVC = UINavigationController(rootViewController: scheduleVC)
        scheduleNavVC?.isNavigationBarHidden = true
        
        let mvpRaceVC = self.storyboard?.instantiateViewController(withIdentifier: "MVPRaceVC") as! MVPRaceVC
        mvpRaceVC.tusslyTabVC = self.tusslyTabVC
        mvpRaceVC.leagueTabVC = {
            return self
        }
        mvpRaceNavVC = UINavigationController(rootViewController: mvpRaceVC)
        mvpRaceNavVC?.isNavigationBarHidden = true
        
        let highlightVC = self.storyboard?.instantiateViewController(withIdentifier: "HighlightVC") as! HighlightVC
        highlightVC.tusslyTabVC = self.tusslyTabVC
        highlightVC.leagueTabVC = {
            return self
        }
        highlightNavVC = UINavigationController(rootViewController: highlightVC)
        highlightNavVC?.isNavigationBarHidden = true
        
        let rosterVC = self.storyboard?.instantiateViewController(withIdentifier: "ManageRosterVC") as! ManageRosterVC
        rosterVC.tusslyTabVC = self.tusslyTabVC
        rosterVC.leagueTabVC = {
            return self
        }
        manageRosterNavVC = UINavigationController(rootViewController: rosterVC)
        manageRosterNavVC?.isNavigationBarHidden = true
        
        arenaStepOneVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStepOneVC") as! ArenaStepOneVC
        arenaStepOneVC.tusslyTabVC = self.tusslyTabVC
        arenaStepOneVC.leagueTabVC = {
            return self
        }
        stepOneNavVC = UINavigationController(rootViewController: arenaStepOneVC)
        stepOneNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        lobbyVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaLobbyTournamentVC") as! ArenaLobbyTournamentVC
        lobbyVC.tusslyTabVC = self.tusslyTabVC
        lobbyVC.leagueTabVC = {
            return self
        }
        lobbyNavVC = UINavigationController(rootViewController: lobbyVC)
        lobbyNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let leagueInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueInfoVC") as! LeagueInfoVC
        // By Pranay
        print("Call - 1")
        leagueInfoVC.isLeagueJoinStatus = self.isLeagueJoinStatus
        leagueInfoVC.tournamentInviteLink = self.tournamentInviteLink
        leagueInfoVC.leagueRegistrationStatus = self.leagueRegistrationStatus
        leagueInfoVC.leagueMatchStatus = self.leagueMatchStatus
        leagueInfoVC.discordLink = self.discordLink
        // .
        leagueInfoVC.tusslyTabVC = self.tusslyTabVC
        leagueInfoVC.leagueTabVC = {
            return self
        }
        leagueInfoNavVC = UINavigationController(rootViewController: leagueInfoVC)
        leagueInfoNavVC?.isNavigationBarHidden = true
        
        let enterIdVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaEnterBattleIDVC") as! ArenaEnterBattleIDVC
        enterIdVC.tusslyTabVC = self.tusslyTabVC
        enterIdVC.leagueTabVC = {
            return self
        }
        enterBalltleIdNavVC = UINavigationController(rootViewController: enterIdVC)
        enterBalltleIdNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let viewIdVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaViewBattleIDVC") as! ArenaViewBattleIDVC
        viewIdVC.tusslyTabVC = self.tusslyTabVC
        viewIdVC.leagueTabVC = {
            return self
        }
        viewBattleIdNavVC = UINavigationController(rootViewController: viewIdVC)
        viewBattleIdNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        // By Pranay
        let arenaMatchResetVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaMatchResetVC") as! ArenaMatchResetVC
        arenaMatchResetVC.tusslyTabVC = self.tusslyTabVC
        arenaMatchResetVC.leagueTabVC = {
            return self
        }
        matchResetNavVC = UINavigationController(rootViewController: arenaMatchResetVC)
        matchResetNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let connectCodeVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaConnectCodeVC") as! ArenaConnectCodeVC
        connectCodeVC.tusslyTabVC = self.tusslyTabVC
        connectCodeVC.leagueTabVC = {
            return self
        }
        connectCodeNavVC = UINavigationController(rootViewController: connectCodeVC)
        connectCodeNavVC?.updateNavigation(width: self.view.frame.size.width)
        //.
        
        let charSelectVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
        charSelectVC.tusslyTabVC = self.tusslyTabVC
        charSelectVC.leagueTabVC = {
            return self
        }
        charSelectionNavVC = UINavigationController(rootViewController: charSelectVC)
        charSelectionNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let readyVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWeAreBothInVC") as! ArenaWeAreBothInVC
        readyVC.tusslyTabVC = self.tusslyTabVC
        readyVC.leagueTabVC = {
            return self
        }
        bothReadyNavVC = UINavigationController(rootViewController: readyVC)
        bothReadyNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        rpcVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRockPaperScisierVC") as! ArenaRockPaperScisierVC
        rpcVC.tusslyTabVC = self.tusslyTabVC
        rpcVC.leagueTabVC = {
            return self
        }
        rpcNavVC = UINavigationController(rootViewController: rpcVC)
        rpcNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
        stagePickVC.tusslyTabVC = self.tusslyTabVC
        stagePickVC.leagueTabVC = {
            return self
        }
        stagePickNavVC = UINavigationController(rootViewController: stagePickVC)
        stagePickNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        scoreVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
        scoreVC.tusslyTabVC = self.tusslyTabVC
        scoreVC.leagueTabVC = {
            return self
        }
        roundNavVC = UINavigationController(rootViewController: scoreVC)
        roundNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        nextRoundVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaNextRoundStepVC") as! ArenaNextRoundStepVC
        nextRoundVC.tusslyTabVC = self.tusslyTabVC
        nextRoundVC.leagueTabVC = {
            return self
        }
        nextRoundNavVC = UINavigationController(rootViewController: nextRoundVC)
        nextRoundNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let disputescoreVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeScoreVC") as! ArenaDisputeScoreVC
        disputescoreVC.tusslyTabVC = self.tusslyTabVC
        disputescoreVC.leagueTabVC = {
            return self
        }
        arenaDisputeScoreNavVC = UINavigationController(rootViewController: disputescoreVC)
        arenaDisputeScoreNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        let groupChat = self.storyboard?.instantiateViewController(withIdentifier: "ArenaGroupChatVC") as! ArenaGroupChatVC
        groupChat.tusslyTabVC = self.tusslyTabVC
        groupChat.leagueTabVC = {
            return self
        }
        groupChatNavVC = UINavigationController(rootViewController: groupChat)
        groupChatNavVC?.updateNavigation(width: self.view.frame.size.width)
        
        bracketVC = self.storyboard?.instantiateViewController(withIdentifier: "BracketTabVC") as! BracketTabVC
        bracketVC.tusslyTabVC = self.tusslyTabVC
        bracketVC.leagueTabVC = {
            return self
        }
        tournamentBracketNavVC = UINavigationController(rootViewController: bracketVC)
        tournamentBracketNavVC?.isNavigationBarHidden = true
        
        chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.isFromTournament = true
        chatVC.leagueTabVC = {
            return self
        }
        chatNavVC = UINavigationController(rootViewController: chatVC)
        chatNavVC?.isNavigationBarHidden = true
        
        let waitDalogVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
        waitDalogVC.tusslyTabVC = self.tusslyTabVC
        waitDalogVC.leagueTabVC = {
            return self
        }
        waitNavVC = UINavigationController(rootViewController: waitDalogVC)
        waitNavVC?.isNavigationBarHidden = true
        
    }
    
    func loadTabsOfLeagueScreen() {
        if APIManager.sharedManager.leagueType == "League" {
            cvLeagueTabs.setupCategoryDataSource(items: ["Arena","League Info","Standings", "Results", "Schedule", "Leaderboard"], btnLeft: btnLeft, btnRight: btnRight, isFromPlayer: false, isFromTeams: false)
            viewControllers = [statusNav!,leagueInfoNavVC!,standingsNavVC!, resultsNavVC!, scheduleNavVC!, leaderBoardNavVC!]
        }
        else {
            self.delegateTeam?.openTeamFromTournament()
            cvLeagueTabs.setupCategoryDataSource(items: ["Tournament Info","Arena","Bracket", "Leaderboard", "Contact Admin"], btnLeft: btnLeft, btnRight: btnRight, isFromPlayer: false, isFromTeams: false)
            viewControllers = [leagueInfoNavVC!,statusNav!,tournamentBracketNavVC!, standingsNavVC!, chatNavVC!]
        }
        self.delegate?.reloadTab()
        updateTab(at: selectedIndex)
    }
    
    func redirectToTeam(teamId: Int) {
        DispatchQueue.main.async {
            self.cvLeagueTabs.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            self.tusslyTabVC!().redirectToTeam(teamID: teamId)
        }
    }
    
    func updateTab(at index: Int) {
        if viewControllers != nil {
            APIManager.sharedManager.timer.invalidate()
            APIManager.sharedManager.timerRPC.invalidate()
            APIManager.sharedManager.timerPopup.invalidate()
            
            if index == 4 {
                if (APIManager.sharedManager.user?.id ?? 0) != (self.gameDetails?.createdBy ?? 0) {
                    /// Pass the CometChat user id for chat
                    self.showLoading()
                    //let vc: UINavigationController = teamDetailsNavVC!
                    CometChat.getConversation(conversationWith: "\(self.gameDetails?.createdBy ?? 0)", conversationType: .user) { conversation in
                        
                        self.openTournamentChatConvorsation(conversation: conversation, type: .user, receiverId: "\(self.gameDetails?.createdBy ?? 0)")
                    } onError: { error in
                        print("error \(String(describing: error?.errorDescription))")
                        self.hideLoading()
                        //Utilities.showPopup(title: "\((error?.errorDescription)!)", type: .error)
                        
                        if let cometChatError = error {
                            if (cometChatError.errorCode == "ERR_CONVERSATION_NOT_ACCESSIBLE") || ((error?.errorDescription ?? "").contains("does not exists")) {
                                self.openTournamentChatConvorsation(conversation: nil, type: .user, receiverId: "\(self.gameDetails?.createdBy ?? 0)")
                            }
                            else {
                                if (error?.errorCode ?? "") == "ERROR_USER_NOT_LOGGED_IN" {
                                    //Utilities.showPopup(title: "User not register with chat.", type: .error)
                                    Utilities.showPopup(title: "Chat login failed. Messaging features will be unavailable, but the rest of the application is unaffected.", type: .error)
                                }
                                DispatchQueue.main.async {
                                    self.cvLeagueTabs.selectedIndex = self.previousSectedIndex
                                    self.cvLeagueTabs.reloadData()
                                    self.updateTab(at: self.previousSectedIndex)
                                }
                            }
                        }
                    }
                }
                else {
                    Utilities.showPopup(title: "This is your own tourament.", type: .error)
                    self.cvLeagueTabs.selectedIndex = self.previousSectedIndex
                    self.cvLeagueTabs.reloadData()
                    self.updateTab(at: self.previousSectedIndex)
                }
            }
            else {
                DispatchQueue.main.async {
                    let vc: UINavigationController = self.viewControllers[index]
                    vc.popToRootViewController(animated: false)
                    
                    if self.contentView.subviews.count > 0 {
                        for view in self.contentView.subviews {
                            view.removeFromSuperview()
                        }
                    }
                    self.addChild(vc)
                    vc.view.frame = self.contentView.bounds
                    self.contentView.addSubview(vc.view)
                    vc.didMove(toParent: self)
                }
            }
        }
    }
    
    func getStatus() {
        DispatchQueue.main.async {
            self.hightContantView.constant = self.viewMain.frame.height - 74
            self.view.layoutIfNeeded()
            UserDefaults.standard.set(0, forKey: "isDispute")
        }
        setupLeagueTabbar()
        if (APIManager.sharedManager.match?.homeTeamId == nil) && (APIManager.sharedManager.match?.awayTeamId == nil) {
            print("Call after change tab. --- isBackToArena >>>>>>>>>")
            if self.isBackToArena {
                self.isBackToArena = false
                print("Call after change tab. --- isBackToArena >>>>>>>>> false")
                DispatchQueue.main.async {
                    self.getTournamentContent()
                }
            }
        }
        else if APIManager.sharedManager.match?.isManualUpdateFromUpcoming == 1 {
            self.statusNav = self.stepOneNavVC!
            self.loadTabsOfLeagueScreen()
        }
        else if APIManager.sharedManager.match?.isManualUpdate == 1 {
            self.statusNav = self.matchResetNavVC!
            self.loadTabsOfLeagueScreen()
        }
        else if APIManager.sharedManager.match?.joinStatus == 0 {
            if self.isBackToArena {
                //self.getStageCharacter()
                if self.isBackToArena {
                    self.isBackToArena = false
                    //self.statusNav = self.stepOneNavVC!
                    //self.loadTabsOfLeagueScreen()
                    DispatchQueue.main.async {
                        self.getTournamentContent()
                    }
                }
                else {
                    if self.isArenaClsoe {
                        self.isArenaClsoe = false
                    }
                }
            }
            else {
                self.statusNav = self.stepOneNavVC!
                self.loadTabsOfLeagueScreen()
            }
        }
        else {
            if APIManager.sharedManager.firebaseId != "" && APIManager.sharedManager.firebaseId != nil {
                self.isBackToArena = false
                
                guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
                print("FirebaseId LeagueTabVC getStatus >>>>>>>>>>>>>> \(firebaseId)")
                
//                self.log.i("LeagueTabVC getStatus listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                let dbref = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "")
                dbref.getDocument { (document, error) in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    }
                    else {
                        if document != nil {
                            self.doc =  document!
                            
//                            self.log.i("LeagueTabVC getStatus listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                            
                            if self.doc?.data() != nil {
                                let status = self.doc?.data()?["status"] as! String
                                var playerArr = [[String:AnyObject]]()
                                playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                                var host = 0
                                
                                if playerArr[0]["playerId"] as? Int == APIManager.sharedManager.user?.id {
                                    APIManager.sharedManager.myPlayerIndex = 0
                                }
                                else{
                                    APIManager.sharedManager.myPlayerIndex = 1
                                }
                                
                                if playerArr[0]["host"] as! Int == 1 {
                                    host = 0
                                }
                                else{
                                    host = 1
                                }
                                
                                let arrStage = playerArr[APIManager.sharedManager.myPlayerIndex]["stages"]
                                let char : String = (playerArr[APIManager.sharedManager.myPlayerIndex]["characterName"] as? String) ?? ""
                                
                                //if matchReset then navigate to ArenaMatchResetVC
                                if self.doc?.data()?["resetMatch"] as! Int == 1 {
                                    self.statusNav = self.matchResetNavVC!
                                }
                                // waiting to proceed || ready to proceed
                                else if(status == Messages.waitingToProceed || status == Messages.readyToProceed){
                                    self.statusNav = self.lobbyNavVC!
                                    if playerArr[APIManager.sharedManager.myPlayerIndex]["ssbmConnectProceed"] as! Int == 1 {
                                        self.statusNav = self.viewBattleIdNavVC!
                                        if APIManager.sharedManager.myPlayerIndex == host {
                                            self.statusNav = self.enterBalltleIdNavVC!
                                        }
                                    }
                                }
                                // entering battle id
                                else if(status == Messages.enteringBattleId ){
                                    if playerArr[APIManager.sharedManager.myPlayerIndex]["ssbmConnectProceed"] as! Int == 1 {
                                        if APIManager.sharedManager.myPlayerIndex == host {
                                            self.statusNav = self.enterBalltleIdNavVC!
                                        }
                                        else {
                                            if char != "" && arrStage?.count != 0 {
                                                //self.lobbyVC.isFromHome = true
                                                self.statusNav = self.viewBattleIdNavVC!
                                            }
                                            //self.statusNav = self.lobbyNavVC!
                                            //self.statusNav = self.viewBattleIdNavVC!
                                        }
                                    }
                                    else {
                                        self.statusNav = self.lobbyNavVC!
                                    }
                                }
                                //entered battle id
                                else if(status == Messages.enteringBattleId || status == Messages.enteredBattleId){
                                    if playerArr[APIManager.sharedManager.myPlayerIndex]["ssbmConnectProceed"] as! Int == 1 {
                                        if APIManager.sharedManager.myPlayerIndex == host {
                                            self.statusNav = self.enterBalltleIdNavVC!
                                        }
                                        else {
                                            if char != "" && arrStage?.count != 0 {
                                                self.statusNav = self.viewBattleIdNavVC!
                                            }
                                            else {
                                                self.statusNav = self.lobbyNavVC!
                                            }
                                            //self.statusNav = self.viewBattleIdNavVC!
                                        }
                                    }
                                    else {
                                        self.statusNav = self.lobbyNavVC!
                                    }
                                }
                                //battle id fail
                                else if(status == Messages.battleIdFail){
                                    if APIManager.sharedManager.myPlayerIndex == host {
                                        //self.statusNav = self.enterBalltleIdNavVC!
                                        self.statusNav = self.bothReadyNavVC!
                                    }
                                    else {
                                        //self.statusNav = self.viewBattleIdNavVC!
                                        self.statusNav = self.bothReadyNavVC!
                                    }
                                }
                                // By Pranay
                                // Both player move to Connect code
                                else if(status == Messages.waitingToCharacterSelection){
                                    if APIManager.sharedManager.myPlayerIndex == host {
                                        //self.statusNav = self.enterBalltleIdNavVC!
                                        self.statusNav = playerArr[0]["ssbmConnectProceed"] as? Int == 0 ? self.lobbyNavVC! : self.connectCodeNavVC!
                                    }
                                    else {
                                        //self.statusNav = self.viewBattleIdNavVC!
                                        //if playerArr[1]["dispute"] as? Int == 0 {
                                        //    self.statusNav = self.lobbyNavVC!
                                        //}
                                        //self.statusNav = self.connectCodeNavVC!
                                        self.statusNav = playerArr[1]["ssbmConnectProceed"] as? Int == 0 ? self.lobbyNavVC! : self.connectCodeNavVC!
                                    }
                                }
                                //.
                                //character selection
                                else if(status == Messages.characterSelection){
                                    if self.doc?.data()?["currentRound"] as! Int != 1 {
                                        self.statusNav = self.charSelectionNavVC!
                                    }
                                    else {
                                        if self.doc?.data()?["weAreReadyBy"] as! Int != 0 {
                                            self.statusNav = self.charSelectionNavVC!
                                        }
                                        else {
                                            if APIManager.sharedManager.myPlayerIndex == host {
                                                self.statusNav = self.enterBalltleIdNavVC
                                            }
                                            else {
                                                self.statusNav = self.viewBattleIdNavVC!
                                            }
                                        }
                                    }
                                }
                                //select rpc || rpc result done
                                else if(status == Messages.selectRPC || status == Messages.rpcResultDone){
                                    self.rpcVC.isFromHome = true
                                    self.statusNav = self.rpcNavVC!
                                }
                                //stage pick ban
                                else if(status == Messages.stagePickBan){
                                    self.statusNav = self.stagePickNavVC!
                                }
                                //next round
                                else if(status == Messages.waitingToStagePickBan){
                                    self.statusNav = self.nextRoundNavVC!
                                }
                                //playing round || entering score || entered score || score confirm || dispute || entered dispute score || match finished
                                else if(status == Messages.playinRound || status == Messages.enteringScore || status == Messages.enteredScore || status == Messages.scoreConfirm || status == Messages.dispute || status == Messages.enterDisputeScore || status == Messages.matchFinished){
                                    self.scoreVC.isFromHome = true
                                    if status == Messages.matchFinished {
                                        self.scoreVC.isReminderOpen = true
                                        if self.matchDetail?.isManualUpdate == 1 {
                                            self.scoreVC.isAdminUpdate = true
                                        }
                                    }
                                    
                                    if status == Messages.scoreConfirm {
                                        self.isFromOutSideArena = true
                                    }
                                    self.statusNav = self.roundNavVC!
                                }
                                self.loadTabsOfLeagueScreen()
                            }
                            else {
                                Utilities.showPopup(title: "Data not found", type: .error)
                            }
                        }
                    }
                }
            }
            else {
                if self.isTBD {
                    if APIManager.sharedManager.match?.joinStatus == nil && self.isBackToArena == true {
                        self.isBackToArena = false
                        self.isArenaClsoe = true // when league/tournament created but match not scheduled then arena close view will be shown.
                        if self.isArenaClsoe {
                            self.isArenaClsoe = false
                            self.statusNav = self.stepOneNavVC!
                            self.loadTabsOfLeagueScreen()
                        }
                    }
                    else {
                        self.isBackToArena = false
                        self.statusNav = self.stepOneNavVC!
                        self.loadTabsOfLeagueScreen()
                    }
                }
                else {
                    //Utilities.showPopup(title: "Data not found", type: .error)
                    self.isBackToArena = false
                    self.lobbyVC.isDataNotFound = true
                    self.statusNav = self.lobbyNavVC!
                    self.loadTabsOfLeagueScreen()
                }
            }
        }
    }
    
    func openStageRankingDialog() {
        if !isStageRank {
            isStageRank = true
            arrStagePicked = playerStage.count != 0 ? self.playerStage : []
        }
        
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
        dialog.arrSelectedStageIndex = arrSelectedStageIndex
        dialog.teamId = self.teamId
        dialog.arrSwaped = arrStagePicked
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { arr in
            if(arr[0] as! Bool == false){
                let dialog1 = self.storyboard?.instantiateViewController(withIdentifier: "StageUnselectPopupVC") as! StageUnselectPopupVC
                dialog1.arrSelectedStageIndex = dialog.arrSelectedStageIndex
                dialog1.modalPresentationStyle = .overCurrentContext
                dialog1.modalTransitionStyle = .crossDissolve
                dialog1.tapOk = {
                    self.arrStagePicked = arr[1] as? [Int] ?? []
                    self.arrSelectedStageIndex = dialog1.arrSelectedStageIndex
                    self.openStageRankingDialog()
                }
                self.view!.tusslyTabVC.present(dialog1, animated: true, completion: nil)
            } else {
                if (arr[1] as? [Int])?.count ?? 0 > 0 {
                    self.arrStagePicked = arr[1] as! [Int]
                    self.arrSelectedStageIndex.removeAll()
                }
            }
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil) //  */
    }
    
    // MARK: - Button Click Events
    @IBAction func tapOnSocialMedia(_ sender: UIButton) {
        if (APIManager.sharedManager.content?.socialMedias?.count ?? 0) > 0 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "SocialMediaPopupVC") as! SocialMediaPopupVC
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: Webservices
    func getTournamentContent() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTournamentContent()
                }
            }
            return
        }
        // By Pranay
//        self.log.i("GET_TOURNAMENT_CONTENT api call. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TOURNAMENT_CONTENT, parameters: ["leagueId" : tournamentDetail?.id ?? 0, "timeZone" : APIManager.sharedManager.timezone, "teamId" : tournamentDetail?.leagueMatch?.teamId ?? 0, "gameId": tournamentDetail?.gameId ?? 0, "device": "ios"]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.hideLoading()
                
//                self.log.i("GET_TOURNAMENT_CONTENT api call success. - \(APIManager.sharedManager.user?.userName ?? "")")
                //self.log.i("GET_TOURNAMENT_CONTENT api call success. - \(APIManager.sharedManager.user?.userName ?? "") - \(response?.result)")
                
                self.isDisputeNotificationApiCall = false
                
                self.getLeagueMatches = (response?.result?.getLeagueMatches)!
                
                APIManager.sharedManager.match = self.getLeagueMatches?.match
                APIManager.sharedManager.previousMatch = self.getLeagueMatches?.match
                
                APIManager.sharedManager.nextScheduledMatchTimer = self.getLeagueMatches?.match?.nextScheduledMatchTimer ?? 10
                APIManager.sharedManager.arenaMatchFinishTimer = self.getLeagueMatches?.match?.arenaMatchFinishTimer ?? 5
                
                APIManager.sharedManager.firebaseId = self.getLeagueMatches?.match?.firebaseDocumentId ?? "" //self.matchDetail?.firebaseDocumentId
                APIManager.sharedManager.isReminderOpen = self.getLeagueMatches?.match?.isShowReminderPopup ?? 0 //self.matchDetail?.isShowReminderPopup ?? 0
                
                APIManager.sharedManager.gameId = self.getLeagueMatches?.match?.league?.gameId ?? 0
                
                APIManager.sharedManager.eliminationType = self.getLeagueMatches?.match?.league?.eliminationType ?? ""
                
                APIManager.sharedManager.content = response?.result?.contents
                
                DispatchQueue.main.async {
                    // By Pranay
                    APIManager.sharedManager.customStageCharSettings = response?.result?.customStageCharSettings
                    APIManager.sharedManager.stagePickBan = response?.result?.getLeagueMatches?.stagePickBan ?? ""
                    APIManager.sharedManager.customizeScore = response?.result?.getLeagueMatches?.customizeScore ?? 1
                    APIManager.sharedManager.gameSettings = response?.result?.gameSetting
                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                    print("APIManager.sharedManager.gameSettings >>>>>>>>>>>>> \(APIManager.sharedManager.gameSettings?.gameName ?? "")")
                    print(Messages.waitToConfirm)
                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                    APIManager.sharedManager.isShoesCharacter = self.getLeagueMatches?.isShoesCharacter ?? "No"
                    APIManager.sharedManager.maxCharacterLimit = self.getLeagueMatches?.maxCharacterLimit ?? 2
                    
                    if (APIManager.sharedManager.match?.homeTeamId ?? 0 != 0) && (APIManager.sharedManager.match?.awayTeamId ?? 0 != 0) {
                        if (APIManager.sharedManager.user?.id ?? 0) == APIManager.sharedManager.match?.homeTeamPlayers?[0].userId ?? 0 {
                            for i in 0 ..< (APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter!.count ?? 0) {
                                for j in 0 ..< (APIManager.sharedManager.content?.characters!.count)! {
                                    if (APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter![i].id) == (APIManager.sharedManager.content?.characters![j].id) {
                                        APIManager.sharedManager.content?.characters![j].characterUseCnt = APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter![i].characterUseCnt
                                        break
                                    }
                                }
                            }
                        }
                        else {
                            for i in 0 ..< (APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter!.count ?? 0) {
                                for j in 0 ..< (APIManager.sharedManager.content?.characters!.count)! {
                                    if (APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter![i].id) == (APIManager.sharedManager.content?.characters![j].id) {
                                        APIManager.sharedManager.content?.characters![j].characterUseCnt = APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter![i].characterUseCnt
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    self.matchDetail = (self.getLeagueMatches?.match)!
                    
                    self.hideLoading()
                    
                    self.viewshadow.cornerWithShadow(offset: CGSize(width: 0.0, height: 4.0), color: UIColor.lightGray, radius: 1.5, opacity: 0.5, corner: self.viewshadow.frame.height/2)
                    
                    self.lblTireName.text = self.matchDetail?.league?.leagueName ?? ""
                    
                    var inputString: String = self.matchDetail?.league?.discription ?? ""
                    let target: String = "Hosted by:"
                    if let range = inputString.range(of: target) {
                        //let startingIndex = inputString.distance(from: inputString.startIndex, to: range.lowerBound)
                        //let endingIndex = inputString.distance(from: inputString.startIndex, to: range.upperBound)
                        
                        inputString.insert("\n", at: range.lowerBound)
                    }
                    else {
                        print("Character not found")
                    }
                    //self.lblDesc.text = self.matchDetail?.league?.discription ?? ""
                    self.lblDesc.text = inputString
                    self.tusslyTabVC!().lblHeader.text = self.matchDetail?.league?.abbrevation
                    
                    if self.matchDetail?.league?.bannerImage == "" {
                        self.ivLogo.setImage(imageUrl: self.matchDetail?.league?.gameImage ?? "")
                    }
                    else {
                        self.ivLogo.setImage(imageUrl: self.matchDetail?.league?.bannerImage ?? "")
                    }
                    
                    if self.matchDetail?.league?.profileImage == "" {
                        self.tusslyTabVC!().imgLogo.setImage(imageUrl: self.matchDetail?.league?.gameImage ?? "")
                        self.ivGameLogo.setImage(imageUrl: self.matchDetail?.league?.gameImage ?? "")
                    }
                    else {
                        self.tusslyTabVC!().imgLogo.setImage(imageUrl: self.matchDetail?.league?.profileImage ?? "")
                        self.ivGameLogo.setImage(imageUrl: self.matchDetail?.league?.profileImage ?? "")
                    }
                    
                    self.tournamentInviteLink = self.getLeagueMatches?.redirectUrl ?? ""
                    self.leagueRegistrationStatus = self.getLeagueMatches?.registrationStatus ?? 1
                    self.leagueMatchStatus = self.getLeagueMatches?.leagueMatchStatus ?? 0
                    self.discordLink = self.getLeagueMatches?.discordUrl ?? ""
                    
                    self.userRole = (response?.result?.joinedTournamentDetails?.userRoles)!
                    APIManager.sharedManager.myTeamId = response?.result?.joinedTournamentDetails?.teamDetail?.id ?? 0
                    
                    self.teamName = response?.result?.joinedTournamentDetails?.teamDetail?.teamName ?? ""
                    self.teamId = response?.result?.joinedTournamentDetails?.teamDetail?.id ?? 0
                    
                    self.gameDetails = response?.result?.joinedTournamentDetails?.gameDetail
                    
                    self.playerChar = response?.result?.playerStagesAndCharacters?.playerCharacter
                    self.playerStage = response?.result?.playerStagesAndCharacters?.playerStagers ?? []
                    
                    if (APIManager.sharedManager.content?.socialMedias?.count ?? 0) > 0 {
                        self.ivSocialMedia1.setImage(imageUrl: APIManager.sharedManager.content?.socialMedias?[0].imageUrl ?? "")
                        if (APIManager.sharedManager.content?.socialMedias?.count ?? 0) == 1 {
                            self.socialViewHeight.constant = 28
                            self.ivSocialMedia2.isHidden = true
                            self.lblSocialMediaCount.text = ""
                        }
                        else if (APIManager.sharedManager.content?.socialMedias?.count ?? 0) == 2 {
                            self.socialViewHeight.constant = 52
                            self.lblSocialMediaCount.text = ""
                        }
                        else {
                            self.lblSocialMediaCount.text =  "+\((APIManager.sharedManager.content?.socialMedias?.count ?? 0) - 2)"
                        }
                        
                        if (APIManager.sharedManager.content?.socialMedias?.count ?? 0) > 1 {
                            self.ivSocialMedia2.isHidden = false
                            self.ivSocialMedia2.setImage(imageUrl: APIManager.sharedManager.content?.socialMedias?[1].imageUrl ?? "")
                        }
                        self.socialMediaView.layer.cornerRadius = 5.0
                        self.socialMediaView.isHidden = false
                    }
                    
                    if self.matchDetail?.leagueId == 0 {
                        self.isTBD = true
                    }
                    if (self.matchDetail?.homeTeam?.id ?? 0 != 0) && (self.matchDetail?.awayTeam?.id ?? 0 != 0) && (self.matchDetail?.isManualUpdateFromUpcoming ?? 0 == 0) {
                        APIManager.sharedManager.isMatchRefresh = true
                    }
                    else if (self.matchDetail?.homeTeam?.id ?? 0 == 0) && (self.matchDetail?.awayTeam?.id ?? 0 == 0) {
                        APIManager.sharedManager.firebaseId = ""
                    }
                    else if (self.matchDetail?.homeTeamId ?? 0 == 0) || (self.matchDetail?.awayTeamId ?? 0 == 0) {
                        print("isMatchRefresh flag make active/inactive.")
                        APIManager.sharedManager.isMatchRefresh = (self.selectedIndex == 1) ? false : true
                    }
                    
                    if self.isNewMatch {
                        self.isNewMatch = false
                        self.getStatus()
                    }
                    else {
                        self.setupLeagueTabbar()
                        self.statusNav = self.stepOneNavVC!
                        self.loadTabsOfLeagueScreen()
                    }
                    
                    if APIManager.sharedManager.isArenaTabOpen {
                        APIManager.sharedManager.isArenaTabOpen = false
                        self.updateTab(at: 1)
                        self.selectedIndex = 1
                        self.cvLeagueTabs.selectedIndex = self.selectedIndex
                        self.cvLeagueTabs.reloadData()
                    }
                    APIManager.sharedManager.isArenaTabOpen = false
                    
                    self.getChatUnreadCount(chatId: self.matchDetail?.chatId ?? "")
                }
            }
            else {
                self.hideLoading()
                APIManager.sharedManager.isArenaTabOpen = false
                Utilities.showPopup(title: response?.message ?? "", type: .error)
//                self.log.e("GET_TOURNAMENT_CONTENT api call fail. - \(APIManager.sharedManager.user?.userName ?? "") = \(response?.result)")  //  By Pranay.
            }
        }
    }
}

extension LeagueTabVC {
    fileprivate func openTournamentChatConvorsation(conversation: Conversation?, type: CometChat.ConversationType, receiverId: String) {
        DispatchQueue.main.async {
            let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
            
            messagesVC.isFromTournament = true
            messagesVC.tusslyTabVC = self.tusslyTabVC
            messagesVC.leagueTabVC = {
                return self
            }
            
            messagesVC.objConversation = conversation
            messagesVC.senderId = APIManager.sharedManager.strChatUserId
            messagesVC.receiverId = receiverId
            messagesVC.conversationId = conversation?.conversationId ?? ""
            //(conversation.conversationWith as? CometChatSDK.User)?.tags
            
            messagesVC.strUserName = self.gameDetails?.creatorName ?? ""
            messagesVC.strUserAvatar = self.gameDetails?.creatorImage ?? ""
            
            self.hideLoading()
            //vc.pushViewController(messagesVC, animated: true)
            self.chatNavVC = UINavigationController(rootViewController: messagesVC)
            self.chatNavVC?.isNavigationBarHidden = true
            let vc: UINavigationController = self.chatNavVC!
            self.addChild(vc)
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
    }
}

extension LeagueTabVC: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        print("League Tab Text message received")
        self.getChatUnreadCount(chatId: self.matchDetail?.chatId ?? "")
        self.messageMarkAsDelivered(baseMessage: textMessage)
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        print("League Tab Media message received")
        self.getChatUnreadCount(chatId: self.matchDetail?.chatId ?? "")
        self.messageMarkAsDelivered(baseMessage: mediaMessage)
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        print("League Tab Custom message received")
    }
    
    func messageMarkAsDelivered(baseMessage: BaseMessage) {
        CometChat.markAsDelivered(baseMessage : baseMessage, onSuccess: {
            print("League Tab markAsDelivered Succces")
        }, onError: {(error) in
            print("League Tab markAsDelivered error message",error?.errorDescription)
        })
    }
    
    func getChatUnreadCount(chatId : String) {
        //self.matchDetail?.chatId ?? ""
        DispatchQueue.main.async {
            CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount in
                if let tempUreadCount = dictUnreadCount as? [String: Int] {
                    if let count = tempUreadCount[chatId] {
                        print("Count >>>>>>>>>>>>  \(count)")
                        self.showUnreadCount = true
                        NotificationCenter.default.post(name: .chatUnreadCountUpdated, object: nil, userInfo: ["hasUnread": self.showUnreadCount])
                    }
                    else {
                        print("Count >>>>>>>>>>>>  00")
                        self.showUnreadCount = false
                        //self.onChatUnreadUpdate?(false)
                    }
                }
            } onError: { error in
                print("\(error?.errorCode ?? "")")
            }
        }
    }
}

extension Notification.Name {
    static let chatUnreadCountUpdated = Notification.Name("chatUnreadCountUpdated")
}
