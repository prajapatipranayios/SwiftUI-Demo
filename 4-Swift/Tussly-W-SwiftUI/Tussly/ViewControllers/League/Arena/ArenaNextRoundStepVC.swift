//
//  ArenaNextRoundStepVC.swift
//  Tussly
//
//  Created by Auxano on 25/10/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
//import ShipBookSDK

class ArenaNextRoundStepVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    var timeSeconds = 0
    var arrSelectedStageIndex = [Int]()
    var arrFirebase : FirebaseInfo?
    let db = Firestore.firestore()
    var myPlayerIndex = 0
    var opponent = 1
    var arrPlayer = [ArenaPlayerData]()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var isProceed = false
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var leaderboardData: [[String: Any]]!
    var hostIndex = 0
    var opponentIndex = 0
    var isTap = false
    var isTimeUp = false
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isTapChat = false
    var roundTime = 0
    var isNextRoundRemovedFromStack = false
    var navStatus = Messages.stagePickBan
    var roundStartTime = Int(NSDate().timeIntervalSince1970)
//    fileprivate let log = ShipBook.getLogger(ArenaNextRoundStepVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblPlayer1Status : UILabel!
    @IBOutlet weak var lblPlayer2Status : UILabel!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1DisplayName : UILabel!
    @IBOutlet weak var lblPlayer2DisplayName : UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var viewShadowPlayer1 : UIView!
    @IBOutlet weak var viewShadowPlayer2 : UIView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnStageRanking: UIButton!
    @IBOutlet weak var imgCharacter : UIImageView!
    @IBOutlet weak var lblCharacter : UILabel!
    @IBOutlet weak var viewCharacterSelection : UIView!
    @IBOutlet weak var cvResult: UICollectionView!
    @IBOutlet weak var cvResultGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvResultGridLayout.stickyRowsCount = 1
            cvResultGridLayout.stickyColumnsCount = 1
        }
    }

    // By Pranay
    @IBOutlet weak var lblHost: UILabel!
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnHostUsedChar1: UIButton!
    @IBOutlet weak var btnHostUsedChar2: UIButton!
    @IBOutlet weak var btnAwayUsedChar1: UIButton!
    @IBOutlet weak var btnAwayUsedChar2: UIButton!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rowHeaders = ["Players", "R1", "R2", "R3", "Final"]
        leaderboardData = []
            /*[
                "Players": "",
                "avatarImage": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R1": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R2": "",
                "R3": "",
                "score1": "",
                "score2": "",
                "score3": "",
                "Final": ""
            ], [
                "Players": "",
                "avatarImage": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R1": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R2": "",
                "R3": "",
                "score1": "",
                "score2": "",
                "score3": "",
                "Final": ""
            ]
        ]*/
        
        self.cvResult.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: self.contentCellIdentifier)
        self.cvResult.register(UINib(nibName: "ResultUsersCVCell", bundle: nil), forCellWithReuseIdentifier: "ResultUsersCVCell")
        self.cvResult.register(UINib(nibName: "ImgScoreCVCell", bundle: nil), forCellWithReuseIdentifier: "ImgScoreCVCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if APIManager.sharedManager.gameSettings?.isTournamentHost ?? 0 == 1 {
            lblHost.isHidden = false
        } else {
            lblHost.isHidden = true
        }
        
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
            self.lblTitle.text = "Next: Character Selection"
        } else {
            self.lblTitle.text = "Next: Stage Pick/Ban"
        }
        
        self.imgCharacter.layer.cornerRadius = self.imgCharacter.frame.size.height / 2
        
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationItem.setTopbar()
        
        isTap = false
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        
        viewNav = UINavigationBar(frame: CGRect.init(x: 0, y: 0, width: 70, height: 50))
        
        self.btnForfeit = UIButton(frame: CGRect.init(x: 0, y: 10, width: 30, height: 30))
        self.btnForfeit.setImage(UIImage(named: "forfeit"), for: .normal)
        self.btnForfeit.addTarget(self, action: #selector(self.onTapForfeit), for: .touchUpInside)

        self.btnChat = UIButton(frame: CGRect.init(x: 40, y: 10, width: 30, height: 30))
        self.btnChat.setImage(UIImage(named: "Chat_Icon"), for: .normal)
        self.btnChat.addTarget(self, action: #selector(self.onTapChat), for: .touchUpInside)
        
        let btnForfeit = UIBarButtonItem(customView: self.btnForfeit)
        let btnChat = UIBarButtonItem(customView: self.btnChat)
        
        self.navigationItem.setRightBarButtonItems([btnChat, btnForfeit], animated: true)
        
        lblMessageCount = UILabel(frame: CGRect.init(x: 55, y: 2, width: 20, height: 20))
        lblMessageCount.backgroundColor = Colors.theme.returnColor()
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        lblMessageCount.font = Fonts.Bold.returnFont(size: 15.0)
        lblMessageCount.textColor = UIColor.white
        lblMessageCount.clipsToBounds = true
        lblMessageCount.text = "0"
        lblMessageCount.textAlignment = .center
        
        isNextRoundRemovedFromStack = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackInfo),
            name: NSNotification.Name(rawValue: "DismissInfo"),
            object: nil)
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.chatCountUpdate),
                    name: NSNotification.Name(rawValue: "newMessageNotification"),
                    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        if isTapChat {
            isTapChat = false
            callBackInfo()
        }
        else {
            DispatchQueue.main.async {
                self.setupUI()
                
                self.setNotificationCountObserver()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        isNextRoundRemovedFromStack = true
        listner?.remove()
    }
        
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isNextRoundRemovedFromStack = true
            APIManager.sharedManager.timer.invalidate()
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
        
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            APIManager.sharedManager.timer.invalidate()
            print("Timer is over.")
        } else {
            lblTime.text = timeFormatted(seconds: timeSeconds)
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return "Time limit: \(minutes):\(seconds)"
    }
    
    @objc func chatCountUpdate() {
        self.lblMessageCount.removeFromSuperview()
        chatBadge()
    }
    
    @objc func onTapChat() {
        let chatUserId : String = (self.leagueTabVC!().matchDetail?.chatId ?? "-1")
        if chatUserId != "-1" && !self.isChatBtnTap {
            self.isChatBtnTap = true
            self.isTapChat = true
            self.openArenaGroupConvorsation(id: chatUserId, type: .group, isFromArena: true, tusslyTabVC: self.tusslyTabVC) { success in
                if success {
                    self.isChatBtnTap = true
                    self.leagueTabVC!().showUnreadCount = false
                }
                else {
                    self.isTapChat = false
                }
            }
        }
        else {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
    }
    
    @objc func onTapForfeit() {
        print("Forfeit - button tap.")
        
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.forfeitMatch
        dialog.message = Messages.forfeitMsg
        dialog.btnYesText = Messages.yes
        dialog.isMsgCenter = true
        dialog.tapOK = {
            print("Forfeit button tapped.")
            self.declareForfeitTeam()
        }
        dialog.btnNoText = Messages.close
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    func setNotificationCountObserver() {
        self.showChatRedDot(show: self.leagueTabVC!().showUnreadCount)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnreadUpdate(_:)), name: .chatUnreadCountUpdated, object: nil)
    }
    
    @objc func handleUnreadUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            guard self.isViewLoaded, self.view.window != nil else { return }
            
            if let hasUnread = notification.userInfo?["hasUnread"] as? Bool {
                self.showChatRedDot(show: hasUnread)
            }
        }
    }
    
    func showChatRedDot(show: Bool) {
        DispatchQueue.main.async {
            // Remove existing red dot if any
            if let existingDot = self.btnChat.viewWithTag(999) {
                existingDot.removeFromSuperview()
            }

            guard show else { return }

            let redDotSize: CGFloat = 13
            let redDot = UIView(frame: CGRect(x: self.btnChat.frame.width - redDotSize / 2,
                                              y: -redDotSize / 2,
                                              width: redDotSize,
                                              height: redDotSize))
            redDot.backgroundColor = .red
            redDot.layer.cornerRadius = redDotSize / 2
            redDot.clipsToBounds = true
            redDot.tag = 999

            self.btnChat.addSubview(redDot)
        }
    }
    
    func chatBadge() {
        let chatCount = self.getUnreadChatCount(id: self.arrPlayer[self.opponent].playerId ?? 0).stringValue
        if chatCount == "0"{
            self.lblMessageCount.isHidden = true
        } else {
            self.lblMessageCount.isHidden = false
            self.lblMessageCount.text = chatCount
            self.viewNav.addSubview(self.lblMessageCount)
        }
    }
    
    @objc func onTapInfo() {
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 0
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if isNextRoundRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    func setupUI() {
        btnProceed.layer.cornerRadius = self.btnProceed.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = self.lblMessageCount.frame.size.height / 2
        viewCharacterSelection.layer.cornerRadius = viewCharacterSelection.frame.size.height / 2
        imgPlayer1.layer.cornerRadius = imgPlayer1.frame.size.height / 2
        imgPlayer2.layer.cornerRadius = imgPlayer2.frame.size.height / 2
        viewShadowPlayer1.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: UIColor.lightGray, radius: 1.0, opacity: 0.5, corner: viewShadowPlayer1.frame.height/2)
        viewShadowPlayer2.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: UIColor.lightGray, radius: 1.0, opacity: 0.5, corner: viewShadowPlayer2.frame.height/2)
        viewCharacterSelection.layer.borderWidth = 1.0
        viewCharacterSelection.layer.borderColor = Colors.border.returnColor().cgColor
        btnStageRanking.layer.cornerRadius = 6
            
        roundTime = ((APIManager.sharedManager.match?.matchType == Messages.regular || APIManager.sharedManager.match?.matchType == Messages.tournament) ? APIManager.sharedManager.content?.regularArenaTimeSettings?.timeBetweenRound : APIManager.sharedManager.content?.playoffArenaTimeSettings?.timeBetweenRound) ?? 1
        
        getTime()
        
        // By Pranay
        //if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count == 0 {
        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
            self.btnStageRanking.isUserInteractionEnabled = false
            self.btnStageRanking.backgroundColor = Colors.disableButton.returnColor()
        }
        // .
    }
    
    func setFirestoreData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        if self.timeSeconds > 0 {
            /// Close timer if already exist in memory
            if APIManager.sharedManager.timer.isValid == true {
                APIManager.sharedManager.timer.invalidate()
            }
            APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
        } else {
            self.lblTime.text = "Time limit: 0:0"
            self.isTimeUp = true
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaNextRoundStepVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaNextRoundStepVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            
            if let err = err {
//                self.log.e("ArenaNextRoundStepVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
                
//                self.log.i("ArenaNextRoundStepVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaNextRoundStepVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            self.arrPlayer = self.arrFirebase?.playerDetails ?? []
                            if self.arrPlayer.count > 0 {
                                self.hostIndex = self.arrPlayer[0].host == 1 ? 0 : 1
                                self.opponentIndex = self.hostIndex == 1 ? 0 : 1
                                
                                self.roundStartTime = Int(NSDate().timeIntervalSince1970)
                                self.navStatus = ((APIManager.sharedManager.stagePickBan ?? "" == "Yes") ? Messages.stagePickBan : Messages.characterSelection)
                                
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    if APIManager.sharedManager.timer.isValid == true {
                                        APIManager.sharedManager.timer.invalidate()
                                    }
                                    self.listner?.remove()
                                    self.leagueTabVC!().getTournamentContent()
                                    
                                    return
                                }
                                else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    if APIManager.sharedManager.timer.isValid == true {
                                        APIManager.sharedManager.timer.invalidate()
                                    }
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.listner?.remove()
                                    //self.navigateToArenaRoundResult()
                                    self.leagueTabVC!().getTournamentContent()
                                    
                                    return
                                }
                                else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    self.navigateToArenaMatchReset()
                                    
                                    return
                                }
                                else if self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan {
                                    if self.doc?.data()?["readyToStagePickBanBy"] as? Int != 0 {
                                        if self.doc?.data()?["readyToStagePickBanBy"] as? Int == self.arrPlayer[self.hostIndex].playerId! {
                                            self.lblPlayer1Status.text =  Messages.readyToStart
                                            self.lblPlayer1Status.textColor = Colors.black.returnColor()
                                        } else {
                                            self.lblPlayer2Status.text = Messages.readyToStart
                                            self.lblPlayer2Status.textColor = Colors.black.returnColor()
                                        }
                                        
                                        // By Pranay
                                        self.leagueTabVC!().isDisputeNotificationApiCall = false
                                        // .
                                        
                                        // if you are ready then wait for other player to proceed
                                        if self.doc?.data()?["readyToStagePickBanBy"] as? Int == self.arrPlayer[APIManager.sharedManager.myPlayerIndex].playerId! {
                                            APIManager.sharedManager.timer.invalidate()
                                            self.listner?.remove()
                                            if APIManager.sharedManager.myPlayerIndex == self.hostIndex {
                                                self.lblPlayer1Status.text =  Messages.readyToStart
                                                self.lblPlayer1Status.textColor = Colors.black.returnColor()
                                            } else {
                                                self.lblPlayer2Status.text = Messages.readyToStart
                                                self.lblPlayer2Status.textColor = Colors.black.returnColor()
                                            }
                                            
                                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                            dialog.modalPresentationStyle = .overCurrentContext
                                            dialog.modalTransitionStyle = .crossDissolve
                                            dialog.descriptionString = Messages.waitForJoinMatch
                                            dialog.arenaFlow = "waitForOpponentToNextRound"
                                            dialog.isLoader = false
                                            dialog.timeSeconds = self.timeSeconds
                                            dialog.manageOnStatus = { status in
                                                
                                                if status == "Schedule Removed" {
                                                   self.scheduledRemoved()
                                                }
                                                else if status == "Match Forfeit" {
                                                   self.navigateToArenaRoundResult()
                                                }
                                                else if status == "Match Reset" {
                                                   self.navigateToArenaMatchReset()
                                                }
                                                else if status == "" {
//                                                    self.log.i("ArenaNextRoundStepVC get document in waiting response after proceed btn tap when timer is over  - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                                                        if let err = err {
//                                                            self.log.e("ArenaNextRoundStepVC get document in waiting response after proceed btn tap when timer is over  - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                                            print("Error getting documents: \(err)")
                                                        } else {
                                                            var newDoc:DocumentSnapshot?
                                                            newDoc = querySnapshot!
                                                            
//                                                            self.log.i("ArenaNextRoundStepVC get document in waiting response after proceed btn tap when timer is over  - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                                                            
                                                            //if status is not stagePickBan then update it
                                                            if newDoc?.data()?["status"] as? String != Messages.stagePickBan {
                                                                if !Network.reachability.isReachable {
                                                                    self.isRetryInternet { (isretry) in
                                                                        if isretry! {
                                                                            self.callBackInfo()
                                                                        }
                                                                    }
                                                                    return
                                                                }
                                                                /// Added status var to collection query.
                                                                /// "gameStartTime": self.roundStartTime
                                                                let param = [
                                                                    "status":self.navStatus
                                                                    //"gameStartTime": self.roundStartTime
                                                                ] as [String: Any]
                                                                
//                                                                self.log.i("ArenaNextRoundStepVC get document in waiting response after proceed btn tap when timer is over  - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                                                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                                                    if let err = err {
//                                                                        self.log.e("ArenaNextRoundStepVC get document in waiting response after proceed btn tap when timer is over  - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                                                        print("Error writing document: \(err)")
                                                                    } else {
//                                                                        self.log.i("ArenaNextRoundStepVC and update status SUCCESS. -> \(self.navStatus). -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                                                        self.navigateToScreen()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    if status == "Proceed by opponet first" {
                                                        /// Added status var to collection query.
                                                        /// "gameStartTime": self.roundStartTime
                                                        let param = [
                                                            "status":self.navStatus
                                                            //"gameStartTime": self.roundStartTime
                                                        ] as [String: Any]
                                                        
//                                                        self.log.i("ArenaNextRoundStepVC - Proceed by opponet first -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                                            if let err = err {
//                                                                self.log.e("ArenaNextRoundStepVC - Proceed by opponet first fail -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                                                print("Error writing document: \(err)")
                                                            } else {
                                                                self.navigateToScreen()
                                                            }
                                                        }
                                                    } else {
                                                        self.navigateToScreen()
                                                    }
                                                }
                                            }
                                            if self.isNextRoundRemovedFromStack == false {
                                                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                            }
                                        }
                                    } else {
                                        self.lblPlayer1Status.text =  Messages.waitingForPlayer
                                        self.lblPlayer1Status.textColor = UIColor.lightGray
                                        self.lblPlayer2Status.text = Messages.waitingForPlayer
                                        self.lblPlayer2Status.textColor = UIColor.lightGray
                                    }
                                }
                                // By Pranay
                                /*else if (self.doc?.data()?["status"] as? String == Messages.matchFinished) && (self.doc?.data()?["matchForfeit"] as? Int == 1) {
                                 self.listner?.remove()
                                 self.navigationController?.popViewController(animated: true)
                                 }*/
                                else if (self.doc?.data()?["status"] as? String == Messages.matchFinished) {
                                     APIManager.sharedManager.timer.invalidate()
                                     self.listner?.remove()
                                     //self.navigationController?.popViewController(animated: true)  //  Comment by Pranay.
                                     let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                     for aViewController in viewControllers {
                                         if aViewController is ArenaRoundResultVC {
                                             self.navigationController!.popToViewController(aViewController, animated: true)
                                             break
                                         } else {
                                             let roundResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                             roundResultVC.tusslyTabVC = self.tusslyTabVC
                                             roundResultVC.leagueTabVC = self.leagueTabVC
                                             self.navigationController?.pushViewController(roundResultVC, animated: true)
                                             break
                                         }
                                     }
                                 }
                                //.
                                else {
                                    self.listner?.remove()
                                    APIManager.sharedManager.timer.invalidate()
                                    self.lblPlayer1Status.text =  Messages.readyToStart
                                    self.lblPlayer1Status.textColor = Colors.black.returnColor()
                                    self.lblPlayer2Status.text = Messages.readyToStart
                                    self.lblPlayer2Status.textColor = Colors.black.returnColor()
                                    self.navigateToScreen()
                                }
                                
                                //let hostImage = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.homeTeam?.homeImage ?? "")
                                //let opponentImage = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.awayTeam?.awayImage ?? "")
                                self.imgPlayer1.setImage(imageUrl: self.arrPlayer[self.hostIndex].avatarImage ?? "")
                                self.imgPlayer2.setImage(imageUrl: self.arrPlayer[self.opponentIndex].avatarImage ?? "")
                                
                                let homeTeamName = (self.arrPlayer[self.hostIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.hostIndex].teamName ?? "")[..<(self.arrPlayer[self.hostIndex].teamName ?? "").index((self.arrPlayer[self.hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.hostIndex].teamName ?? "")
                                let awayTeamName = (self.arrPlayer[self.opponentIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.opponentIndex].teamName ?? "")[..<(self.arrPlayer[self.opponentIndex].teamName ?? "").index((self.arrPlayer[self.opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.opponentIndex].teamName ?? "")
                                
                                self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : homeTeamName
                                self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.opponentIndex].displayName ?? "") : awayTeamName
                                
                                self.lblPlayer1DisplayName.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? "" : (self.arrPlayer[self.hostIndex].displayName ?? "")
                                self.lblPlayer2DisplayName.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? "" : (self.arrPlayer[self.opponentIndex].displayName ?? "")
                                
                                // Display scoreboard data
                                self.rowHeaders = ["Players"]
                                for i in 0 ..< (self.arrFirebase?.rounds?.count ?? 0) {
                                    self.rowHeaders.append("R\(i+1)")
                                }
                                self.rowHeaders.append("Final")
                                
                                self.leaderboardData = []
                                for i in 0 ..< self.arrPlayer.count {
                                    var arr = [String:Any]()
                                    for j in 0 ..< (self.arrFirebase?.rounds?.count ?? 0) {
                                        
                                        let roundArr = self.arrFirebase?.rounds ?? [Rounds]()
                                        let contentArr  = APIManager.sharedManager.content?.characters ?? [Characters]()
                                        
                                        if ((self.arrFirebase?.currentRound ?? 0) - 1) > j {
                                            for m in 0 ..< (APIManager.sharedManager.content?.characters?.count ?? 0) {
                                                if (contentArr[m].id! == (i == 0 ? roundArr[j].homeCharacterId!: roundArr[j].awayCharacterId!)) {
                                                    arr["R\(j+1)"] = APIManager.sharedManager.content?.characters?[m].imagePath
                                                    break
                                                }
                                            }
                                        }
                                        
                                        arr["score\(j+1)"] = "-"
                                        if ((self.arrFirebase?.currentRound ?? 0) - 1) > j {
                                            arr["score\(j+1)"] = i == 0 ? String(self.arrFirebase?.rounds?[j].team1Score ?? 0) : String(self.arrFirebase?.rounds?[j].team2Score ?? 0)
                                        }
                                    }
                                    //arr["Players"] = i == 0 ? (APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.hostIndex].displayName ?? "" : self.arrPlayer[self.hostIndex].teamName ?? "") : (APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.opponentIndex].displayName ?? "" : self.arrPlayer[self.opponentIndex].teamName ?? "") //  Comment by Pranay.
                                    arr["Players"] = i == 0 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : (self.arrPlayer[self.opponentIndex].displayName ?? "")   //  Added by Pranay.
                                    arr["avatarImage"] = i == 0 ? (APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.hostIndex].avatarImage ?? "" : self.arrPlayer[self.hostIndex].teamImage ?? "") : (APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.opponentIndex].avatarImage ?? "" : self.arrPlayer[self.opponentIndex].teamImage ?? "")
                                    
                                    var final = 0
                                    for j in 0 ..< (self.arrFirebase?.currentRound ?? 0) {
                                        if i == 0 {
                                            if(self.arrFirebase?.rounds?[j].winnerTeamId == self.arrFirebase?.playerDetails?[self.hostIndex].teamId){
                                                final = final + 1
                                            }
                                        } else {
                                            if(self.arrFirebase?.rounds?[j].winnerTeamId == self.arrFirebase?.playerDetails?[self.opponentIndex].teamId){
                                                final = final + 1
                                            }
                                        }
                                    }
                                    arr["Final"] = final
                                    self.leaderboardData.append(arr)
                                }
                                self.cvResult.reloadData()
                                
                                self.chatBadge()
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func navigateToScreen() {
        /*var navController = UIViewController()
        if self.navStatus == Messages.stagePickBan {
            navController = ArenaStagePickVC()
            navController = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
        } else {
            
        }   //  */
            
        if APIManager.sharedManager.timer.isValid == true {
            APIManager.sharedManager.timer.invalidate()
        }
        
        if self.navStatus == Messages.stagePickBan {
            self.listner?.remove()
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is ArenaStagePickVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                    break
                } else {
                    let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
                    stagePickVC.tusslyTabVC = self.tusslyTabVC
                    stagePickVC.leagueTabVC = self.leagueTabVC
                    if self.isNextRoundRemovedFromStack == false {
                        self.navigationController?.pushViewController(stagePickVC, animated: true)
                    }
                    break
                }
            }
        } else if self.navStatus == Messages.characterSelection {
            self.listner?.remove()
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is ArenaCharacterSelectionVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                    break
                } else {
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                    nextVC.tusslyTabVC = self.tusslyTabVC
                    nextVC.leagueTabVC = self.leagueTabVC
                    if self.isNextRoundRemovedFromStack == false {
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                    break
                }
            }
        }
    }
    
    // 223 - By Pranay.     -   Comment by Pranay.
    /*func navigateToStagePickScreen() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ArenaStagePickVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            } else {
                let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
                stagePickVC.tusslyTabVC = self.tusslyTabVC
                stagePickVC.leagueTabVC = self.leagueTabVC
                if self.isNextRoundRemovedFromStack == false {
                    self.navigationController?.pushViewController(stagePickVC, animated: true)
                }
                break
            }
        }
    }   // 223 . */
    
    func openStageRankingDialog() {
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
        dialog.arrSelectedStageIndex = self.arrSelectedStageIndex
        dialog.teamId = (self.arrFirebase?.playerDetails?[self.myPlayerIndex].teamId)!
        dialog.arrSwaped = self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages ?? []
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { arr in
            if(arr[0] as! Bool == false){
                //unselect stage to select new stage
                let dialog1 = self.storyboard?.instantiateViewController(withIdentifier: "StageUnselectPopupVC") as! StageUnselectPopupVC
                dialog1.arrSelectedStageIndex = dialog.arrSelectedStageIndex
                dialog1.modalPresentationStyle = .overCurrentContext
                dialog1.modalTransitionStyle = .crossDissolve
                dialog1.tapOk = {
                    self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages = arr[1] as? [Int]
                    self.arrSelectedStageIndex = dialog1.arrSelectedStageIndex
                    self.openStageRankingDialog()
                }
                self.view!.tusslyTabVC.present(dialog1, animated: true, completion: nil)
            } else {
                if (arr[1] as? [Int])?.count ?? 0 > 0 {
                    if !Network.reachability.isReachable {
                        self.isRetryInternet { (isretry) in
                            if isretry! {
                                self.callBackInfo()
                            }
                        }
                        return
                    }
                    
                    self.arrSelectedStageIndex.removeAll()
                    /*var playerArr = [[String:AnyObject]]()
                    playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    playerArr[self.myPlayerIndex]["stages"] = arr[1] as! [Int] as AnyObject //  */
                    // By Pranay
                    
//                    self.log.i("ArenaNextRoundStepVC - openStageRankingDialog() getDocument -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                        if let err = err {
//                            self.log.i("ArenaNextRoundStepVC - openStageRankingDialog() getDocument Fail -- \(APIManager.sharedManager.user?.userName ?? "") --- Error-> \(err)")  //  By Pranay.
                            print("Error getting documents: \(err)")
                        } else {
                            var newDoc:DocumentSnapshot?
                            newDoc =  querySnapshot!
                            
//                            self.log.i("ArenaNextRoundStepVC - openStageRankingDialog() getDocument response -- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                            
                            var playerArr = [[String:AnyObject]]()
                            playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                            playerArr[self.myPlayerIndex]["stages"] = arr[1] as! [Int] as AnyObject
                            
//                            self.log.i("ArenaNextRoundStepVC - openStageRankingDialog() update new stage rank to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> playerDetails: \(playerArr)")  //  By Pranay.
                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                "playerDetails": playerArr
                            ]) { err in
                                if let err = err {
//                                    self.log.i("ArenaNextRoundStepVC - openStageRankingDialog() update new stage rank to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- Error-> \(err)")  //  By Pranay.
                                    print("Error writing document: \(err)")
                                } else {
                                    self.callBackInfo()
                                }
                            }
                        }
                    } //.
                    //  */
                    
                    /*self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                        "playerDetails.\(self.myPlayerIndex).stages": arr[1] as! [Int] as AnyObject
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.callBackInfo()
                        }
                    }   //  */
                }
            }
        }
        if self.isNextRoundRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func proceedTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        roundStartTime = Int(NSDate().timeIntervalSince1970)
        if isTap == false {
            isTap = true
            var param = [String:AnyObject]()
            ///
            if isTimeUp {
//                self.log.i("TimeUp and Proceed tap.-- status ->\(self.navStatus) - Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                param = ["status":navStatus,
                         "readyToStagePickBanBy" : self.arrPlayer[APIManager.sharedManager.myPlayerIndex].playerId!
                         //"gameStartTime": roundStartTime
                ] as [String:AnyObject]
            }
            else {
                if self.doc?.data()?["readyToStagePickBanBy"] as? Int != 0 {
                    param = ["status":navStatus
                             //"gameStartTime": roundStartTime
                    ] as [String:AnyObject]
//                    self.log.i("Tap proceed after opponent tap.-- status ->\(self.navStatus) - Remain time -> \(self.timeSeconds) -- Param - \(param)")  //  By Pranay.
                }
                else {
                    param = ["readyToStagePickBanBy":self.arrPlayer[APIManager.sharedManager.myPlayerIndex].playerId!
                             //"gameStartTime": roundStartTime
                    ] as [String:AnyObject]
//                    self.log.i("First tap on proceed.-- status ->\(self.navStatus)  - Remain time -> \(self.timeSeconds) -- Param - \(param)")  //  By Pranay.
                }
            }   /// */
            
            //param = ["gameStartTime": roundStartTime] as [String: AnyObject]
