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

class ArenaViewBattleIDVC: UIViewController, refreshTabDelegate {
    
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
//    fileprivate let log = ShipBook.getLogger(ArenaViewBattleIDVC.self)
    var placeHolderMsg: String = ""
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var viewEnterID : UIView!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var lblBattleId : UILabel!

    
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblEnterID: UILabel!
    @IBOutlet weak var btnHowDoIGetID: UIButton!
    @IBOutlet weak var lblDesc2: UILabel!
    @IBOutlet weak var viewWaitMsg: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        //btnNo.layer.cornerRadius = btnNo.frame.size.height / 2
        btnYes.layer.cornerRadius = btnYes.frame.size.height / 2
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        viewEnterID.layer.cornerRadius = viewEnterID.frame.size.height / 2
        
        ////Beta 1 - Disable option
        //btnNo.backgroundColor = Colors.disableButton.returnColor()
        
        self.viewEnterID.clipsToBounds = true
        self.viewEnterID.layer.shadowColor = UIColor(red: 95/255.0, green: 95/255.0, blue: 95/255.0, alpha: 1).cgColor
        self.viewEnterID.layer.shadowOffset = .zero
        self.viewEnterID.layer.shadowOpacity = 1
        self.viewEnterID.layer.shadowRadius = 1
        //self.lblBattleId.text = "Waiting for \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")"
        //self.lblBattleId.text = "Waiting for ID and Password"
        self.lblBattleId.font = UIFont.italicSystemFont(ofSize: 14.0)
        self.viewWaitMsg.isHidden = true
        self.btnYes.isEnabled = false
        
        viewEnterID.layer.borderWidth = 1.0
        viewEnterID.layer.borderColor = UIColor.black.cgColor
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        
        let gameId: Int = APIManager.sharedManager.gameSettings?.id ?? 0
        
        switch gameId {
        case 11, 15:        // 11-SSBU, 15-VF5
            self.placeHolderMsg = "Waiting for ID and Password"
        case 16:        // NASB2
            self.placeHolderMsg = "Waiting for Lobby Password"
        default:
            self.placeHolderMsg = ""
        }
        
        self.lblBattleId.text = self.placeHolderMsg
        
