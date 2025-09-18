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

class ArenaEnterBattleIDVC: UIViewController, UITextFieldDelegate, refreshTabDelegate {
    
    // MARK: - Variables
    
    var playerArr = [[String:AnyObject]]()
    let db = Firestore.firestore()
    var myPlayerIndex = 0
    var opponent = 1
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isTapChat = false
    var isHostIdRemovedFromStack = false
    
//    fileprivate let log = ShipBook.getLogger(ArenaEnterBattleIDVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var viewEnterID : UIView!
    @IBOutlet weak var txtEnterId : UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblEnterID: UILabel!
    @IBOutlet weak var btnHowDoIGetID: UIButton!
    
    
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var viewProceed: UIView!
    @IBOutlet weak var lblDesc1: UILabel!
    @IBOutlet weak var lblDesc2: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var viewWaitMsg: UIView!
    @IBOutlet weak var lblWaitMsg1: UILabel!
    @IBOutlet weak var btnGameSettings: UIButton!
    @IBOutlet weak var constbtnGetIdToSubmit: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .   */
        
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        viewEnterID.layer.cornerRadius = viewEnterID.frame.size.height / 2
        //txtEnterId.delegate = self
        viewEnterID.layer.borderWidth = 1.0
        viewEnterID.layer.borderColor = Colors.border.returnColor().cgColor
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        
        
        let gameId: Int = APIManager.sharedManager.gameSettings?.id ?? 0
        var placeHolderMsg: String
        
        switch gameId {
        case 11, 15:        // 11-SSBU, 15-VF5
            placeHolderMsg = "Enter the ID and Password here."
        case 16:        // NASB2
            placeHolderMsg = "Enter the Lobby Password."
        default:
            placeHolderMsg = ""
        }
        
        lblTitle.text = APIManager.sharedManager.gameSettings?.gameLabel ?? ""
        //lblDesc.text = "You are the host of this match. Set up a \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") in the game and send the ID and Password (optional) below to your opponent so they can join."
        lblDesc.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.hostMsg ?? ""
        lblEnterID.text = APIManager.sharedManager.gameSettings?.gameLabel ?? ""
        btnHowDoIGetID.setTitle("How do I get a \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")? >", for: .normal)
        
        self.txtEnterId.placeholder = placeHolderMsg
        
        
        self.viewProceed.isHidden = true
        self.viewProceed.backgroundColor = .white
        self.btnProceed.layer.cornerRadius = self.btnProceed.frame.size.height / 2
        self.viewWaitMsg.isHidden = true
        
        self.btnGameSettings.isHidden = (APIManager.sharedManager.gameSettings?.isGameSetting ?? 0 == 0) ? true : false
        self.constbtnGetIdToSubmit.constant = (APIManager.sharedManager.gameSettings?.isGameSetting ?? 0 == 0) ? 2 : -8
        
        DispatchQueue.main.async {
            print("View did load called - Enter Battle ID")
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        /// 224 - By Pranay
        //lblMessage.attributedText = message.setMultiBoldString(boldString: arrHighlightString, fontSize: 16.0)
        //The BattleArenaID has been sent to your opponent.
        //
        //["Players:", "Teams:", "Tournaments:"]
        
        self.lblDesc1.text = "The \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") has been sent to your opponent."
        self.lblDesc2.attributedText = "DO NOT tap proceed until BOTH you and your opponent have entered the \(APIManager.sharedManager.gameSettings?.gameLabel2 ?? "") in the Game.".setMultiBoldUnderlineString(boldString: ["DO NOT", "BOTH"], fontSize: 15.0)
        /// 224 .
        