//            self.log.i("ArenaNextRoundStepVC and update on proceed tap. Status-> \(self.navStatus). -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            
            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if err != nil {
//                    self.log.e("ArenaNextRoundStepVC and update status Fails. -> \(self.navStatus). -- \(APIManager.sharedManager.user?.userName ?? "") --- Error-> \(err)")  //  By Pranay.
                }
                else {
//                    self.log.i("ArenaNextRoundStepVC and update status SUCCESS. -> \(self.navStatus). -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                }
            }
        }
    }
     
    @IBAction func characterSelectionTapped(_ sender: UIButton) {
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CharacterSelectionPopupVC") as! CharacterSelectionPopupVC
        dialog.teamId = (self.arrFirebase?.playerDetails?[self.myPlayerIndex].teamId)!
        dialog.isFromNextRound = true
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        /// 331 - By Pranay
        dialog.strCharName = self.lblCharacter.text!
        /// 331 .
        dialog.tapOk = { arr in
            if !Network.reachability.isReachable {
                self.isRetryInternet { (isretry) in
                    if isretry! {
                        self.callBackInfo()
                    }
                }
                return
            }
            
            APIManager.sharedManager.arrDefaultChar = arr
            let array : [[Characters]] = arr[0] as! [[Characters]]
            self.lblCharacter.text = array[arr[1] as! Int][arr[2] as! Int].name
            self.imgCharacter.setImage(imageUrl: array[arr[1] as! Int][arr[2] as! Int].imagePath ?? "")
            
            var playerArr = [[String:AnyObject]]()
            playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
            
            /// 113 - By Pranay
            /// Comment for not update previous character in player array
            //playerArr[self.myPlayerIndex]["characterName"] = array[arr[1] as! Int][arr[2] as! Int].name as AnyObject?
            //playerArr[self.myPlayerIndex]["characterImage"] = array[arr[1] as! Int][arr[2] as! Int].imagePath as AnyObject?
            //playerArr[self.myPlayerIndex]["characterId"] = array[arr[1] as! Int][arr[2] as! Int].id as AnyObject?
            
            /// Update default character in player array
            playerArr[self.myPlayerIndex]["defaultCharName"] = array[arr[1] as! Int][arr[2] as! Int].name as AnyObject?
            playerArr[self.myPlayerIndex]["defaultCharImage"] = array[arr[1] as! Int][arr[2] as! Int].imagePath as AnyObject?
            playerArr[self.myPlayerIndex]["defaultCharId"] = array[arr[1] as! Int][arr[2] as! Int].id as AnyObject?
            /// 113 .
            
//            self.log.i("ArenaNextRoundStepVC - characterSelectionTapped() update new char to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> playerDetails: \(playerArr)")  //  By Pranay.
            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                "playerDetails": playerArr
            ]) { err in
                if let err = err {
//                    self.log.i("ArenaNextRoundStepVC - characterSelectionTapped() update new char to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- Error-> \(err)")  //  By Pranay.
                    print("Error writing document: \(err)")
                } else {
                    self.callBackInfo()
                }
            }
        }
        dialog.tapClose = {
            self.callBackInfo()
        }
        if self.isNextRoundRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
        
    @IBAction func stagedPickOrBanTapped(_ sender: UIButton) {
        openStageRankingDialog()
    }
    
    @IBAction func setDefaultTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSetDefaultPopupVC") as! ArenaSetDefaultPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = {
            self.callBackInfo()
        }
        if self.isNextRoundRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnHostUsedChatTap(_ sender: UIButton) {
        //self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter ?? [])
    }
    
    @IBAction func btnAwayUsedChatTap(_ sender: UIButton) {
        //self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter ?? [])
    }
    
    func openUsedCharacterPopup(name: String, image: String, characters: [Characters]) {
        if ((APIManager.sharedManager.isShoesCharacter ?? "") == "Yes") {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "DisplayPlayerCharacterPopup") as! DisplayPlayerCharacterPopup
            //dialog.isFromNextRound = true
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            //dialog.strCharName = self.lblCharacter.text!
            //let tChar: [PlayerAllCharacter] = (self.playerCharacter?.filter({ $0.playerId == (standingData[indexPath.section - 1]["playerId"] as? Int)! }))!
            let tChar: [Characters] = characters
            dialog.playerCharacter = (tChar.count > 0) ? tChar : []
            dialog.maxCharacterLimit = APIManager.sharedManager.maxCharacterLimit
            //dialog.playerCharacter = self.playerCharacter![0].characters
            dialog.strUserName = name
            dialog.strUserProfileImg = image
            dialog.isActivateListener = true
            
            dialog.tapClose = {
                self.listner?.remove()
                self.setFirestoreData()
            }
            
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Webservices
    func getTime() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTime()
                }
            }
            return
        }
        
