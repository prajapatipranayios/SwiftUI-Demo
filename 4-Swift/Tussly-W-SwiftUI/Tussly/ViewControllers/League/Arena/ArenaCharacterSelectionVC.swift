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

class ArenaCharacterSelectionVC: UIViewController, refreshTabDelegate {
    // MARK: - Variables
    var arrChar = ["A-F","G-K","L-P","Q-U","V-Z"]
    var arrChars = [Characters]()
    var arrNames = [[Characters]]()
    var arrTitle = [String]()
    let charNameCell = CharNameTVCell()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var timeSeconds = 0
    var finalSeconds = 0
    var lastSection = -1
    let db = Firestore.firestore()
    var myPlayerIndex = 0
    var opponent = 1
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var isUpdate = false
    var finalChar = Characters()
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var unselectSection = -1
    var isTapChat = false
    var playerArr = [[String:AnyObject]]()
    var isPreviousSelected = false
    var isCharacterRemovedFromStack = false
    
    var currentSectinoSelected = -1
    var currentItemSelected = -1
    
    var isAutoSelect: Bool = false
    var intMaxNoOfCharSelect: Int = APIManager.sharedManager.maxCharacterLimit ?? 0
//    fileprivate let log = ShipBook.getLogger(ArenaCharacterSelectionVC.self)
    var contentHeight: Int = 0
    
    var isChatBtnTap: Bool = false
    
    
    
    // MARK: - Outlets
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var cvCharName: UICollectionView!
    @IBOutlet weak var cvCharacter: UICollectionView!
    @IBOutlet weak var cvHeightConst : NSLayoutConstraint!
    @IBOutlet weak var imgCheck : UIImageView!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var lblCaptainName : UILabel!
    @IBOutlet weak var viewCaptainName : UIView!
    @IBOutlet weak var imgCaptain : UIImageView!
    @IBOutlet weak var imgOpponent : UIImageView!
    @IBOutlet weak var lblOpponent : UILabel!
    @IBOutlet weak var lblStageToPlay : UILabel!
    @IBOutlet weak var lblMessage : UILabel!   
    @IBOutlet weak var viewTopHeightConst : NSLayoutConstraint!
    @IBOutlet weak var viewSelectOpponent : UIView!
    @IBOutlet weak var viewHeader : UIView!
    @IBOutlet weak var viewSelectOpponentHeightConst : NSLayoutConstraint!
    @IBOutlet weak var lblStageHeight : NSLayoutConstraint!
    @IBOutlet weak var lblTimer : UILabel!
    @IBOutlet weak var scrlView : UIScrollView!
    
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var btnPreviousCharacter: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponent = myPlayerIndex == 0 ? 1 : 0
        arrTitle = ["A-F", "G-K", "L-P", "Q-U", "V-Z"]
        
        btnProceed.layer.cornerRadius = 10
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        viewCaptainName.layer.cornerRadius = 4
        viewCaptainName.layer.borderColor = UIColor.black.cgColor
        viewCaptainName.layer.borderWidth = 1
        
        //arrChars = APIManager.sharedManager.content?.characters ?? []
        cvCharName.register(UINib(nibName: "CharNameCVCell", bundle: nil), forCellWithReuseIdentifier: "CharNameCVCell")
                
        cvCharName.isHidden = true
        viewHeader.isHidden = true
        cvCharacter.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arrChars.removeAll()
        arrChars = APIManager.sharedManager.content?.characters ?? []       /// By Pranay. from viewDidLoad
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        self.imgCaptain.layer.cornerRadius = self.imgCaptain.frame.size.height / 2
        self.imgOpponent.layer.cornerRadius = self.imgOpponent.frame.size.height / 2
        
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
        
        isCharacterRemovedFromStack = false
        arrNames.removeAll()
        currentSectinoSelected = -1
        currentItemSelected = -1
        btnProceed.isEnabled = false
        btnProceed.backgroundColor = Colors.border.returnColor()
        
        finalSeconds = ((APIManager.sharedManager.match?.matchType == Messages.regular || APIManager.sharedManager.match?.matchType == Messages.tournament) ? APIManager.sharedManager.content?.regularArenaTimeSettings?.timeForSelectPlayerCharacter : APIManager.sharedManager.content?.playoffArenaTimeSettings?.timeForSelectPlayerCharacter) ?? 15
        timeSeconds = finalSeconds
        
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
                self.setUI()
                
