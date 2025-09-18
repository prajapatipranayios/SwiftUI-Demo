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

class ArenaRockPaperScisierVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    var selectedType = -1
    var isClickOnProceed = false
    var isTie = false
    var timeSeconds = 0
    var finalSeconds = 0
    var myPlayerIndex = 0
    var opponent = 1
    let db = Firestore.firestore()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var selectedOption = ""
    var winner = 0
    var playerArr = [[String:AnyObject]]()
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var arrPlayer = [ArenaPlayerData]()
    var opponentStatus = ""
    var winnerChosen = false
    var hostIndex = 0
    var otherPlayerIndex = 1
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var isFromHome = false
    var isTimerRPCActive = false
    var isTapChat = false
    var isConfirmWinner = false
    var isTieFinish = false
    var isRPCRemovedFromStack = false
    var isConfirmTie = false
    
    // By Pranay
//    fileprivate let log = ShipBook.getLogger(ArenaRockPaperScisierVC.self)
    // .
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var lblTimer : UILabel!
    @IBOutlet weak var lblTimerWin : UILabel!
    @IBOutlet weak var viewFirst : UIView!
    @IBOutlet weak var viewTie : UIView!
    @IBOutlet weak var viewWin : UIView!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var selectImages: [UIImageView]!
    @IBOutlet weak var viewBottomWin : UIView!
    @IBOutlet weak var viewHeightConst : NSLayoutConstraint!
    @IBOutlet weak var viewTimeLimit : UIView!
    @IBOutlet weak var viewHeaderHeight : NSLayoutConstraint!
    @IBOutlet weak var btnProceedTopConst : NSLayoutConstraint!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var lblWinnerName : UILabel!
    @IBOutlet weak var lblWinnerChar : UILabel!
    @IBOutlet weak var imgWinner : UIImageView!
    @IBOutlet weak var imgWinOption1 : UIImageView!
    @IBOutlet weak var imgWinOption2 : UIImageView!
    @IBOutlet weak var imgTieOption1 : UIImageView!
    @IBOutlet weak var imgTieOption2 : UIImageView!
    @IBOutlet weak var lblOpponentMessage : UILabel!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        btnProceed.layer.cornerRadius = btnProceed.frame.size.height / 2
        btnYes.layer.cornerRadius = btnYes.frame.size.height / 2
        btnNo.layer.cornerRadius = btnNo.frame.size.height / 2
        imgPlayer1.layer.cornerRadius = imgPlayer1.frame.size.height / 2
        imgPlayer2.layer.cornerRadius = imgPlayer2.frame.size.height / 2
        imgWinner.layer.cornerRadius = imgWinner.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        
        btnProceedTopConst.constant = 0
        viewHeightConst.constant = 320
        btnProceed.isHidden = false
        viewBottomWin.isHidden = true
        btnProceed.isEnabled = false
        btnProceed.backgroundColor = Colors.border.returnColor()
        self.btnProceed.titleLabel?.textColor = UIColor.white
        self.view.layoutIfNeeded()
        
        for i in 0..<buttons.count {
            buttons[i].cornerWithShadow(offset: CGSize(width: 0, height: 0), color: Colors.border.returnColor(), radius: 2.8, opacity: 0.8, corner: 18)
        }
        
        for i in 0..<selectImages.count {
            selectImages[i].isHidden = true
        }
        
        viewTie.isHidden = true
        viewWin.isHidden = true
        viewFirst.isHidden = false
        
        finalSeconds = ((APIManager.sharedManager.match?.matchType == Messages.regular || APIManager.sharedManager.match?.matchType == Messages.tournament) ? APIManager.sharedManager.content?.regularArenaTimeSettings?.timeForSelectRPS : APIManager.sharedManager.content?.playoffArenaTimeSettings?.timeForSelectRPS) ?? 15
        timeSeconds = finalSeconds
        
        if APIManager.sharedManager.timer.isValid == true {
//            self.log.i("ArenaRockPaperScisierVC Remove previous active timer - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
            APIManager.sharedManager.timer.invalidate()
        }
        
        
        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
        
        DispatchQueue.main.async {
            self.setData()
        }
        //  */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        let btnChat = UIBarButtonItem(customView: btnChat)
        
        self.navigationItem.setRightBarButtonItems([btnChat, btnForfeit], animated: true)

        lblMessageCount = UILabel(frame: CGRect.init(x: 55, y: 2, width: 20, height: 20))
        lblMessageCount.backgroundColor = Colors.theme.returnColor()
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        lblMessageCount.font = Fonts.Bold.returnFont(size: 15.0)
        lblMessageCount.textColor = UIColor.white
        lblMessageCount.clipsToBounds = true
        lblMessageCount.text = "0"
        lblMessageCount.textAlignment = .center
        
        isRPCRemovedFromStack = false
        
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
            self.setNotificationCountObserver()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        isRPCRemovedFromStack = true
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        APIManager.sharedManager.timer.invalidate()         //  By PRanay
        APIManager.sharedManager.timerRPC.invalidate()      //  By PRanay
        listner?.remove()
    }
        
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isRPCRemovedFromStack = true
            APIManager.sharedManager.timer.invalidate()
            APIManager.sharedManager.timerRPC.invalidate()
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    //MARK: - UI Methods
    // timer to select option from R, P and S
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            for i in 0..<buttons.count {
                buttons[i].isEnabled = false
            }
            APIManager.sharedManager.timer.invalidate()
            if self.doc != nil {
                if(self.doc?.data()?["status"] as? String != Messages.rpcResultDone) {
                    
                    if !Network.reachability.isReachable {
                        self.isRetryInternet { (isretry) in
                            if isretry! {
                                self.callBackInfo()
                            }
                        }
                        return
                    }
                    
                    for i in 0..<selectImages.count {
                        selectImages[i].isHidden = true
                    }
                    if self.playerArr[self.opponent]["rpc"] as? String != "" {
                        // if opponent player has chose the option
                        if self.playerArr[self.opponent]["rpc"] as? String == "R" {
                            self.playerArr[self.myPlayerIndex]["rpc"] = "S" as AnyObject
                            self.selectImages[2].isHidden = false
                        } else if self.playerArr[self.opponent]["rpc"] as? String == "P" {
                            self.playerArr[self.myPlayerIndex]["rpc"] = "R" as AnyObject
                            self.selectImages[0].isHidden = false
                        } else {
                            self.playerArr[self.myPlayerIndex]["rpc"] = "P" as AnyObject
                            self.selectImages[1].isHidden = false
                        }
                        self.winner = self.opponent
                    } else {
                        //opponent and this player doesn't select option
                        self.playerArr[self.hostIndex]["rpc"] = "R" as AnyObject
                        self.playerArr[self.otherPlayerIndex]["rpc"] = "S" as AnyObject
                        
                        if self.myPlayerIndex == self.hostIndex {
                            self.selectImages[0].isHidden = false
                        } else {
                            self.selectImages[2].isHidden = false
                        }
                        self.winner = self.hostIndex
                    }
                    
                    let param = [
                        "playerDetails": playerArr,
                        "status" : Messages.rpcResultDone,
                        "stagePicBanPlayerId" : self.playerArr[self.winner]["playerId"] ?? 0
                    ] as [String: Any]
                    
//                    self.log.i("RPS update firestore callTimer() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if let err = err {
//                            self.log.e("RPS update firestore callTimer() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                            print("Error writing document: \(err)")
                        } else {
                            self.isClickOnProceed = true
                            self.winnerAction()
                        }
                    }
                }
                else {
                    //find winner
                    self.isClickOnProceed = true
                    if self.doc?.data()?["stagePicBanPlayerId"] as? Int != 0 {
                        if self.doc?.data()?["stagePicBanPlayerId"] as? Int == self.playerArr[self.hostIndex]["playerId"] as? Int {
                            self.winner = self.hostIndex
                        } else  {
                            self.winner = self.otherPlayerIndex
                        }
                        self.winnerAction()
                    }
                }
            }
        } else {
            lblTimer.text = "Time Limit: \(timeFormatted(seconds: timeSeconds))"
        }
    }
    
    //timer to choose player to ban stage first
    @objc func callTimer1()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            APIManager.sharedManager.timerRPC.invalidate()
            if self.doc != nil {
                if !Network.reachability.isReachable {
                    self.isRetryInternet { (isretry) in
                        if isretry! {
                            self.callBackInfo()
                        }
                    }
                    return
                }
                
//                self.log.i("RPS and callTimer1 over - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                
                self.playerArr[self.myPlayerIndex]["rpcSelected"] = "selected" as AnyObject
                self.playerArr[self.opponent]["rpcSelected"] = "selected" as AnyObject
                if (doc?.data()?["stagePicBanPlayerId"] as? Int != self.playerArr[self.opponent]["playerId"] as? Int) {
                    if isTie == false && (doc?.data()?["stagePicBanPlayerId"] as? Int == self.playerArr[self.winner]["playerId"] as? Int) {
                        
                        let param = [
                            "status": Messages.stagePickBan,
                            "stagePicBanPlayerId" : self.playerArr[self.myPlayerIndex]["playerId"] ?? 0,
                            "playerDetails": self.playerArr
                        ] as [String: Any]
                        
//                        self.log.i("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                            if let err = err {
//                                self.log.e("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                print("Error writing document: \(err)")
                            } else {
//                                self.log.i("RPS and update in if status -> \(Messages.stagePickBan). - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                if self.isFromHome {
                                    self.isFromHome = false
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        self.log.i("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument")  //  By Pranay.
                        let dbref = self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "")
                        dbref.getDocument { (documentNew, error) in
                            if let err = error {
//                                self.log.e("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument -- Error-> \(err)")  //  By Pranay.
                                print("Error getting documents: \(err)")
                            }
                            else {
                                if documentNew != nil {
//                                    self.log.i("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument --- response-> \(documentNew?.data())")  //  By Pranay.
                                    
                                    var arr1 = [[String:AnyObject]]()
                                    arr1 = documentNew?.data()?["bannedStages"] as! [[String : AnyObject]]
                                    if arr1.count == 0 {
                                        
                                        // By Pranay
                                        //self.playerArr = documentNew?.data()?["playerDetails"] as! [[String : AnyObject]]
                                        //self.playerArr[self.myPlayerIndex]["rpcSelected"] = "selected" as AnyObject
                                        //self.playerArr[self.opponent]["rpcSelected"] = "selected" as AnyObject
                                        // .
                                        
                                        let param = [
                                            "status": Messages.stagePickBan,
                                            "stagePicBanPlayerId" : self.playerArr[self.opponent]["playerId"] ?? 0,
                                            "playerDetails": self.playerArr
                                        ] as [String: Any]
                                        
//                                        self.log.i("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - updateData --- param-> \(param)")  //  By Pranay.
                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                            if let err = err {
//                                                self.log.e("RPS update firestore callTimer1() - over -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - updateData - Error-> \(err)")  //  By Pranay.
                                                print("Error writing document: \(err)")
                                            }
                                            else {
//                                                self.log.i("RPS and update in else status -> \(Messages.stagePickBan). - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                                if self.isFromHome {
                                                    self.isFromHome = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            // Double check if UI is correct with winner decided
            // this scenario occurs when player 1 has selected option and wait for player 2 to select. player 2 select at last moment as player 1 timer goes off
            // so chance are both player shows winner UI
            if timeSeconds == finalSeconds - 2 && isConfirmWinner == false {
                isConfirmWinner = true
//                self.log.i("RPS update firestore callTimer1() - isConfirmWinner == false -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
//                        self.log.e("RPS update firestore callTimer1() - isConfirmWinner == false -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument -- Error-> \(err)")  //  By Pranay.
                        print("Error getting documents: \(err)")
                    } else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        
//                        self.log.i("RPS update firestore callTimer1() - isConfirmWinner == false -- Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") - getDocument --- response-> \(newDoc?.data())")  //  By Pranay.
                        
                        if let theJSONData = try? JSONSerialization.data(withJSONObject: newDoc?.data(),options: []) {
                            //let theJSONText = String(data: theJSONData,encoding: .ascii)
                            //let jsonData = Data(theJSONText!.utf8)
                            let decoder = JSONDecoder()
                            do {
                                let arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                                self.arrPlayer = arrFire.playerDetails ?? []
                                if newDoc?.data()?["stagePicBanPlayerId"] as? Int == self.arrPlayer[self.myPlayerIndex].playerId {
                                    if self.btnNo.isHidden == true {
                                        self.isTimerRPCActive = false
                                        APIManager.sharedManager.timerRPC.invalidate()
                                        self.confirmWinnerUI()
                                    }
                                } else {
                                    if self.btnNo.isHidden != true {
                                        self.isTimerRPCActive = false
                                        APIManager.sharedManager.timerRPC.invalidate()
                                        self.confirmWinnerUI()
                                    }
                                }
                            } catch {
                                print("error")
                            }
                        }
                    }
                }
            }
            if (doc?.data()?["stagePicBanPlayerId"] as? Int == self.playerArr[self.opponent]["playerId"] as? Int) {
                lblTimerWin.text = "Opponent's time limit: \(timeFormatted(seconds: timeSeconds))"
            } else {
                lblTimerWin.text = "Time Limit: \(timeFormatted(seconds: timeSeconds))"
            }
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let newSeconds = ((seconds % 3600) % 60)
        return String(format: "%d:%d", minutes, newSeconds)
    }
    
    func confirmWinnerUI() {
        for i in 0..<self.selectImages.count {
            self.selectImages[i].isHidden = true
        }
        if self.arrPlayer[self.myPlayerIndex].rpc == "R" {
            self.selectImages[0].isHidden = false
        } else if self.arrPlayer[self.myPlayerIndex].rpc == "P" {
            self.selectImages[1].isHidden = false
        } else {
            self.selectImages[2].isHidden = false
        }
        self.winnerAction()
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
    
    func reloadTab() {
        print("update")
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
        APIManager.sharedManager.timerRPC.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 4
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isRPCRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func setData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaRockPaperScisierVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaRockPaperScisierVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaRockPaperScisierVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaRockPaperScisierVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaRockPaperScisierVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            let arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            
                            self.arrPlayer = arrFire.playerDetails ?? []
                            self.chatBadge()
                            
                            self.hostIndex = self.arrPlayer[0].host == 1 ? 0 : 1
                            self.otherPlayerIndex = self.hostIndex == 1 ? 0 : 1
                            
                            self.lblPlayer2Char.text = self.arrPlayer[self.otherPlayerIndex].characterName
                            self.lblPlayer1Char.text = self.arrPlayer[self.hostIndex].characterName
                            self.imgPlayer1.setImage(imageUrl: self.arrPlayer[self.hostIndex].characterImage ?? "")
                            self.imgPlayer2.setImage(imageUrl: self.arrPlayer[self.otherPlayerIndex].characterImage ?? "")
                            
                            let homeTeamName = (self.arrPlayer[self.hostIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.hostIndex].teamName ?? "")[..<(self.arrPlayer[self.hostIndex].teamName ?? "").index((self.arrPlayer[self.hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.hostIndex].teamName ?? "")
                            let awayTeamName = (self.arrPlayer[self.otherPlayerIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.otherPlayerIndex].teamName ?? "")[..<(self.arrPlayer[self.otherPlayerIndex].teamName ?? "").index((self.arrPlayer[self.otherPlayerIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.otherPlayerIndex].teamName ?? "")
                            
                            self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : homeTeamName
                            self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.otherPlayerIndex].displayName ?? "") : awayTeamName
                            
                            //screen opens directly from home tab
                            if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                /// Scheduled removed by Orgaizer
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
                                APIManager.sharedManager.timer.invalidate()
                                APIManager.sharedManager.timerRPC.invalidate()
                                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                for aViewController in viewControllers {
                                    APIManager.sharedManager.match?.resetMatch = 1
                                    if aViewController is ArenaMatchResetVC {
                                        self.navigationController!.popToViewController(aViewController, animated: true)
                                        break
                                    }
                                    else {
                                        let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaMatchResetVC") as! ArenaMatchResetVC
                                        stagePickVC.leagueTabVC = self.leagueTabVC
                                        self.navigationController?.pushViewController(stagePickVC, animated: true)
                                        break
                                    }
                                }
                                
                                return
                            }
                            else if self.isFromHome {
                                if self.doc?.data()?["status"] as? String == Messages.selectRPC {
                                    self.isFromHome = false
                                    self.selectedOption = self.arrPlayer[self.myPlayerIndex].rpc ?? ""
                                    if self.selectedOption != "" {
                                        APIManager.sharedManager.timer.invalidate()
                                        if self.selectedOption == "R" {
                                            self.selectedType = 0
                                        }
                                        else if self.selectedOption == "P" {
                                            self.selectedType = 1
                                        }
                                        else {
                                            self.selectedType = 2
                                        }
                                        self.selectImages[self.selectedType].isHidden = false
                                    }
                                    else {
                                        if UserDefaults.standard.object(forKey: "tieRPS") != nil {
                                            //tie
                                            APIManager.sharedManager.timer.invalidate()
                                            self.selectedOption = UserDefaults.standard.string(forKey: "tieRPS") ?? ""
                                            self.tieAction()
                                        }
                                        else {
                                            self.selectedType = -1
                                        }
                                    }
                                }
                                else {
                                    //self.isFromHome = false
                                    APIManager.sharedManager.timer.invalidate()
                                    self.winnerAction()
                                }
                            }
                            else {
                                //case: this player came from another tab(selectOption = "") and later on opponent decided winner (selectOption != ""). so assign your option value to selectOption
                                if self.doc?.data()?["status"] as? String == Messages.rpcResultDone {
                                    if self.selectedOption == "" {
                                        self.selectedOption = self.arrPlayer[self.myPlayerIndex].rpc ?? ""
                                        self.setChooseImage(id: self.myPlayerIndex)
                                    }
                                }
                            }
                            
                            //if winner is declared
                            if self.winnerChosen {
                                if self.doc?.data()?["stagePicBanPlayerId"] as? Int == self.arrPlayer[self.myPlayerIndex].playerId {
                                    //not from home screen
                                    //winner is this player
                                    
                                    self.isFromHome = false
                                    self.listner?.remove()
                                    APIManager.sharedManager.timer.invalidate()
                                    APIManager.sharedManager.timerRPC.invalidate()
                                    let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
                                    arenaLobby.tusslyTabVC = self.tusslyTabVC
                                    arenaLobby.leagueTabVC = self.leagueTabVC
                                    if self.isRPCRemovedFromStack == false {
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    }
                                }
                                else {
                                    //winner is opponent
                                    self.isFromHome = false
                                    self.navigateToBan()
                                }
                            }
                            else {
                                if (self.doc?.data()?["status"] as? String == Messages.stagePickBan) && (self.doc?.data()?["stagePicBanPlayerId"] as? Int == self.arrPlayer[self.myPlayerIndex].playerId) {
                                    self.isFromHome = false
                                    self.listner?.remove()
                                    APIManager.sharedManager.timer.invalidate()
                                    APIManager.sharedManager.timerRPC.invalidate()
                                    let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
                                    arenaLobby.tusslyTabVC = self.tusslyTabVC
                                    arenaLobby.leagueTabVC = self.leagueTabVC
                                    if self.isRPCRemovedFromStack == false {
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    }
                                    return
                                }
                                //winner not decided yet
                                self.opponentStatus = self.arrPlayer[self.opponent].rpc ?? ""
                                if self.opponentStatus != "" && self.selectedOption != "" {
                                    //both player select option
                                    if self.opponentStatus == self.selectedOption {
                                        self.isConfirmTie = true
                                        self.tieAction()
                                    } else {
                                        self.winnerAction()
                                    }
                                }
                                else if self.selectedOption != "" {
                                    //this player has selected option but opponent hasn't
                                    self.listner?.remove()
                                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                    dialog.isLoader = false
                                    //dialog.timeSeconds = self.finalSeconds
                                    dialog.timeSeconds = self.timeSeconds
                                    dialog.modalPresentationStyle = .overCurrentContext
                                    dialog.modalTransitionStyle = .crossDissolve
                                    dialog.arenaFlow = "WaitingOpponentRPC"
                                    dialog.descriptionString = "Waiting for your opponent to select a option."
                                    dialog.manageOnStatus = { rpc in
                                        if rpc == "Tie"{
                                            if APIManager.sharedManager.timer.isValid == true {
//                                                self.log.i("ArenaRockPaperScisierVC Remove previous active timer - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                                APIManager.sharedManager.timer.invalidate()
                                            }
                                            self.tieAction()
                                        }
                                        self.setData()
                                    }
                                    if self.isRPCRemovedFromStack == false {
                                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                    }
                                }
                                else if self.selectedOption == "" {
                                    //check if other player has updated your rpc or not
                                    if self.isTie == false {
                                        if self.arrPlayer[self.myPlayerIndex].rpc != "" {
                                            self.setChooseImage(id: self.myPlayerIndex)
                                            self.selectedOption = self.arrPlayer[self.myPlayerIndex].rpc ?? ""
                                            self.winnerAction()
                                        }
                                    }
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
        
    func tieAction() {
        // Double check if winner is decided but UI shows tie
        // this scenario occurs when player 1 has selected option and wait for player 2 to select. player 2 select at last moment as player 1 timer goes off
        // so chance are both player shows tie UI
        
//        self.log.i("Get document in tieAction() -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("Get document in tieAction() -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                var newDoc:DocumentSnapshot?
                newDoc = querySnapshot!
                
//                self.log.i("Get document in tieAction() response -- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                
                if let theJSONData = try? JSONSerialization.data(withJSONObject: newDoc?.data(),options: []) {
                    //let theJSONText = String(data: theJSONData,encoding: .ascii)
                    //let jsonData = Data(theJSONText!.utf8)
                    let decoder = JSONDecoder()
                    do {
                        let arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                        self.arrPlayer = arrFire.playerDetails ?? []
                        if newDoc?.data()?["status"] as? String == Messages.rpcResultDone {
                            APIManager.sharedManager.timer.invalidate()
                            self.isTieFinish  = true
                            self.confirmWinnerUI()
                        }
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        //if tie happes
        if isTieFinish == false {
            if self.arrPlayer[self.myPlayerIndex].rpc != self.arrPlayer[self.opponent].rpc && self.isConfirmTie == true {
                self.playerArr[self.myPlayerIndex]["rpc"] = "" as AnyObject
                self.playerArr[self.opponent]["rpc"] = "" as AnyObject
                
//                self.log.i("Get document in tieAction() clear rpc key -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \"playerDetails : \(self.playerArr)\"")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(["playerDetails": self.playerArr]) { err in
                    if let err = err {
//                        self.log.e("Get document in tieAction() clear rpc key Fail -- \(APIManager.sharedManager.user?.userName ?? "") --- Error-> \(err)")  //  By Pranay.
                    }
                }
            } else {
                for i in 0..<selectImages.count {
                    selectImages[i].isHidden = true
                }
                if selectedOption == "R" {
                    self.imgTieOption1.image = UIImage(named: "Rock_left")
                    self.imgTieOption2.image = UIImage(named: "Rock_right")
                }
                else if selectedOption == "P" {
                    self.imgTieOption1.image = UIImage(named: "Paper_left")
                    self.imgTieOption2.image = UIImage(named: "Paper_right")
                }
                else {
                    self.imgTieOption1.image = UIImage(named: "Scissor_left")
                    self.imgTieOption2.image = UIImage(named: "Scissor_right")
                }
                APIManager.sharedManager.timer.invalidate()
                UserDefaults.standard.set(selectedOption, forKey: "tieRPS")
                self.selectedOption = ""
                self.isTie = true
                self.selectedType = -1
                timeSeconds = finalSeconds
                APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                updateUI()
            }
        }
        isConfirmTie = false
    }
    
    func updateUI() {
        if selectedType != -1 {
            btnProceed.isEnabled = true
            btnProceed.backgroundColor = Colors.theme.returnColor()
            self.btnProceed.titleLabel?.textColor = UIColor.white
        }else {
            btnProceed.isEnabled = false
            btnProceed.backgroundColor = Colors.border.returnColor()
            self.btnProceed.titleLabel?.textColor = UIColor.white
        }
        
        if isTie {
            btnProceedTopConst.constant = 0
            viewTie.isHidden = false
            viewWin.isHidden = true
            viewHeightConst.constant = 370
            btnProceed.isHidden = false
            viewBottomWin.isHidden = true
        } else {
            btnProceedTopConst.constant = 90
            viewTie.isHidden = true
            viewWin.isHidden = false
            viewHeightConst.constant = 430
            btnProceed.isHidden = true
            viewBottomWin.isHidden = false
            viewTimeLimit.isHidden = true
            viewHeaderHeight.constant = 50
            
            for i in 0..<buttons.count {
                buttons[i].isEnabled = false
            }
            
            // I am winner
            if(self.doc?.data()?["stagePicBanPlayerId"] as? Int == self.arrPlayer[self.myPlayerIndex].playerId){
                lblOpponentMessage.isHidden = true
                btnNo.isHidden = false
                btnYes.isHidden = false
                winner = myPlayerIndex
            }
            else {
                if self.doc?.data()?["stagePicBanPlayerId"] as? Int == 0 {
                    if((self.arrPlayer[self.myPlayerIndex].rpc == "R" && self.arrPlayer[self.opponent].rpc == "P") || (self.arrPlayer[self.myPlayerIndex].rpc == "P" && self.arrPlayer[self.opponent].rpc == "R")){ // winner P
                        if self.arrPlayer[self.myPlayerIndex].rpc == "P" {
                            self.winner = self.myPlayerIndex
                        } else {
                            self.winner = self.opponent
                        }
                    }
                    else if((self.arrPlayer[self.myPlayerIndex].rpc == "S" && self.arrPlayer[self.opponent].rpc == "P") || (self.arrPlayer[self.myPlayerIndex].rpc == "P" && self.arrPlayer[self.opponent].rpc == "S")){ // winner S
                        if self.arrPlayer[self.myPlayerIndex].rpc == "S" {
                            self.winner = self.myPlayerIndex
                        }
                        else {
                            self.winner = self.opponent
                        }
                    }
                    else { // winner R
                        if self.arrPlayer[self.myPlayerIndex].rpc == "R" {
                            self.winner = self.myPlayerIndex
                        }
                        else {
                            self.winner = self.opponent
                        }
                    }
                    
                    if winner == myPlayerIndex {
                        lblOpponentMessage.isHidden = true
                    }
                    else {
                        btnNo.isHidden = true
                        btnYes.isHidden = true
                    }
                }
                else {
                    lblOpponentMessage.isHidden = false
                    winner = opponent
                    btnNo.isHidden = true
                    btnYes.isHidden = true
                }
            }
            
            let img = playerArr[winner]["characterImage"]
            imgWinner.setImage(imageUrl: img as! String)
            
            let winnerTeamName = (playerArr[winner]["teamName"] as? String ?? "").count > 30 ? String((playerArr[winner]["teamName"] as? String ?? "")[..<(playerArr[winner]["teamName"] as? String ?? "").index((playerArr[winner]["teamName"] as? String ?? "").startIndex, offsetBy: 30)]) : (playerArr[winner]["teamName"] as? String ?? "")
            
            lblWinnerName.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (playerArr[winner]["displayName"] as? String ?? "") : winnerTeamName
            lblWinnerChar.text = playerArr[winner]["characterName"] as? String
        }
        viewFirst.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    func winnerAction() {
//        self.log.i("Get document in winnerAction() -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("Get document in winnerAction() Fail -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                var newDoc:DocumentSnapshot?
                newDoc = querySnapshot!
                
//                self.log.i("Get document in winnerAction() response -- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                
                let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                // if both player select different options and proceed at same time then it might possible that one player will have result declare and another player still waits. To avaoid this scenario, check first if status == Select RPC then update it to RPC Result done else continue with flow.
                
                if newDoc?.data()?["status"] as! String == Messages.selectRPC
                {
                    if((self.selectedOption == "R" && playerArr[self.opponent]["rpc"] as! String == "P") || (self.selectedOption == "P" && playerArr[self.opponent]["rpc"] as! String == "R"))
                    { // winner P
                        if self.selectedOption == "P" {
                            self.winner = self.myPlayerIndex
                        }
                        else {
                            self.winner = self.opponent
                        }
                    }
                    else if((self.selectedOption == "S" && playerArr[self.opponent]["rpc"] as! String == "P") || (self.selectedOption == "P" && playerArr[self.opponent]["rpc"] as! String == "S"))
                    { // winner S
                        if self.selectedOption == "S" {
                            self.winner = self.myPlayerIndex
                        }
                        else {
                            self.winner = self.opponent
                        }
                    }
                    else { // winner R
                        if self.selectedOption == "R" {
                            self.winner = self.myPlayerIndex
                        }
                        else {
                            self.winner = self.opponent
                        }
                    }
                    self.playerArr[self.myPlayerIndex]["rpc"] = self.selectedOption as AnyObject
                    self.playerArr[self.opponent]["rpc"] = playerArr[self.opponent]["rpc"] as! String as AnyObject
                    
                    let param = [
                        "playerDetails": self.playerArr,
                        "status" : Messages.rpcResultDone,
                        "stagePicBanPlayerId" : playerArr[self.winner]["playerId"] ?? 0
                    ] as [String: Any]
                    
//                    self.log.i("Declare round winner in winnerAction() updateData -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if let err = err {
//                            self.log.e("Declare round winner in winnerAction() updateData Fail -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                        }
                    }
                }
                else {
                    if playerArr[self.hostIndex]["rpc"] as! String == "R" {
                        self.imgWinOption1.image = UIImage(named: "Rock_left")
                    }
                    else if playerArr[self.hostIndex]["rpc"] as! String == "P" {
                        self.imgWinOption1.image = UIImage(named: "Paper_left")
                    }
                    else {
                        self.imgWinOption1.image = UIImage(named: "Scissor_left")
                    }

                    if playerArr[self.otherPlayerIndex]["rpc"] as! String == "R" {
                        self.imgWinOption2.image = UIImage(named: "Rock_right")
                    }
                    else if playerArr[self.otherPlayerIndex]["rpc"] as! String == "P" {
                        self.imgWinOption2.image = UIImage(named: "Paper_right")
                    }
                    else {
                        self.imgWinOption2.image = UIImage(named: "Scissor_right")
                    }
                    
                    if self.isFromHome {
                        self.setChooseImage(id: self.myPlayerIndex)
                    }
                    else {
                        if self.selectedType == -1 {
                            self.setChooseImage(id: self.hostIndex == self.myPlayerIndex ? self.hostIndex : self.otherPlayerIndex)
                        }
                    }
                    
                    self.winnerChosen = true
                    
                    if self.isTimerRPCActive == false {
                        self.isTimerRPCActive = true
                        APIManager.sharedManager.timer.invalidate()
                        self.timeSeconds = self.finalSeconds
                        APIManager.sharedManager.timerRPC.invalidate()
                        APIManager.sharedManager.timerRPC = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer1), userInfo: nil, repeats: true)
                    }
                    self.isTie = false
                    self.updateUI()
                }
            }
        }
    }
    
    func setChooseImage(id: Int) {
        for i in 0..<selectImages.count {
            selectImages[i].isHidden = true
        }
        if self.arrPlayer[id].rpc ?? "" == "R" {
            self.selectedType = 0
        } else if self.arrPlayer[id].rpc ?? "" == "P" {
            self.selectedType = 1
        } else {
            self.selectedType = 2
        }
        self.selectImages[self.selectedType].isHidden = false
    }
    
    func navigateToBan() {
        if self.playerArr[self.myPlayerIndex]["rpcSelected"] as? String != "" {
            APIManager.sharedManager.timer.invalidate()
            APIManager.sharedManager.timerRPC.invalidate()
            self.listner?.remove()
            
            var waitingMsg = "Your opponent is selecting a stage to ban."
            var arenaFlow = "FirstStageBan"
            if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![0].banCount?.count)! > 0 {
                waitingMsg = "Your opponent is selecting a stage to ban."
                arenaFlow = "FirstStageBan"
                print("FirstStageBan === \((APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![0].banCount?.count)!)")
            }
            else {
                //waitingMsg = "Select a stage to play on!"
                waitingMsg = "Your opponent is picking a stage to play on."
                arenaFlow = "lastStageToPick"
                print("lastStageToPick === \((APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![0].banCount?.count)!)")
            }
            
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.isLoader = false
            //dialog.timeSeconds = finalSeconds
            dialog.timeSeconds = ((APIManager.sharedManager.match?.matchType == Messages.regular || APIManager.sharedManager.match?.matchType == Messages.tournament) ? APIManager.sharedManager.content?.regularArenaTimeSettings?.timerForBanOrPickStage : APIManager.sharedManager.content?.playoffArenaTimeSettings?.timerForBanOrPickStage) ?? 15
            timeSeconds = finalSeconds
            dialog.descriptionString = waitingMsg
            dialog.arenaFlow = arenaFlow
            dialog.tapOk = {
                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaStagePickVC") as! ArenaStagePickVC
                arenaLobby.tusslyTabVC = self.tusslyTabVC
                arenaLobby.leagueTabVC = self.leagueTabVC
                if self.isRPCRemovedFromStack == false {
                    self.navigationController?.pushViewController(arenaLobby, animated: true)
                }
            }
            dialog.manageOnStatus = { statusIs in
                if statusIs == "Schedule Removed" {
                    self.scheduledRemoved()
                }
                else if statusIs == "Match Forfeit" {
                    self.navigateToArenaRoundResult()
                }
                else if statusIs == "Match Reset" {
                    self.navigateToArenaMatchReset()
                }
            }
            if self.isRPCRemovedFromStack == false {
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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
        
        APIManager.sharedManager.timer.invalidate()
        selectedOption = selectedType == 0 ? "R" : selectedType == 1 ? "P" : "S"
        isClickOnProceed = true
        self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
        self.playerArr[self.myPlayerIndex]["rpc"] = self.selectedOption as AnyObject
        var param = [String:AnyObject]()
        
//        self.log.i("RPS proceed tap - Remain time ->\(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        
        if opponentStatus != "" {
            if opponentStatus == self.playerArr[self.myPlayerIndex]["rpc"] as? String{
                //Tie
                self.playerArr[self.myPlayerIndex]["rpc"] = "" as AnyObject
                self.playerArr[self.opponent]["rpc"] = "" as AnyObject
                
//                self.log.i("RPS proceed tap - Remain time ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->playerDetails = \(self.playerArr)")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(["playerDetails": self.playerArr]) { err in
                    if let err = err {
//                        self.log.e("RPS proceed tap - Remain time Fail ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->playerDetails = \(self.playerArr) --- Error-> \(err)")  //  By Pranay.
                    }
                }
            }
            else {
                //not a tie
                if((self.selectedOption == "R" && opponentStatus == "P") || (self.selectedOption == "P" && opponentStatus == "R")){ // winner P
                    if self.selectedOption == "P" {
                        self.winner = self.myPlayerIndex
                    }
                    else {
                        self.winner = self.opponent
                    }
                }
                else if((self.selectedOption == "S" && opponentStatus == "P") || (self.selectedOption == "P" && opponentStatus == "S")){ // winner S
                    if self.selectedOption == "S" {
                        self.winner = self.myPlayerIndex
                    }
                    else {
                        self.winner = self.opponent
                    }
                }
                else { // winner R
                    if self.selectedOption == "R" {
                        self.winner = self.myPlayerIndex
                    }
                    else {
                        self.winner = self.opponent
                    }
                }
                self.playerArr[self.myPlayerIndex]["rpc"] = self.selectedOption as AnyObject
                param = [
                    "playerDetails": self.playerArr,
                    "status" : Messages.rpcResultDone,
                    "stagePicBanPlayerId" : playerArr[winner]["playerId"] ?? 0
                ] as [String:AnyObject]
                
//                self.log.i("RPS proceed tap update result - Remain time ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param)")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                    if let err = err {
//                        self.log.i("RPS proceed tap update result Fail - Remain time ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param) --- Error-> \(err)")  //  By Pranay.
                    }
                }
            }
        } else {
            param = ["playerDetails": playerArr] as [String:AnyObject]
            
//            self.log.i("RPS proceed tap update selected option - Remain time ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
//                    self.log.i("RPS proceed tap update selected option Fail - Remain time ->\(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? "") --- param->\(param) --- Error-> \(err)")  //  By Pranay.
                }
            }
        }
    }
    
    @IBAction func proceedStageTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
//        self.log.i("RPS Winner select Yes/No - Remain time ->\(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") = Selected option -> \(sender.tag == 0 ? "Yes" : "No")")  //  By Pranay.
        
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("RPS Winner Select, don't get document. - Remain time ->\(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
                var newDoc:DocumentSnapshot?
                newDoc = querySnapshot!
                
//                self.log.i("RPS Winner Select, get document. - Remain time ->\(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                
                let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                
                if newDoc?.data()?["stagePicBanPlayerId"] as? Int == playerArr[self.myPlayerIndex]["playerId"] as? Int {
                    if self.isFromHome {
                        self.isFromHome = false
                    }
                    APIManager.sharedManager.timerRPC.invalidate()
                    let myId : Int = (self.playerArr[self.myPlayerIndex]["playerId"] as? Int) ?? 0
                    let otherPlayerId : Int = (self.playerArr[self.opponent]["playerId"] as? Int) ?? 0
                    self.playerArr[self.myPlayerIndex]["rpcSelected"] = "selected" as AnyObject
                    self.playerArr[self.opponent]["rpcSelected"] = "selected" as AnyObject
                    
                    let param = [
                        "status": Messages.stagePickBan,
                        "stagePicBanPlayerId" : sender.tag == 0 ? myId : otherPlayerId,
                        "playerDetails": self.playerArr
                    ] as [String: AnyObject]
                    
//                    self.log.i("RPS Winner set stagePicBanPlayerId on Yes/No tap. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                        if err != nil {
//                            self.log.e("RPS Winner Yes/No tap get error. - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                        } else {
//                            self.log.i("RPS Winner Yes/No tap successful. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func rockPaperScicerTapped(_ sender: UIButton) {
        selectedType = sender.tag
        for i in 0..<selectImages.count {
            selectImages[i].isHidden = true
        }
        selectImages[sender.tag].isHidden = false
        
        btnProceed.isEnabled = true
        btnProceed.backgroundColor = Colors.theme.returnColor()
        self.btnProceed.titleLabel?.textColor = UIColor.white
    }
}

extension ArenaRockPaperScisierVC {
    
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
                //self.setData()
            }
        }
    }
}