//        self.log.i("GetTime API call GET_ROUND_REMAIN_TIME - \(APIManager.sharedManager.user?.userName ?? "") -- ")  //  By Pranay.
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ROUND_REMAIN_TIME, parameters: ["leagueId" : APIManager.sharedManager.match!.leagueId!, "matchId" :  APIManager.sharedManager.match!.matchId!, "for" : APIManager.sharedManager.match?.matchType ?? ""]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
//                self.log.i("GetTime API call GET_ROUND_REMAIN_TIME success - \(APIManager.sharedManager.user?.userName ?? "") -- response->\(response)")  //  By Pranay.
                DispatchQueue.main.async {
                    self.timeSeconds = (response?.result?.remainTime ?? 0) / 1000
                    
                    print("Get remain time for next match", self.timeSeconds/60)
                    if self.timeSeconds > 0 {
                        print("self.isTimeUp is false...")
                        self.isTimeUp = false
                    }
                    self.getStageCharacter()
                }
            } else {
                DispatchQueue.main.async {
                    self.getStageCharacter()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getStageCharacter() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getStageCharacter()
                }
            }
            return
        }
        
//        self.log.i("getStageCharacter API call GET_PLAYER_STAGE_CHARACTER - \(APIManager.sharedManager.user?.userName ?? "") -- ")  //  By Pranay.
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_STAGE_CHARACTER, parameters: ["leagueId" : APIManager.sharedManager.match!.leagueId!, "teamId": APIManager.sharedManager.myTeamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
//                self.log.i("GetTime API call GET_PLAYER_STAGE_CHARACTER success - \(APIManager.sharedManager.user?.userName ?? "") -- response->\(response)")  //  By Pranay.
                DispatchQueue.main.async {
                    self.lblCharacter.text = response?.result?.playerCharacter?.name
                    self.imgCharacter.setImage(imageUrl: response?.result?.playerCharacter?.imagePath ?? "")
                    self.setFirestoreData()
                }
            } else {
                DispatchQueue.main.async {
                    self.setFirestoreData()
                }
            }
        }
    }
    
    func navigateToArenaMatchReset() {
        /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaMatchResetVC
        self.listner?.remove()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            APIManager.sharedManager.match?.resetMatch = 1
            if aViewController is ArenaMatchResetVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            } else {
                let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaMatchResetVC") as! ArenaMatchResetVC
                stagePickVC.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(stagePickVC, animated: true)
                break
            }
        }
    }
    
    func navigateToArenaRoundResult() {
        self.listner?.remove()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ArenaRoundResultVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            }
            else {
                let arenaRoundResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                arenaRoundResultVC.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(arenaRoundResultVC, animated: true)
                break
            }
        }
    }
    
    func scheduledRemoved() {
        if APIManager.sharedManager.timer.isValid == true {
            APIManager.sharedManager.timer.invalidate()
        }
        self.listner?.remove()
        self.leagueTabVC!().getTournamentContent()
    }
}

