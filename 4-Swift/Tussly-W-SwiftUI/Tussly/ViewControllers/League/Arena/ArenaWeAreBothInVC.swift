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

class ArenaWeAreBothInVC: UIViewController, refreshTabDelegate {
    
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
    var playerArr = [[String:AnyObject]]()
    var isTapChat = false
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isReadyScreenRemovedFromStack = false
    var isBattleIdFail = false
    var groupchatId = ""
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var btnBothIn: UIButton!
    @IBOutlet weak var btnEnterGroup: UIButton!

    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
        
        btnBothIn.layer.cornerRadius = btnBothIn.frame.size.height / 2
        btnEnterGroup.layer.cornerRadius = btnEnterGroup.frame.size.height / 2
        
        btnEnterGroup.isEnabled = false
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        
        if isBattleIdFail { //applozic id != "" then open grop chat
            isBattleIdFail = false
            isTapChat = true
            openGroupChat(id: groupchatId)
        } else {
            setUI()
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
        
        isReadyScreenRemovedFromStack = false
        
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
        
        if isTapChat {
            isTapChat = false
            setUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isReadyScreenRemovedFromStack = true
        listner?.remove()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
    }
    
    // MARK: - UI Methods
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
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
        
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    self.chatBadge()
                    
                    if self.doc?.data()?["appLozicGroupId"] as? String != "" {
                        self.btnEnterGroup.isEnabled = true
                        self.btnEnterGroup.backgroundColor = Colors.theme.returnColor()
                    }
                    
                    if self.doc?.data()?["status"] as! String == Messages.characterSelection && self.isReadyScreenRemovedFromStack == false {
                        self.listner?.remove()
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                        arenaLobby.leagueTabVC = self.leagueTabVC
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    } else {
                        if self.doc?.data()?["weAreReadyBy"] as! Int != 0 { //any player requested to join
                            self.listner?.remove()
                            if self.doc?.data()?["weAreReadyBy"] as! Int != self.playerArr[APIManager.sharedManager.myPlayerIndex]["playerId"] as! Int {
                                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                                dialog.modalPresentationStyle = .overCurrentContext
                                dialog.modalTransitionStyle = .crossDissolve
                                dialog.titleText = Messages.confirm
                                dialog.message = Messages.readyToJoinMatch
                                dialog.highlightString = ""
                                dialog.isFromBattleId = true
                                dialog.tapOkForBattleId = { isReady in
                                    if isReady {
                                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                                        arenaLobby.leagueTabVC = self.leagueTabVC
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    } else {
                                        if !Network.reachability.isReachable {
                                            self.isRetryInternet { (isretry) in
                                                if isretry! {
                                                    self.callBackInfo()
                                                }
                                            }
                                            return
                                        }
                                        
                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                            "status" : Messages.characterSelection
                                        ]) { err in
                                            if let err = err {
                                                print("Error writing document: \(err)")
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
                                    if !Network.reachability.isReachable {
                                        self.isRetryInternet { (isretry) in
                                            if isretry! {
                                                self.callBackInfo()
                                            }
                                        }
                                        return
                                    }
                                    
                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                        "weAreReadyBy" : 0
                                    ]) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
                                        } else {
                                            self.setUI()
                                        }
                                    }
                                }
                                dialog.btnYesText = Messages.yes
                                dialog.btnNoText = Messages.no
                                if self.isReadyScreenRemovedFromStack == false {
                                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                }
                            } else {
                                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                dialog.modalPresentationStyle = .overCurrentContext
                                dialog.modalTransitionStyle = .crossDissolve
                                dialog.descriptionString = Messages.waitForConfirm
                                dialog.arenaFlow = "WeAreBothIn"
                                dialog.isLoader = false
                                dialog.timeSeconds = 3
                                dialog.manageOnStatus = { ready in
                                    self.setUI()
                                }
                                if self.isReadyScreenRemovedFromStack == false {
                                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
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
    
    @objc func onTapInfo() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 0
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isReadyScreenRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func bothInTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        if self.doc?.data()?["weAreReadyBy"] as? Int == 0 && isBattleIdFail == false {
            listner?.remove()
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                "weAreReadyBy" : self.playerArr[APIManager.sharedManager.myPlayerIndex]["playerId"] as! Int
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else{
                    self.setUI()
                }
            }
        }
    }
    
    @IBAction func enterGroupTapped(_ sender: UIButton) {
        if self.doc?.data()?["appLozicGroupId"] as? String != "" && isBattleIdFail == false && isTapChat == false {
            listner?.remove()
            self.isTapChat = true
//            let object = self.storyboard?.instantiateViewController(withIdentifier: "ArenaGroupChatVC") as! ArenaGroupChatVC
//            object.leagueTabVC = self.leagueTabVC
//            self.navigationController?.pushViewController(object, animated: true)
            if !isReadyScreenRemovedFromStack {
                self.openGroupChat(id: self.doc?.data()?["appLozicGroupId"] as! String)
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
}

extension ArenaWeAreBothInVC {
    
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
