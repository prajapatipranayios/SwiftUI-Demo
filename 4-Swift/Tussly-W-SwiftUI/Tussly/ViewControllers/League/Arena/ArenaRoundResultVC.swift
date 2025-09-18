//
//  ArenaVC.swift
//  Tussly
//
//  Created by Auxano on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
//import ShipBookSDK

class ArenaRoundResultVC: UIViewController, refreshTabDelegate {
    // MARK: - variables
    let db = Firestore.firestore()
    var myPlayerIndex = 1
    var opponent = 1
    var arrPlayer = [ArenaPlayerData]()
    var player1Score = "0"
    var player2Score = "0"
    var arrFire : FirebaseInfo?
    var winnerId = 0
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var hostIndex = 0
    var opponentIndex = 1
    var lblMessageCount = UILabel()
    var isEnter = false
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var isListenerAsign = false
    var isGameOver = false
    var stagePickNavVC: UINavigationController?
    var isAdminUpdate = false
    var isFromHome = false
    var isTapChat = false
    var isTieByMistake = false
    var isScoreRemovedFromStack = false
    var isReminderOpen = false
    
    
    var isRedirect : Bool = false
    var isReminderOnceAppear : Bool = false
    var isRedirectNext : Bool = false
    var isCallOneTime : Bool = false
    var myWinCount : Int = 0
//    fileprivate let log = ShipBook.getLogger(ArenaRoundResultVC.self)
    var refreshTimer = Timer()
    var isGetLeagueMatchApiCall: Bool = false
    var isMatchForfeit: Bool = false
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Controls
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var cvResult: UICollectionView!
    