// MARK: - UICollectionViewDelegate
extension ArenaNextRoundStepVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return (leaderboardData?.count ?? 10) + 2
        //return APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count != 0 ? (leaderboardData?.count ?? 0) + 2 : (leaderboardData?.count ?? 0) + 1
        return APIManager.sharedManager.stagePickBan ?? "" == "Yes" ? (leaderboardData?.count ?? 0) + 2 : (leaderboardData?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
            
            if rowHeaders != nil {
//                cell.hideAnimation()
                cell.contentLabel.text = rowHeaders[indexPath.row]
            }
            else {
                cell.contentLabel.text = ""
//                cell.showAnimation()
            }
            
            cell.contentLabel.textColor = UIColor.white
            cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
            //cell.backgroundColor = Colors.blueTheme.returnColor() //  By Pranay - comment by pranay
            
            /// 333 - By Pranay
            cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
            /// 333 .
            
            return cell
        }
        else if indexPath.section == (leaderboardData.count + 1) {
            if(indexPath.row == 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.contentLabel.text = "Stages"
                }
                else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                //cell.backgroundColor = Colors.blueTheme.returnColor() //  By Pranay - comment by pranay
                
                /// 333 - By Pranay
                cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
                /// 333 .
                
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                cell.ivCheck.isHidden = true
                if rowHeaders != nil {
//                    cell.ivIcon.hideSkeleton()
                    if indexPath.row < self.arrFirebase?.currentRound ?? 0 {
                        cell.ivIcon.setCharacter(imageUrl: (self.arrFirebase?.rounds?[indexPath.row - 1].finalStage?.imagePath == nil) ? "" : (self.arrFirebase?.rounds?[indexPath.row - 1].finalStage?.imagePath ?? ""))
                    }
                    else {
                        cell.ivIcon.setCharacter(imageUrl: "")
                    }
                    
                    if(indexPath.row == rowHeaders.count - 1){
                        cell.ivIcon.sd_setImage(with: URL(string: ""))
                    }
                    
                    //cell.ivWidthConst.constant = 20
                    cell.lblScore.text = ""
                    cell.lblScoreBottom.constant = 30
                    cell.ivIconTop.constant = 10
                }
                else
                {
//                    cell.ivIcon.showAnimatedSkeleton()
                }
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultUsersCVCell",
                for: indexPath) as! ResultUsersCVCell
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] as? String
                    cell.ivPlayer.setImage(imageUrl: leaderboardData[indexPath.section - 1]["avatarImage"] as! String)
                    cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.width/2
                }else {
                    cell.lblPlayerName.text = ""
//                    cell.showAnimation()
                }
                return cell
            } else if indexPath.row == rowHeaders.count - 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let row = leaderboardData[indexPath.section - 1]
                    if self.arrFirebase?.currentRound != 1 {
                        cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)" == "" ? "-" : "\(row[rowHeaders[indexPath.row]]!)"
                    } else {
                        cell.contentLabel.text = "-"
                    }
                }else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                if rowHeaders != nil {
//                    cell.ivIcon.hideSkeleton()
                    cell.ivIcon.setCharacter(imageUrl: (leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] ?? "") as! String)
                    cell.lblScore.text = leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as? String
                    cell.ivWidthConst.constant = 25
                    if indexPath.section == 1 {
                        cell.lblScoreBottom.constant = 4.5
                        cell.ivIconTop.constant = 4
                    } else {
                        cell.lblScoreBottom.constant = 35
                        cell.ivIconTop.constant = 25
                    }
                    
                    if leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as! String == "-" {
                        cell.ivCheck.isHidden = true
                    } else if(self.arrFirebase?.rounds?[indexPath.row - 1].winnerTeamId != nil) {
                        if indexPath.section == 1
                        {
                            if self.arrFirebase?.rounds?[indexPath.row - 1].winnerTeamId == self.arrPlayer[self.hostIndex].teamId {
                                cell.ivCheck.isHidden = false
                            } else {
                                cell.ivCheck.isHidden = true
                            }
                        } else {
                            if self.arrFirebase?.rounds?[indexPath.row - 1].winnerTeamId == self.arrPlayer[self.opponentIndex].teamId
                            {
                                cell.ivCheck.isHidden = false
                            } else {
                                cell.ivCheck.isHidden = true
                            }
                        }
                    }
                } else {
//                    cell.ivIcon.showAnimatedSkeleton()
                }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 60)) > CGFloat(self.view.frame.width) ? 60 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100 : currentWidth, height: indexPath.section == 0 ? 40 : indexPath.section == (leaderboardData.count + 1) ? 40 : 60)
    }
}

extension ArenaNextRoundStepVC {
    
    func declareForfeitTeam() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.declareForfeitTeam()
                }
            }
            return
        }
        
        self.showLoading()
        
        var winnerTeamId = APIManager.sharedManager.match?.homeTeamId ?? 0
        var losserTeamId = APIManager.sharedManager.match?.awayTeamId ?? 0
        
        if  APIManager.sharedManager.user?.id == (APIManager.sharedManager.match?.homeTeamPlayers![0].userId ?? 0) {
            winnerTeamId = APIManager.sharedManager.match?.awayTeamId ?? 0
            losserTeamId = APIManager.sharedManager.match?.homeTeamId ?? 0
        }
        
        let param = [
            "matchId": APIManager.sharedManager.match?.matchId ?? 0,
            "winnerTeamId": winnerTeamId,
            "losserTeamId": losserTeamId,
            "timeZone": APIManager.sharedManager.timezone
        ] as [String : Any]
        
        //self.listner?.remove()
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DECLARE_FORFEIT_TEAM, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.isMatchForfeitByMe = true
                //DispatchQueue.main.async {
                    //self.leagueTabVC!().getTournamentContent()
                //}
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
                //self.setFirestoreData()
            }
        }
    }
}