        print("View will appear called - Enter Battle ID")
        if isTapChat {
            print("View will appear called - Enter Battle ID - isTapChat")
            isTapChat = false
            self.leagueTabVC!().showUnreadCount = false
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
        print("FirebaseId ArenaEnterBattleIDVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaEnterBattleIDVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaEnterBattleIDVC listner call fail - \(APIManager.sharedManager.user?.userName ?? "") -- Error->\(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaEnterBattleIDVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    self.chatBadge()
                    
                    //self.log.i("ArenaEnterBattleIDVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    if self.playerArr[self.myPlayerIndex]["ssbmConnectProceed"] as! Int == 0 {
                        var playerArr = [[String:AnyObject]]()
                        playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        playerArr[self.myPlayerIndex]["ssbmConnectProceed"] = 1 as AnyObject
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                            "playerDetails":playerArr
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                        }
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
                    else if self.doc?.data()?["resetMatch"] as? Int == 1
                    {
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
                    else if self.doc?.data()?["status"] as? String == Messages.enteringBattleId
                    {
                        self.viewProceed.isHidden = true
                        self.viewWaitMsg.isHidden = true
                        self.btnSubmit.isEnabled = true
                        self.btnSubmit.backgroundColor = Colors.activeButton.returnColor()
                        self.txtEnterId.isUserInteractionEnabled = true
                    }
                    else if (self.doc?.data()?["status"] as? String == Messages.enteredBattleId)
                    {
                        self.txtEnterId.text = self.doc?.data()?["battelArenaId"] as? String
                        self.txtEnterId.isUserInteractionEnabled = false
                        self.btnSubmit.backgroundColor = Colors.disableButton.returnColor()
                        self.btnSubmit.isEnabled = false
                        self.viewProceed.isHidden = false
                        
                        self.viewWaitMsg.isHidden = true
                        self.btnProceed.isEnabled = true
                        self.btnProceed.backgroundColor = Colors.activeButton.returnColor()
                        self.viewWaitMsg.isHidden = true
                        
                        if self.doc?.data()?["weAreReadyBy"] as! Int == (self.playerArr[self.myPlayerIndex]["playerId"] as! Int) {
                            self.btnProceed.isEnabled = false
                            self.btnProceed.backgroundColor = Colors.disableButton.returnColor()
                            self.viewWaitMsg.isHidden = false
                        }
                    }
                    else if self.doc?.data()?["status"] as? String == Messages.battleIdFail
                    {
                        self.battleIdFail()
                    }
                    else if self.doc?.data()?["status"] as? String == Messages.characterSelection
                    {
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                        arenaLobby.leagueTabVC = self.leagueTabVC
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    }
                }
            }
        }
    }
    
    func doubleConfirmID() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        let roundStartTime = Int(NSDate().timeIntervalSince1970)
        self.listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = ""
        dialog.message = Messages.confirmBothReady
        dialog.highlightString = ""
        dialog.isFromIDDoubleConfirm = true
        dialog.tapOK = {
            //update weAreReadyBy key by your(host) id to confirm to select character
            if !self.isHostIdRemovedFromStack {
                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                    "weAreReadyBy" : self.playerArr[self.myPlayerIndex]["playerId"]!
                    //"gameStartTime": roundStartTime
                ]) { err in
                    if let err = err {
                        Utilities.showPopup(title: "\(err)", type: .error)
                    } else {
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                        arenaLobby.leagueTabVC = self.leagueTabVC
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    }
                }
            }
        }
        dialog.btnYesText = Messages.confirm
        if !isHostIdRemovedFromStack {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh area tab")
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == txtEnterId{
            return checkBattleIdFormat(string: string, str: str)
        }else{
            return true
        }
    }
    
    func checkBattleIdFormat(string: String?, str: String?) -> Bool{
        if string == ""{ //BackSpace
            return true
        }else if str?.last == " " {
            return false
        }else if str!.count == 6{
            txtEnterId.text = txtEnterId.text! + "-"
        }else if str!.count > 11{
            return false
        }
        return true
    }
    
    func battleIdFail() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        self.listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaBattleArenaFailPopupVC") as! ArenaBattleArenaFailPopupVC
        dialog.id = self.txtEnterId.text ?? ""
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.isComeFromEnterID = true
        dialog.tapOk = { areBothIn in
            if areBothIn { //opponent ready to chat
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = Messages.confirm
                dialog.message = Messages.readyToJoinMatch
                dialog.highlightString = ""
                dialog.isFromBattleId = true
                dialog.tapOkForBattleId = { isReady in
                    if isReady { // opponent confirm to select character
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                        arenaLobby.leagueTabVC = self.leagueTabVC
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    } else {
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                            "status" : Messages.characterSelection
                        ]) { err in
                            if let err = err {
                                Utilities.showPopup(title: "\(err)", type: .error)
                            } else {
                                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                arenaLobby.tusslyTabVC = self.tusslyTabVC
                                arenaLobby.leagueTabVC = self.leagueTabVC
                                self.navigationController?.pushViewController(arenaLobby, animated: true)
                            }
                        }
                    }
                }
                dialog.tapCancel = {
                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                        "weAreReadyBy" : 0
                    ]) { err in
                        if let err = err {
                            Utilities.showPopup(title: "\(err)", type: .error)
                        } else {
                            self.battleIdFail()
                        }
                    }
                }
                dialog.btnYesText = Messages.yes
                dialog.btnNoText = Messages.no
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }
            else {
                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWeAreBothInVC") as! ArenaWeAreBothInVC
                arenaLobby.tusslyTabVC = self.tusslyTabVC
                arenaLobby.leagueTabVC = self.leagueTabVC
                arenaLobby.isBattleIdFail = self.doc?.data()?["appLozicGroupId"] as? String != "" ? true : false
                arenaLobby.groupchatId = self.doc?.data()?["appLozicGroupId"] as? String ?? ""
                self.navigationController?.pushViewController(arenaLobby, animated: true)
            }
        }
        if !isHostIdRemovedFromStack {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }

    // MARK: - Button Click Events
    @IBAction func submitTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        //submit battleId
        if txtEnterId.text != "" {
//            self.log.i("Submit tap - \(APIManager.sharedManager.user?.userName ?? "") -- battelArenaId -> \(txtEnterId.text!) -- \(APIManager.sharedManager.gameSettings?.customId ?? 0).")
            if self.btnSubmit.isEnabled {
                self.btnSubmit.isEnabled = false 
                playerArr[self.myPlayerIndex]["battleInStatus"] = true as AnyObject
                
                let param = [
                    "status" : Messages.enteredBattleId,
                    "playerDetails" : self.playerArr,
                    "battelArenaId" : self.txtEnterId.text ?? ""
                ] as [String: Any]
                
//                self.log.i("ArenaEnterBattleIDVC update submitTapped() - \(APIManager.sharedManager.user?.userName ?? "") -- status and playerDetails --- param-> \(param)")
                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                    if let err = err {
                        Utilities.showPopup(title: "\(err)", type: .error)
                        self.btnSubmit.isEnabled = true
//                        self.log.e("BattelArenaId firebase update fail - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")
                    }
                    else {
//                        self.log.i("BattelArenaId firebase update success - \(APIManager.sharedManager.user?.userName ?? "") -- battelArenaId -> \(self.txtEnterId.text!).")
                    }
                }
            }
        }
        else
        {
            Utilities.showPopup(title: Messages.enterBattleId, type: .error)
        }
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaGameSettingPopupVC") as! ArenaGameSettingPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func getBattleArenaTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleLoby = APIManager.sharedManager.content?.arenaContents?.how_to_get_battle_arena_id?.heading ?? ""
        let totalData = APIManager.sharedManager.content?.arenaContents?.how_to_get_battle_arena_id?.data
        let count : Int = totalData?.count ?? 0
        for i in 0 ..< count {
            dialog.arrLoby.append(GameLobby(id: i+1, stepNo: i+1, lobbyContent: totalData?[i].description ?? ""))
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func btnProceed(_ sender: UIButton) {
        if self.btnProceed.isEnabled {
            self.btnProceed.isEnabled = false
            self.viewWaitMsg.isHidden = false
            self.btnProceed.backgroundColor = Colors.disableButton.returnColor()
            let roundStartTime = Int(NSDate().timeIntervalSince1970)
            
            var param : [String: Any]
            
            if doc?.data()?["weAreReadyBy"] as! Int == 0 {
                param = [
                    "weAreReadyBy": self.playerArr[myPlayerIndex]["playerId"] ?? 0
                ] as [String: Any]
                
//                self.log.i("ArenaEnterBattleIDVC Proceed btn tap while 'weAreReadyBy = 0' -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                //listner?.remove()
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
//                        self.log.e("ArenaEnterBattleIDVC Proceed btn tap 'Update weAreReadyBy with playerID fail' - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                    } else {
                        self.btnProceed.isEnabled = false
                        self.btnProceed.backgroundColor = Colors.disableButton.returnColor()
                        self.viewWaitMsg.isHidden = false
//                        self.log.i("ArenaEnterBattleIDVC Proceed btn tap 'Update weAreReadyBy with playerID success' - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                    }
                }
            }
            else {
                param = [
                    "status": Messages.characterSelection
                    //"gameStartTime": roundStartTime
                ] as [String: Any]
                
//                self.log.i("ArenaEnterBattleIDVC Proceed btn tap while 'weAreReadyBy != 0' -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
//                        self.log.e("ArenaEnterBattleIDVC Proceed btn tap 'Update status to characterSelection fail' - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                    }
                }
                //print("Proceed button tap else part --- \(Messages.characterSelection)")
            }   /// */
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

extension ArenaEnterBattleIDVC {
    
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
