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
import Firebase

class ArenaLobbyTournamentVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    var isFromHome = false
    var arrSelectedStageIndex = [Int]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
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
    var isDataNotFound = false
    var isLobbyRemovedFromStack = false
    var selectedData = [[String:AnyObject]]()
    var isBtnTap : Bool = false
//    fileprivate let log = ShipBook.getLogger(ArenaLobbyTournamentVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    //Outlets
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblGameTime : UILabel!
    @IBOutlet weak var lblPlayer1Status : UILabel!
    @IBOutlet weak var lblPlayer2Status : UILabel!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Host : UILabel!
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

    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var btnHostUsedChar: UIButton!
    @IBOutlet weak var btnAwayUsedChar: UIButton!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnProceed.isEnabled = false
        
        // By Pranay
        if APIManager.sharedManager.gameSettings?.isTournamentHost ?? 0 == 1 {
            lblPlayer1Host.isHidden = false
        } else {
            lblPlayer1Host.isHidden = true
        }
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        //.
        
        if (APIManager.sharedManager.match?.onlyTime == "" || APIManager.sharedManager.match?.onlyTime == "TBD") {
            self.lblGameTime.attributedText = ("Game Time: TBD").setAttributedString(boldString: "Game Time:", fontSize: 18.0)
        } else {
            //let timeIs = "Game Time: \(APIManager.sharedManager.match?.onlyTime ?? "") \(APIManager.sharedManager.match?.league?.timeZone ?? "")"  // Comment by Pranay
            // By Pranay
            let timeIs = "Game Time: \(APIManager.sharedManager.match?.onlyTime ?? "")"
            // .
            self.lblGameTime.attributedText = timeIs.setAttributedString(boldString: "Game Time:", fontSize: 18.0)
        }
        lblCharacter.text = Messages.selectChar
        
        DispatchQueue.main.async {
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

        self.imgCharacter.layer.cornerRadius = self.imgCharacter.frame.size.height / 2
        
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
        
        isLobbyRemovedFromStack = false
        
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.chatCountUpdate),
                    name: NSNotification.Name(rawValue: "newMessageNotification"),
                    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        
        self.setNotificationCountObserver()
        
        if self.isChatBtnTap {
            self.isChatBtnTap = false
            DispatchQueue.main.async {
                self.showChatRedDot(show: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isLobbyRemovedFromStack = true
        listner?.remove()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
    }
    
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isLobbyRemovedFromStack = true
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    //MARK:- UI Methods
    func  timeFormatted(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return "\(minutes):\(seconds)"
    }
    
    @objc func chatCountUpdate() {
        self.lblMessageCount.removeFromSuperview()
        chatBadge()
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
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    @objc func onTapChat() {
        let chatUserId : String = (self.leagueTabVC!().matchDetail?.chatId ?? "-1")
        if chatUserId != "-1" && !self.isChatBtnTap {
            self.isChatBtnTap = true
            //self.isTapChat = true
            self.openArenaGroupConvorsation(id: chatUserId, type: .group, isFromArena: true, tusslyTabVC: self.tusslyTabVC) { success in
                if !success {
                    //self.isTapChat = false
                    self.isChatBtnTap = false
                }
                else {
                    self.leagueTabVC!().showUnreadCount = false
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
        dialog.currentPage = 1
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if self.isLobbyRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        
        if isDataNotFound {
            dataNotFound()
        } else {
            setFirestoreData()
        }
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
        
        // By Pranay
        btnHostUsedChar.layer.cornerRadius = btnHostUsedChar.frame.size.height / 2
        btnAwayUsedChar.layer.cornerRadius = btnAwayUsedChar.frame.size.height / 2
        
        //if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count == 0 {
        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
            self.btnStageRanking.isUserInteractionEnabled = false
            self.btnStageRanking.backgroundColor = Colors.disableButton.returnColor()
        }
        // .
    }
    
    func dataNotFound() {
        let myType = APIManager.sharedManager.match?.homeTeamPlayers![0].playerDetails?.id == APIManager.sharedManager.user?.id ? 1 : 0
        
        self.lblPlayer1Status.text = myType == 1 ? Messages.readyToStart : Messages.waitingForPlayer
        self.lblPlayer1Status.textColor = myType == 1 ? Colors.black.returnColor() : UIColor.lightGray
        self.lblPlayer2Status.text = myType == 0 ? Messages.readyToStart : Messages.waitingForPlayer
        self.lblPlayer2Status.textColor = myType == 0 ? Colors.black.returnColor() : UIColor.lightGray
        
        let hostImage = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.homeTeam?.homeImage ?? "")
        self.imgPlayer1.setImage(imageUrl: hostImage)
        let opponentImage = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.awayTeam?.awayImage ?? "")
        self.imgPlayer2.setImage(imageUrl: opponentImage)
        
        let homeTeamName = (APIManager.sharedManager.match?.homeTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.homeTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.homeTeam?.teamName ?? "").index((APIManager.sharedManager.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.homeTeam?.teamName ?? "")
        let awayTeamName = (APIManager.sharedManager.match?.awayTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.awayTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.awayTeam?.teamName ?? "").index((APIManager.sharedManager.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.awayTeam?.teamName ?? "")
        self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? "") : homeTeamName
        self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? "") : awayTeamName
        
        self.lblPlayer1DisplayName.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? "" : (APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? "")
        self.lblPlayer2DisplayName.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? "" : (APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? "")
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
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaLobbyTournamentVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaLobbyTournamentVC listner call - \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            
            guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
            print("FirebaseId ArenaLobbyTournamentVC >>>>>>>>>>>>>> \(firebaseId)")
            
            if let err = err {
//                self.log.e("c listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err).")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaLobbyTournamentVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        
                        do {
                            self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            self.arrPlayer = self.arrFirebase?.playerDetails ?? []
                            
                            if self.arrPlayer.count != 0 {
                                let hostIndex : Int = self.arrPlayer[0].host == 1 ? 0 : 1
                                let opponentIndex : Int = hostIndex == 1 ? 0 : 1
                                self.lblPlayer1Status.text = self.arrPlayer[hostIndex].arenaJoin == 0 ? Messages.waitingForPlayer : Messages.readyToStart
                                self.lblPlayer1Status.textColor = self.arrPlayer[hostIndex].arenaJoin == 0 ? UIColor.lightGray : Colors.black.returnColor()
                                self.lblPlayer2Status.text = self.arrPlayer[opponentIndex].arenaJoin == 0 ? Messages.waitingForPlayer : Messages.readyToStart
                                self.lblPlayer2Status.textColor = self.arrPlayer[opponentIndex].arenaJoin == 0 ? UIColor.lightGray : Colors.black.returnColor()
                                
                                //let hostImage = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.homeTeam?.homeImage ?? "")
                                //let opponentImage = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "") :  (APIManager.sharedManager.match?.awayTeam?.awayImage ?? "")
                                self.imgPlayer1.setImage(imageUrl: self.arrPlayer[hostIndex].avatarImage ?? "")
                                self.imgPlayer2.setImage(imageUrl: self.arrPlayer[opponentIndex].avatarImage ?? "")
                                
                                let homeTeamName = (self.arrPlayer[hostIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[hostIndex].teamName ?? "")[..<(self.arrPlayer[hostIndex].teamName ?? "").index((self.arrPlayer[hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[hostIndex].teamName ?? "")
                                let awayTeamName = (self.arrPlayer[opponentIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[opponentIndex].teamName ?? "")[..<(self.arrPlayer[opponentIndex].teamName ?? "").index((self.arrPlayer[opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[opponentIndex].teamName ?? "")
                                
                                self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[hostIndex].displayName ?? "") : homeTeamName
                                self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[opponentIndex].displayName ?? "") : awayTeamName
                                
                                self.lblPlayer1DisplayName.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? "" : (self.arrPlayer[hostIndex].displayName ?? "")
                                self.lblPlayer2DisplayName.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? "" : (self.arrPlayer[opponentIndex].displayName ?? "")
                                
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
                                else if self.arrFirebase?.manualUpdateFromUpcoming == 1 {
                                    self.listner?.remove()
                                    APIManager.sharedManager.isMatchRefresh = false
                                    self.leagueTabVC!().getTournamentContent()
                                    
                                    return
                                }
                                /*else if self.arrFirebase?.previousMatchActive == 1 {
                                    self.listner?.remove()
                                    APIManager.sharedManager.isMatchRefresh = false
                                    self.leagueTabVC!().getTournamentContent()
                                }   //  */
                                else if APIManager.sharedManager.user?.id == self.arrPlayer[0].playerId {
                                    self.myPlayerIndex = 0
                                    APIManager.sharedManager.myPlayerIndex = 0
                                    self.opponent = self.myPlayerIndex == 0 ? 1 : 0
                                    
                                    //self.log.i("ArenaLobbyTournamentVC listner response - \(APIManager.sharedManager.user?.userName ?? "") == awayUser-> \(self.arrPlayer[1].displayName) --- response-> \(self.doc?.data())")  //  By Pranay.
                                    
                                    self.lblCharacter.text = self.arrPlayer[0].characterName == "" ? Messages.selectChar : self.arrPlayer[0].characterName
                                    if self.arrPlayer[0].characterName == "" {
                                        self.imgCharacter.image = UIImage(named: "Default")
                                    } else {
                                        self.imgCharacter.setImage(imageUrl: self.arrPlayer[0].characterImage ?? "")
                                    }
                                    
                                    /*if(self.arrPlayer[0].arenaJoin != 0 && self.arrPlayer[0].characterName != "" && self.arrPlayer[0].stages?.count != 0 && self.arrPlayer[1].arenaJoin != 0){
                                        self.btnProceed.backgroundColor = Colors.theme.returnColor()
                                        self.btnProceed.titleLabel?.textColor = UIColor.white
                                        self.btnProceed.isEnabled = true
                                    }   //  */
                                    if (self.arrPlayer[0].arenaJoin != 0 && self.arrPlayer[0].characterName != "" && (((APIManager.sharedManager.stagePickBan ?? "") == "Yes" && self.arrPlayer[0].stages?.count != 0) || ((APIManager.sharedManager.stagePickBan ?? "") == "No")) && self.arrPlayer[1].arenaJoin != 0) {
                                        self.btnProceed.backgroundColor = Colors.theme.returnColor()
                                        self.btnProceed.titleLabel?.textColor = UIColor.white
                                        self.btnProceed.isEnabled = true
                                    }
                                    /*/// 223 - By Pranay
                                    else if(self.arrPlayer[0].arenaJoin != 0 && self.arrPlayer[0].characterName != "" && (((APIManager.sharedManager.stagePickBan) == "YES" && self.arrPlayer[0].stages?.count != 0) || ((APIManager.sharedManager.stagePickBan ?? "") == "NO")) && self.arrPlayer[1].arenaJoin != 0){
                                        self.btnProceed.backgroundColor = Colors.theme.returnColor()
                                        self.btnProceed.titleLabel?.textColor = UIColor.white
                                        self.btnProceed.isEnabled = true
                                    }
                                    /// 223 .   */
                                    else {
                                        if self.selectedData.count != 0 && (self.arrPlayer[0].stages?.count == 0 || self.arrPlayer[0].characterName == "") {
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterId = (self.selectedData[0]["characterId"] as! Int)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterImage = (self.selectedData[0]["characterImage"] as! String)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterName = (self.selectedData[0]["characterName"] as! String)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages = (self.selectedData[0]["stages"] as! [Int])
                                            //self.savePlayerDetail()
                                        }
                                    }
                                }
                                else {
                                    APIManager.sharedManager.myPlayerIndex = 1
                                    self.myPlayerIndex = 1
                                    self.opponent = self.myPlayerIndex == 0 ? 1 : 0
                                    
//                                    self.log.i("ArenaLobbyTournamentVC listner response - \(APIManager.sharedManager.user?.userName ?? "") == awayUser-> \(self.arrPlayer[0].displayName) --- response-> \(self.doc?.data())")  //  By Pranay.
                                    
                                    self.lblCharacter.text = self.arrPlayer[1].characterName == "" ? Messages.selectChar : self.arrPlayer[1].characterName
                                    if self.arrPlayer[1].characterName == "" {
                                        self.imgCharacter.image = UIImage(named: "Default")
                                    } else {
                                        self.imgCharacter.setImage(imageUrl: self.arrPlayer[1].characterImage ?? "")
                                    }
                                    
                                    /// 223 - By Pranay
                                    if (self.arrPlayer[1].arenaJoin != 0 && self.arrPlayer[1].characterName != "" && (((APIManager.sharedManager.stagePickBan ?? "") == "Yes" && self.arrPlayer[1].stages?.count != 0) || ((APIManager.sharedManager.stagePickBan ?? "") == "No")) && self.arrPlayer[0].arenaJoin != 0) {
                                        self.btnProceed.backgroundColor = Colors.theme.returnColor()
                                        self.btnProceed.titleLabel?.textColor = UIColor.white
                                        self.btnProceed.isEnabled = true
                                    }
                                    /// 223  .
                                    else {
                                        if self.selectedData.count != 0 && (self.arrPlayer[1].stages?.count == 0 || self.arrPlayer[1].characterName == "") {
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterId = (self.selectedData[1]["characterId"] as! Int)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterImage = (self.selectedData[1]["characterImage"] as! String)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterName = (self.selectedData[1]["characterName"] as! String)
                                            self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages = (self.selectedData[1]["stages"] as! [Int])
                                            //self.savePlayerDetail()
                                        }
                                    }
                                }
                                
                                self.chatBadge()
                                
                                //if (self.arrPlayer[1].arenaJoin != 0 && self.arrPlayer[1].characterName != "" && self.arrPlayer[1].stages?.count != 0 && self.arrPlayer[0].arenaJoin != 0 && self.arrPlayer[0].characterName != "" && self.arrPlayer[0].stages?.count != 0) {
                                /// Condition updated by Pranay.
                                if (self.arrPlayer[1].arenaJoin != 0 && self.arrPlayer[1].characterName != "" && (((APIManager.sharedManager.stagePickBan ?? "") == "Yes" && self.arrPlayer[1].stages?.count != 0) || ((APIManager.sharedManager.stagePickBan ?? "") == "No")) && self.arrPlayer[0].arenaJoin != 0 && self.arrPlayer[0].characterName != "" && (((APIManager.sharedManager.stagePickBan ?? "") == "No") || self.arrPlayer[0].stages?.count != 0)) {
                                    
                                    if self.doc?.data()?["status"] as! String == Messages.enteringBattleId {
                                    } else if self.doc?.data()?["status"] as! String == Messages.enteredBattleId {
                                    } else if self.doc?.data()?["status"] as! String == Messages.readyToProceed {
                                    }
                                    /// 333 - By Pranay
                                    else if self.doc?.data()?["status"] as! String == Messages.characterSelection {
                                        print("Navigate to character screen.")
                                        let arenaChar = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                        arenaChar.tusslyTabVC = self.tusslyTabVC
                                        arenaChar.leagueTabVC = self.leagueTabVC
                                        self.listner?.remove()
                                        self.navigationController?.pushViewController(arenaChar, animated: true)    //  */
                                    }
                                    /// 333 .
                                    else {
                                        if !Network.reachability.isReachable {
                                            self.isRetryInternet { (isretry) in
                                                if isretry! {
                                                    self.callBackInfo()
                                                }
                                            }
                                            return
                                        }
                                        if self.doc?.data()?["status"] as! String == Messages.waitingToProceed {
                                            let param = [
                                                "status": Messages.readyToProceed
                                            ] as [String: Any]
//                                            self.log.i("ArenaLobbyTournamentVC setFirestoreData() update status to-> \(Messages.readyToProceed) -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                                if let err = err {
//                                                    self.log.e("ArenaLobbyTournamentVC Fail Update status in setFirestoreData()-> \(Messages.readyToProceed) -- \(APIManager.sharedManager.user?.userName ?? "") -- Update status --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                                } else {
//                                                    self.log.i("ArenaLobbyTournamentVC setFirestoreData() update success - status to-> \(Messages.readyToProceed) -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if self.isFromHome {
                                    self.proceedTapped(self.btnProceed)
                                }
                                
                                // By Pranay
                                if self.doc?.data()?["status"] as! String == Messages.readyToProceed {
                                    if (self.doc?.data()?["weAreReadyBy"] as! Int != 0) && (self.arrFirebase?.playerDetails![self.myPlayerIndex].playerId != self.doc?.data()?["weAreReadyBy"] as? Int) && self.isBtnTap {
                                        let param = [
                                            "status": Messages.characterSelection
                                        ] as [String: Any]
//                                        self.log.i("ArenaLobbyTournamentVC setFirestoreData() update status to-> \(Messages.characterSelection) -- startedc - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                            if err != nil {
//                                                self.log.e("ArenaLobbyTournamentVC Fail Update status in setFirestoreData()-> \(Messages.characterSelection) -- \(APIManager.sharedManager.user?.userName ?? "") -- Update status --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                                self.isBtnTap = false
                                            } else {
//                                                self.log.i("ArenaLobbyTournamentVC setFirestoreData() update status to-> \(Messages.characterSelection) completed -- \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                            }
                                        }
                                    }
                                    else if (self.doc?.data()?["weAreReadyBy"] as! Int != 0) && (self.arrFirebase?.playerDetails![self.myPlayerIndex].playerId == self.doc?.data()?["weAreReadyBy"] as? Int) {
                                        self.btnProceed.isEnabled = false
                                        self.listner?.remove()
                                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                        dialog.isLoader = true
                                        dialog.modalPresentationStyle = .overCurrentContext
                                        dialog.modalTransitionStyle = .crossDissolve
                                        dialog.arenaFlow = "directCharacterSelection"
                                        dialog.descriptionString = Messages.waitingToChar
                                        dialog.manageOnStatus = { statusIs in
                                            self.setFirestoreData()
                                        }
                                        if !self.isLobbyRemovedFromStack {
                                            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                        }
                                    }
                                    else if (self.doc?.data()?["weAreReadyBy"] as! Int == 0) || (self.arrFirebase?.playerDetails![self.myPlayerIndex].playerId != self.doc?.data()?["weAreReadyBy"] as? Int) {
                                        self.isBtnTap = false
                                    }
                                }
                            }
                            else {
                                if (self.doc?.data()?["previousMatchActive"] as! Int) == 1 {
                                    let param = [
                                        "previousMatchActive": 0
                                    ] as [String: Any]
                                    self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                        if let err = err {
//                                            self.log.e("ArenaLobbyTournamentVC Fail Update data in previousMatchActive - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                            print("Error writing document: \(err)")
                                        } else {//
                                            _ = self.doc?.data()?["status"] as! String
                                        }
                                    }
                                }   //  */
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func openStageRankingDialog() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
        dialog.arrSelectedStageIndex = self.arrSelectedStageIndex
        dialog.teamId = self.leagueTabVC!().teamId
        dialog.arrSwaped = self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages ?? []
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.isUpdateFireStore = 1
        dialog.tapOk = { arr in
            if(arr[0] as! Bool == false){
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
                self.arrSelectedStageIndex.removeAll()
                if (arr[1] as? [Int])?.count ?? 0 > 0 {
                    self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages = arr[1] as? [Int]
                    if self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterName != "" {
                        //self.savePlayerDetail()
                    }
                }
            }
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    func hostAction() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        let param = [
            "status": Messages.enteringBattleId
        ] as [String: Any]
        
//        self.log.i("ArenaLobbyTournamentVC Update data in host action - \(APIManager.sharedManager.user?.userName ?? "") -- Update status to - \(Messages.enteringBattleId) - started --- param-> \(param)")  //  By Pranay.
        listner?.remove()
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("ArenaLobbyTournamentVC Update data in host action - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err).")  //  By Pranay.
                print("Error writing document: \(err)")
                self.isBtnTap = false
            } else {
//                self.log.i("ArenaLobbyTournamentVC Update data in host action - \(APIManager.sharedManager.user?.userName ?? "") -- Update status to - \(Messages.enteringBattleId) - completed")  //  By Pranay.
                
                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaEnterBattleIDVC") as! ArenaEnterBattleIDVC
                arenaLobby.tusslyTabVC = self.tusslyTabVC
                arenaLobby.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(arenaLobby, animated: true)
            }
        }
    }
    
    func opponentAction() {
        
        self.listner?.remove()
        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaViewBattleIDVC") as! ArenaViewBattleIDVC
        arenaLobby.myPlayerIndex = self.myPlayerIndex
        arenaLobby.tusslyTabVC = self.tusslyTabVC
        arenaLobby.leagueTabVC = self.leagueTabVC
        self.navigationController?.pushViewController(arenaLobby, animated: true)   //  */
        
        /*if doc?.data()?["status"] as! String == Messages.enteredBattleId {
            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaViewBattleIDVC") as! ArenaViewBattleIDVC
            arenaLobby.myPlayerIndex = self.myPlayerIndex
            self.listner?.remove()
            arenaLobby.leagueTabVC = self.leagueTabVC
            self.navigationController?.pushViewController(arenaLobby, animated: true)
        } else {
            self.listner?.remove()
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.isLoader = true
            dialog.descriptionString = Messages.waitForBattleId
            dialog.status = Messages.enteredBattleId
            dialog.tapOk = {
                //self.btnProceed.isEnabled = true
                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaViewBattleIDVC") as! ArenaViewBattleIDVC
                arenaLobby.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(arenaLobby, animated: true)
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }   /// */
    }
    
    func savePlayerDetail() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        var playerArr = [[String:AnyObject]]()
        do {
            let encodedData = try JSONEncoder().encode(self.arrFirebase?.playerDetails ?? [])
            let jsonString = String(data: encodedData,encoding: .utf8)
            if let data = jsonString?.data(using: String.Encoding.utf8) {
                do {
                    playerArr = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] ?? []
                } catch let error as NSError {
                    print(error)
                }
            }
            
        } catch {
            print("error")
        }
        
        playerArr[self.myPlayerIndex]["characterCurrent"] = false as AnyObject
        playerArr[self.opponent]["characterCurrent"] = false as AnyObject
        
        let param = [
            "playerDetails": playerArr
        ] as [String: Any]
        
//        self.log.i("ArenaLobbyTournamentVC Update data in savePlayerDetail() - \(APIManager.sharedManager.user?.userName ?? "") - started --- param-> \(param)")  //  By Pranay.
        
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("ArenaLobbyTournamentVC Fail Update data in savePlayerDetail() - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                print("Error writing document: \(err)")
            } else {
                
//                self.log.i("ArenaLobbyTournamentVC Update data in savePlayerDetail() - \(APIManager.sharedManager.user?.userName ?? "")- completed")  //  By Pranay.
                
                if(playerArr[self.opponent]["arenaJoin"] as! Int == 1){
                    self.btnProceed.backgroundColor = Colors.theme.returnColor()
                    self.btnProceed.titleLabel?.textColor = UIColor.white
                    self.btnProceed.isEnabled = true
                }
            }
        }
    }
    
    func connectCode() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        var playerArr = [[String:AnyObject]]()
        playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
        playerArr[self.myPlayerIndex]["ssbmConnectProceed"] = 1 as AnyObject
        
        let param = [
            "status": Messages.waitingToCharacterSelection,
            "playerDetails":playerArr
        ] as [String: Any]
        
//        self.log.i("ArenaLobbyTournamentVC Update data in connectCode() - \(APIManager.sharedManager.user?.userName ?? "") -- Update playerDetail and status - started --- param-> \(param)")  //  By Pranay.
        
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("ArenaLobbyTournamentVC Fail Update data in connectCode() - \(APIManager.sharedManager.user?.userName ?? "") -- Update playerDetail and status --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                print("Error writing document: \(err)")
                self.isBtnTap = false
            }
            else {
//                self.log.i("ArenaLobbyTournamentVC Update data in connectCode() - \(APIManager.sharedManager.user?.userName ?? "") -- Update playerDetail and status - completed")  //  By Pranay.
                
                let arenaConnect = self.storyboard?.instantiateViewController(withIdentifier: "ArenaConnectCodeVC") as! ArenaConnectCodeVC
                arenaConnect.tusslyTabVC = self.tusslyTabVC
                arenaConnect.leagueTabVC = self.leagueTabVC
                self.listner?.remove()
                self.navigationController?.pushViewController(arenaConnect, animated: true)
            }
        }
    }
    
    func proceedToChar() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        var param : [String: Any]
        
        if self.doc?.data()?["weAreReadyBy"] as! Int != 0 {
            param = [
                "status": Messages.characterSelection
            ] as [String: Any]
            
//            self.log.i("ArenaLobbyTournamentVC Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update status --- - started - param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
//                    self.log.e("ArenaLobbyTournamentVC Fail Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update status --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                    self.isBtnTap = false
                }
                else {
//                    self.log.i("ArenaLobbyTournamentVC Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update status - completed")  //  By Pranay.
                }
            }
        }
        else {
            param = [
                "weAreReadyBy": self.arrFirebase?.playerDetails?[myPlayerIndex].playerId ?? 0
            ] as [String: Any]
            
//            self.log.i("ArenaLobbyTournamentVC Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update weAreReadyBy - started --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                "weAreReadyBy": self.arrFirebase?.playerDetails?[myPlayerIndex].playerId ?? 0
            ]) { err in
                if let err = err {
//                    self.log.e("ArenaLobbyTournamentVC Fail Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update weAreReadyBy --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                    self.isBtnTap = false
                } else {
//                    self.log.i("ArenaLobbyTournamentVC Update data in proceedToChar() - \(APIManager.sharedManager.user?.userName ?? "") -- Update weAreReadyBy - completed --- param-> \(param)")  //  By Pranay.
                }
            }
        }
    }
    
    func buttonClick() {
//        self.log.i("Proceed tap call - \(APIManager.sharedManager.user?.userName ?? "") = custom ID - \(APIManager.sharedManager.gameSettings?.customId ?? 0).")
        self.isBtnTap = true
        if APIManager.sharedManager.gameSettings?.customId ?? 0 == 0 {
            proceedToChar()
        }
        else if APIManager.sharedManager.gameSettings?.customId ?? 0 == 1 {
            if(arrFirebase?.playerDetails?[myPlayerIndex].host == 1){
                self.hostAction()
            } else {
                opponentAction()
            }
        }
        else if APIManager.sharedManager.gameSettings?.customId ?? 0 == 2 {
            connectCode()
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func proceedTapped(_ sender: UIButton) {
        if !isBtnTap {
            self.isBtnTap = true
            self.startMatch(matchId: self.doc?.data()?["matchId"] as! Int)
        }
    }
    
    @IBAction func lobbySetupTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func characterSelectionTapped(_ sender: UIButton) {
        if isDataNotFound == false {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CharacterSelectionPopupVC") as! CharacterSelectionPopupVC
            dialog.teamId = self.leagueTabVC!().teamId
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            /// 331 - By Pranay
            dialog.isUpdateFireStore = 1
            dialog.strCharName = self.lblCharacter.text!
            /// 331 .
            dialog.tapOk = { arr in
                APIManager.sharedManager.arrDefaultChar = arr
                let array : [[Characters]] = arr[0] as! [[Characters]]
                self.lblCharacter.text = array[arr[1] as! Int][arr[2] as! Int].name
                self.imgCharacter.setImage(imageUrl: array[arr[1] as! Int][arr[2] as! Int].imagePath ?? "")
                
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterId = array[arr[1] as! Int][arr[2] as! Int].id
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterImage = array[arr[1] as! Int][arr[2] as! Int].imagePath
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].characterName = array[arr[1] as! Int][arr[2] as! Int].name
                
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].defaultCharId = array[arr[1] as! Int][arr[2] as! Int].id
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].defaultCharImage = array[arr[1] as! Int][arr[2] as! Int].imagePath
                self.arrFirebase?.playerDetails?[self.myPlayerIndex].defaultCharName = array[arr[1] as! Int][arr[2] as! Int].name
                
                if self.arrFirebase?.playerDetails?[self.myPlayerIndex].stages?.count != 0 {
                    //self.savePlayerDetail()
                }
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        } else {
            Utilities.showPopup(title: Messages.matchNotFound, type: .error)
        }
    }
    
    @IBAction func stagedPickOrBanTapped(_ sender: UIButton) {
        if isDataNotFound == false {
            openStageRankingDialog()
        } else {
            Utilities.showPopup(title: Messages.matchNotFound, type: .error)
        }
    }
    
    @IBAction func setDefaultTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSetDefaultPopupVC") as! ArenaSetDefaultPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    /// 121 - By Pranay
    @IBAction func btnHostUsedCharTap(_ sender: UIButton) {
        self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter ?? [])
    }
    
    @IBAction func btnAwayUsedCharTap(_ sender: UIButton) {
        self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter ?? [])
    }
    
    // MARK: - Function
    
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
            
            dialog.tapOk = { arr in
            }
            
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
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

// MARK: Webservices
extension ArenaLobbyTournamentVC {
    
    func startMatch(matchId: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.startMatch(matchId: matchId)
                }
            }
            return
        }
        self.showLoading()
        
        let param = [
            "leagueId": leagueTabVC!().tournamentDetail?.id ?? 0,
            "matchId": matchId,
            "device": "ios"
        ] as [String: Any]
//        self.log.i("START_MATCH api call. - \(APIManager.sharedManager.user?.userName ?? "") --- \(param)")
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.START_MATCH, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
//                    self.log.i("START_MATCH api call success. - \(APIManager.sharedManager.user?.userName ?? "")")
                    self.buttonClick()
                }
            }
            else {
//                self.log.e("START_MATCH api call fail. - \(APIManager.sharedManager.user?.userName ?? "")")
                self.startMatch(matchId: matchId)
            }
        }
    }
    
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