        lblTitle.text = APIManager.sharedManager.gameSettings?.gameLabel ?? ""
        //self.lblDesc.text = "Your opponent is host and is setting up the \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") in the game for you to join. You will receive the ID and Password (if applicable) below:"
        self.lblDesc.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.nonHostMsg ?? ""
        lblEnterID.text = "Your \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") is"
        btnHowDoIGetID.setTitle("Where do I enter the \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")? >", for: .normal)
        self.lblDesc2.attributedText = "DO NOT tap proceed until BOTH you and your opponent have entered the \(APIManager.sharedManager.gameSettings?.gameLabel2 ?? "") in the Game.".setMultiBoldUnderlineString(boldString: ["DO NOT", "BOTH"], fontSize: 15.0)
        
        //self.lblBattleId.font = UIFont(name: "OpenSans-Italic", size: 14)
        self.btnYes.backgroundColor = Colors.disableButton.returnColor()
        
        DispatchQueue.main.async {
            print("View did load called - View Battle ID")
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
        
        isOppIdRemovedFromStack = false
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.chatCountUpdate),
                    name: NSNotification.Name(rawValue: "newMessageNotification"),
                    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        
        print("View will appear called - View Battle ID")
        if isTapChat {
            print("View will appear called - View Battle ID - isTapChat")
            isTapChat = false
            callBackInfo()
        }
        else {
            self.setNotificationCountObserver()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isOppIdRemovedFromStack = true
        listner?.remove()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isOppIdRemovedFromStack = true
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("update")
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
        print("FirebaseId ArenaViewBattleIDVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaViewBattleIDVC listner call -- \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaViewBattleIDVC listner call -- \(APIManager.sharedManager.user?.userName ?? ""). Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaViewBattleIDVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    self.chatBadge()
                    
                    /// 334 - By Pranay
                    //self.log.i("ArenaViewBattleIDVC listner response- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")
                    
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
                    else if self.doc?.data()?["status"] as? String == Messages.enteringBattleId
                    {
                        //self.lblDesc.text = "Your opponent is host and is setting up a \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") in the Game. You will receive the ID below as soon as it is sent"
                        //self.lblDesc.text = "Your opponent is host and is setting up the \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") in the game for you to join. You will receive the ID and Password (if applicable) below:"
                        self.lblDesc.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.nonHostMsg ?? ""
                        self.lblDesc.font = UIFont(name: "OpenSans", size: 15)
                        self.lblDesc.textAlignment = .justified
                        self.lblBattleId.text = self.placeHolderMsg
                        self.lblBattleId.font = UIFont(name: "OpenSans-Italic", size: 15)
                        self.viewWaitMsg.isHidden = true
                        self.btnYes.isEnabled = false
                        self.btnYes.backgroundColor = Colors.disableButton.returnColor()
                    }
                    else if (self.doc?.data()?["status"] as? String == Messages.enteredBattleId)
                    {
                        //Enter the BattleArena ID (and password if applicable) in the game to join your opponent
                        //self.lblDesc.text = "Enter the \(APIManager.sharedManager.gameSettings?.gameLabel ?? "") (and password if applicable) in your game to join your opponent."
                        self.lblDesc.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.nonHostMsg2 ?? ""
                        self.lblDesc.font = UIFont(name: "OpenSans-Bold", size: 15)
                        self.lblDesc.textAlignment = .justified
                        self.lblBattleId.text = self.doc?.data()?["battelArenaId"] as? String
                        self.lblBattleId.font = UIFont(name: "OpenSans", size: 15)
                        
                        self.btnYes.isEnabled = true
                        self.btnYes.backgroundColor = Colors.activeButton.returnColor()
                        self.viewWaitMsg.isHidden = true
                        
                        if self.doc?.data()?["weAreReadyBy"] as! Int == (self.playerArr[self.myPlayerIndex]["playerId"] as! Int) {
                            self.btnYes.isEnabled = false
                            self.btnYes.backgroundColor = Colors.disableButton.returnColor()
                            self.viewWaitMsg.isHidden = false
                        }
                    }
                    else if self.doc?.data()?["status"] as? String == Messages.battleIdFail
                    {
                        //self.noTapped(self.btnNo)
                    }
                    else if self.doc?.data()?["status"] as? String == Messages.characterSelection
                    {
                        //self.doubleConfirmWait()
                        self.listner?.remove()
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                        arenaLobby.leagueTabVC = self.leagueTabVC
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    }
                }
            }
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
    
    @objc func onTapInfo() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 2
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isOppIdRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }

    // MARK: - Button Click Events
    @IBAction func noTapped(_ sender: UIButton) {
        ////Beta 1 - Disable option
//        if !Network.reachability.isReachable {
//            self.isRetryInternet { (isretry) in
//                if isretry! {
//                    self.callBackInfo()
//                }
//            }
//            return
//        }
//
//        self.listner?.remove()
//        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
//            "status" : Messages.battleIdFail
//        ]) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaBattleArenaFailPopupVC") as! ArenaBattleArenaFailPopupVC
//                dialog.modalPresentationStyle = .overCurrentContext
//                dialog.modalTransitionStyle = .crossDissolve
//                dialog.isComeFromEnterID = false
//                dialog.tapOk = { areBothIn in
//                    //self.listner?.remove()
//                    if areBothIn {
//                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//                        dialog.modalPresentationStyle = .overCurrentContext
//                        dialog.modalTransitionStyle = .crossDissolve
//                        dialog.titleText = Messages.confirm
//                        dialog.message = Messages.readyToJoinMatch
//                        dialog.highlightString = ""
//                        dialog.isFromBattleId = true
//                        dialog.tapOkForBattleId = { isReady in
//                            if isReady {
//                                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
//                                arenaLobby.tusslyTabVC = self.tusslyTabVC
//                                arenaLobby.leagueTabVC = self.leagueTabVC
//                                self.navigationController?.pushViewController(arenaLobby, animated: true)
//                            } else {
//                                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
//                                    "status" : Messages.characterSelection
//                                ]) { err in
//                                    if let err = err {
//                                        print("Error writing document: \(err)")
//                                    } else {
//                                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
//                                        arenaLobby.tusslyTabVC = self.tusslyTabVC
//                                        arenaLobby.leagueTabVC = self.leagueTabVC
//                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
//                                    }
//                                }
//                            }
//                        }
//                        dialog.tapCancel = {
//                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
//                                "weAreReadyBy" : 0
//                            ]) { err in
//                                if let err = err {
//                                    print("Error writing document: \(err)")
//                                } else {
//                                    self.noTapped(self.btnNo)
//                                }
//                            }
//                        }
//                        dialog.btnYesText = Messages.yes
//                        dialog.btnNoText = Messages.no
//                        if !self.isOppIdRemovedFromStack {
//                            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//                        }
//                    } else {
//                        if !self.isOppIdRemovedFromStack {
//                            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWeAreBothInVC") as! ArenaWeAreBothInVC
//                            arenaLobby.leagueTabVC = self.leagueTabVC
//                            arenaLobby.isBattleIdFail = self.doc?.data()?["appLozicGroupId"] as? String != "" ? true : false
//                            arenaLobby.groupchatId = self.doc?.data()?["appLozicGroupId"] as? String ?? ""
//                            self.navigationController?.pushViewController(arenaLobby, animated: true)
//                        }
//                    }
//                }
//                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//            }
//        }
    }
    
    @IBAction func yesTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        //update status character selection to let host know about you being ready
        
        let roundStartTime = Int(NSDate().timeIntervalSince1970)
