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
import AVFoundation
//import ShipBookSDK

class ArenaDisputeScoreVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    var arrFire : FirebaseInfo?
    let db = Firestore.firestore()
    var score1 = ""
    var score2 = ""
    var myPlayerIndex = 0
    var opponent = 1
    var winnerId = 0
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var disputeId = 0
    var disputeImage = UIImage()
    var isTapOne = false
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var hostIndex = 0
    var opponentIndex = 1
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isTapChat = false
    var isDisputeRemovedFromStack = false
    
    var arrPlayer = [ArenaPlayerData]()
    var isFromViewAcceptOpponentScore : Bool = false
    //var isDisputeNotificationApiCall : Bool = false
    //var isImageCapture: Bool = false
    //var isEnter = false
//    fileprivate let log = ShipBook.getLogger(ArenaDisputeScoreVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var btnProceed1: UIButton!
    @IBOutlet weak var btnProceed2: UIButton!
    @IBOutlet weak var btnAbandon: UIButton!
    
    // By Pranay
    @IBOutlet weak var viewChooseOption: UIView!
    @IBOutlet weak var viewContectOrganizer: UIView!
    @IBOutlet weak var btnContactOrganizer: UIButton!
    @IBOutlet weak var btnAcceptOpponentScore: UIButton!
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnProceed1.layer.cornerRadius = btnProceed1.frame.size.height / 2
        btnProceed2.layer.cornerRadius = btnProceed2.frame.size.height / 2
        btnAbandon.layer.cornerRadius = btnAbandon.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
        
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationItem.setTopbar()
        
        // By Pranay
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        
        if (UserDefaults.standard.value(forKey: UserDefaultType.forDisputePopup) == nil) {
            UserDefaults.standard.set(0, forKey: UserDefaultType.forDisputePopup)
        }
        self.showDisputePopup()
        AVCaptureDevice.requestAccess(for: .video) { grant in }
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
        
        isDisputeRemovedFromStack = false
        
        if isTapChat {
            isTapChat = false
            callBackInfo()
        }
        else {
            self.setNotificationCountObserver()
        }
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.chatCountUpdate),
                    name: NSNotification.Name(rawValue: "newMessageNotification"),
                    object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackInfo),
            name: NSNotification.Name(rawValue: "DismissInfo"),
            object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        isDisputeRemovedFromStack = true
        listner?.remove()
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isDisputeRemovedFromStack = true
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
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    func chatBadge() {
        let chatCount = self.getUnreadChatCount(id: self.arrFire?.playerDetails?[self.opponent].playerId ?? 0).stringValue
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
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 7
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isDisputeRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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
        
//        self.log.i("ArenaDisputeScoreVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { [self] (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaDisputeScoreVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaDisputeScoreVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            //self.log.i("ArenaDisputeScoreVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                            
                            self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            
                            self.chatBadge()
                            
                            self.hostIndex = self.arrFire?.playerDetails?[0].host == 1 ? 0 : 1
                            self.opponentIndex = self.hostIndex == 1 ? 0 : 1
                            
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
                            else if(self.doc?.data()?["resetMatch"] as? Int == 1) {
                                self.navigateToArenaMatchReset()
                                
                                return
                            }
                            //enter score
                            //else if self.isEnter && self.doc?.data()?["status"] as? String == Messages.enteringScore {
                            else if self.doc?.data()?["status"] as? String == Messages.enteringScore {
                                self.listner?.remove()
                                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaReportScorePopupVC") as! ArenaReportScorePopupVC
                                dialog.modalPresentationStyle = .overCurrentContext
                                dialog.modalTransitionStyle = .crossDissolve
                                dialog.isFromDisputeScore = true
                                dialog.tapOk = { arr, isMatchReset in
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
                                    else if arr[0] as! Bool == true { //opponent confirm score
                                        self.listner?.remove()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    else {
                                        self.score1 = arr[2] as! String
                                        self.score2 = arr[3] as! String
                                        if Int(self.score1) == Int(self.score2) {
                                            self.tieDialog(isTie: arr[1] as! Bool)
                                        } else {
                                            if (Int(self.score1) ?? 0) > (Int(self.score2) ?? 0) {
                                                self.winnerId = self.hostIndex
                                            } else {
                                                self.winnerId = self.opponentIndex
                                            }
                                            self.disputeScore()
                                        }
                                    }
                                }
                                dialog.tapDismiss = {
                                    
                                    let param = [
                                        "status": Messages.dispute
                                    ] as [String: Any]
                                    
                                    //self.isEnter = false
                                    //self.listner?.remove()
//                                    self.log.i("Update status on cancel button. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")
                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                        if let err = err {
//                                            self.log.e("Update status on cancel button. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")
                                        }
                                        else {
                                            //self.isEnter = false
                                            self.setUI()
                                        }
                                    }
                                }
                                if self.isDisputeRemovedFromStack == false {
                                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                }
                            } else if(self.doc?.data()?["status"] as? String == Messages.enterDisputeScore) {
                                // By Pranay
                                if isFromViewAcceptOpponentScore {//Click view & accept
                                    isFromViewAcceptOpponentScore = false
                                    if self.isDisputeRemovedFromStack == false {
                                        self.listner?.remove()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                } else {//disputeBy me then pop back
                                    self.arrPlayer = self.arrFire?.playerDetails ?? []
                                    if self.doc?.data()?["disputeBy"] as! Int == self.arrPlayer[self.myPlayerIndex].playerId ?? 0 {
                                        self.listner?.remove()
                                        self.navigationController?.popViewController(animated: true)
                                    } else if self.doc?.data()?["disputeBy"] as! Int == self.arrPlayer[self.opponent].playerId ?? 0 {    //  self.opponent
                                        //if self.isDisputeRemovedFromStack == false {
                                        //self.disputeScore()
                                        //}
                                        self.listner?.remove()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                                //.
                            } else if(self.doc?.data()?["status"] as? String == Messages.scoreConfirm) {
                                hideLoading()   //  By Pranay
                                DispatchQueue.main.async {
                                    if self.isDisputeRemovedFromStack == false {
                                        self.listner?.remove()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                }
                            } else if(self.doc?.data()?["status"] as? String == Messages.enteredScore) {
                                if self.isDisputeRemovedFromStack == false {
                                    self.listner?.remove()
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            }
                            // By Pranay
                            else if(self.doc?.data()?["status"] as? String == Messages.dispute) {
                                
                                if arrFire?.playerDetails![0].dispute == 1 && arrFire?.playerDetails![1].dispute == 1 {
                                    viewContectOrganizer.isHidden = false
                                    viewChooseOption.isHidden = true
                                    if !self.leagueTabVC!().isDisputeNotificationApiCall {
                                        self.leagueTabVC!().isDisputeNotificationApiCall = true
                                        let currentRound : Int = arrFire?.currentRound ?? 0
                                        let roundId : Int = (arrFire?.rounds![currentRound == 0 ? currentRound : currentRound - 1].roundId ?? 0)
                                        self.sendDisputeNotification(roundId)
                                    }
                                } else {
                                    viewContectOrganizer.isHidden = true
                                    viewChooseOption.isHidden = false
                                }
                            } else if(self.doc?.data()?["status"] as? String == Messages.matchFinished) {
                                if self.isDisputeRemovedFromStack == false {
                                    self.listner?.remove()
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            //.
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func submitDisputeScore() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        var roundArr = [[String:AnyObject]]()
        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
        
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team1Score"] = Int(self.score1) as AnyObject
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team2Score"] = Int(self.score2) as AnyObject
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["winnerTeamId"] = self.arrFire?.playerDetails?[self.winnerId].teamId as AnyObject
        
        // By Pranay
        var playerArr = [[String:AnyObject]]()
        playerArr = doc?.data()?["playerDetails"] as! [[String : AnyObject]]
        var disputeScore = [String:AnyObject]()
        disputeScore = [
            "team1Score": Int(self.score1) as AnyObject,
            "team2Score" : Int(self.score2) as AnyObject,
            "winnerTeamId" : self.arrFire?.playerDetails?[self.winnerId].teamId ?? 0,
            "disputeImagePath":""
        ] as [String:AnyObject]
        playerArr[self.myPlayerIndex]["disputeScore"] = disputeScore as AnyObject
        playerArr[self.myPlayerIndex]["dispute"] = Int(1) as AnyObject
        
        
        let param = [
            "status": Messages.enterDisputeScore,
            "rounds" : roundArr,
            "disputeImagePath" : "",
            "playerDetails":playerArr
        ] as [String: Any]
        //.
//        self.log.i("Submit score with submitDisputeScore. - \(APIManager.sharedManager.user?.userName ?? "") -- param->\(param)")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("Submit score with submitDisputeScore fail. - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error writing document: \(err)")
            } else {
                if self.isDisputeRemovedFromStack == false {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func tieDialog(isTie : Bool) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.score1 = self.score1
        dialog.score2 = self.score2
        dialog.isFromDisputeScore = true
        
        // If tie damage percentage
        if(isTie) {
            //dialog.secondMessage = Messages.selectTheWinner
            dialog.secondMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTieMsg ?? ""
            dialog.thirdMessage = Messages.lowestDamage
            dialog.isTieByDamagePercentage = true
        }
        
        // If tie Sudden Death
        //            dialog.secondMessage = Messages.selectTheWinner
        //            dialog.thirdMessage = Messages.suddenDeath
        //            dialog.isTieBySuddenDeath = true
        dialog.tapOk = { arr in
            if arr[0] as! Bool == true {
                if self.isDisputeRemovedFromStack == false {
                    self.listner?.remove()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                if arr[1] as! Int == 0 {
                    self.winnerId = arr[2] as! Int == 0 ? self.hostIndex : self.opponentIndex
                    self.disputeScore()
                } else if arr[1] as! Int == 1 {
                    // Custom Dialog
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.titleText = Messages.tiedDamage
                    dialog.message = Messages.areYouSureTheWasTied
                    dialog.highlightString = ""
                    dialog.isFromDisputeScore = true
                    dialog.tapOKForArenaScore = { isScoreSubmit in
                        if isScoreSubmit {
                            if self.isDisputeRemovedFromStack == false {
                                self.listner?.remove()
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            // Arena Winner selection screen
                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
                            dialog.modalPresentationStyle = .overCurrentContext
                            dialog.modalTransitionStyle = .crossDissolve
                            dialog.score1 = self.score1
                            dialog.score2 = self.score2
                            dialog.secondMessage = ""
                            //dialog.thirdMessage = Messages.singleLifeRematch
                            dialog.thirdMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scorePercentageTieMsg ?? ""
                            dialog.isSingleLifeRemath = true
                            dialog.isFromDisputeScore = true
                            dialog.tapOk = { index in
                                if index[0] as! Bool == true && self.isDisputeRemovedFromStack == false{
                                    self.listner?.remove()
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSelectWinnerPopupVC") as! ArenaSelectWinnerPopupVC
                                    dialog.modalPresentationStyle = .overCurrentContext
                                    dialog.modalTransitionStyle = .crossDissolve
                                    dialog.score1 = self.score1
                                    dialog.score2 = self.score2
                                    //dialog.isFromEnterScore = true
                                    dialog.isFromEnterScore = false // By Pranay
                                    //dialog.secondMessage = Messages.selectTheWinner
                                    dialog.secondMessage = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTieMsg ?? ""
                                    dialog.thirdMessage = Messages.suddenDeath
                                    dialog.isTieBySuddenDeath = true
                                    dialog.suddenDeathWinner = index[2] as! Int
                                    dialog.tapOk = { index in
                                        if index[0] as! Bool == true {
                                            self.listner?.remove()
                                            self.navigationController?.popViewController(animated: true)
                                        } else {
                                            if index[1] as! Int == 0 {
                                                self.winnerId = index[2] as! Int == 0 ? self.hostIndex : self.opponentIndex
                                            }
                                            self.disputeScore()
                                        }
                                    }
                                    if self.isDisputeRemovedFromStack == false {
                                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                    }
                                }
                            }
                            if self.isDisputeRemovedFromStack == false {
                                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                            }
                        }
                    }
                    
                    dialog.tapCancel = {
                        self.tieDialog(isTie: true)
                    }
                    
                    dialog.btnYesText = Messages.yes
                    dialog.btnNoText = Messages.close
                    if self.isDisputeRemovedFromStack == false {
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                }
            }
        }
        dialog.tapDismiss = {
            self.setUI()
        }
        
        //        // If tie damage percentage
        //        dialog.secondMessage = Messages.singleLifeRematch
        //        dialog.thirdMessage = ""
        //        dialog.isSingleLifeRemath = true
        if self.isDisputeRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    /// 343 By Pranay
    func    showDisputePopup() {
        if (UserDefaults.standard.value(forKey: UserDefaultType.forDisputePopup)! as! Int) == 0 {
            UserDefaults.standard.set(0, forKey: UserDefaultType.forDisputePopup)
            
            DispatchQueue.main.async {
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "BetaCustomDialog") as! BetaCustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.mainTitleText = "Important Message"
                dialog.titleText = ""   //Messages.betaVersionTitle
                dialog.message = Messages.disputePopupMsg
                //dialog.arrHighlightString = ["Players:", "Teams:", "Tournaments:"]
                dialog.tapOK = {
                    UserDefaults.standard.set(1, forKey: UserDefaultType.forDisputePopup)
                }
                dialog.btnYesText = Messages.close
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }
        }
    }
    /// 343 .
    
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
        
        var param : [String: Any]
        
        //score with evidence
        if sender.tag == 0 {
//            self.log.i("Submit score with evidence. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
            if #available(iOS 10.0, *) {
                let startCam = self.storyboard?.instantiateViewController(withIdentifier: "StartCamVC") as! StartCamVC
                startCam.passImage = { img in
                    appDelegate.myOrientation = .portrait
                    DispatchQueue.main.async {
                        
                        // By Pranay
                        self.view.layoutIfNeeded()
                        self.view.layoutSubviews()
                        //.
                        
                        let value = UIInterfaceOrientation.portrait.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                        self.isTapOne = true
                        self.disputeImage = img
                        
                        let param = [
                            "status": Messages.enteringScore
                        ] as [String: Any]
                        
                        //self.isEnter = true
                        
//                        self.log.i("Submit score with evidence. - \(APIManager.sharedManager.user?.userName ?? "") -- Update status. --- param-> \(param)")  //  By Pranay.
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                            if let err = err {
//                                self.log.e("Submit score with evidence. - \(APIManager.sharedManager.user?.userName ?? "") -- Update status. --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                            }
                            else {
                                //self.isTapOne = true    //  Added by Pranay.
                                //self.leagueTabVC!().isImageCapture = true
                            }
                        }
                    }
                }
                startCam.dismiss = {
                    appDelegate.myOrientation = .portrait
                    DispatchQueue.main.async {
                        
                        // By Pranay
                        self.view.layoutIfNeeded()
                        self.view.layoutSubviews()
                        //.
                        
                        let value = UIInterfaceOrientation.portrait.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                        
//                        self.log.i("Submit score with evidence startCam.dismiss getDocument. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                            if let err = err {
//                                self.log.e("Submit score with evidence startCam.dismiss getDocument. - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                                print("Error getting documents: \(err)")
                            }
                            else {
                                var newDoc:DocumentSnapshot?
                                newDoc =  querySnapshot!
                                
//                                self.log.i("Submit score with evidence startCam.dismiss getDocument. - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                                
                                if newDoc?.data()?["status"] as? String != Messages.enteringScore || newDoc?.data()?["status"] as? String != Messages.enterDisputeScore || newDoc?.data()?["status"] as? String != Messages.scoreConfirm || newDoc?.data()?["status"] as? String != Messages.enteredScore {
                                    self.listner?.remove()
                                    self.callBackInfo()
                                }
                            }
                        }
                    }
                }
                startCam.modalPresentationStyle = .overCurrentContext
                startCam.modalTransitionStyle = .crossDissolve
                self.view!.tusslyTabVC.present(startCam, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        else if sender.tag == 1 { //only score
            
            param = [
                "status": Messages.enteringScore
            ] as [String: Any]
            
            //self.listner?.remove()
            //self.isEnter = true
//            self.log.i("Submit score without evidence update status. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
//                    self.log.e("Submit score without evidence update status Fails. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")
                }
            }
        } else if sender.tag == 2 { //abandon
            // By Pranay
            
            var playerArr = [[String:AnyObject]]()
            playerArr = doc?.data()?["playerDetails"] as! [[String : AnyObject]]
            playerArr[self.myPlayerIndex]["dispute"] = 0 as AnyObject
            
            param = [
                "status": Messages.enteredScore,
                "playerDetails" : playerArr
            ] as [String: Any]
            
//            self.log.i("Abandon dispute and accept opponent's submited score update status. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            //.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
//                    self.log.e("Abandon dispute and accept opponent's submited score update status Fails. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                }
            }
        }
        // By Pranay
        else if sender.tag == 3 { //contact admin
            
            self.leagueTabVC!().cvLeagueTabs.collectionView(self.leagueTabVC!().cvLeagueTabs, didSelectItemAt: IndexPath(item: 4, section: 0))
            
        } else if sender.tag == 4 { //view and accept opponent reported score
            /**
             * If user accept report score then user confirm/dispute opponent reported score.
             * Update firestore round array item team1Score, team2Score,winnerTeamId for current round.
             * If user goes back then update status "Entered dispute score" same as abandon process.
             * */
//            self.log.i("view and accept opponent reported score. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
            if myPlayerIndex == opponentIndex {
                showLoading()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.hideLoading()
                    self.viewAndAccept()
                })
            } else {
                viewAndAccept()
            }
        }
        //.
    }
    
    // By Pranay
    func viewAndAccept()
    {
        isFromViewAcceptOpponentScore = true
        self.arrPlayer = self.arrFire?.playerDetails ?? []
        var roundArr = [[String:AnyObject]]()
        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
        
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team1Score"] = self.arrPlayer[self.opponent].disputeScore?.team1Score as AnyObject
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team2Score"] = self.arrPlayer[self.opponent].disputeScore?.team2Score as AnyObject
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["winnerTeamId"] = self.arrPlayer[self.opponent].disputeScore?.winnerTeamId as AnyObject
        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["winnerTeamId"] = self.arrPlayer[self.opponent].disputeScore?.winnerTeamId as AnyObject
        
        let param = [
            "status": Messages.enterDisputeScore,
            "rounds": roundArr,
            "disputeImagePath" : self.arrPlayer[self.opponent].disputeScore?.disputeImagePath as AnyObject,
            "disputeBy": self.arrPlayer[self.opponent].playerId ?? 0
        ] as [String: Any]
        
//        self.log.i("viewAndAccept and accept opponent's submited score update status. - \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param)")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("viewAndAccept and accept opponent's submited score update status. - \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param) --- Error-> \(err)")  //  By Pranay.
            }
        }
    }
    //.
    
    @IBAction func howToWorkTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 0
        if sender.tag == 0 {
            dialog.infoType = 1
        }
        else {
            dialog.infoType = 2
        }
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isDisputeRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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

// MARK: Webservices
extension ArenaDisputeScoreVC {
    func disputeScore() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.disputeScore()
                }
            }
            return
        }
        showLoading()
        //self.hostIndex
        //self.opponentIndex
        var sc = [[String:Any]]()
        let p1 = ["userId" : self.arrFire?.playerDetails?[self.hostIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.hostIndex].teamId,
                  "stock" : Int(score1)]
        let p2 = ["userId" : self.arrFire?.playerDetails?[self.opponentIndex].playerId,
                  "teamId": self.arrFire?.playerDetails?[self.opponentIndex].teamId,
                  "stock" : Int(score2)]
        sc.append(p1 as [String : Any])
        sc.append(p2 as [String : Any])
        let loser = winnerId == 0 ? 1 : 0
        
        let param = ["matchId": (APIManager.sharedManager.match?.matchId) ?? 0,
                     "roundId": (self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].roundId) ?? 0,
                     "winnerUserId": (self.arrFire?.playerDetails?[self.winnerId].playerId) ?? 0,
                     "losserUserId": (self.arrFire?.playerDetails?[loser].playerId) ?? 0,
                     "score": sc,
                     "teamId" : (self.arrFire?.playerDetails?[self.myPlayerIndex].teamId) ?? 0,
                     "homeCharacterId": (self.arrFire?.playerDetails?[self.hostIndex].characterId) ?? 0,
                     "awayCharacterId": (self.arrFire?.playerDetails?[self.opponentIndex].characterId) ?? 0,
                     "stageId": (self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].finalStage?.id) ?? 0,
                     "leagueId" : APIManager.sharedManager.match?.leagueId ?? 0,  //  Added by Pranay.
                     "device": "ios"] as [String: Any]
        