                self.setNotificationCountObserver()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        isCharacterRemovedFromStack = true
        listner?.remove()
    }
        
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isCharacterRemovedFromStack = true
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
    
    func setUI() {
        DispatchQueue.main.async {
            self.viewSelectOpponentHeightConst.constant = 0.0
            self.viewSelectOpponent.isHidden = true
        }
        
        let sortedUsers = arrChars.sorted {
            ($0.name ?? "") < ($1.name ?? "")
        }
        let arrNew = sortedUsers.map{Array(arrayLiteral: $0.name)[0]}
        
        let arrAF = ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F"]
        var cr = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrAF.count
            {
                if(arrAF[j] == chr!)
                {
                    cr.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr)
        
        let arrGK = ["g", "G", "h", "H", "i", "I", "j", "J", "k", "K"]
        var cr1 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrGK.count
            {
                if(arrGK[j] == chr!)
                {
                    cr1.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr1)
        
        let arrLP = ["l", "L", "m", "M", "n", "N", "o", "O", "p", "P"]
        var cr2 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrLP.count
            {
                if(arrLP[j] == chr!)
                {
                    cr2.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr2)
        
        let arrQU = ["q", "Q", "r", "R", "s", "S", "t", "T", "u", "U"]
        var cr3 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrQU.count
            {
                if(arrQU[j] == chr!)
                {
                    cr3.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr3)
        
        let arrVZ = ["v", "V", "w", "W", "x", "X", "y", "Y", "z", "Z"]
        var cr4 = [Characters]()
        for i in 0 ..< arrNew.count
        {
            let chr = arrNew[i]?.prefix(1)
            for j in 0 ..< arrVZ.count
            {
                if(arrVZ[j] == chr!)
                {
                    cr4.append(sortedUsers[i])
                }
            }
        }
        arrNames.append(cr4)
        
        let count = arrNames[0].count % 2
        let height = count == 0 ? 0 : 1
        let h = CGFloat(((arrNames[0].count / 2)+height) * 48)
        let count1 = arrNames[1].count % 2
        let height1 = count1 == 0 ? 0 : 1
        let h1 = CGFloat(((arrNames[1].count / 2)+height1) * 48)
        let count2 = arrNames[2].count % 2
        let height2 = count2 == 0 ? 0 : 1
        let h2 = CGFloat(((arrNames[2].count / 2)+height2) * 48)
        let count3 = arrNames[3].count % 2
        let height3 = count3 == 0 ? 0 : 1
        let h3 = CGFloat(((arrNames[3].count / 2)+height3) * 48)
        let count4 = arrNames[4].count % 2
        let height4 = count4 == 0 ? 0 : 1
        let h4 = CGFloat(((arrNames[4].count / 2)+height4) * 48)
        cvHeightConst.constant = h + h1 + h2 + h3 + h4 + 250
        self.contentHeight = Int(h + h1 + h2 + h3 + h4 + 570)
        
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        cvCharName.reloadData()
        cvCharacter.reloadData()
        viewHeader.isHidden = false
        cvCharacter.isHidden = false
        cvCharName.isHidden = false
        
        print(cvHeightConst.constant)
        
        if APIManager.sharedManager.timer.isValid == true
        {
//            self.log.i("ArenaCharacterSelectionVC Remove previous active timer - \(APIManager.sharedManager.user?.userName ?? "")")
            APIManager.sharedManager.timer.invalidate()
        }
        addListner()
        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
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
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 3
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if isCharacterRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            timeSeconds = 0
            APIManager.sharedManager.timer.invalidate()
            if self.doc != nil {
                //proceedTapped(btnProceed) //  Comment by Pranay.
                // By Pranay
                self.isAutoSelect = true
                self.proceedTapped(UIButton())
                
                /*let host = playerArr[0]["host"] as! Int == 1 ? 0 : 1
                if (APIManager.sharedManager.myPlayerIndex == host) && (self.doc?.data()?["currentRound"] as! Int == 1) {
                    self.showLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.hideLoading()
                        self.proceedTap()
                    }
                }
                else {
                    self.proceedTap()
                }   //  */
                // .
                print("Timer is over and call proceed ...")
            }
        } else {
            lblTimer.text = "Time Limit: \(timeFormatted(seconds: timeSeconds))"
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let newSeconds = ((seconds % 3600) % 60)
        return String(format: "%d:%d", minutes, newSeconds)
    }
    
    func addListner() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaCharacterSelectionVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaCharacterSelectionVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaCharacterSelectionVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaCharacterSelectionVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaCharacterSelectionVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    var roundArr = [[String:AnyObject]]()
                    var status = false
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                    
                    self.chatBadge()
                    
                    status = ((self.playerArr[self.opponent])["characterCurrent"]) as! Bool
                    
                    
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
                    //round more than 1
                    else if self.doc?.data()?["currentRound"] as! Int != 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.scrlView.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(self.contentHeight))
                            //self.scrlView.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat(self.contentHeight))
                        }
                        
                        if (roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == self.playerArr[self.myPlayerIndex]["teamId"] as? Int) && (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count ?? 0 > 0) {
                            var finalIs = [String:AnyObject]()
                            finalIs = roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["finalStage"] as! [String : AnyObject]
                            let stage : String = finalIs["stageName"] as! String
                            self.lblStageToPlay.text = "Stage: \(stage)"
                        } else {
                            self.lblStageToPlay.isHidden = true
                            self.lblStageHeight.constant = 0
                        }
                        self.lblMessage.text = "Select your character"
                        self.viewTopHeightConst.constant = 50.0
                        self.viewTop.isHidden = false
                        self.imgCheck.isHidden = true
                        self.btnProceed.setTitle("Proceed", for: .normal)
                        self.scrlView.contentSize = CGSize(width: self.view.frame.size.width, height: self.scrlView.frame.size.height + 100)
                        
                        self.imgCaptain.setImage(imageUrl: (self.playerArr[self.myPlayerIndex]["characterImage"] as? String) ?? "")
                        self.lblCaptainName.text = self.playerArr[self.myPlayerIndex]["characterName"] as? String
                        
                        self.btnPreviousCharacter.isUserInteractionEnabled = true
                        
                        if (APIManager.sharedManager.isShoesCharacter ?? "") == "Yes" {
                            let playedChar: [Characters] = ((self.playerArr[self.myPlayerIndex]["host"] as? Int ?? 0)! == 1) ? (APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter)! : (APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter)!
                            
                            let arrCharId: [Characters] = playedChar.filter({ $0.id == (self.playerArr[self.myPlayerIndex]["characterId"] as? Int ?? 0)! })
                            if arrCharId.count > 0 {
                                //if arrCharId[0].characterUseCnt == 0 {
                                //}
                                //else
                                if arrCharId[0].characterUseCnt ?? 0 == self.intMaxNoOfCharSelect {
                                    //self.viewCaptainName.layer.borderColor = UIColor(hexString: "ED1C25").cgColor
                                    //self.lblCaptainName.textColor = UIColor(hexString: "ED1C25")
                                    self.btnPreviousCharacter.isUserInteractionEnabled = false
                                    self.viewCaptainName.layer.borderColor = Colors.disableButton.returnColor().cgColor
                                    self.lblCaptainName.textColor = Colors.disableButton.returnColor()
                                }
                                //else if arrCharId[0].characterUseCnt ?? 0 >= Int(self.intMaxNoOfCharSelect/2) + 1 {
                                //    self.viewCaptainName.layer.borderColor = UIColor(hexString: "FFCA19").cgColor
                                //    self.lblCaptainName.textColor = UIColor(hexString: "FFCA19")
                                //}
                                //else if arrCharId[0].characterUseCnt ?? 0 < Int(self.intMaxNoOfCharSelect/2) + 1 {
                                //    self.viewCaptainName.layer.borderColor = UIColor(hexString: "0DD146").cgColor
                                //    self.lblCaptainName.textColor = UIColor(hexString: "0DD146")
                                //}
                            }
                        }
                        
                        //opponent character selected but your character is not selected
                        if status == true && (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == false) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.scrlView.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(self.contentHeight - 45))
                                //self.scrlView.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat(self.contentHeight))
                            }
                            
                            self.viewSelectOpponentHeightConst.constant = 30.0
                            self.viewSelectOpponent.isHidden = false
                            self.lblOpponent.text = self.playerArr[self.opponent]["characterName"] as? String
                            self.imgOpponent.setImage(imageUrl: self.playerArr[self.opponent]["characterImage"] as? String ?? "")
                            if APIManager.sharedManager.timer.isValid == false {
                                APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                            }
                        }
                        //both player character selected
                        else if status == true && (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true) {
                            self.listner?.remove()
                            APIManager.sharedManager.timer.invalidate()
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                            for aViewController in viewControllers {
                                if aViewController is ArenaRoundResultVC {
                                    let aVC = aViewController as! ArenaRoundResultVC
                                    aVC.isListenerAsign = true
                                    // By Pranay
                                    aVC.isReminderOnceAppear = false
                                    //.
                                    //self.navigationController!.popToViewController(aViewController, animated: true)
                                    if self.isCharacterRemovedFromStack == false {
                                        _ = self.navigationController?.popToViewController(aVC, animated: true)
                                    }
                                    break
                                }
                                else {
                                    let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                    arenaLobby.tusslyTabVC = self.tusslyTabVC
                                    arenaLobby.leagueTabVC = self.leagueTabVC
                                    if self.isCharacterRemovedFromStack == false {
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    }
                                    break
                                }
                            }
                        }
                        
                        //previous round winner is you && your character selected && opponent character not selected
                        if roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == self.playerArr[self.myPlayerIndex]["teamId"] as? Int && (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true) && (self.playerArr[self.opponent]["characterCurrent"] as! Bool == false) {
                            
                            if APIManager.sharedManager.customStageCharSettings?.charSelectByWinner == 1 {
                                let host = self.playerArr[0]["host"] as! Int == 1 ? 0 : 1
                                let otherPlayer = host == 0 ? 1 : 0
                                var param : [String: Any]
                                
                                var randNo: Int = 0
                                var roundArr = [[String:AnyObject]]()
                                roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                                
                                let characterId : Int = (self.myPlayerIndex == host) ? ((self.playerArr[host]["characterId"] as AnyObject) as! Int) : ((self.playerArr[otherPlayer]["characterId"] as AnyObject) as! Int)
                                let tempChar: [Characters] = self.arrChars.filter({ $0.id == characterId })
                                if ((APIManager.sharedManager.isShoesCharacter ?? "") == "Yes") && (tempChar[0].characterUseCnt ?? 0 >= self.intMaxNoOfCharSelect) {
                                    
                                    let characterId : Int = (self.myPlayerIndex == host) ? ((self.playerArr[host]["defaultCharId"] as AnyObject) as! Int) : ((self.playerArr[otherPlayer]["defaultCharId"] as AnyObject) as! Int)
                                    let tempChar: [Characters] = self.arrChars.filter({ $0.id == characterId })
                                    
                                    if (tempChar[0].characterUseCnt ?? 0 >= self.intMaxNoOfCharSelect) {
                                        let tempChar: [Characters] = self.arrChars.filter({ $0.characterUseCnt ?? 0 < self.intMaxNoOfCharSelect })
                                        randNo = Int.random(in: 0 ..< tempChar.count)
                                        
                                        self.playerArr[self.myPlayerIndex]["characterName"] = tempChar[randNo].name as AnyObject?
                                        self.playerArr[self.myPlayerIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject?
                                        self.playerArr[self.myPlayerIndex]["characterId"] = tempChar[randNo].id as AnyObject?
                                        
                                        if self.myPlayerIndex == host {
                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = tempChar[randNo].id as AnyObject
                                        } else {
                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = tempChar[randNo].id as AnyObject
                                        }
                                    }
                                    else {
                                        self.playerArr[self.myPlayerIndex]["characterName"] = self.playerArr[self.myPlayerIndex]["defaultCharName"]
                                        self.playerArr[self.myPlayerIndex]["characterImage"] = self.playerArr[self.myPlayerIndex]["defaultCharImage"]
                                        self.playerArr[self.myPlayerIndex]["characterId"] = self.playerArr[self.myPlayerIndex]["defaultCharId"]
                                        
                                        if self.myPlayerIndex == host {
                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = self.playerArr[host]["defaultCharId"] as AnyObject
                                        } else {
                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = self.playerArr[otherPlayer]["defaultCharId"] as AnyObject
                                        }
                                    }
                                    
                                    param = [
                                        "rounds": roundArr,
                                        "playerDetails": self.playerArr
                                    ] as [String: Any]
                                }
                                else {
                                    if self.myPlayerIndex == host {
                                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = self.playerArr[host]["characterId"] as AnyObject
                                    } else {
                                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = self.playerArr[otherPlayer]["characterId"] as AnyObject
                                    }
                                    
                                    param = [
                                        "rounds": roundArr
                                    ] as [String: Any]
                                }
                                
//                                self.log.i("ArenaCharacterSelectionVC - InListner update firestore data for winner detail  - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                    if let err = err {
//                                        self.log.e("ArenaCharacterSelectionVC - InListner Fail update firestore data for winner detail  - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                    }
                                }
                            }
                            self.waitingPopup()
                        }
                        //previous round winner is you && opponent character selected
                        else if roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == self.playerArr[self.myPlayerIndex]["teamId"] as? Int && (self.playerArr[self.opponent]["characterCurrent"] as! Bool == true) {
                            self.characterSelectionDone()
                        }
                        //previous round winner is oppponent && opponent character not selected
                        else if roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == self.playerArr[self.opponent]["teamId"] as? Int && (self.playerArr[self.opponent]["characterCurrent"] as! Bool == false) {
                            self.waitingPopup()
                        }
                        //previous round winner is oppponent && both player character selected
                        else if roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == self.playerArr[self.opponent]["teamId"] as? Int && (self.playerArr[self.opponent]["characterCurrent"] as! Bool == true) && (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true){
                            self.characterSelectionDone()
                        }
                    }
                    //round 1
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.scrlView.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(self.contentHeight - 80))
                            //self.scrlView.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat(self.contentHeight))
                        }
                        
                        self.lblStageToPlay.isHidden = true
                        self.lblStageHeight.constant = 0
                        self.viewTopHeightConst.constant = 0.0
                        self.viewTop.isHidden = true
                        self.lblMessage.text = "Blind Pick. Select your character and proceed."
                        
                        // By Pranay
                        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
                            self.btnProceed.setTitle("Proceed", for: .normal)
                        }
                        
                        let host = self.playerArr[0]["host"] as! Int == 1 ? 0 : 1
                        let isHost = (host == self.myPlayerIndex) ? true : false
                        // .
                        
                        if status == true && (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true) {
                            self.characterSelectionDone()
                        }
                        else if (self.playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true ) {
                            APIManager.sharedManager.timer.invalidate()
                            self.listner?.remove()
                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                            dialog.modalPresentationStyle = .overCurrentContext
                            dialog.modalTransitionStyle = .crossDissolve
                            dialog.descriptionString = "Waiting for your opponent to select a Character."
                            //dialog.status = self.doc?.data()?["currentRound"] as! Int != 1 ? Messages.playinRound : Messages.selectRPC
                            dialog.arenaFlow = "FirstRoundCharacter"
                            dialog.isLoader = false
                            // By Pranay
                            dialog.isHost = isHost
                            // .
                            dialog.timeSeconds = self.finalSeconds
                            dialog.tapOk = {
                                
                                if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRockPaperScisierVC") as! ArenaRockPaperScisierVC
                                    controller.tusslyTabVC = self.tusslyTabVC
                                    controller.leagueTabVC = self.leagueTabVC
                                    if self.isCharacterRemovedFromStack == false {
                                        self.navigationController?.pushViewController(controller, animated: true)
                                    }
                                }
                                else {
                                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                    for aViewController in viewControllers {
                                        if aViewController is ArenaRoundResultVC {
                                            let aVC = aViewController as! ArenaRoundResultVC
                                            aVC.isListenerAsign = true
                                            aVC.isReminderOnceAppear = false
                                            if self.isCharacterRemovedFromStack == false {
                                                _ = self.navigationController?.popToViewController(aVC, animated: true)
                                            }
                                            break
                                        }
                                        else {
                                            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                            arenaLobby.tusslyTabVC = self.tusslyTabVC
                                            arenaLobby.leagueTabVC = self.leagueTabVC
                                            if self.isCharacterRemovedFromStack == false {
                                                self.navigationController?.pushViewController(arenaLobby, animated: true)
                                            }
                                            break
                                        }
                                    }
                                }
                                
                            }
                            if self.isCharacterRemovedFromStack == false {
                                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func characterSelectionDone() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        var navStatus = Messages.selectRPC
        //if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! == 0 {
        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
            navStatus = Messages.playinRound
        }
        
        if self.doc?.data()?["currentRound"] as! Int == 1 {
            let param = [
                "status" : navStatus
            ] as [String: Any]
//            self.log.i("ArenaCharacterSelectionVC - characterSelectionDone() update firestore - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                if let err = err {
//                    self.log.e("ArenaCharacterSelectionVC - characterSelectionDone() update firestore fail - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                    Utilities.showPopup(title: "\(err)", type: .error)
                } else {
                    self.listner?.remove()
//                    self.log.i("Round 1 char selection done. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                    //if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! != 0 {
                    if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRockPaperScisierVC") as! ArenaRockPaperScisierVC
                        //self.listner?.remove()
                        controller.tusslyTabVC = self.tusslyTabVC
                        controller.leagueTabVC = self.leagueTabVC
                        if self.isCharacterRemovedFromStack == false {
                            APIManager.sharedManager.timer.invalidate()
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    } else {
                        //self.moveToProceedScreen()  //  Added by Pranay.
                        APIManager.sharedManager.timer.invalidate()
                        //self.listner?.remove()
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                        for aViewController in viewControllers {
                            if aViewController is ArenaRoundResultVC {
                                let aVC = aViewController as! ArenaRoundResultVC
                                aVC.isListenerAsign = true
                                aVC.isReminderOnceAppear = false
                                if self.isCharacterRemovedFromStack == false {
                                    _ = self.navigationController?.popToViewController(aVC, animated: true)
                                }
                                break
                            } else {
                                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                arenaLobby.tusslyTabVC = self.tusslyTabVC
                                arenaLobby.leagueTabVC = self.leagueTabVC
                                if self.isCharacterRemovedFromStack == false {
                                    self.navigationController?.pushViewController(arenaLobby, animated: true)
                                }
                                break
                            }
                        }
                    }
                }
            }
        } else {
            /*db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                "status" : Messages.playinRound
            ])  //  */
            self.moveToProceedScreen()  //  Added by Pranay.
        }
    }
    
    /// 444 - By Pranay
    func moveToProceedScreen() {
//        self.log.i("Char selection done Update status. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \"status : \(Messages.playinRound)\"")  //  By Pranay.
        db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
            "status" : Messages.playinRound
        ]) { err in
            if let err = err {
//                self.log.e("Char selection done Update status fail. - Remain time -> \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
            }
        }
    }
    /// 444 .
    
    func waitingPopup() {
        APIManager.sharedManager.timer.invalidate()
        self.listner?.remove()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.descriptionString = "Waiting for your opponent to select a Character."
        dialog.arenaFlow = "CharacterSelected"
        dialog.isLoader = false
        dialog.timeSeconds = finalSeconds
        dialog.myPlayerIndex = self.myPlayerIndex
        dialog.tapOk = {
            self.addListner()
        }
        if self.isCharacterRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
        
    // MARK: - Button Click Events
    @IBAction func proceedTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        
        // By Pranay
//        self.log.i("char proceed tap. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        let host = playerArr[0]["host"] as! Int == 1 ? 0 : 1
        //self.listner?.remove()
        if self.doc?.data()?["currentRound"] as! Int == 1 {
            if host == myPlayerIndex {
                if self.doc?.data()?["awayCharSelect"] as! Int == 1 {
                    self.proceedTap()
                } else {
                    APIManager.sharedManager.timer.invalidate()
                    self.listner?.remove()
                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                    dialog.modalPresentationStyle = .overCurrentContext
                    dialog.modalTransitionStyle = .crossDissolve
                    dialog.descriptionString = "Waiting for your opponent to select a Character."
                    //dialog.status = self.doc?.data()?["currentRound"] as! Int != 1 ? Messages.playinRound : Messages.selectRPC
                    dialog.arenaFlow = "FirstRoundCharacter"
                    dialog.isLoader = false
                    // By Pranay
                    dialog.isHost = true
                    // .
                    dialog.timeSeconds = self.finalSeconds
                    dialog.tapOk = {
//                        self.log.i("char proceed tap waiting dialog ok tap and get document. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                            if let err = err {
//                                self.log.e("char proceed tap waiting dialog ok tap and get document fail. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                                print("Error getting documents: \(err)")
                            }
                            else {
                                if querySnapshot != nil {
                                    self.doc =  querySnapshot!
                                    
//                                    self.log.i("char proceed tap waiting dialog ok tap and get document. response -- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                                    
                                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                                    self.proceedTap()
                                }
                            }
                        }
                    }
                    if self.isCharacterRemovedFromStack == false {
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                }
            } else {
                self.proceedTap()
            }
        }
        else {
            self.proceedTap()
        }
        // .
    }
    
    // By Pranay
    func proceedTap() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        if self.isAutoSelect {
            self.isAutoSelect = false
            
            playerArr[self.myPlayerIndex]["characterName"] = playerArr[self.myPlayerIndex]["defaultCharName"]
            playerArr[self.myPlayerIndex]["characterImage"] = playerArr[self.myPlayerIndex]["defaultCharImage"]
            playerArr[self.myPlayerIndex]["characterId"] = playerArr[self.myPlayerIndex]["defaultCharId"]
            
            let tempChar: [Characters] = arrChars.filter({ $0.id == ((playerArr[self.myPlayerIndex]["defaultCharId"])! as! Int) })
            if ((APIManager.sharedManager.isShoesCharacter ?? "") == "Yes") && (tempChar[0].characterUseCnt ?? 0 >= self.intMaxNoOfCharSelect) {
                let tempChar: [Characters] = arrChars.filter({ $0.characterUseCnt ?? 0 < self.intMaxNoOfCharSelect })
                let randNo: Int = Int.random(in: 0 ..< tempChar.count)
                
                playerArr[self.myPlayerIndex]["characterName"] = tempChar[randNo].name as AnyObject?
                playerArr[self.myPlayerIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject?
                playerArr[self.myPlayerIndex]["characterId"] = tempChar[randNo].id as AnyObject?
            }
        }
        else if (isUpdate == true) {
            playerArr[self.myPlayerIndex]["characterName"] = finalChar.name as AnyObject?
            playerArr[self.myPlayerIndex]["characterImage"] = finalChar.imagePath as AnyObject?
            playerArr[self.myPlayerIndex]["characterId"] = finalChar.id as AnyObject?
        }
        playerArr[self.myPlayerIndex]["characterCurrent"] = true as AnyObject?
        
        let host = playerArr[0]["host"] as! Int == 1 ? 0 : 1
        let otherPlayer = host == 0 ? 1 : 0
        var roundArr = [[String:AnyObject]]()
        var param = [String: Any]()
        
        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
        
        if APIManager.sharedManager.myPlayerIndex == host {
            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = playerArr[host]["characterId"] as AnyObject
            
            param = [
                "playerDetails": self.playerArr,
                "rounds": roundArr
            ]
        } else {
            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = playerArr[otherPlayer]["characterId"] as AnyObject
            if self.doc?.data()?["currentRound"] as! Int == 1 {
                param = [
                    "awayCharSelect": 1,
                    "playerDetails": self.playerArr,
                    "rounds": roundArr
                ]
            } else {
                param = [
                    "playerDetails": self.playerArr,
                    "rounds": roundArr
                ]
            }
        }
        //roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = playerArr[host]["characterId"] as AnyObject
        //roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = playerArr[otherPlayer]["characterId"] as AnyObject
        
//        self.log.i("char proceedTap() and updateData. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") -- param - \(param)")  //  By Pranay.
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
            if let err = err {
//                self.log.e("char proceedTap() and updateData. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") -- playerDetails, rounds -- Error-> \(err)")  //  By Pranay.
            }
            else {
                if self.doc?.data()?["currentRound"] as! Int == 1 {
                    let host = self.playerArr[0]["host"] as! Int == 1 ? 0 : 1
                    if host == self.myPlayerIndex {
                        //self.addListner()
                        if self.doc?.data()?["awayCharSelect"] as! Int == 1 {
                            self.characterSelectionDone()
                        }
                    } else {
                        /*//let key = (host == self.myPlayerIndex) ? "hostCharSelect" : "awayCharSelect"
                        self.log.i("Update awayCharSelect to 1 for away player. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                            "awayCharSelect" : 1
                        ]) { err in
                            if let err = err {
                                self.log.e("Update awayCharSelect to 1 for away player. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                            }
                        }   //  */
                    }
                }
            }
        }
    }
    
    @IBAction func previousCharacterTapped(_ sender: UIButton) {
        if isPreviousSelected {
            imgCheck.isHidden = true
            isPreviousSelected = false
            btnProceed.backgroundColor = Colors.border.returnColor()
            btnProceed.isEnabled = false
        } else {
            if currentSectinoSelected != -1 {
                currentSectinoSelected = -1
                currentItemSelected = -1
                cvCharacter.reloadData()
            }
            isUpdate = false
            imgCheck.isHidden = false
            isPreviousSelected = true
            btnProceed.backgroundColor = Colors.theme.returnColor()
            btnProceed.isEnabled = true
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

//MARK:- UICollectionViewDelegate

extension ArenaCharacterSelectionVC : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return collectionView == cvCharacter ? arrNames.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collectionView == cvCharacter ? arrNames[section].count : arrChar.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == cvCharacter
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharProfileCVCell", for: indexPath) as! CharProfileCVCell
            cell.btnChar.isHidden = true
            cell.lblTitle.text = arrNames[indexPath.section][indexPath.row].name
            cell.imgProfile.setImage(imageUrl: arrNames[indexPath.section][indexPath.row].imagePath ?? "")
            cell.lblTitle.textColor = .black
            
            cell.lblNoOfCharSelect.isHidden = true
            cell.isUserInteractionEnabled = true
            cell.lblNoOfCharSelect.isHidden = true
            
            let selected: String = "Selected \(arrNames[indexPath.section][indexPath.row].characterUseCnt ?? 0)/\(intMaxNoOfCharSelect)"
            
            if (APIManager.sharedManager.isShoesCharacter ?? "") == "Yes"
            {
                cell.lblNoOfCharSelect.isHidden = false
                if arrNames[indexPath.section][indexPath.row].characterUseCnt ?? 0 == 0
                {
                    cell.lblNoOfCharSelect.isHidden = true
                }
                else if arrNames[indexPath.section][indexPath.row].characterUseCnt ?? 0 >= intMaxNoOfCharSelect
                {
                    cell.lblNoOfCharSelect.text = selected
                    cell.lblNoOfCharSelect.textColor = Colors.red.returnColor()     //UIColor(hexString: "ED1C25")
                    cell.isUserInteractionEnabled = false
                    cell.lblTitle.textColor = Colors.disableButton.returnColor()
                }
                else if arrNames[indexPath.section][indexPath.row].characterUseCnt ?? 0 >= Int(intMaxNoOfCharSelect/2) + 1
                {
                    cell.lblNoOfCharSelect.text = selected
                    cell.lblNoOfCharSelect.textColor = Colors.yellow.returnColor()     //UIColor(hexString: "FFCA19")
                }
                else if arrNames[indexPath.section][indexPath.row].characterUseCnt ?? 0 < Int(intMaxNoOfCharSelect/2) + 1
                {
                    cell.lblNoOfCharSelect.text = selected
                    cell.lblNoOfCharSelect.textColor = Colors.green.returnColor()     //UIColor(hexString: "0DD146")
                }
            }
            
            
            if indexPath.section == currentSectinoSelected && indexPath.row == currentItemSelected {
                if isPreviousSelected {
                    imgCheck.isHidden = true
                    isPreviousSelected = false
                }
                cell.imgSelected.isHidden = false
            } else {
                cell.imgSelected.isHidden = true
            }
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharNameCVCell", for: indexPath) as! CharNameCVCell
            cell.lblTitle.text = arrChar[indexPath.row]
            
//            if arrNames.count != 0 {
//                if arrNames[indexPath.row].count == 0
//                {
//                    cell.lblTitle.textColor = Colors.disable.returnColor()
//                }
//                else
//                {
//                    cell.lblTitle.textColor = .black
//                }
//            }
            
            return cell
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == cvCharacter {
//            currentSectinoSelected = indexPath.section
//            currentItemSelected = indexPath.row
//            cvCharacter.reloadData()
//            btnProceed.backgroundColor = Colors.theme.returnColor()
//            btnProceed.isEnabled = true
//            isUpdate = true
//            finalChar = arrNames[indexPath.section][indexPath.row]
//        } else {
//            DispatchQueue.main.async {
//                let sectionRect = self.cvCharacter.layoutAttributesForItem(at:IndexPath(row: 0, section: indexPath.item))?.frame
//                self.cvCharacter.setContentOffset(CGPoint(x: 0,y :sectionRect!.origin.y - 50), animated: true)
//                //self.cvCharacter.scrollToItem(at:IndexPath(item: 0, section: indexPath.item), at: .right, animated: false)
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == cvCharacter
        {
            currentSectinoSelected = indexPath.section
            currentItemSelected = indexPath.row
            cvCharacter.reloadData()
            btnProceed.backgroundColor = Colors.theme.returnColor()
            btnProceed.isEnabled = true
            isUpdate = true
            finalChar = arrNames[indexPath.section][indexPath.row]
        }
        else
        {
            DispatchQueue.main.async {
                let sectionRect = self.cvCharacter.layoutAttributesForItem(at:IndexPath(row: 0, section: indexPath.item))?.frame
                if sectionRect != nil
                {
                    self.cvCharacter.setContentOffset(CGPoint(x: 0,y :sectionRect!.origin.y - 50), animated: true)
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if(scrollView == scrlView)
        {
            if scrollView.contentOffset.y == 0
            {
                print(self.cvCharacter.contentOffset.y)
                self.cvCharacter.contentOffset = CGPoint(x:self.cvCharacter.contentOffset.x, y:0.0);
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if collectionView == cvCharacter
        {
            if let sectionHeader = cvCharacter.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CharacterSection", for: indexPath) as? CharacterSection
            {
                sectionHeader.lblTitle.text = arrChar[indexPath.section]
                return sectionHeader
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == cvCharacter
        {
            return CGSize(width: self.cvCharacter.frame.size.width / 2, height: 48)
        }
        else
        {
            return CGSize(width: 76, height: 48)
        }
    }
}

extension ArenaCharacterSelectionVC {
    
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
                //self.addListner()
            }
        }
    }
}