//        self.log.i("Yes button tap - battelArenaId displayed to label - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
        self.viewWaitMsg.isHidden = false
        self.btnYes.isEnabled = false
        self.btnYes.backgroundColor = Colors.disableButton.returnColor()
        
        var param : [String: Any]
        
        if doc?.data()?["weAreReadyBy"] as! Int == 0 {
            param = [
                "weAreReadyBy": self.playerArr[myPlayerIndex]["playerId"] ?? 0
            ] as [String: Any]
            
//            self.log.i("ArenaEnterBattleIDVC Proceed btn tap - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            //listner?.remove()
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
                    print("Error writing document: \(err)")
//                    self.log.e("ArenaEnterBattleIDVC Proceed btn tap 'Update weAreReadyBy with playerID fail' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                } else {
                    self.btnYes.isEnabled = false
                    self.btnYes.backgroundColor = Colors.disableButton.returnColor()
                    self.viewWaitMsg.isHidden = false
//                    self.log.i("ArenaEnterBattleIDVC Proceed btn tap 'Update weAreReadyBy with playerID success' - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                }
            }
        }
        else {
            param = [
                "status": Messages.characterSelection
                //"gameStartTime": roundStartTime
            ] as [String: Any]
            
//            self.log.i("ArenaEnterBattleIDVC Proceed btn tap - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
                    print("Error writing document: \(err)")
//                    self.log.e("ArenaEnterBattleIDVC Proceed btn tap 'Update status to characterSelection fail' - \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                }
            }
            //print("Proceed button tap else part --- \(Messages.characterSelection)")
        }   /// */
        
        /*listner?.remove()
        playerArr[self.myPlayerIndex]["battleInStatus"] = true as AnyObject
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(["status" : Messages.characterSelection, "playerDetails" : self.playerArr]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                self.btnYes.isEnabled = true
                self.log.i("Yes button tap - Update status to firestore fail - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
            } else {
                self.doubleConfirmWait()
            }
        }   //  */
    }
    
    func doubleConfirmWait() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.descriptionString = Messages.waitForConfirm
        dialog.arenaFlow = "IdDoubleConfirmation"
        dialog.isLoader = true
        dialog.tapOk = {
            //host confirmso redirect to character screen
            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
            arenaLobby.tusslyTabVC = self.tusslyTabVC
            arenaLobby.leagueTabVC = self.leagueTabVC
            self.navigationController?.pushViewController(arenaLobby, animated: true)
        }
        if !isOppIdRemovedFromStack {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func enterBattleArenaTapped(_ sender: UIButton)
    {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleLoby = APIManager.sharedManager.content?.arenaContents?.how_to_get_battle_arena_id_non_host?.heading ?? ""
        let totalData = APIManager.sharedManager.content?.arenaContents?.how_to_get_battle_arena_id_non_host?.data
        let count : Int = totalData?.count ?? 0
        for i in 0 ..< count
        {
            debugPrint("Dialog Content --> \(i + 1) -- \(totalData?[i].description ?? "")")
            dialog.arrLoby.append(GameLobby(id: i + 1, stepNo: i + 1, lobbyContent: totalData?[i].description ?? ""))
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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

extension ArenaViewBattleIDVC {
    
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