    @IBOutlet weak var cvResultGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvResultGridLayout.stickyRowsCount = 1
            cvResultGridLayout.stickyColumnsCount = 1
        }
    }
    
    @IBOutlet weak var lblRoundName: UILabel!
    @IBOutlet weak var lblNextPlayer1: UILabel!
    @IBOutlet weak var lblNextPlayer2: UILabel!
    @IBOutlet weak var imgNextPlayer2: UIImageView!
    @IBOutlet weak var imgNextPlayer1: UIImageView!
    @IBOutlet weak var lblNextMatchTime: UILabel!
    @IBOutlet weak var lblNextGame: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewStageDetail: UIView!
    @IBOutlet weak var viewStageDetailHeightConst : NSLayoutConstraint!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewBottomHeightConst : NSLayoutConstraint!
    @IBOutlet weak var lblStage : UILabel!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    
    // By Pranay
    @IBOutlet weak var lblScoreBoardScrOpen: UILabel!
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblTimerMsg: UILabel!
    //.
    
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var leaderboardData: [[String: Any]]!
    var gameName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // By Pranay
        gameName =  APIManager.sharedManager.gameSettings?.gameName ?? "" //APIManager.sharedManager.gameSettings?.id == 11 ? "SSBU" : "SSBM"
        lblScoreBoardScrOpen.text = "Keep your \(gameName) Scoreboard screen open"
        //.
        
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        btnReport.layer.cornerRadius = btnReport.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        imgPlayer1.layer.cornerRadius = imgPlayer1.frame.size.height / 2
        imgPlayer2.layer.cornerRadius = imgPlayer2.frame.size.height / 2
        imgNextPlayer2.layer.cornerRadius = imgNextPlayer2.frame.size.height / 2
        imgNextPlayer1.layer.cornerRadius = imgNextPlayer1.frame.size.height / 2
        
        rowHeaders = ["Players", "R1", "R2", "R3", "Final"]
        leaderboardData = []
            /*[
                "Players": "JD Molson",
                "avatarImage": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R1": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R2": "",
                "R3": "",
                "score1": "",
                "score2": "",
                "score3": "",
                "Final": ""
            ], [
                "Players": "Zedrick",
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
        
        UserDefaults.standard.removeObject(forKey: "tieRPS")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // By Pranay
        self.isRedirect = false
        self.isRedirectNext = false
        self.isGetLeagueMatchApiCall = false
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        //.
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationItem.setTopbar()
        
        // By Pranay
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        //.
        
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
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.callBackInfo),name: NSNotification.Name(rawValue: "DismissInfo"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.chatCountUpdate),name: NSNotification.Name(rawValue: "newMessageNotification"),object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        if isTapChat {
            isTapChat = false
            self.isRedirectNext = false
            callBackInfo()
        }
        else {
            self.setNotificationCountObserver()
            
            //screen just open/reopen
            isScoreRemovedFromStack = false
            
            self.leagueTabVC!().hightContantView.constant = self.leagueTabVC!().viewMain.frame.height - 74
            self.lblTimerMsg.text = "The Arena will auto-refresh in  \(APIManager.sharedManager.arenaMatchFinishTimer) seconds"
            
            if self.refreshTimer.isValid == false {
                APIManager.sharedManager.isMatchRefresh = true
            }
            
            //if admin manually update score then call league match api
            if self.isAdminUpdate {
                self.isAdminUpdate = false
                self.isGameOver = true
                viewBottom.isHidden = true
                viewBottomHeightConst.constant = 0
                print("Call getLeagueMatch This From Here >>>>>>>>>>  01")
                self.getLeagueMatch()
            }
            else {
                print("Call This From Here >>>>>>>>>>  01")
                setUI()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "backFromCharacter"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        //removed this screen from stack
        isScoreRemovedFromStack = true
        listner?.remove()
        self.refreshTimer.invalidate()
    }
    
    // By Pranay
    func showReminder() {
        //reminder dialog
        if APIManager.sharedManager.isReminderOpen == 0 {
            var isDialogOpen = false
            if isFromHome {
                if isReminderOpen {
                    isDialogOpen = true
                }
            }
            if isDialogOpen == false && self.doc?.data()?["status"] as? String == Messages.playinRound {
                self.isReminderOnceAppear = true
                isReminderOpen = true
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaReminderPopupVC") as! ArenaReminderPopupVC
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.tapOk = {
                        self.isReminderOpen = false
                        self.listner?.remove()
                        print("Call This From Here >>>>>>>>>>  02")
                        self.setUI()
                    }
                    if self.isScoreRemovedFromStack == false {
                        self.listner?.remove()
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    //.
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isScoreRemovedFromStack = true
            listner?.remove()
            self.view!.tusslyTabVC.dismiss(animated: true)
            self.refreshTimer.invalidate() // By Pranay
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    @objc func chatCountUpdate() {
        self.lblMessageCount.removeFromSuperview()
        chatBadge()
    }
    
    @objc func callBackFromCharacter() {
        if isListenerAsign {
            isListenerAsign = false
            print("Call This From Here >>>>>>>>>>  03")
            self.setUI()
            self.btnReport.isEnabled = true
            self.btnReport.backgroundColor = Colors.theme.returnColor()
        }
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
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    @objc func onTapInfo() {
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 6
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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
    
    func setUI() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaRoundResultVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaRoundResultVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaRoundResultVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaRoundResultVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaRoundResultVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    if let dataDict = self.doc?.data(),
                       let theJSONData = try? JSONSerialization.data(withJSONObject: dataDict, options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            self.arrPlayer = self.arrFire?.playerDetails ?? []
                            
                            if !self.isReminderOnceAppear {
                                self.isReminderOnceAppear = self.doc?.data()?["status"] as? String == Messages.playinRound ? false : true
                            }
                            if !self.isReminderOnceAppear {
                                self.showReminder()
                            }
                            //self.chatBadge()  //  comment by Pranay.  -   16122022
                            
                            if self.arrFire?.playerDetails?.count ?? 0 != 0 {
                                self.hostIndex = self.arrPlayer[0].host == 1 ? 0 : 1
                                self.opponentIndex = self.hostIndex == 1 ? 0 : 1
                                
                                let homeTeamName = (self.arrPlayer[self.hostIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.hostIndex].teamName ?? "")[..<(self.arrPlayer[self.hostIndex].teamName ?? "").index((self.arrPlayer[self.hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.hostIndex].teamName ?? "")
                                let awayTeamName = (self.arrPlayer[self.opponentIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.opponentIndex].teamName ?? "")[..<(self.arrPlayer[self.opponentIndex].teamName ?? "").index((self.arrPlayer[self.opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.opponentIndex].teamName ?? "")
                                
                                self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : homeTeamName
                                self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.opponentIndex].displayName ?? "") : awayTeamName
                                
                                self.lblPlayer2Char.text = self.arrPlayer[self.opponentIndex].characterName
                                self.lblPlayer1Char.text = self.arrPlayer[self.hostIndex].characterName
                                self.imgPlayer1.setImage(imageUrl: self.arrPlayer[self.hostIndex].characterImage ?? "")
                                self.imgPlayer2.setImage(imageUrl: self.arrPlayer[self.opponentIndex].characterImage ?? "")
                                self.lblStage.text = self.arrFire?.rounds?[self.doc?.data()?["currentRound"] as! Int - 1].finalStage?.stageName ?? "" != "" ? "Stage: \(self.arrFire?.rounds?[self.doc?.data()?["currentRound"] as! Int - 1].finalStage?.stageName ?? "-")" : "Stage: -"
                                
                                //Display scoreboard data
                                self.rowHeaders = ["Players"]
                                for i in 0 ..< (self.arrFire?.rounds?.count ?? 0) {
                                    self.rowHeaders.append("R\(i+1)")
                                }
                                self.rowHeaders.append("Final")
                                
                                //self.myWinCount = 0 //  Added by Pranay.
                                self.leaderboardData = []
                                for i in 0 ..< self.arrPlayer.count {
                                    var arr = [String:Any]()
                                    for j in 0 ..< (self.arrFire?.rounds?.count ?? 0) {
                                        
                                        let roundArr = self.arrFire?.rounds ?? [Rounds]()
                                        let contentArr  = APIManager.sharedManager.content?.characters ?? [Characters]()
                                        
                                        if (self.arrFire?.currentRound ?? 0) > j {
                                            for m in 0 ..< (APIManager.sharedManager.content?.characters?.count ?? 0) {
                                                if (contentArr[m].id! == (i == 0 ? roundArr[j].homeCharacterId! : roundArr[j].awayCharacterId!)) {
                                                    arr["R\(j+1)"] = APIManager.sharedManager.content?.characters?[m].imagePath
                                                    break
                                                }
                                            }
                                        }
                                        
                                        arr["score\(j+1)"] = "-"
                                        // By Pranay
                                        if (self.doc?.data()?["matchForfeit"] as! Int == 1) {
                                            arr["score\(j+1)"] = i == 0 ? String(self.arrFire?.rounds?[j].team1Score ?? 0) : String(self.arrFire?.rounds?[j].team2Score ?? 0)
                                        }
                                        else {       // By Pranay
                                            if ((self.arrFire?.currentRound ?? 0) - 1) > j {
                                                arr["score\(j+1)"] = i == 0 ? String(self.arrFire?.rounds?[j].team1Score ?? 0) : String(self.arrFire?.rounds?[j].team2Score ?? 0)
                                            }
                                        }   // By Pranay
                                        
                                        if self.doc?.data()?["status"] as? String == Messages.matchFinished {
                                            if self.arrFire?.rounds?[j].played == 1 {
                                                arr["score\(self.arrFire?.currentRound ?? 0)"] = i == 0 ? String(self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 0) - 1].team1Score ?? 0) : String(self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 0) - 1].team2Score ?? 0)
                                            }
                                        }
                                    }
                                    //arr["Players"] = i == 0 ? (APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.hostIndex].displayName ?? "" : self.arrPlayer[self.hostIndex].teamName ?? "") : (APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.opponentIndex].displayName ?? "" : self.arrPlayer[self.opponentIndex].teamName ?? "") //  Comment by Pranay
                                    
                                    arr["Players"] = i == 0 ? self.arrPlayer[self.hostIndex].displayName ?? "" : self.arrPlayer[self.opponentIndex].displayName ?? ""   //  Added by Pranay.
                                    
                                    //(APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.hostIndex].displayName ?? "" : self.arrPlayer[self.hostIndex].teamName ?? "") : (APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.opponentIndex].displayName ?? "" : self.arrPlayer[self.opponentIndex].teamName ?? "")   //  Added by Pranay.
                                    
                                    arr["avatarImage"] = i == 0 ?
                                    (APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.hostIndex].avatarImage ?? "" : self.arrPlayer[self.hostIndex].teamImage ?? "") : (APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? self.arrPlayer[self.opponentIndex].avatarImage ?? "" : self.arrPlayer[self.opponentIndex].teamImage ?? "")
                                    //self.arrPlayer[self.hostIndex].avatarImage ?? "" : self.arrPlayer[self.opponentIndex].avatarImage ?? ""
                                    
                                    var final = 0
                                    self.myWinCount = 0
                                    
                                    for j in 0 ..< (self.arrFire?.currentRound ?? 0) {
                                        if self.arrFire?.rounds?[j].played == 1 {
                                            if i == 0 {
                                                if(self.arrFire?.rounds?[j].winnerTeamId == self.arrFire?.playerDetails?[self.hostIndex].teamId){
                                                    //final = final + 1
                                                    final = (self.doc?.data()?["matchForfeit"] as! Int == 1) ? 1 : final + 1
                                                }
                                            }
                                            else {
                                                if(self.arrFire?.rounds?[j].winnerTeamId == self.arrFire?.playerDetails?[self.opponentIndex].teamId){
                                                    //final = final + 1
                                                    final = (self.doc?.data()?["matchForfeit"] as! Int == 1) ? 1 : final + 1
                                                }
                                            }
                                            /*if self.arrFire?.rounds?[j].winnerTeamId == self.arrFire?.playerDetails?[self.myPlayerIndex].teamId {
                                                self.myWinCount += 1
                                            }   //  */
                                        }
                                    }
                                    
                                    arr["Final"] = final
                                    self.leaderboardData.append(arr)
                                }
                                // By Pranay
                                /*if self.arrFire?.bestWinRound == self.myWinCount {
                                    APIManager.sharedManager.match = APIManager.sharedManager.previousMatch
                                }   //  */
                                //APIManager.sharedManager.match = APIManager.sharedManager.previousMatch
                                self.cvResult.reloadData()  //  Added by Pranay
                            }
                            else {
                                
                            }
                            print("Setui call and Status - \(self.doc?.data()?["status"] as? String)")
                            DispatchQueue.main.async { [self] in
                                if self.doc?.data()?["status"] as? String == Messages.matchFinished {
                                    if self.isFromHome {
                                        print("Status match finished isFromHome === 1")    //  Added by Pranay.
                                        self.isFromHome = false
                                        self.listner?.remove()
                                        self.isGameOver = true
                                        self.viewBottom.isHidden = true
                                        self.viewBottomHeightConst.constant = 0
                                        print("Delay for 1 sec.")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            print("Get League Match Call === 1")    //  Added by Pranay.
                                            self.getLeagueMatch()
                                        })
                                    }
                                    else {
                                        print("Status match finished isFromHome - else  === 2")    //  Added by Pranay.
                                        //if ((APIManager.sharedManager.eliminationType == "Double Elimination") || (APIManager.sharedManager.eliminationType == "Single Elimination")) && (!self.isRedirect || (self.doc?.data()?["manualUpdate"] as? Int == 1)) {
                                        if (!self.isRedirect || (self.doc?.data()?["manualUpdate"] as? Int == 1)) {
                                            print("Status match finished Double Elimination & Single Elimination === 1")    //  Added by Pranay.
                                            self.isRedirect = true
                                            self.listner?.remove()
//                                            self.log.i("ArenaRoundResultVC -- status- match finish and manualUpdate = 1  -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> manualUpdate : 0")  //  By Pranay.
                                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([ "manualUpdate": 0 ]) { err in
                                                if let err = err {
//                                                    self.log.e("ArenaRoundResultVC -- status- match finish and manualUpdate = 1  -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                                    print("Call This From Here >>>>>>>>>>  04")
                                                    self.setUI()
                                                }
                                                else {
                                                    print("Delay for 1 sec.")
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                                        print("Get League Match Call === 2")    //  Added by Pranay.
                                                        self.getLeagueMatch()
                                                    })
                                                }
                                            }
                                        }
                                        else {
                                            print("Status match finished Double Elimination & Single Elimination -- else === 2")    //  Added by Pranay.
                                            if APIManager.sharedManager.isMatchRefresh {
                                                print("Match refresh call")
                                                APIManager.sharedManager.isMatchRefresh = false
                                                if !(APIManager.sharedManager.isMatchForfeit) {
                                                    self.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(APIManager.sharedManager.arenaMatchFinishTimer), repeats: false) { timer in
                                                        print("Refresh timer call after 30 sec.")
                                                        self.refreshTimer.invalidate()
                                                        self.listner?.remove()
                                                        self.leagueTabVC!().getTournamentContent()
                                                        return
                                                    }
                                                }
                                                else {
                                                    self.refreshTimer.invalidate()
                                                    self.listner?.remove()
                                                    self.leagueTabVC!().getTournamentContent()
                                                    return
                                                }
                                            }
                                            else {
                                                print("Match refresh call in else part...")
                                            }
                                        }
                                    }
                                    
                                    if self.doc?.data()?["matchForfeit"] as! Int == 1 && !self.isMatchForfeit {
                                        self.isMatchForfeit = true
                                        self.listner?.remove()
                                        self.viewBottom.isHidden = true
                                        self.viewBottomHeightConst.constant = 0
                                        //self.matchForfeitByAdmin()    //  Comment by Pranay.
                                        //self.listner?.remove()
                                        
                                        APIManager.sharedManager.isMatchForfeit = true
                                        
//                                        self.log.i("ArenaRoundResultVC -- status- match finish and matchForfeit = 1  -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> matchForfeit: 0")  //  By Pranay.
                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([ "matchForfeit": 0 ]) { err in
                                            if let err = err {
//                                                self.log.e("ArenaRoundResultVC -- status- match finish and matchForfeit = 1  -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                                    self.isMatchForfeit = false
                                                    self.setUI()
                                                })
                                            }
                                            else {
                                                //self.getLeagueMatch()
                                                print("Delay for 1 sec.")
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                                    print("Get League Match Call === 3")    //  Added by Pranay.
                                                    self.getLeagueMatch()
                                                })
                                            }
                                        }
                                        //self.getLeagueMatch()
                                    }
                                    self.lblRoundName.text = Messages.gameOver
                                    self.lblTitle.text = Messages.finalResult
                                    self.lblTitle.font.withSize(18.0)
                                    self.viewStageDetail.isHidden = true
                                    self.viewStageDetailHeightConst.constant = 0
                                }
                                else {
                                    self.lblRoundName.text = "Round \(self.arrFire?.currentRound ?? 1)"
                                    self.lblTitle.text = Messages.startMatch
                                    self.lblTitle.font.withSize(20.0)
                                    self.viewStageDetail.isHidden = false
                                    self.viewStageDetailHeightConst.constant = 235   //  Added by Pranay.
                                    self.viewBottom.isHidden = true
                                    self.viewBottomHeightConst.constant = 0
                                }
                                self.view.layoutIfNeeded()
                            }
                            //self.cvResult.reloadData()    //  Comment by Pranay.
                            
                            if self.isReminderOpen == false {
                                
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    if APIManager.sharedManager.timer.isValid == true {
                                        APIManager.sharedManager.timer.invalidate()
                                    }
                                    self.listner?.remove()
                                    self.leagueTabVC!().getTournamentContent()
                                    return
                                }
                                else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    self.navigateToArenaMatchReset()
                                }
                                else if self.doc?.data()?["status"] as! String == Messages.enteringScore {
                                    //not done dispute
                                    if self.arrFire?.disputeBy == 0 {
                                        if self.isEnter == true {
                                            self.enterScore()
                                        }
                                    }
                                    else {
                                        //any player dispute score
                                        if self.arrFire?.disputeBy != self.arrPlayer[self.myPlayerIndex].playerId {
                                            self.waitingPopup(arenaFlow: "WaitingScoreConfirm", description: Messages.waitToConfirm)
                                        }
                                        else {
                                            self.listner?.remove()
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeScoreVC") as! ArenaDisputeScoreVC
                                            vc.arrFire = self.arrFire
                                            vc.tusslyTabVC = self.tusslyTabVC
                                            vc.leagueTabVC = self.leagueTabVC
                                            if self.isScoreRemovedFromStack == false {
                                                self.navigationController?.pushViewController(vc, animated: true)
                                            }
                                        }
                                    }
                                }
                                //Status = entered score
                                else if(self.doc?.data()?["status"] as? String == Messages.enteredScore) {
                                    //not done dispute
                                    if(self.doc?.data()?["disputeBy"] as? Int == 0){
                                        if (self.arrFire?.enteredScoreBy ?? 0) != (self.arrPlayer[self.myPlayerIndex].playerId ?? 0) {
                                            self.confirmedEnteredScore()
                                        }
                                        else {
                                            self.waitingPopup(arenaFlow: "WaitingScoreConfirm", description: Messages.waitToConfirm)
                                        }
                                    }
                                    else {
                                        //player dispute score
                                        if self.arrFire?.disputeBy == self.arrPlayer[self.myPlayerIndex].playerId {
                                            //self.confirmedEnteredScore()
                                            // By Pranay
                                            if self.arrFire?.playerDetails![0].dispute == 1 || self.arrFire?.playerDetails![1].dispute == 1 {
                                                self.disputeScore() //  By Pranay
                                            }
                                            else {
                                                self.confirmedEnteredScore()
                                            }
                                            //.
                                        }
                                        else {
                                            self.waitingPopup(arenaFlow: "WaitingScoreConfirm", description: Messages.waitToConfirm)
                                        }
                                    }
                                }
                                //Status = entered dispute score
                                else if(self.doc?.data()?["status"] as? String == Messages.enterDisputeScore){
                                    UserDefaults.standard.set(1, forKey: "isDispute")
                                    if self.arrFire?.disputeBy == self.arrPlayer[self.myPlayerIndex].playerId {
                                        //dispute by me
                                        self.waitingPopup(arenaFlow: "WaitingScoreConfirmOrDispute", description: Messages.waitToConfirmOrDispute)
                                    } else {
                                        //dispute by other player
                                        self.listner?.remove()
                                        self.disputeScore()
                                    }
                                }
                                //Status = dispute
                                else if(self.doc?.data()?["status"] as? String == Messages.dispute) {
                                    //duspute done by both side
                                    if self.arrFire?.playerDetails![0].dispute == 1 && self.arrFire?.playerDetails![1].dispute == 1 {
                                        self.listner?.remove()
//                                        self.log.i("Both player dispute score. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeScoreVC") as! ArenaDisputeScoreVC
                                        vc.arrFire = self.arrFire
                                        vc.tusslyTabVC = self.tusslyTabVC
                                        vc.leagueTabVC = self.leagueTabVC
                                        if self.isScoreRemovedFromStack == false {
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                    //dispute by other player
                                    else if self.arrFire?.disputeBy != self.arrPlayer[self.myPlayerIndex].playerId {
                                        self.waitingPopup(arenaFlow: "WaitingScoreConfirm", description: Messages.waitToConfirm)
                                    }
                                    else {
                                        //dispute by me
                                        self.listner?.remove()
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeScoreVC") as! ArenaDisputeScoreVC
                                        vc.arrFire = self.arrFire
                                        vc.tusslyTabVC = self.tusslyTabVC
                                        vc.leagueTabVC = self.leagueTabVC
                                        if self.isScoreRemovedFromStack == false {
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                    }
                                }
                                //Status = waiting to stage pick ban
                                else if(self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan && !self.isRedirectNext) {
                                    UserDefaults.standard.set(0, forKey: "isDispute")
                                    self.listner?.remove()
                                    /// 441 - By Pranay
                                    self.isRedirectNext = true
                                   
                                    
                                    if (self.arrFire?.manualUpdate == 1) && ((self.arrFire?.currentRound ?? 0) < 3) {
//                                        self.log.i("ArenaRoundResultVC -- status- Messages.waitingToStagePickBan and manualUpdate = 1  -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> manualUpdate: 0")  //  By Pranay.
                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                            "manualUpdate": 0
                                        ]) { err in
                                            if let err = err {
//                                                self.log.e("ArenaRoundResultVC -- status- Messages.waitingToStagePickBan and manualUpdate = 1 - fail  -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                            }
                                        }
                                    }
                                    self.updatePlayedCharacter()
                                    APIManager.sharedManager.arrDefaultChar = []
                                    self.btnReport.isEnabled = true
                                    self.btnReport.backgroundColor = Colors.theme.returnColor()
                                    DispatchQueue.main.async {
                                        if self.isGetLeagueMatchApiCall {
                                            APIManager.sharedManager.match = APIManager.sharedManager.previousMatch
                                        } else {
                                            APIManager.sharedManager.previousMatch = APIManager.sharedManager.match
                                        }
                                        
                                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                        for aViewController in viewControllers {
                                            if aViewController is ArenaNextRoundStepVC {
                                                self.navigationController!.popToViewController(aViewController, animated: true)
                                                break
                                            } else {
                                                let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaNextRoundStepVC") as! ArenaNextRoundStepVC
                                                stagePickVC.tusslyTabVC = self.tusslyTabVC
                                                stagePickVC.leagueTabVC = self.leagueTabVC
                                                self.navigationController?.pushViewController(stagePickVC, animated: true)
                                                break
                                            }
                                        }
                                    }
                                }
                                /// 441 - by Pranay
                                else if (self.doc?.data()?["status"] as? String == Messages.scoreConfirm && self.doc?.data()?["disputeConfirmBy"] as! Int == 1)  {
                                    // status confirmed by admin
                                    self.acceptByAdmin()
                                }
                                else if (self.doc?.data()?["status"] as? String == Messages.playinRound && self.doc?.data()?["matchFinish"] as! Int == 1)  {
                                    self.acceptByAdmin()
                                }
                                /*else if (self.doc?.data()?["status"] as? String == Messages.scoreConfirm) && (self.doc?.data()?["manualUpdate"] as? Int == 1) {
                                    // status confirmed by opponent
                                    print("acceptByAdmin while manualUpdate 1 call ===")
                                    self.acceptByAdmin()
                                }   //  */
                                else if (self.doc?.data()?["status"] as? String == Messages.scoreConfirm) && (self.leagueTabVC!().isFromOutSideArena) {
                                    // status confirmed by opponent
                                    print("scoreConfirm call ===")
                                    self.leagueTabVC!().isFromOutSideArena = false
                                    self.declareRoundWinner()
                                    
                                    /*self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([ "iosDeclareWinnerFail": 0 ]) {
                                        err in
                                        if let err = err {
                                            self.listner?.remove()
                                            self.setUI()
                                        } else {
                                            self.declareRoundWinner()
                                        }
                                    }   //  */
                                    //iosDeclareWinnerFail
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
        
    func submitScore() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
//        self.log.i("ArenaRoundResultVC -- submitScore() - getDocument -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaRoundResultVC -- submitScore() - getDocument -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                var newDoc:DocumentSnapshot?
                newDoc =  querySnapshot!
                
//                self.log.i("ArenaRoundResultVC -- submitScore() - getDocument response -- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                
                var playerArr = [[String:AnyObject]]()
                playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                
                var roundArr = [[String:AnyObject]]()
                
                roundArr = newDoc?.data()?["rounds"] as! [[String : AnyObject]]
                roundArr[newDoc?.data()?["currentRound"] as! Int - 1]["team1Score"] = Int(self.player1Score) as AnyObject
                roundArr[newDoc?.data()?["currentRound"] as! Int - 1]["team2Score"] = Int(self.player2Score) as AnyObject
                roundArr[newDoc?.data()?["currentRound"] as! Int - 1]["winnerTeamId"] = playerArr[self.winnerId]["teamId"] as AnyObject
                
                // By Pranay
                var disputeScore = [String:AnyObject]()
                disputeScore = [
                    "team1Score": Int(self.player1Score) as AnyObject,
                    "team2Score" : Int(self.player2Score) as AnyObject,
                    "winnerTeamId" : playerArr[self.winnerId]["teamId"] ?? 0,
                    "disputeImagePath" : ""
                ] as [String:AnyObject]
                
                playerArr[self.myPlayerIndex]["disputeScore"] = disputeScore as AnyObject
                //.
                
                //if other player has not submitted score yet then submit your score
                if newDoc?.data()?["status"] as? String == Messages.enteringScore {
                    let param = [
                        "status": Messages.enteredScore,
                        "rounds" : roundArr,
                        "enteredScoreBy": playerArr[self.myPlayerIndex]["playerId"] ?? 0,
                        "playerDetails":playerArr
                    ] as [String: Any]
//                    self.log.i("ArenaRoundResultVC -- submitScore() started - submit score to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if let err = err {
//                            self.log.e("ArenaRoundResultVC -- submitScore() - submit score to firestore -- \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                            print("Error writing document: \(err)")
                        }
                        else {
//                            self.log.i("ArenaRoundResultVC -- submitScore() completed to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")
                            print("Call This From Here >>>>>>>>>>  05")
                            self.setUI()
                        }
                    }
                }
                else {
                    print("Call This From Here >>>>>>>>>>  06")
                    self.setUI()
                }
            }
        }
    }
    
    func disputeScore(){
        let rounds = self.arrFire?.rounds ?? [Rounds]()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaDisputeVC") as! ArenaDisputeVC
        dialog.score1 = String(rounds[self.doc?.data()?["currentRound"] as! Int - 1].team1Score ?? 0)
        dialog.score2 = String(rounds[self.doc?.data()?["currentRound"] as! Int - 1].team2Score ?? 0)
        
        if ((self.arrPlayer[self.hostIndex].teamId ?? 0) == rounds[self.doc?.data()?["currentRound"] as! Int - 1].winnerTeamId ?? 0) {
            dialog.winnerId = 0
        } else {
            dialog.winnerId = 1
        }
        
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { index in
            if index == 0 {
                //confirm disputed score
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = Messages.confirm
                dialog.message = Messages.areYouSureCofirmOpponentScore
                dialog.highlightString = ""
                dialog.isFromDisputeScore = true
                dialog.tapOKForArenaScore = { isConfirm in
                    APIManager.sharedManager.timer.invalidate()
                    if isConfirm == false {
                        self.updateScoreAsConfirm()
                    }
                    else {
                        print("Call This From Here >>>>>>>>>>  07")
                        self.setUI()
                    }
                }
                dialog.tapCancel = {
                    APIManager.sharedManager.timer.invalidate()
                    self.disputeScore()
                }
                dialog.btnYesText = Messages.yesProceed
                dialog.btnNoText = Messages.noGoBack
                if self.isScoreRemovedFromStack == false {
                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                }
            }
            else if index == 1 {
                //dispute score again
                if !Network.reachability.isReachable {
                    self.isRetryInternet { (isretry) in
                        if isretry! {
                            self.callBackInfo()
                        }
                    }
                    return
                }
                
                let param = [
                    "status" : Messages.dispute,
                    "disputeBy": self.arrPlayer[self.myPlayerIndex].playerId ?? 0
                ] as [String: Any]
                
//                self.log.i("ArenaRoundResultVC -- disputeScore() - submit dispute status to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                    if let err = err {
//                        self.log.e("ArenaRoundResultVC -- disputeScore() - submit dispute status to firestore -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                        print("Error writing document: \(err)")
                    }
                    else {
                        print("Call This From Here >>>>>>>>>>  08")
                        self.setUI()
                    }
                }
            }
            else if index == 2 {
                //view evidence image
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVideoVC") as! ViewImageVideoVC
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.meiaURL = self.arrFire?.disputeImagePath ?? ""
                dialog.tapOk = { isConfirm in
                    if isConfirm {
                        print("Call This From Here >>>>>>>>>>  09")
                        self.setUI()
                    }
                    else {
                        self.disputeScore()
                    }
                }
                if self.isScoreRemovedFromStack == false {
                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                }
            }
            else if index == 3 {
                print("Call This From Here >>>>>>>>>>  10")
                self.setUI()
            }
            else if index == 4 {
                self.updateScoreAsConfirm()
            }
            else if index == 9 {
                /// Match reset by organizer.
                self.navigateToArenaMatchReset()
            }
            else if index == 10 {
                /// Scheduled Removed by organizer.
                self.scheduledRemoved()
            }
            else if index == 11 {
                // Mach Forfeit
                self.navigateToArenaRoundResult()
            }
        }
        if self.isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func tieDialog(isTie : Bool) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.score1 = self.player1Score
        dialog.score2 = self.player2Score
        dialog.isFromEnterScore = true
        
        // If tie damage percentage
        if(isTie) {
            //dialog.secondMessage = Messages.selectTheWinner
            dialog.secondMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTieMsg ?? ""
            dialog.thirdMessage = Messages.lowestDamage
            dialog.isTieByDamagePercentage = true
        }
        
        dialog.tapOk = { arr in
            if arr[0] as! Bool == true { //other player entered score
                print("Call This From Here >>>>>>>>>>  11")
                self.setUI()
            }
            else {
                if arr[1] as! Int == 0 { // choose winer and sumbit score
                    self.winnerId = arr[2] as! Int == 0 ? self.hostIndex : self.opponentIndex
                    self.submitScore()
                } else if arr[1] as! Int == 1 { // tie percentage dialog
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.isFromEnterScore = true
                    dialog.titleText = Messages.tiedDamage
                    dialog.message = Messages.areYouSureTheWasTied
                    dialog.highlightString = ""
                    dialog.isFromArenaScore = true
                    dialog.tapOKForArenaScore = { isScoreSubmit in
                        if isScoreSubmit { // score submitted by other player
                            print("Call This From Here >>>>>>>>>>  12")
                            self.setUI()
                        }
                        else {
                            // single life rematch
                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
                            dialog.modalPresentationStyle = .overCurrentContext
                            dialog.modalTransitionStyle = .crossDissolve
                            dialog.score1 = self.player1Score
                            dialog.score2 = self.player2Score
                            dialog.isFromEnterScore = true
                            dialog.secondMessage = ""
                            //dialog.thirdMessage = Messages.singleLifeRematch
                            dialog.thirdMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scorePercentageTieMsg ?? ""
                            dialog.isSingleLifeRemath = true
                            dialog.tapOk = { index in
                                if index[0] as! Bool == true {
                                    print("Call This From Here >>>>>>>>>>  13")
                                    self.setUI()
                                }
                                else {
                                  //Sudden Death
                                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
                                    dialog.modalPresentationStyle = .overCurrentContext
                                    dialog.modalTransitionStyle = .crossDissolve
                                    dialog.score1 = self.player1Score
                                    dialog.score2 = self.player2Score
                                    dialog.isFromEnterScore = true
                                    //dialog.secondMessage = Messages.selectTheWinner
                                    dialog.secondMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTieMsg ?? ""
                                    dialog.thirdMessage = Messages.suddenDeath
                                    dialog.isTieBySuddenDeath = true
                                    dialog.suddenDeathWinner = index[2] as! Int
                                    dialog.tapOk = { index in
                                        if index[0] as! Bool == true {
                                            print("Call This From Here >>>>>>>>>>  14")
                                            self.setUI()
                                        }
                                        else {
                                            if index[1] as! Int == 0 {
                                                self.winnerId = index[2] as! Int == 0 ? self.hostIndex : self.opponentIndex
                                            }
                                            self.submitScore()
                                        }
                                    }
                                    if self.isScoreRemovedFromStack == false {
                                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                    }
                                }
                            }
                            if self.isScoreRemovedFromStack == false {
                                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                            }
                        }
                    }
                    dialog.tapCancel = {
                        self.tieDialog(isTie: true)
                    }
                    dialog.btnYesText = Messages.yes
                    dialog.btnNoText = Messages.close
                    if self.isScoreRemovedFromStack == false {
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                }
            }
        }
        dialog.tapDismiss = {
            self.isEnter = true
            self.isTieByMistake = true
            print("Call This From Here >>>>>>>>>>  15")
            self.setUI()
        }
        if self.isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func enterScore() {
        self.isEnter = false
        self.listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaReportScorePopupVC") as! ArenaReportScorePopupVC
        dialog.isFromEnterScore = true
        if isTieByMistake {
            dialog.tieScore = self.player1Score
            dialog.isTieByMistake = true
        }
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { arr, isMatchReset in
            if self.isTieByMistake {
                self.isTieByMistake = false
            }
            if isMatchReset {
                if arr[0] as! String == "Schedule Removed" {
                    self.scheduledRemoved()
                }
                else if arr[0] as! String == "Match Forfeit" {
                    self.navigateToArenaRoundResult()
                }
                else if arr[0] as! String == "Match Reset" {
                    self.navigateToArenaMatchReset()
                }
            }
            else if arr[0] as! Bool == true { //score submitted by other player
                print("Call This From Here >>>>>>>>>>  16")
                self.setUI()
            }
            else {
                self.player1Score = arr[2] as! String
                self.player2Score = arr[3] as! String
                if Int(self.player1Score) == Int(self.player2Score) {
                    self.tieDialog(isTie: arr[1] as! Bool)
                } else {
                    if (Int(self.player1Score) ?? 0) > (Int(self.player2Score) ?? 0) {
                        self.winnerId = self.hostIndex
                    } else {
                        self.winnerId = self.opponentIndex
                    }
                    self.submitScore()
                }
            }
        }
        dialog.tapDismiss = {
            self.btnReport.isEnabled = true
            self.btnReport.backgroundColor = Colors.theme.returnColor()
            self.isEnter = false
            print("Call This From Here >>>>>>>>>>  17")
            self.setUI()
        }
        if self.isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func updateScoreAsConfirm() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        print("Come from ArenaDisputeVC - Auto confirm.")
        var roundArr = [[String:AnyObject]]()
        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["played"] = 1 as AnyObject
        let timestamp = Date().timeIntervalSince1970
        
        print("----------------------------------")
        print("Current Tiemstamp ----> \(timestamp)")
        print("----------------------------------")
        
        let param = [
            "rounds" : roundArr,
            "status" : Messages.scoreConfirm,
            "gameStartTime": Int(timestamp)
        ] as [String: Any]
        
//        self.log.i("ArenaRoundResultVC -- updateScoreAsConfirm() - submit status and rounds to firestore -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("ArenaRoundResultVC -- updateScoreAsConfirm() - submit status and rounds to firestore -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error writing document: \(err)")
                self.updateScoreAsConfirm()
                /*DispatchQueue.main.async {
                    self.updateScoreAsConfirm()
                }   //  */
            } else {
                self.declareRoundWinner()
            }
        }
    }
    
    func confirmedEnteredScore() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        self.listner?.remove()
        let rounds = self.arrFire?.rounds ?? [Rounds]()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaConfirmRoundScorePopupVC") as! ArenaConfirmRoundScorePopupVC
        dialog.score1 = String(rounds[self.doc?.data()?["currentRound"] as! Int - 1].team1Score ?? 0)
        dialog.score2 = String(rounds[self.doc?.data()?["currentRound"] as! Int - 1].team2Score ?? 0)
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { arr, isMatchReset in
            /// 332 - By Pranay
            if isMatchReset {
                if arr[0] as? String == "Schedule Removed" {
                    self.scheduledRemoved()
                }
                else if arr[0] as? String == "Match Forfeit" {
                    self.navigateToArenaRoundResult()
                }
                else if arr[0] as? String == "Match Reset" {
                    self.navigateToArenaMatchReset()
                }
            }
            /// 332 .
            else if arr[0] as! Bool {
                print("Call This From Here >>>>>>>>>>  18")
                self.setUI()
            }
            else {
                if arr[1] as! Int == 0 { //confirm score
//                    self.log.i("Confirm reported score and call updateScoreAsConfirm. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                    self.showLoading()
                    self.updateScoreAsConfirm()
                } else { //dispute score
                    let param = [
                        "status" : Messages.dispute,
                        "disputeBy": self.arrPlayer[self.myPlayerIndex].playerId ?? 0
                    ] as [String: Any]
//                    self.log.i("Dispute reported score and update status. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if let err = err {
//                            self.log.e("Dispute reported score and update status. - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                            print("Error writing document: \(err)")
                        }
                        else {
                            print("Call This From Here >>>>>>>>>>  19")
                            self.setUI()
                        }
                    }
                }
            }
        }
        if self.isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
        
    func waitingPopup(arenaFlow: String, description: String) {
        //if screen is removed from stack then don't open dialog from this screen
        self.listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.isLoader = false
        dialog.timeSeconds = 60
        dialog.arenaFlow = arenaFlow
        dialog.descriptionString = description
        dialog.manageOnStatus = { status in
            if status == "ConfirmedRoundByOpp" {
//                self.log.i("Confirm reported score. And call setui - \(APIManager.sharedManager.user?.userName ?? "")")
                print("Call This From Here >>>>>>>>>>  20")
                self.setUI()
            }
            else if status == "MatchFinishByOpp" {
//                self.log.i("Confirm reported score. And call getLeagueMatch - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                self.isGameOver = true
                print("Get League Match Call === 4")    //  Added by Pranay.
                self.getLeagueMatch()
            }
            else if status == "" {
//                self.log.i("Waiting timer is over and call declareRoundWinner - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                //self.isGameOver = false
                self.showLoading()
                self.declareRoundWinner()
            }
            else if status == "ScorConfirmedByAdmin" {
//                self.log.i("Score confirm by admin and call setui. - \(APIManager.sharedManager.user?.userName ?? "")")
                print("Call This From Here >>>>>>>>>>  21")
                self.setUI()
            }
            else if status == "Match Reset" {
//                self.log.i("Match Reset by admin and navigateToArenaMatchReset. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
               self.navigateToArenaMatchReset()
            }
            else if status == "Schedule Removed" {
               self.scheduledRemoved()
            }
            else if status == "Match Forfeit" {
               self.navigateToArenaRoundResult()
            }
            else {
                print("Call This From Here >>>>>>>>>>  22")
                self.setUI()
            }
        }
        if isScoreRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
        
    /// 1113 - By Pranay
    func updatePlayedCharacter() {
        //// Update home player character
        var tChar: [Characters] = (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.filter({
            $0.id == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].homeCharacterId)!
        }))!
        if tChar.count > 0 {
            for i in 0 ..< (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter!.count ?? 0) {
                if (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?[i].id)! == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].homeCharacterId)! {
                    //(APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?[0].characterUseCnt)! as Int += 1
                    let no: Int = (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?[i].characterUseCnt)!
                    APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?[i].characterUseCnt = no + 1
                    break
                }
            }
        }
        else {
            if (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.count ?? 0) == 0 {
                APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.removeAll()
            }
            var tempChar: [Characters] = (APIManager.sharedManager.content?.characters?.filter({
                $0.id == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].homeCharacterId)!
            }))!
            tempChar[0].characterUseCnt = 1
            APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.append(tempChar[0])
        }
        
        //// Update away player character
        tChar.removeAll()
        tChar = (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.filter({
            $0.id == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].awayCharacterId)!
        }))!
        if tChar.count > 0 {
            for i in 0 ..< (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter!.count ?? 0) {
                if (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?[i].id)! == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].awayCharacterId)! {
                    let no: Int = (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?[i].characterUseCnt)!
                    APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?[i].characterUseCnt = no + 1
                    break
                }
            }
        } else {
            if (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.count ?? 0) == 0 {
                APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.removeAll()
            }
            var tempChar: [Characters] = (APIManager.sharedManager.content?.characters?.filter({
                $0.id == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].awayCharacterId)!
            }))!
            tempChar[0].characterUseCnt = 1
            APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.append(tempChar[0])
        }
        
        if ((self.arrPlayer[self.myPlayerIndex].host ?? 0) == 1) {
            for i in 0 ..< (APIManager.sharedManager.content?.characters?.count ?? 0) {
                if (APIManager.sharedManager.content?.characters![i].id ?? 0) == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].homeCharacterId)! {
                    let no: Int = (APIManager.sharedManager.content?.characters![i].characterUseCnt)!
                    APIManager.sharedManager.content?.characters![i].characterUseCnt = no + 1
                    break
                }
            }
        } else {
            for i in 0 ..< (APIManager.sharedManager.content?.characters?.count ?? 0) {
                if (APIManager.sharedManager.content?.characters![i].id ?? 0) == (self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 2].awayCharacterId)! {
                    let no: Int = (APIManager.sharedManager.content?.characters![i].characterUseCnt)!
                    APIManager.sharedManager.content?.characters![i].characterUseCnt = no + 1
                    break
                }
            }
        }
    }
    /// 1113 .
    
    // MARK: - Button Click Events
    @IBAction func reportTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        print("Report tap. Status - \(self.doc?.data()?["status"] as? String ?? "")")
        if self.doc?.data()?["status"] as? String == Messages.playinRound || self.doc?.data()?["status"] as? String == Messages.enteringScore {
            listner?.remove()
//            self.log.i("Report tap. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> status - \(self.doc?.data()?["status"] as? String ?? "")")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                "status": Messages.enteringScore
            ]) { err in
                if let err = err {
//                    self.log.e("Report tap. Status not updated in firestore. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                    print("Else part of Report tap. Status - \(self.doc?.data()?["status"] as? String)")
                    print("Error writing document: \(err)")
                }
                else {
                    self.btnReport.isEnabled = false
                    self.btnReport.backgroundColor = Colors.border.returnColor()
                    self.isEnter = true
                    print("Call This From Here >>>>>>>>>>  23")
                    self.setUI()
                }
            }
        }
    }
    
    @IBAction func infoTapped(_ sender: UIButton) {
    }
    
    @IBAction func navigateToSchedule(_ sender: UIButton) {
//        let matchId = APIManager.sharedManager.match?.matchId ?? 0
//        let matchNo = APIManager.sharedManager.match?.matchNo ?? 0
//        self.leagueTabVC!().navigateToBracket(matchId: matchId, matchNo: matchNo)
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
            }
            else {
                let arenaMatchResetVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaMatchResetVC") as! ArenaMatchResetVC
                arenaMatchResetVC.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(arenaMatchResetVC, animated: true)
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
        return
    }
}

