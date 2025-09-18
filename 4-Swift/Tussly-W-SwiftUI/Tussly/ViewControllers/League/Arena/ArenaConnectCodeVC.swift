//
//  ArenaConnectCodeVC.swift
//  Tussly
//
//  Created by MAcBook on 17/06/22.
//  Copyright © 2022 Auxano. All rights reserved.
//
// By Pranay - Screen added by pranay.

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
//import ShipBookSDK

class ArenaConnectCodeVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    let db = Firestore.firestore()
    var myPlayerIndex = 0
    var opponent = 1
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var content = [HowToUseContent]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var playerArr = [[String:AnyObject]]()
    var isTapChat = false
    var isOppIdRemovedFromStack = false
    var isHostIdRemovedFromStack = false
    var arrFirebase : FirebaseInfo?
    var arrPlayer = [ArenaPlayerData]()
//    fileprivate let log = ShipBook.getLogger(ArenaConnectCodeVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var viewOppoConnectCode: UIView!
    @IBOutlet weak var lblOppoConnectCode: UILabel!
    @IBOutlet weak var viewOwnConnectCode: UIView!
    @IBOutlet weak var lblOwnConnectCode: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblWaitingMsg: UILabel!
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblOpponentCode: UILabel!
    @IBOutlet weak var lblOwnCode: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lblOppoConnectCode.text = "Opponent's \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")"
        lblOwnConnectCode.text = "Your \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")"
        
        /// 331 - By Pranay
        /// Comment below three line for disable dynamic BattleID
        lblTitle.text = "\(APIManager.sharedManager.gameSettings?.gameLabel ?? "")"
        lblOpponentCode.text = "Your opponent's \((APIManager.sharedManager.gameSettings?.gameLabel ?? "").lowercased())"
        lblOwnCode.text = "Your \((APIManager.sharedManager.gameSettings?.gameLabel ?? "").lowercased())"
        /// 331 .
        
        btnProceed.layer.cornerRadius = btnProceed.frame.height / 2
        viewOppoConnectCode.layer.cornerRadius = viewOppoConnectCode.frame.height / 2
        viewOwnConnectCode.layer.cornerRadius = viewOwnConnectCode.frame.height / 2
        viewOppoConnectCode.layer.borderWidth = 1.0
        viewOppoConnectCode.layer.borderColor = Colors.border.returnColor().cgColor
        viewOwnConnectCode.layer.borderWidth = 1.0
        viewOwnConnectCode.layer.borderColor = Colors.border.returnColor().cgColor
        
        btnProceed.backgroundColor = UIColor(red: 138/255.0, green: 7/255.0, blue: 2/255.0, alpha: 1)
        
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //viewGameBar.backgroundColor = Utilities.getGameColor(gameId: APIManager.sharedManager.gameId)
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationItem.setTopbar()
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
        
        isHostIdRemovedFromStack = false
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.chatCountUpdate),
                    name: NSNotification.Name(rawValue: "newMessageNotification"),
                    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        
        if isTapChat {
            isTapChat = false
            callBackInfo()
        }
        else {
            self.setNotificationCountObserver()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isHostIdRemovedFromStack = true
        self.listner?.remove()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh area tab")
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isHostIdRemovedFromStack = true
            listner?.remove()
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
    
    func chatBadge() {
        let chatCount = self.getUnreadChatCount(id: self.playerArr[self.opponent]["playerId"] as? Int ?? 0).stringValue
        if chatCount == "0"{
            self.lblMessageCount.isHidden = true
        } else {
            self.lblMessageCount.isHidden = false
            self.lblMessageCount.text = chatCount
            self.viewNav.addSubview(self.lblMessageCount)
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
    
    @objc func onTapInfo() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 2
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isHostIdRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaConnectCodeVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaConnectCodeVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaConnectCodeVC listner call - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaConnectCodeVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            //self.log.i("ArenaConnectCodeVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                            
                            self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            self.arrPlayer = self.arrFirebase?.playerDetails ?? []
                            let hostIndex : Int = self.arrPlayer[0].host == 1 ? 0 : 1
                            let opponentIndex : Int = hostIndex == 1 ? 0 : 1
                            
                            //self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: jsonData)
                            //self.arrPlayer = self.arrFirebase?.playerDetails ?? []
                            self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                            self.chatBadge()
                            
                            let match : Match = APIManager.sharedManager.match ?? Match()
                            // By Pranay
                            if (APIManager.sharedManager.user?.id)! == (match.homeTeamPlayers![0].userId)! {
                                self.lblOwnConnectCode.text = match.homeTeamPlayers?[0].playerDetails?.connectCode ?? ""
                                self.lblOppoConnectCode.text = match.awayTeamPlayers?[0].playerDetails?.connectCode ?? ""
                            } else {
                                self.lblOwnConnectCode.text = match.awayTeamPlayers?[0].playerDetails?.connectCode ?? ""
                                self.lblOppoConnectCode.text = match.homeTeamPlayers?[0].playerDetails?.connectCode ?? ""
                            }
                            //.
                            
                            if APIManager.sharedManager.user?.id == self.arrPlayer[0].playerId {
                                self.myPlayerIndex = 0
                                APIManager.sharedManager.myPlayerIndex = 0
                                self.opponent = self.myPlayerIndex == 0 ? 1 : 0
                            } else {
                                APIManager.sharedManager.myPlayerIndex = 1
                                self.myPlayerIndex = 1
                                self.opponent = self.myPlayerIndex == 0 ? 1 : 0
                            }
                            
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
                                
                                return
                            }
                            //wait for opponent to confirm/fail your entered battle id
                            else if self.doc?.data()?["status"] as? String == Messages.enteredBattleId {
                                //self.listner?.remove()
                                /*
                                 let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                 dialog.isLoader = true
                                 dialog.modalPresentationStyle = .overCurrentContext
                                 dialog.modalTransitionStyle = .crossDissolve
                                 dialog.arenaFlow = "HostBattleId"
                                 dialog.descriptionString = Messages.battleIdSent
                                     = { statusIs in
                                 if statusIs == Messages.battleIdFail { // fail, id not match
                                 //self.battleIdFail()
                                 } else {
                                 //self.doubleConfirmID() //confirm to proceed to select character
                                 }
                                 }
                                 if !self.isHostIdRemovedFromStack {
                                 self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                 }   //  */
                            }
                            else if self.doc?.data()?["status"] as? String == Messages.waitingToCharacterSelection {
                                let param : [String: Any]
                                
                                if self.arrPlayer[self.myPlayerIndex].ssbmConnectProceed == 0 {
                                    var playerArr = [[String:AnyObject]]()
                                    playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                                    playerArr[self.myPlayerIndex]["ssbmConnectProceed"] = 1 as AnyObject
                                    
                                    param = [
                                        "playerDetails":playerArr
                                    ] as [String: Any]
                                    
//                                    self.log.i("ArenaConnectCodeVC setupUi() update ssbmConnectProceed -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
//                                            self.log.i("ArenaConnectCodeVC setupUi() update ssbmConnectProceed -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                        }
                                    }
                                } else if self.doc?.data()?["weAreReadyBy"] as! Int == self.arrPlayer[self.myPlayerIndex].playerId ?? 0 {
                                    self.btnProceed.isEnabled = false
                                    self.btnProceed.backgroundColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
                                    self.lblWaitingMsg.isHidden = false
                                } else if (!self.btnProceed.isEnabled) && (self.doc?.data()?["weAreReadyBy"] as! Int == self.arrPlayer[self.opponent].playerId ?? 0) {
                                    
                                    param = [
                                        "status": Messages.characterSelection
                                    ] as [String: Any]
                                    
//                                    self.log.i("ArenaConnectCodeVC setupUi() update status -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                        if let err = err {
//                                            self.log.e("ArenaConnectCodeVC setupUi() update status->\(Messages.characterSelection) -- \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                            print("Error writing document: \(err)")
                                        }
                                    }
                                    //print("Listener call btn disabled --- \(Messages.characterSelection)")
                                    
                                } else {
                                    self.btnProceed.isEnabled = true
                                    self.btnProceed.backgroundColor = UIColor(red: 138/255.0, green: 7/255.0, blue: 2/255.0, alpha: 1)
                                    self.lblWaitingMsg.isHidden = true
                                    
                                    //print("Else part ---\(Messages.characterSelection)")
                                }
                            } else if self.doc?.data()?["status"] as? String == Messages.characterSelection && self.doc?.data()?["weAreReadyBy"] as! Int != 0 {
                                let arenaChar = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                arenaChar.tusslyTabVC = self.tusslyTabVC
                                arenaChar.leagueTabVC = self.leagueTabVC
                                self.listner?.remove()
                                self.navigationController?.pushViewController(arenaChar, animated: true)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Button Tap
    @IBAction func btnProceedTap(_ sender: UIButton) {
        self.btnProceed.isEnabled = false
        let roundStartTime = Int(NSDate().timeIntervalSince1970)
        
        let param : [String: Any]
        
        if doc?.data()?["weAreReadyBy"] as! Int == 0 {
            //listner?.remove()
            param = [
                "weAreReadyBy": self.arrPlayer[myPlayerIndex].playerId ?? 0
            ] as [String: Any]
            
//            self.log.i("ConnectCode Proceed btn tap while 'weAreReadyBy = 0' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
                    print("Error writing document: \(err)")
//                    self.log.e("ConnectCode Proceed btn tap 'Update weAreReadyBy fail' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                } else {
                    self.btnProceed.isEnabled = false
                    self.btnProceed.backgroundColor = UIColor(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
                    self.lblWaitingMsg.isHidden = false
//                    self.log.i("ConnectCode Proceed btn tap 'Update weAreReadyBy with playerID success' - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                }
            }
        }
        else {
            param = [
                "status": Messages.characterSelection
                //"gameStartTime": roundStartTime
            ] as [String: Any]
            
//            self.log.i("ConnectCode Proceed btn tap while 'weAreReadyBy != 0' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
                    print("Error writing document: \(err)")
//                    self.log.e("ConnectCode Proceed btn tap 'Update status to characterSelection fail' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                }
            }
            
            //print("Proceed button tap else part --- \(Messages.characterSelection)")
            
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
}

extension ArenaConnectCodeVC {
    
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
                //self.setupUI()
            }
        }
    }
}