//        self.log.i("API call disputeScore(). - \(APIManager.sharedManager.user?.userName ?? "") -- param->\(param)")  //  By Pranay.
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DISPUTE_ROUND, parameters: param) { (response: ApiResponse?, error) in
            if response?.status == 1 {
//                self.log.i("API call disputeScore. - \(APIManager.sharedManager.user?.userName ?? "") -- response->\(response)")  //  By Pranay.
                self.hideLoading()
                self.disputeId = response?.result?.disputeId ?? 0
                DispatchQueue.main.async {
                    if self.isTapOne {
                        self.uploadImage(type: "DisputeImage", image: self.disputeImage)
                        self.isTapOne = false
                    } else {
                        self.submitDisputeScore()
                    }
                }
            } else {
                self.hideLoading()
//                self.log.e("API call disputeScore(). - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(response?.message ?? "")")  //  By Pranay.
                Utilities.showPopup(title: response != nil ? (response?.message ?? "") : "Something went wrong!", type: .error)
            }
        }
    }
    
    func uploadImage(type : String,image: UIImage) {
        showLoading()
        APIManager.sharedManager.uploadImage(url: APIManager.sharedManager.UPLOAD_IMAGE, fileName: "image", image: image, type: type, id: self.disputeId) { (success, response, message) in
            self.hideLoading()
            if success {
                if !Network.reachability.isReachable {
                    self.isRetryInternet { (isretry) in
                        if isretry! {
                            self.callBackInfo()
                        }
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    
                    // By Pranay
                    var playerArr = [[String:AnyObject]]()
                    playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    playerArr[self.myPlayerIndex]["dispute"] = 1 as AnyObject
                    
                    var disputeScore = [String:AnyObject]()
                    disputeScore = [
                        "team1Score": Int(self.score1) as AnyObject,
                        "team2Score" : Int(self.score2) as AnyObject,
                        "winnerTeamId" : self.arrFire?.playerDetails?[self.winnerId].teamId as AnyObject,
                        "disputeImagePath": response?["filePath"] ?? ""
                    ] as! [String:AnyObject]
                    playerArr[self.myPlayerIndex]["disputeScore"] = disputeScore as AnyObject
                    //.
                    
                    var roundArr = [[String:AnyObject]]()
                    roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                    roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team1Score"] = Int(self.score1) as AnyObject
                    roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["team2Score"] = Int(self.score2) as AnyObject
                    roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["winnerTeamId"] = self.arrFire?.playerDetails?[self.winnerId].teamId as AnyObject
                    
                    let param = [
                        "disputeImagePath": response?["filePath"] ?? "",
                        "status": Messages.enterDisputeScore,
                        "rounds" : roundArr,
                        "playerDetails":playerArr   // By Pranay
                    ] as [String: Any]
                    
//                    self.log.i("API call uploadImage Success and update firestore. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) {err in
//                        self.log.i("API call uploadImage Success and update firestore. - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                        if self.isDisputeRemovedFromStack == false {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
    
    func sendDisputeNotification(_ roundId : Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendDisputeNotification(roundId)
                }
            }
            return
        }
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEND_DISPUTE_NOTIFICATION, parameters: ["leagueId" : APIManager.sharedManager.match?.leagueId ?? 0, "roundId" : roundId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension ArenaDisputeScoreVC {
    
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
                //self.setUI()
            }
        }
    }
}