// MARK: - UICollectionViewDelegate
extension ArenaRoundResultVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return (leaderboardData?.count ?? 0) + 2
        //return APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count != 0 ? (leaderboardData?.count ?? 0) + 2 : (leaderboardData?.count ?? 0) + 1
        return APIManager.sharedManager.stagePickBan ?? "" == "Yes" ? (leaderboardData?.count ?? 0) + 2 : (leaderboardData?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0
        {
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
            
            //cell.backgroundColor = Colors.blueTheme.returnColor()
            cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
            
            return cell
        }
        else if indexPath.section == (leaderboardData.count + 1)
        {
            if(indexPath.row == 0)
            {
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
                
                //cell.backgroundColor = Colors.blueTheme.returnColor()
                cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
                
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                cell.ivCheck.isHidden = true
                
                if rowHeaders != nil
                {
//                    cell.ivIcon.hideSkeleton()
                    
                    if self.doc?.data()?["status"] as? String == Messages.matchFinished
                    {
                        if indexPath.row <= self.arrFire?.currentRound ?? 0
                        {
                            if self.arrFire?.rounds?[indexPath.row - 1].played == 1
                            {
                                cell.ivIcon.setCharacter(imageUrl: (self.arrFire?.rounds?[indexPath.row - 1].finalStage?.imagePath == nil) ? "" : (self.arrFire?.rounds?[indexPath.row - 1].finalStage?.imagePath ?? ""))
                            }
                            else
                            {
                                cell.ivIcon.sd_setImage(with: URL(string: ""))
                            }
                        }
                        else
                        {
                            cell.ivIcon.sd_setImage(with: URL(string: ""))
                        }
                    }
                    else
                    {
                        if indexPath.row <= self.arrFire?.currentRound ?? 0
                        {
                            cell.ivIcon.setCharacter(imageUrl: (self.arrFire?.rounds?[indexPath.row - 1].finalStage?.imagePath == nil) ? "" : (self.arrFire?.rounds?[indexPath.row - 1].finalStage?.imagePath ?? ""))
                        }
                        else
                        {
                            cell.ivIcon.setCharacter(imageUrl: "")
                        }
                    }
                    
                    if(indexPath.row == rowHeaders.count - 1)
                    {
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
        }
        else
        {
            if indexPath.row == 0
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultUsersCVCell",
                for: indexPath) as! ResultUsersCVCell
                
                if rowHeaders != nil
                {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] as? String
                    cell.ivPlayer.setImage(imageUrl: leaderboardData[indexPath.section - 1]["avatarImage"] as! String)
                    cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.width/2
                }
                else
                {
                    cell.lblPlayerName.text = ""
//                    cell.showAnimation()
                }
                return cell
            }
            else if indexPath.row == rowHeaders.count - 1
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                
                if rowHeaders != nil
                {
//                    cell.hideAnimation()
                    let row = leaderboardData[indexPath.section - 1]
                    
                    if doc?.data() != nil
                    {
                        if doc?.data()?["matchForfeit"] as! Int == 1
                        {
                            cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)" == "" ? "-" : "\(row[rowHeaders[indexPath.row]]!)"
                        }
                        else
                        {
                            if self.arrFire?.currentRound != 1
                            {
                                cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)" == "" ? "-" : "\(row[rowHeaders[indexPath.row]]!)"
                            }
                            else
                            {
                                cell.contentLabel.text = "-"
                            }
                        }
                    }
                    else
                    {
                        if self.arrFire?.currentRound != 1
                        {
                            cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)" == "" ? "-" : "\(row[rowHeaders[indexPath.row]]!)"
                        }
                        else
                        {
                            cell.contentLabel.text = "-"
                        }
                    }
                }
                else
                {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                if rowHeaders != nil
                {
//                    cell.ivIcon.hideSkeleton()
                    
                    if self.doc?.data()?["status"] as? String == Messages.matchFinished
                    {
                        if self.arrFire?.rounds?[indexPath.row - 1].played == 1
                        {
                            cell.ivIcon.setCharacter(imageUrl: (leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] ?? "") as! String)
                        }
                        else
                        {
                            cell.ivIcon.sd_setImage(with: URL(string: ""))
                        }
                    }
                    else
                    {
                        cell.ivIcon.setCharacter(imageUrl: (leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] ?? "") as! String)
                    }
                    
                    cell.lblScore.text = leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as? String
                    cell.ivWidthConst.constant = 25
                    
                    if indexPath.section == 1
                    {
                        cell.lblScoreBottom.constant = 4.5
                        cell.ivIconTop.constant = 4
                    }
                    else
                    {
                        cell.lblScoreBottom.constant = 36
                        cell.ivIconTop.constant = 27
                    }
                    
                    if leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as! String == "-"
                    {
                        cell.ivCheck.isHidden = true
                    }
                    else if(self.arrFire?.rounds?[indexPath.row - 1].winnerTeamId != nil)
                    {
                        if indexPath.section == 1
                        {
                            if self.arrFire?.rounds?[indexPath.row - 1].winnerTeamId == self.arrPlayer[self.hostIndex].teamId
                            {
                                cell.ivCheck.isHidden = false
                            }
                            else
                            {
                                cell.ivCheck.isHidden = true
                            }
                        }
                        else
                        {
                            if self.arrFire?.rounds?[indexPath.row - 1].winnerTeamId == self.arrPlayer[self.opponentIndex].teamId
                            {
                                cell.ivCheck.isHidden = false
                            }
                            else
                            {
                                cell.ivCheck.isHidden = true
                            }
                        }
                    }
                }
                else
                {
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

// MARK: Webservices
extension ArenaRoundResultVC {
    
    //  By Pranay
    func acceptByAdmin() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.acceptByAdmin()
                }
            }
            return
        }
        
        var sc = [[String:Any]]()
        let p1 = ["userId" : self.arrFire?.playerDetails?[self.hostIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.hostIndex].teamId,
                  "stock" : self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 1].team1Score
        ]
        let p2 = ["userId" : self.arrFire?.playerDetails?[self.opponentIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.opponentIndex].teamId,
                  "stock" : self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 1].team2Score
        ]
        sc.append(p1 as [String : Any])
        sc.append(p2 as [String : Any])
        
        if ((self.arrFire?.playerDetails?[self.hostIndex].teamId ?? 0) == self.arrFire?.rounds?[self.doc?.data()?["currentRound"] as! Int - 1].winnerTeamId ?? 0) {
            winnerId = self.hostIndex
        } else {
            winnerId = self.opponentIndex
        }
        let loser = winnerId == 0 ? 1 : 0
        
        var id = 0
        var isWinnerDecided = false
        var matchStatus = ""
        if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count {
            matchStatus = Messages.matchFinished
        } else {
            if self.doc?.data()?["currentRound"] as! Int >= ((self.arrFire?.rounds!.count)! / 2) + 1 {
                var hostWinner = 0
                var oppoWinner = 0
                for i in 0 ..< (self.doc?.data()?["currentRound"] as! Int){
                    if i == 0 {
                        id = self.arrFire?.rounds?[i].winnerTeamId ?? 0
                    }
                    if (self.arrPlayer[self.hostIndex].teamId == self.arrFire?.rounds?[i].winnerTeamId ?? 0) {
                        hostWinner += 1
                    } else {
                        oppoWinner += 1
                    }
                }
                if ((hostWinner == ((self.arrFire?.rounds!.count)! / 2) + 1) && (oppoWinner < hostWinner)) || ((oppoWinner == ((self.arrFire?.rounds!.count)! / 2) + 1) && (hostWinner < oppoWinner)) {
                    isWinnerDecided = true
                }
            }
            
            if isWinnerDecided && id != 0 {
                matchStatus = Messages.matchFinished
            } else {
                matchStatus = ""
            }
        }
        
        if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count {
            //self.getLeagueMatch()   //  Comment by Pranay
            self.getNextMatch() //  By Pranay - Added
        } else {
            if matchStatus != "" {
                self.getNextMatch() //  By Pranay - Added
            } else {
                DispatchQueue.main.async {
                    var roundIs = 0
                    if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count {
                        roundIs = self.doc?.data()?["currentRound"] as! Int
                    } else {
                        roundIs = self.doc?.data()?["currentRound"] as! Int + 1
                    }
                    
                    let bannSt = [[String:AnyObject]]()
                    var playerArr = [[String:AnyObject]]()
                    playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    playerArr[self.myPlayerIndex]["rpc"] = "" as AnyObject
                    playerArr[self.opponent]["rpc"] = "" as AnyObject
                    playerArr[self.myPlayerIndex]["characterCurrent"] = false as AnyObject
                    playerArr[self.opponent]["characterCurrent"] = false as AnyObject
                    
                    if APIManager.sharedManager.customStageCharSettings?.charSelectByWinner ?? 0 == 1 {
                        playerArr[self.winnerId]["characterCurrent"] = true as AnyObject
                        print("Winning player's character auto select from previous winning char.-- \(self.winnerId)")
                    }
                    
                    playerArr[self.myPlayerIndex]["dispute"] = 0 as AnyObject
                    playerArr[self.opponent]["dispute"] = 0 as AnyObject
                    
                    var disputeScore = [String:AnyObject]()
                    disputeScore = [
                        "team1Score": Int(0) as AnyObject,
                        "team2Score" : Int(0) as AnyObject,
                        "winnerTeamId" : 0
                    ] as [String:AnyObject]
                    
                    playerArr[self.myPlayerIndex]["disputeScore"] = disputeScore as AnyObject
                    playerArr[self.opponent]["disputeScore"] = disputeScore as AnyObject
                    
                    // By Pranay
                    /// This will set user id to go for stage pic ban in normal flow.
                    var stagePicBanPlayerId : Int = self.arrFire?.playerDetails?[self.winnerId].playerId! ?? 0
                    
                    /// In this when playing round is more then 3 ( like 5 ) and game is SSBM that time only loser select playing round and go on.
                    /*if APIManager.sharedManager.gameId == 13 && ((self.arrFire?.rounds?.count)! > 3) {
                        stagePicBanPlayerId = self.arrFire?.playerDetails?[loser].playerId! ?? 0
                    }   //  */
                    
                    //if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! != 0 {
                    if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                        var nextRound : Int = 0
                        if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! >= roundIs {
                            //nextRound = (self.arrFire?.currentRound)! - 1
                            nextRound = roundIs - 1
                        } else {
                            nextRound = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! - 1
                        }
                        
                        if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![nextRound].firstBanBy != nil {
                            if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![nextRound].firstBanBy == "L" {
                                stagePicBanPlayerId = self.arrFire?.playerDetails?[loser].playerId! ?? 0
                            }
                        }
                    }
                    // .
                    
                    let param = [
                        "status": Messages.waitingToStagePickBan,
                        "currentRound" : roundIs,
                        "disputeImagePath" : "",
                        "enteredScoreBy" : 0,
                        "readyToStagePickBanBy" : 0,
                        "disputeBy" : 0,
                        "bannedStages" : bannSt,
                        "playerDetails" : playerArr,
                        "stagePicBanPlayerId": stagePicBanPlayerId,  //self.arrFire?.playerDetails?[self.winnerId].playerId!,   - By Pranay comment and add variable.
                        "disputeConfirmBy" : 0,
                        "manualUpdate" : 0,
                        "banRound" : 0
                    ] as [String: Any]
                    
//                    self.log.i("ArenaRoundResultVC - acceptByAdmin() 'Update firstore data' - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if let err = err {
//                            self.log.e("ArenaRoundResultVC - acceptByAdmin() 'Update firstore data fail' - \(APIManager.sharedManager.user?.userName ?? ""). Error-> \(err)")  //  By Pranay.
                            print("Error writing document: \(err)")
                        }
                        else {
                            print("Call This From Here >>>>>>>>>>  24")
                            self.setUI()
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.btnReport.isEnabled = false
            self.btnReport.backgroundColor = Colors.border.returnColor()
        }
        
    }
    //.
    
    func declareRoundWinner() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.declareRoundWinner()
                }
            }
            return
        }
        
        var sc = [[String:Any]]()
        let p1 = ["userId" : self.arrFire?.playerDetails?[self.hostIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.hostIndex].teamId,
                  "stock" : self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 1].team1Score
        ]
        let p2 = ["userId" : self.arrFire?.playerDetails?[self.opponentIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.opponentIndex].teamId,
                  "stock" : self.arrFire?.rounds?[(self.doc?.data()?["currentRound"] as! Int) - 1].team2Score
        ]
        sc.append(p1 as [String : Any])
        sc.append(p2 as [String : Any])
        
        if ((self.arrFire?.playerDetails?[self.hostIndex].teamId ?? 0) == self.arrFire?.rounds?[self.doc?.data()?["currentRound"] as! Int - 1].winnerTeamId ?? 0) {
            winnerId = self.hostIndex
        } else {
            winnerId = self.opponentIndex
        }
        let loser = winnerId == 0 ? 1 : 0
        
        var id = 0
        var isWinnerDecided = false
        var matchStatus = ""
        if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count {
            matchStatus = Messages.matchFinished
        }
        else {
            if self.doc?.data()?["currentRound"] as! Int >= ((self.arrFire?.rounds!.count)! / 2) + 1 {
                //if self.doc?.data()?["currentRound"] as! Int >= self.doc?.data()?["bestWinRound"] as! Int {
                var hostWinner = 0
                var oppoWinner = 0
                for i in 0 ..< (self.doc?.data()?["currentRound"] as! Int){
                    if i == 0 {
                        id = self.arrFire?.rounds?[i].winnerTeamId ?? 0
                    }
                    if (self.arrPlayer[self.hostIndex].teamId == self.arrFire?.rounds?[i].winnerTeamId ?? 0) {
                        hostWinner += 1
                    } else {
                        oppoWinner += 1
                    }
                }
                if ((hostWinner == ((self.arrFire?.rounds!.count)! / 2) + 1) && (oppoWinner < hostWinner)) || ((oppoWinner == ((self.arrFire?.rounds!.count)! / 2) + 1) && (hostWinner < oppoWinner)) {
                    isWinnerDecided = true
                }
            }
            
            if isWinnerDecided && id != 0 {
                matchStatus = Messages.matchFinished
            } else {
                matchStatus = ""
            }
        }
        //let matchDispute = UserDefaults.standard.object(forKey: "isDispute") != nil ? UserDefaults.standard.integer(forKey: "isDispute") : 0
        let matchDispute = 0
        print("Reached here after auto confirm--------    1")
        
        var rpsKey: String = "homeRPS"
        var rpsKey1: String = "awayRPS"
        var rpsKeyValue: String = ""
        var rpsKeyValue1: String = ""
        var rpsWinner: Int = 0
        
        var bannedStagesKey: String = "homeBannedStages"
        var bannedStagesKey1: String = "awayBannedStages"
        
        let homePlayerId: Int = (self.arrFire?.playerDetails?[self.myPlayerIndex].host ?? 0) == 1 ? (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId ?? 0) : (self.arrFire?.playerDetails?[self.opponent].playerId ?? 0)
        //let awayPlayerId: Int = (self.arrFire?.playerDetails?[self.opponent].host ?? 0) == 0 ? (self.arrFire?.playerDetails?[self.opponent].playerId ?? 0) : (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId ?? 0)
        let awayPlayerId: Int = (self.arrFire?.playerDetails?[self.opponent].host ?? 0) == 1 ? (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId ?? 0) : (self.arrFire?.playerDetails?[self.opponent].playerId ?? 0)
        
        if self.myPlayerIndex == self.hostIndex {
            if (self.arrFire?.currentRound ?? 0) == 1 {
                rpsKeyValue = (self.arrFire?.playerDetails?[self.myPlayerIndex].rpc) ?? ""
                rpsKeyValue1 = (self.arrFire?.playerDetails?[self.opponent].rpc) ?? ""
                
                rpsWinner = (selectWinner(firstValue: (self.arrFire?.playerDetails?[self.myPlayerIndex].rpc) ?? "", secondValue: (self.arrFire?.playerDetails?[self.opponent].rpc) ?? "")) ? (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId) ?? 0 : (self.arrFire?.playerDetails?[self.opponent].playerId) ?? 0
            }
        }
        else {
            rpsKey = "awayRPS"
            rpsKey1 = "homeRPS"
            bannedStagesKey = "awayBannedStages"
            bannedStagesKey1 = "homeBannedStages"
            
            if (self.arrFire?.currentRound ?? 0) == 1 {
                rpsKeyValue = (self.arrFire?.playerDetails?[self.myPlayerIndex].rpc) ?? ""
                rpsKeyValue1 = (self.arrFire?.playerDetails?[self.opponent].rpc) ?? ""
                
                rpsWinner = (selectWinner(firstValue: (self.arrFire?.playerDetails?[self.myPlayerIndex].rpc) ?? "", secondValue: (self.arrFire?.playerDetails?[self.opponent].rpc) ?? "")) ? (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId) ?? 0 : (self.arrFire?.playerDetails?[self.opponent].playerId) ?? 0
            }
        }
        
        let tempBannedStages = self.arrFire?.bannedStages ?? []
        var myBannedStages: [Int] = []
        var opponentBannedStages: [Int] = []
        
        for (_, stage) in tempBannedStages.enumerated() {
            if stage.playerId == (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId) ?? 0 {
                myBannedStages.append(stage.stageId ?? 0)
            }
            else {
                opponentBannedStages.append(stage.stageId ?? 0)
            }
        }
        
        let param = [
            "leagueId": (APIManager.sharedManager.match?.leagueId) ?? 0,
            "matchId": (APIManager.sharedManager.match?.matchId) ?? 0,
            "roundId": (self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].roundId) ?? 0,
            "winnerUserId": (self.arrFire?.playerDetails?[self.winnerId].playerId) ?? 0,
            "losserUserId": (self.arrFire?.playerDetails?[loser].playerId) ?? 0,
            "score": sc,
            "homeCharacterId": (self.arrFire?.playerDetails?[self.hostIndex].characterId) ?? 0,
            "awayCharacterId": (self.arrFire?.playerDetails?[self.opponentIndex].characterId) ?? 0,
            "stageId": (self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].finalStage?.id) ?? 0,
            "matchStatus": matchStatus,
            "matchDispute": matchDispute,
            "stageSelectedBy": (self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].finalStage?.playerId) ?? 0,
            rpsKey: rpsKeyValue,
            rpsKey1: rpsKeyValue1,
            "rpsWinner": rpsWinner,
            bannedStagesKey: myBannedStages,
            bannedStagesKey1: opponentBannedStages,
            "homePlayerId": homePlayerId,
            "awayPlayerId": awayPlayerId,
            "device": "ios"
        ] as [String: Any]
        
//        self.log.i("Declare round winner call. RoundId ->\((self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].roundId) ?? 0) -- \(APIManager.sharedManager.user?.userName ?? "") -- Param -> \(param)")
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DECLARE_ROUND_WINNER, parameters: param
        ){ (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
//                self.log.i("Declare round winner call success. -- RoundId ->\((self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].roundId) ?? 0) -- \(APIManager.sharedManager.user?.userName ?? "") = \(response?.result)")  //  By Pranay.
                
                if (response?.result?.isFinish ?? 0 == 1) {
                    /// Update firestore and get next match scheduled, because match finish.
//                    self.log.i("Declare round winner success isFinish = 1  -- RoundId ->\((self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].roundId) ?? 0) -- \(APIManager.sharedManager.user?.userName ?? "") = \(response?.result)")  //  By Pranay.
                    self.getNextMatch()
                }
                else if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count {
                    self.getNextMatch() //  By Pranay - Added
                }
                else {
                    if matchStatus != "" {
                        self.getNextMatch() //  By Pranay - Added
                    }
                    else {
                        DispatchQueue.main.async {
                            self.listner?.remove()  //  Added by Pranay.
                            var roundIs = 0
                            if self.doc?.data()?["currentRound"] as? Int == self.arrFire?.rounds?.count{
                                roundIs = self.doc?.data()?["currentRound"] as! Int
                            }
                            else {
                                roundIs = self.doc?.data()?["currentRound"] as! Int + 1
                            }
                            
                            let bannSt = [[String:AnyObject]]()
                            var playerArr = [[String:AnyObject]]()
                            playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                            //playerArr[self.myPlayerIndex]["rpc"] = "" as AnyObject
                            //playerArr[self.opponent]["rpc"] = "" as AnyObject
                            playerArr[self.myPlayerIndex]["characterCurrent"] = false as AnyObject
                            playerArr[self.opponent]["characterCurrent"] = false as AnyObject
                            
                            // By Pranay
                            playerArr[self.myPlayerIndex]["dispute"] = 0 as AnyObject
                            playerArr[self.opponent]["dispute"] = 0 as AnyObject
                            
                            if APIManager.sharedManager.customStageCharSettings?.charSelectByWinner ?? 0 == 1 {
                                playerArr[self.winnerId]["characterCurrent"] = true as AnyObject
                                print("Winning player's character auto select from previous winning char.-- \(self.winnerId)")
                            }
                            
                            var disputeScore = [String:AnyObject]()
                            disputeScore = [
                                "team1Score": Int(0) as AnyObject,
                                "team2Score" : Int(0) as AnyObject,
                                "winnerTeamId" : 0,
                                "disputeImagePath" : ""
                            ] as [String:AnyObject]
                            
                            playerArr[self.myPlayerIndex]["disputeScore"] = disputeScore as AnyObject
                            playerArr[self.opponent]["disputeScore"] = disputeScore as AnyObject
                            
                            /// This will set user id to go for stage pic ban in normal flow.
                            var stagePicBanPlayerId : Int = self.arrFire?.playerDetails?[self.winnerId].playerId! ?? 0
                            if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                                var nextRound : Int = 0
                                if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! >= roundIs {
                                    //nextRound = (self.arrFire?.currentRound)! - 1
                                    nextRound = roundIs - 1
                                }
                                else {
                                    nextRound = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! - 1
                                }
                                
                                if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![nextRound].firstBanBy != nil {
                                    if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![nextRound].firstBanBy == "L" {
                                        stagePicBanPlayerId = self.arrFire?.playerDetails?[loser].playerId! ?? 0
                                    }
                                }
                            }
                            //.
                            
                            print("Reached here after auto confirm--------    3")
                            
                            var bannedStagesKey: String = "homeBannedStages"
                            var bannedStagesKey1: String = "awayBannedStages"
                            
                            if self.myPlayerIndex != self.hostIndex {
                                bannedStagesKey = "awayBannedStages"
                                bannedStagesKey1 = "homeBannedStages"
                            }
                            
                            var banStages = self.setHomeAwayBannedStages()
                            
                            let param = [
                                "status": Messages.waitingToStagePickBan,
                                "currentRound" : roundIs,
                                "disputeImagePath" : "",
                                "enteredScoreBy" : 0,
                                "readyToStagePickBanBy" : 0,
                                "disputeBy" : 0,
                                "bannedStages" : bannSt,
                                "playerDetails" : playerArr,
                                "stagePicBanPlayerId": stagePicBanPlayerId, //self.arrFire?.playerDetails?[self.winnerId].playerId! ?? 0
                                "disputeConfirmBy" : 0,
                                "manualUpdate" : 0,
                                "banRound" : 0,
                                bannedStagesKey : banStages[0],
                                bannedStagesKey1 : banStages[1]
                            ] as [String: Any]
                            
//                            self.log.i("ArenaRoundResultVC - declareRoundWinner() 'Update firstore data' - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                if let err = err {
//                                    self.log.e("ArenaRoundResultVC - declareRoundWinner() 'Update firstore data' - \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                                }
                                else {
                                    self.listner?.remove()
                                    print("Call This From Here >>>>>>>>>>  25")
                                    self.setUI()
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.btnReport.isEnabled = false
                    self.btnReport.backgroundColor = Colors.border.returnColor()
                }
            } 
            else {
//                self.log.e("Declare round winner call fail. - \(APIManager.sharedManager.user?.userName ?? "") = \(response?.result)")  //  By Pranay.
                DispatchQueue.main.async {
                    print("Reached here after auto confirm--------    5")
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    print("Call This From Here >>>>>>>>>>  26")
                    self.setUI()
                    self.btnReport.isEnabled = true
                    self.btnReport.backgroundColor = Colors.theme.returnColor()
                }
            }
        }
    }
    
    func setHomeAwayBannedStages() -> [[String: [Int]]] {
        
        var tempBannedStagesKeyValue = [String: [Int]]()
        var tempBannedStagesKeyValue1 = [String: [Int]]()
        
        if self.myPlayerIndex == self.hostIndex {
            var temp = (self.arrFire?.homeBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue = temp
            }
            temp.removeAll()
            temp = (self.arrFire?.awayBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue1 = temp
            }
        }
        else {
            var temp = (self.arrFire?.awayBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue = temp
            }
            temp.removeAll()
            temp = (self.arrFire?.homeBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue1 = temp
            }
        }
        
        let tempBannedStages = self.arrFire?.bannedStages ?? []
        var myBannedStages: [Int] = []
        var opponentBannedStages: [Int] = []
        
        for (_, stage) in tempBannedStages.enumerated() {
            if stage.playerId == (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId) ?? 0 {
                myBannedStages.append(stage.stageId ?? 0)
            }
            else {
                opponentBannedStages.append(stage.stageId ?? 0)
            }
        }
        
        let round = String(describing: self.doc?.data()?["currentRound"] ?? "")
        if myBannedStages.count > 0 {
            //tempBannedStagesKeyValue.append(myBannedStages)
            tempBannedStagesKeyValue[round] = myBannedStages
        }
        if opponentBannedStages.count > 0 {
            tempBannedStagesKeyValue1[round] = opponentBannedStages
        }
        
        var myBanStages = [String: [Int]]()
        var oppoBanStages = [String: [Int]]()
        do {
            let encodedData = try JSONEncoder().encode(tempBannedStagesKeyValue)
            let encodedData1 = try JSONEncoder().encode(tempBannedStagesKeyValue1)
            
            let jsonString = String(data: encodedData,encoding: .utf8)
            let jsonString1 = String(data: encodedData1,encoding: .utf8)
            
            if let data = jsonString?.data(using: String.Encoding.utf8) {
                myBanStages = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [Int]] ?? [:]
            }
            
            if let data1 = jsonString1?.data(using: String.Encoding.utf8) {
                oppoBanStages = try JSONSerialization.jsonObject(with: data1, options: []) as? [String: [Int]] ?? [:]
            }
        } catch {
            print("error")
        }
        
        return [myBanStages, oppoBanStages]
        
//        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
//            if let err = err {
//                print("Firebase update call Fail - Param --> ", param)
//            }
//            else {
//                print("Firebase update call - Param --> ", param)
//            }
//        }
    }
    
    func selectWinner(firstValue: String, secondValue: String) -> Bool {
        if((firstValue == "R" && secondValue == "P") || (firstValue == "P" && secondValue == "R")) {   // winner P
            if firstValue == "P" {
                return true
            }
            else {
                return false
            }
        }
        else if((firstValue == "S" && secondValue == "P") || (firstValue == "P" && secondValue == "S")) {   // winner S
            if firstValue == "S" {
                return true
            }
            else {
                return false
            }
        }
        else { // winner R
            if firstValue == "R" {
                return true
            }
            else {
                return false
            }
        }
    }
    
    func getNextMatch()
    {
        self.listner?.remove()
        let bannSt = [[String:AnyObject]]()
        
        /*var bannedStagesKey: String = "homeBannedStages"
        var bannedStagesKey1: String = "awayBannedStages"
        var tempBannedStagesKeyValue = [String: [Int]]()
        var tempBannedStagesKeyValue1 = [String: [Int]]()
        
        if self.myPlayerIndex == self.hostIndex {
            var temp = (self.arrFire?.homeBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue = temp
            }
            temp.removeAll()
            temp = (self.arrFire?.awayBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue1 = temp
            }
        }
        else {
            bannedStagesKey = "awayBannedStages"
            bannedStagesKey1 = "homeBannedStages"
            
            var temp = (self.arrFire?.awayBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue = temp
            }
            temp.removeAll()
            temp = (self.arrFire?.homeBannedStages) ?? [:]
            if temp.count > 0 {
                tempBannedStagesKeyValue1 = temp
            }
        }
        
        let tempBannedStages = self.arrFire?.bannedStages ?? []
        var myBannedStages: [Int] = []
        var opponentBannedStages: [Int] = []
        
        for (_, stage) in tempBannedStages.enumerated() {
            if stage.playerId == (self.arrFire?.playerDetails?[self.myPlayerIndex].playerId) ?? 0 {
                myBannedStages.append(stage.stageId ?? 0)
            }
            else {
                opponentBannedStages.append(stage.stageId ?? 0)
            }
        }
        
        let round = String(describing: self.doc?.data()?["currentRound"] ?? "")
        if myBannedStages.count > 0 {
            //tempBannedStagesKeyValue.append(myBannedStages)
            tempBannedStagesKeyValue[round] = myBannedStages
        }
        if opponentBannedStages.count > 0 {
            tempBannedStagesKeyValue1[round] = opponentBannedStages
        }
        
        var myBanStages = [String: [Int]]()
        var oppoBanStages = [String: [Int]]()
        do {
            let encodedData = try JSONEncoder().encode(tempBannedStagesKeyValue)
            let encodedData1 = try JSONEncoder().encode(tempBannedStagesKeyValue1)
            
            let jsonString = String(data: encodedData,encoding: .utf8)
            let jsonString1 = String(data: encodedData1,encoding: .utf8)
            
            if let data = jsonString?.data(using: String.Encoding.utf8) {
                myBanStages = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [Int]] ?? [:]
            }
            
            if let data1 = jsonString1?.data(using: String.Encoding.utf8) {
                oppoBanStages = try JSONSerialization.jsonObject(with: data1, options: []) as? [String: [Int]] ?? [:]
            }
        } catch {
            print("error")
        }   //  */
        
        var bannedStagesKey: String = "homeBannedStages"
        var bannedStagesKey1: String = "awayBannedStages"
        var tempBannedStagesKeyValue = [String: [Int]]()
        var tempBannedStagesKeyValue1 = [String: [Int]]()
        
        if self.myPlayerIndex != self.hostIndex {
            bannedStagesKey = "awayBannedStages"
            bannedStagesKey1 = "homeBannedStages"
        }
        
        var banStages = self.setHomeAwayBannedStages()
        
        let param = [
            "status": Messages.matchFinished,
            "enteredScoreBy" : 0,
            "readyToStagePickBanBy" : 0,
            "disputeBy" : 0,
            "disputeConfirmBy" : 0,
            "manualUpdate" : 0,
            "bannedStages" : bannSt,
            bannedStagesKey : banStages[0],
            bannedStagesKey1 : banStages[1]
        ] as [String : Any]
        
//        self.log.i("ArenaRoundResultVC - getNextMatch() 'Update firstore data' - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param).")  //  By Pranay.
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("ArenaRoundResultVC - getNextMatch() 'Update firstore data' - \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                print("Error writing document: \(err)")
                print("Call This From Here >>>>>>>>>>  27")
                self.setUI()
            }
            else {
                self.getLeagueMatch()
            }
        }
    }
    
    func matchForfeitByAdmin() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.matchForfeitByAdmin()
                }
            }
            return
        }
        if APIManager.sharedManager.match?.leagueId != 0 {
            showLoading()
//            self.log.i("matchForfeitByAdmin API call GET_LEAGUE_MATCHES. - \(APIManager.sharedManager.user?.userName ?? "") --")  //  By Pranay.
            APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_MATCHES, parameters: ["leagueId" : APIManager.sharedManager.match?.leagueId ?? 0, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
                if response?.status == 1 {
//                    self.log.i("matchForfeitByAdmin API call GET_LEAGUE_MATCHES. Success - \(APIManager.sharedManager.user?.userName ?? "") -- response->\(response)")  //  By Pranay.
                    self.hideLoading()
                    DispatchQueue.main.async {
                        //self.hideLoading()
                        UserDefaults.standard.set(0, forKey: "isDispute")
                        APIManager.sharedManager.match = (response?.result?.match)!
                        if APIManager.sharedManager.match != nil {
                            if APIManager.sharedManager.match?.matchId != nil && APIManager.sharedManager.match?.matchId != 0 && APIManager.sharedManager.match?.leagueId != 0 {
                                if APIManager.sharedManager.match?.awayTeamId != 0 {
                                    //let player2Team = (response?.result?.match?.awayTeam?.teamName ?? "").count > 30 ? String((response?.result?.match?.awayTeam?.teamName ?? "")[..<(response?.result?.match?.awayTeam?.teamName ?? "").index((response?.result?.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (response?.result?.match?.awayTeam?.teamName ?? "")
                                    // By Pranay
                                    let player2Team = (APIManager.sharedManager.match?.awayTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.awayTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.awayTeam?.teamName ?? "").index((APIManager.sharedManager.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.awayTeam?.teamName ?? "")
                                    // .
                                    if APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 {
                                        self.lblNextPlayer2.text = APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? ""  //  Update by Pranay.
                                    } else {
                                        var name = ""
                                        if APIManager.sharedManager.match?.awayTeamPlayers?.count ?? 0 > 0 {
                                            name = APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? ""
                                        }
                                        var awayShort = player2Team.count > 30 ? String(player2Team[..<player2Team.index(player2Team.startIndex, offsetBy: 30)]) : player2Team
                                        awayShort = player2Team.count > 30 ? (awayShort + "...") : player2Team
                                        let finalName = "\(awayShort)\n\(name)"
                                        self.lblNextPlayer2.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                                    }
                                    self.imgNextPlayer2.setImage(imageUrl: response?.result?.match?.awayTeam?.awayImage ?? "")
                                } else {
                                    self.lblNextPlayer2.text = response?.result?.match?.parentAwayTeamWinnerLabel
                                    self.imgNextPlayer2.setImage(imageUrl: "")
                                }

                                if APIManager.sharedManager.match?.homeTeamId != 0 {
                                    //let player1Team = (response?.result?.match?.homeTeam?.teamName ?? "").count > 30 ? String((response?.result?.match?.homeTeam?.teamName ?? "")[..<(response?.result?.match?.homeTeam?.teamName ?? "").index((response?.result?.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (response?.result?.match?.homeTeam?.teamName ?? "")
                                    // By Pranay
                                    let player1Team = (APIManager.sharedManager.match?.homeTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.homeTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.homeTeam?.teamName ?? "").index((APIManager.sharedManager.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.homeTeam?.teamName ?? "")
                                    // .
                                    if APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 {
                                        self.lblNextPlayer1.text = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""  //  Update by Pranay.
                                    } else {
                                        var name = ""
                                        if APIManager.sharedManager.match?.homeTeamPlayers?.count ?? 0 > 0 {
                                            name = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""
                                        }
                                        var homeShort = player1Team.count > 30 ? String(player1Team[..<player1Team.index(player1Team.startIndex, offsetBy: 30)]) : player1Team
                                        homeShort = player1Team.count > 30 ? (homeShort + "...") : player1Team

                                        let finalName = "\(homeShort)\n\(name)"
                                        self.lblNextPlayer1.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                                    }
                                    self.imgNextPlayer1.setImage(imageUrl: response?.result?.match?.homeTeam?.homeImage ?? "")
                                } else {
                                    self.imgNextPlayer1.setImage(imageUrl: "")
                                    self.lblNextPlayer1.text = response?.result?.match?.parentHomeTeamWinnerLabel
                                }

                                self.lblNextGame.text = APIManager.sharedManager.leagueType != "League" ? response?.result?.match?.nextMatchRoundLabel : response?.result?.match?.league?.leagueName
                                if response?.result?.match?.onlyDate == "" || response?.result?.match?.onlyDate == "TBD" {
                                    self.lblNextMatchTime.text = "TBD"
                                } else {
                                    self.lblNextMatchTime.text = "\(response?.result?.match?.onlyDate ?? "")\n\(response?.result?.match?.onlyTime ?? "")"
                                }
                                self.viewBottom.isHidden = false
                                self.viewBottomHeightConst.constant = 250

                                if APIManager.sharedManager.leagueType != "League" {
                                    var myIdWinner = 0
                                    var oppIdWinner = 0
                                    for j in 0 ..< (self.arrFire?.rounds?.count ?? 0) {
                                        if self.arrFire?.rounds?[j].winnerTeamId == self.arrPlayer[self.myPlayerIndex].teamId {
                                            myIdWinner += 1
                                        } else {
                                            oppIdWinner += 1
                                        }
                                    }
                                    if APIManager.sharedManager.eliminationType == "Double Elimination" {
                                    }
                                    else if myIdWinner > oppIdWinner {
                                        self.viewBottom.isHidden = false
                                        self.viewBottomHeightConst.constant = 250
                                    } else {
                                        self.viewBottom.isHidden = true
                                        self.viewBottomHeightConst.constant = 0
                                    }
                                }
                            } else { //  Else part added by Pranay.
                                self.viewStageDetail.isHidden = false
                                self.viewStageDetailHeightConst.constant = 0
                                self.viewBottom.isHidden = true
                                self.viewBottomHeightConst.constant = 0
                            }
                        } else { //  Else part added by Pranay.
                            self.viewStageDetail.isHidden = false
                            self.viewStageDetailHeightConst.constant = 0
                            self.viewBottom.isHidden = true
                            self.viewBottomHeightConst.constant = 0
                        }
                        self.isFromHome = false
                        self.listner?.remove()
                        print("Call This From Here >>>>>>>>>>  28")
                        self.setUI()
                        self.leagueTabVC!().isNewMatch = true    //  By Pranay - Added
                    }
                } else {
                    self.hideLoading()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        } else {
            viewBottom.isHidden = true
            viewBottomHeightConst.constant = 0
        }
    }
    
    func getLeagueMatch() {
        print("Get Luague match api call")
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLeagueMatch()
                }
            }
            return
        }
        if APIManager.sharedManager.match?.leagueId != 0 {
            showLoading()
//            self.log.i("getLeagueMatch API call GET_LEAGUE_MATCHES. - \(APIManager.sharedManager.user?.userName ?? "") --")  //  By Pranay.
            APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_MATCHES, parameters: ["leagueId" : APIManager.sharedManager.match?.leagueId ?? 0, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
                if response?.status == 1 {
//                    self.log.i("getLeagueMatch API call GET_LEAGUE_MATCHES. - \(APIManager.sharedManager.user?.userName ?? "") -- response->\(response)")  //  By Pranay.
                    self.hideLoading()
                       DispatchQueue.main.async {
                           //self.hideLoading()
                           UserDefaults.standard.set(0, forKey: "isDispute")
                           self.isGetLeagueMatchApiCall = true
                           APIManager.sharedManager.match = (response?.result?.match)!
                           if APIManager.sharedManager.match != nil {
                               if APIManager.sharedManager.match?.matchId != nil && APIManager.sharedManager.match?.matchId != 0 && APIManager.sharedManager.match?.leagueId != 0 {
                                   if APIManager.sharedManager.match?.awayTeamId != 0 {
                                       //let player2Team = (response?.result?.match?.awayTeam?.teamName ?? "").count > 30 ? String((response?.result?.match?.awayTeam?.teamName ?? "")[..<(response?.result?.match?.awayTeam?.teamName ?? "").index((response?.result?.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (response?.result?.match?.awayTeam?.teamName ?? "")
                                       // By Pranay
                                       let player2Team = (APIManager.sharedManager.match?.awayTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.awayTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.awayTeam?.teamName ?? "").index((APIManager.sharedManager.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.awayTeam?.teamName ?? "")
                                       // .
                                       if APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 {
                                           self.lblNextPlayer2.text = APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? ""  //  Update by Pranay.
                                       } else {
                                           var name = ""
                                           if APIManager.sharedManager.match?.awayTeamPlayers?.count ?? 0 > 0 {
                                               name = APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? ""
                                           }
                                           var awayShort = player2Team.count > 30 ? String(player2Team[..<player2Team.index(player2Team.startIndex, offsetBy: 30)]) : player2Team
                                           awayShort = player2Team.count > 30 ? (awayShort + "...") : player2Team
                                           let finalName = "\(awayShort)\n\(name)"
                                           self.lblNextPlayer2.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                                       }
                                       self.imgNextPlayer2.setImage(imageUrl: response?.result?.match?.awayTeam?.awayImage ?? "")
                                   } else {
                                       self.lblNextPlayer2.text = response?.result?.match?.parentAwayTeamWinnerLabel
                                       self.imgNextPlayer2.setImage(imageUrl: "")
                                   }

                                   if APIManager.sharedManager.match?.homeTeamId != 0 {
                                       //let player1Team = (response?.result?.match?.homeTeam?.teamName ?? "").count > 30 ? String((response?.result?.match?.homeTeam?.teamName ?? "")[..<(response?.result?.match?.homeTeam?.teamName ?? "").index((response?.result?.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (response?.result?.match?.homeTeam?.teamName ?? "")
                                       // By Pranay
                                       let player1Team = (APIManager.sharedManager.match?.homeTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.homeTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.homeTeam?.teamName ?? "").index((APIManager.sharedManager.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.homeTeam?.teamName ?? "")
                                       // .
                                       if APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 {
                                           self.lblNextPlayer1.text = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""  //  Update by Pranay.
                                       }
                                       else {
                                           var name = ""
                                           if APIManager.sharedManager.match?.homeTeamPlayers?.count ?? 0 > 0 {
                                               name = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""
                                           }
                                           var homeShort = player1Team.count > 30 ? String(player1Team[..<player1Team.index(player1Team.startIndex, offsetBy: 30)]) : player1Team
                                           homeShort = player1Team.count > 30 ? (homeShort + "...") : player1Team

                                           let finalName = "\(homeShort)\n\(name)"
                                           self.lblNextPlayer1.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                                       }
                                       self.imgNextPlayer1.setImage(imageUrl: response?.result?.match?.homeTeam?.homeImage ?? "")
                                   } else {
                                       self.imgNextPlayer1.setImage(imageUrl: "")
                                       self.lblNextPlayer1.text = response?.result?.match?.parentHomeTeamWinnerLabel
                                   }

                                   self.lblNextGame.text = APIManager.sharedManager.leagueType != "League" ? response?.result?.match?.nextMatchRoundLabel : response?.result?.match?.league?.leagueName
                                   if response?.result?.match?.onlyDate == "" || response?.result?.match?.onlyDate == "TBD" {
                                       self.lblNextMatchTime.text = "TBD"
                                   } else {
                                       self.lblNextMatchTime.text = "\(response?.result?.match?.onlyDate ?? "")\n\(response?.result?.match?.onlyTime ?? "")"
                                   }
                                   self.viewBottom.isHidden = false
                                   self.viewBottomHeightConst.constant = 250

                                   if APIManager.sharedManager.leagueType != "League" {
                                       var myIdWinner = 0
                                       var oppIdWinner = 0
                                       for j in 0 ..< (self.arrFire?.rounds?.count ?? 0) {
                                           if self.arrFire?.rounds?[j].winnerTeamId == self.arrPlayer[self.myPlayerIndex].teamId {
                                               myIdWinner += 1
                                           } else {
                                               oppIdWinner += 1
                                           }
                                       }
                                       if APIManager.sharedManager.eliminationType == "Double Elimination" {
                                       }
                                       else if myIdWinner > oppIdWinner {
                                           self.viewBottom.isHidden = false
                                           self.viewBottomHeightConst.constant = 250
                                       }
                                       else {
                                           self.viewBottom.isHidden = true
                                           self.viewBottomHeightConst.constant = 0
                                       }
                                   }
                               }
                               else { //  Else part added by Pranay.
                                   self.viewStageDetail.isHidden = false
                                   self.viewStageDetailHeightConst.constant = 0
                                   self.viewBottom.isHidden = true
                                   self.viewBottomHeightConst.constant = 0
                               }
                           }
                           else { //  Else part added by Pranay.
                               self.viewStageDetail.isHidden = false
                               self.viewStageDetailHeightConst.constant = 0
                               self.viewBottom.isHidden = true
                               self.viewBottomHeightConst.constant = 0
                           }
                           self.isFromHome = false
                           self.listner?.remove()
                           print("Call This From Here >>>>>>>>>>  29")
                           self.setUI()
                           self.leagueTabVC!().isNewMatch = true    //  By Pranay - Added
                       }
                }
                else {
                    self.hideLoading()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.listner?.remove()
                    print("Call This From Here >>>>>>>>>>  30")
                    self.setUI()
                }
            }
        } else {
            viewBottom.isHidden = true
            viewBottomHeightConst.constant = 0
            self.listner?.remove()
            print("Call This From Here >>>>>>>>>>  31")
            self.setUI()
        }
    }
}

extension ArenaRoundResultVC {
    
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
        
        if APIManager.sharedManager.timer.isValid == true {
            APIManager.sharedManager.timer.invalidate()
        }
        self.refreshTimer.invalidate()
        self.listner?.remove()
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DECLARE_FORFEIT_TEAM, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.isMatchForfeitByMe = true
                print("Call This From Here >>>>>>>>>>  32")
                self.setUI()
                //DispatchQueue.main.async {
                    //self.leagueTabVC!().getTournamentContent()
                //}
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
                print("Call This From Here >>>>>>>>>>  33")
                self.setUI()
            }
        }
    }
}
