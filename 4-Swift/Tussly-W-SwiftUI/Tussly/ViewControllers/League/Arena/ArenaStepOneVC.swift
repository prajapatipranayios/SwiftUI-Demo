//
//  ArenaVC.swift
//  Tussly
//
//  Created by Auxano on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import MarqueeLabel
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import SwipeCellKit
//import ShipBookSDK

class ArenaStepOneVC: UIViewController {
    
    // MARK: - Variables
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var timer = Timer()
    var timeSeconds = 0
    var arrLeagueRound = [LeagueRounds]()
    var arrCounterStage = [StarterStage]()
    var arrStarterStage = [StarterStage]()
    var matchDetail = Match()
    var arrLoby = [GameLobby]()
    var arrSelectedStageIndex = [Int]()
    var arrFirestore : FirebaseInfo?
    let db = Firestore.firestore()
    var arrStagePicked = [Int]()
    var isCharSelect = false
    var btnChat = UIButton()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var randomChar = Characters()
    var fbID = ""
    var isTap = false
    var isMyIdBlock = false
    var isOppoIdBlock = false
    var hostImage = ""
    var opponentImage = ""
    var homeTeamName = ""
    var awayTeamName = ""
    var isDefaultCharSelected = false
    var selectData = [[String:AnyObject]]()
    
//    fileprivate let log = ShipBook.getLogger(ArenaStepOneVC.self)
    var refreshTimer = Timer()
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var scrlView : UIScrollView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblGameTime : UILabel!
    @IBOutlet weak var tvMode: UITableView!
    @IBOutlet weak var tvMap: UITableView!
    @IBOutlet weak var lblModeTitle: UILabel!
    @IBOutlet weak var lblMapTitle : UILabel!
    
    @IBOutlet weak var btnEnterArena: UIButton!
    @IBOutlet weak var btnStageRanking: UIButton!
    @IBOutlet weak var btnCharSelection: UIButton!
    
    @IBOutlet weak var lblGameCountDown: UILabel!
    
    @IBOutlet weak var imgCharacter : UIImageView!
    @IBOutlet weak var lblCharacter : UILabel!
    @IBOutlet weak var viewCharacterSelection : UIView!
    @IBOutlet weak var lblHostName : UILabel!
    @IBOutlet weak var lblOpponentName : UILabel!
    @IBOutlet weak var imgHost : UIImageView!
    @IBOutlet weak var viewHost : UIView!
    @IBOutlet weak var viewNextMatchSchedule : UIView!
    @IBOutlet weak var lblNextPlayer1: UILabel!
    @IBOutlet weak var lblNextPlayer2: UILabel!
    @IBOutlet weak var imgNextPlayer2: UIImageView!
    @IBOutlet weak var imgNextPlayer1: UIImageView!
    @IBOutlet weak var lblNextMatchTime: UILabel!
    @IBOutlet weak var lblNextGame: UILabel!
    @IBOutlet weak var viewOpponent : UIView!
    @IBOutlet weak var viewArenaClose : UIView!
    @IBOutlet weak var imgOpponent : UIImageView!
    @IBOutlet weak var tvStarterHeight : NSLayoutConstraint!
    @IBOutlet weak var tvCounterHeight : NSLayoutConstraint!
    @IBOutlet weak var bottomTimerHeight : NSLayoutConstraint!
    @IBOutlet weak var headerHeight : NSLayoutConstraint!
    
    // By Pranay
    @IBOutlet weak var viewHostUnderScore: UIView!
    @IBOutlet weak var lblHost: UILabel!
    @IBOutlet weak var constViewHost: NSLayoutConstraint!
    @IBOutlet weak var lblResetMatchTitle: UILabel!
    @IBOutlet weak var lblResetMatchMsg1: UILabel!
    @IBOutlet weak var lblResetMatchMsg2: UILabel!
    @IBOutlet weak var btnContactOrganizer: UIButton!
    @IBOutlet weak var btnRefreshMatchDetail: UIButton!
    @IBOutlet weak var lblRefreshMsg: UILabel!
    @IBOutlet weak var btnRefreshMatchDetail1: UIButton!
    @IBOutlet weak var lblManualUpdateMsg: UILabel!
    @IBOutlet weak var btnHostUsedChar: UIButton!
    @IBOutlet weak var btnAwayUsedChar: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if APIManager.sharedManager.gameSettings?.isTournamentHost ?? 0 == 1 {
            viewHostUnderScore.isHidden = false
            lblHost.isHidden = false
            constViewHost.constant = 15
        } else {
            viewHostUnderScore.isHidden = true
            lblHost.isHidden = true
            constViewHost.constant = 0
        }
        lblTitle.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        self.btnEnterArena.isEnabled = false
        
        
        self.tvMode.dataSource = self
        self.tvMode.delegate = self
        self.tvMap.dataSource = self
        self.tvMap.delegate = self
        if UserDefaults.standard.object(forKey: "tieRPS") != nil {
            UserDefaults.standard.removeObject(forKey: "tieRPS")
        }
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleTournamentNotificationObserver),
                                                   name: .tournamentNotificationObserver,
                                                   object: nil)
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
        self.btnChat.isEnabled = true
        self.btnChat.addTarget(self, action: #selector(self.onTapChat), for: .touchUpInside)

        let btnForfeit = UIBarButtonItem(customView: self.btnForfeit)
        let btnChat = UIBarButtonItem(customView: self.btnChat)
        
        self.navigationItem.setRightBarButtonItems([btnChat, btnForfeit], animated: true)
        
        self.lblTitle.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        self.btnRefreshMatchDetail.isUserInteractionEnabled = (APIManager.sharedManager.isMatchRefresh) ? true : false
        let strImgName: String = (APIManager.sharedManager.isMatchRefresh) ? "refresh" : "refreshDisable"
        
        self.btnRefreshMatchDetail.setImage(UIImage(named: strImgName), for: .normal)
        
        self.lblRefreshMsg.text = "Your next match has not been scheduled yet. You will receive a notification as soon as it is scheduled."
        self.lblRefreshMsg.isHidden = (APIManager.sharedManager.isMatchRefresh) ? true : false
        
        /// This button in arena close screen.q
        self.btnRefreshMatchDetail1.setImage(UIImage(named: strImgName), for: .normal)
        self.btnRefreshMatchDetail1.isHidden = (APIManager.sharedManager.match?.isManualUpdateFromUpcoming ?? 0) == 0 ? true : false
        self.btnRefreshMatchDetail1.isUserInteractionEnabled = (APIManager.sharedManager.isMatchRefresh) ? true : false
        self.lblManualUpdateMsg.text = APIManager.sharedManager.match?.manualUpdateFromUpcomingMsg ?? ""
        self.lblManualUpdateMsg.isHidden = (APIManager.sharedManager.match?.isManualUpdateFromUpcoming ?? 0) == 0 ? true : false
        
        if APIManager.sharedManager.isMatchForfeit && !(APIManager.sharedManager.isMatchForfeitByMe) {
            print("APIManager.sharedManager.isMatchForfeit >>>>>>> True --- Condition true")
            APIManager.sharedManager.isMatchForfeit = false
            self.showForfeitPopup()
        }
        else {
            print("APIManager.sharedManager.isMatchForfeit >>>>>>> False --- Condition false")
            APIManager.sharedManager.isMatchForfeitByMe = false
            APIManager.sharedManager.isMatchForfeit = false
        }
        
        if self.refreshTimer.isValid == true {
            self.refreshTimer.invalidate()
        }
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
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
        timer.invalidate()
        
        self.refreshTimer.invalidate()
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .tournamentNotificationObserver, object: nil)
    }
    
    //MARK: - UI Methods
    @objc func onTapForfeit() {
        
        if APIManager.sharedManager.match?.resetMatch ?? 0 == 1 {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
        else if APIManager.sharedManager.match?.isManualUpdateFromUpcoming ?? 0 == 1 {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
        else if matchDetail.isEliminate == 1 {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
        else {
            if matchDetail.matchId != nil {
                if matchDetail.matchId != 0 {
                    if matchDetail.awayTeamId != 0 && matchDetail.homeTeamId != 0 {
                        self.showChatRedDot(show: false)
                        
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
                    else {
                        self.btnChat.setImage(UIImage(named: "Chat_disabled"), for: .normal)
                        self.btnChat.isEnabled = false
                        self.btnForfeit.setImage(UIImage(named: "forfeitDisable"), for: .normal)
                        self.btnForfeit.isEnabled = false
                        self.showChatRedDot(show: false)
                        //viewNextMatch()
                        Utilities.showPopup(title: "Oppoent is not available in this match.", type: .error)
                    }
                }
                else {
                    Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
                }
            }
            else {
                Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
            }
        }
    }
    
    @objc func onTapChat() {
        let chatUserId : String = (self.leagueTabVC!().matchDetail?.chatId ?? "-1")
        if chatUserId != "-1" && !self.isChatBtnTap {
            self.isChatBtnTap = false
            self.openArenaGroupConvorsation(id: chatUserId, type: .group, isFromArena: true, tusslyTabVC: self.tusslyTabVC) { success in
                if success {
                    self.isChatBtnTap = true
                    self.leagueTabVC!().showUnreadCount = false
                }
            }
        }
        else {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
    }
    
    func showForfeitPopup() {
        DispatchQueue.main.async {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = "Match Forfeit"
            dialog.message = "This match has been forfeited. View the bracket for results."
            dialog.btnYesText = Messages.ok
            dialog.isMsgCenter = true
            //dialog.btnNoText = Messages.close
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    func setNotificationCountObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnreadUpdate(_:)), name: .chatUnreadCountUpdated, object: nil)
        
        DispatchQueue.main.async {
            self.showChatRedDot(show: self.leagueTabVC!().showUnreadCount)
        }
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
                print("Remove label from button -- \(show)")
                existingDot.removeFromSuperview()
            }

            guard show else { return }
            
            print("Show label from button -- \(show)")
            let redDotSize: CGFloat = 12
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
    
    @objc private func handleTournamentNotificationObserver() {
        APIManager.sharedManager.strNotificationAction = ""
        self.leagueTabVC!().getTournamentContent()
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 60
        if timeSeconds < 60 {
            timer.invalidate()
            self.bottomTimerHeight.constant = 0
        } else {
            lblGameCountDown.attributedText = timeFormatted(seconds: timeSeconds).setAttributedString(boldString: "Game Time Countdown:", fontSize: 13.0)
            if timeSeconds <= 1800 {
                lblTitle.text = Messages.arenaOpen
                btnEnterArena.isEnabled = true
                btnEnterArena.backgroundColor = Colors.theme.returnColor()
                self.btnEnterArena.titleLabel?.textColor = UIColor.white
            }
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        if days == 0 {
            if hours == 0 {
                return String(format: "Game Time Countdown: %d minutes", minutes)
            } else {
                return String(format: "Game Time Countdown: %d hours %d minutes",hours, minutes)
            }
        }
        // 1 By Ashish
        if hours  == 0 {
            return String(format: "Game Time Countdown: %d days %d minutes", days, minutes)
        } else {
            return String(format: "Game Time Countdown: %d days %d hours %d minutes",days, hours, minutes)
        }
        // 1
//        return String(format: "Game Time Countdown: %d days %d hours %d minutes",days, hours, minutes) // Commented By Ashish
    }
    
    func setupUI() {
        matchDetail = APIManager.sharedManager.match!
        arrCounterStage = APIManager.sharedManager.content?.counterStage ?? []
        arrStarterStage = APIManager.sharedManager.content?.starterStage ?? []
        homeTeamName = (APIManager.sharedManager.match?.homeTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.homeTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.homeTeam?.teamName ?? "").index((APIManager.sharedManager.match?.homeTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.homeTeam?.teamName ?? "")
        awayTeamName = (APIManager.sharedManager.match?.awayTeam?.teamName ?? "").count > 30 ? String((APIManager.sharedManager.match?.awayTeam?.teamName ?? "")[..<(APIManager.sharedManager.match?.awayTeam?.teamName ?? "").index((APIManager.sharedManager.match?.awayTeam?.teamName ?? "").startIndex, offsetBy: 30)]) : (APIManager.sharedManager.match?.awayTeam?.teamName ?? "")
        
        if APIManager.sharedManager.match?.resetMatch ?? 0 == 1 {
            //self.btnChat.setImage(UIImage(named: "Chat_disabled"), for: .normal)
            //self.btnChat.isEnabled = false
//            self.btnChat.isHidden = true
//            self.btnChat.isEnabled = false
//            self.btnForfeit.isHidden = true
//            self.btnForfeit.isEnabled = false
            
            closeArena()
        }
        else if APIManager.sharedManager.match?.isManualUpdateFromUpcoming ?? 0 == 1 {
//            self.btnChat.isHidden = true
//            self.btnChat.isEnabled = false
//            self.btnForfeit.isHidden = true
//            self.btnForfeit.isEnabled = false
            
            closeArena()
        }
        else if matchDetail.isEliminate == 1 {
//            self.btnChat.isHidden = true
//            self.btnChat.isEnabled = false
//            self.btnForfeit.isHidden = true
//            self.btnForfeit.isEnabled = false
            
            closeArena()
        }
        else {
            if matchDetail.matchId != nil {
                if matchDetail.matchId != 0 {
                    if matchDetail.awayTeamId != 0 && matchDetail.homeTeamId != 0 {
                        self.showChatRedDot(show: false)
                        
                        self.btnChat.setImage(UIImage(named: "Chat_Icon"), for: .normal)
                        self.btnChat.isEnabled = true
                        self.btnForfeit.setImage(UIImage(named: "forfeit"), for: .normal)
                        self.btnForfeit.isEnabled = true
                        
                        setDetail()
                    }
                    else {
                        self.btnChat.setImage(UIImage(named: "Chat_disabled"), for: .normal)
                        self.btnChat.isEnabled = false
                        self.btnForfeit.setImage(UIImage(named: "forfeitDisable"), for: .normal)
                        self.btnForfeit.isEnabled = false
                        self.showChatRedDot(show: false)
                        viewNextMatch()
                    }
                }
                else {
//                    self.btnChat.isHidden = true
//                    self.btnChat.isEnabled = false
//                    self.btnForfeit.isHidden = true
//                    self.btnForfeit.isEnabled = false
                    
                    closeArena()
                }
            }
            else {
//                self.btnChat.isHidden = true
//                self.btnChat.isEnabled = false
//                self.btnForfeit.isHidden = true
//                self.btnForfeit.isEnabled = false
                
                closeArena()
            }
        }
    }
    
    func closeArena() {
        self.lblTitle.text = Messages.arenaClose
        scrlView.isScrollEnabled = false
        viewArenaClose.isHidden = false
        viewNextMatchSchedule.isHidden = true
        
        if !APIManager.sharedManager.isMatchRefresh {
            self.activeNextScheduledMatchTimer()
        }
    }
    
    func viewNextMatch() {
        viewNextMatchSchedule.isHidden = false
        viewArenaClose.isHidden = false
        scrlView.isScrollEnabled = false
        imgNextPlayer2.layer.cornerRadius = imgNextPlayer2.frame.size.height / 2
        imgNextPlayer1.layer.cornerRadius = imgNextPlayer1.frame.size.height / 2
        if APIManager.sharedManager.match?.matchId != nil && APIManager.sharedManager.match?.matchId != 0 && APIManager.sharedManager.match?.leagueId != 0 {
            if APIManager.sharedManager.match?.awayTeamId != 0 {
                if APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 {
                    //self.lblNextPlayer2.text = awayTeamName
                    self.lblNextPlayer2.text = APIManager.sharedManager.match?.awayTeamPlayers![0].playerDetails?.displayName ?? ""
                }
                else {
                    var name = ""
                    if APIManager.sharedManager.match?.awayTeamPlayers?.count ?? 0 > 0 {
                        name = APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? ""
                    }
                    var awayShort = awayTeamName.count > 30 ? String(awayTeamName[..<awayTeamName.index(awayTeamName.startIndex, offsetBy: 30)]) : awayTeamName
                    awayShort = awayTeamName.count > 30 ? (awayShort + "...") : awayTeamName
                    let finalName = "\(awayShort)\n\(name)"
                    self.lblNextPlayer2.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                }
                self.imgNextPlayer2.setImage(imageUrl: APIManager.sharedManager.match?.awayTeam?.awayImage ?? "")
            }
            else {
                self.lblNextPlayer2.text = APIManager.sharedManager.match?.parentAwayTeamWinnerLabel
                self.imgNextPlayer2.setImage(imageUrl: "")
            }
            
            if APIManager.sharedManager.match?.homeTeamId != 0 {
                self.imgNextPlayer1.setImage(imageUrl: APIManager.sharedManager.match?.homeTeam?.homeImage ?? "")
                if APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 {
                    //self.lblNextPlayer1.text = homeTeamName
                    self.lblNextPlayer1.text = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""
                }
                else {
                    var name = ""
                    if APIManager.sharedManager.match?.homeTeamPlayers?.count ?? 0 > 0 {
                        name = APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? ""
                    }
                    var homeShort = homeTeamName.count > 30 ? String(homeTeamName[..<homeTeamName.index(homeTeamName.startIndex, offsetBy: 30)]) : homeTeamName
                    homeShort = homeTeamName.count > 30 ? (homeShort + "...") : homeTeamName
                    let finalName = "\(homeShort)\n\(name)"
                    self.lblNextPlayer1.attributedText = finalName.setRegularString(string: name, fontSize: 13.0)
                }
            }
            else {
                self.imgNextPlayer1.setImage(imageUrl: "")
                self.lblNextPlayer1.text = APIManager.sharedManager.match?.parentHomeTeamWinnerLabel
            }
            
            self.lblNextGame.text = APIManager.sharedManager.leagueType != "League" ? APIManager.sharedManager.match?.nextMatchRoundLabel : APIManager.sharedManager.match?.league?.leagueName
            if APIManager.sharedManager.match?.onlyDate == "" || APIManager.sharedManager.match?.onlyDate == "TBD" {
                self.lblNextMatchTime.text = "TBD"
            }
            else {
                self.lblNextMatchTime.text = "\(APIManager.sharedManager.match?.onlyDate ?? "")\n\(APIManager.sharedManager.match?.onlyTime ?? "")"
            }
        }
        
        if !APIManager.sharedManager.isMatchRefresh {
            self.activeNextScheduledMatchTimer()
        }
    }
    
    func setDetail() {
        viewArenaClose.isHidden = true
        scrlView.isScrollEnabled = true
        viewNextMatchSchedule.isHidden = true
        btnEnterArena.layer.cornerRadius = btnEnterArena.frame.size.height / 2
        viewCharacterSelection.layer.cornerRadius = viewCharacterSelection.frame.size.height / 2
        viewCharacterSelection.layer.borderWidth = 1.0
        viewCharacterSelection.layer.borderColor = Colors.border.returnColor().cgColor
        btnStageRanking.layer.cornerRadius = 6
        //player 1 is host
        imgHost.layer.cornerRadius = imgHost.frame.size.height / 2
        imgOpponent.layer.cornerRadius = imgOpponent.frame.size.height / 2
        viewOpponent.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: UIColor.lightGray, radius: 1.0, opacity: 0.5, corner: viewOpponent.frame.height/2)
        viewHost.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: UIColor.lightGray, radius: 1.0, opacity: 0.5, corner: viewHost.frame.height/2)
        hostImage = matchDetail.homeTeam?.isJoinAsPlayer == 1 ? (matchDetail.homeTeamPlayers?.count ?? 0 > 0 ? (matchDetail.homeTeamPlayers![0].playerDetails?.avatarImage ?? "") : (matchDetail.homeTeamId != 0 ? (matchDetail.homeTeam?.homeImage ?? "") : "")) : (matchDetail.homeTeamId != 0 ? (matchDetail.homeTeam?.homeImage ?? "") : "")
        imgHost.setImage(imageUrl: hostImage)
        opponentImage = matchDetail.awayTeam?.isJoinAsPlayer == 1 ? (matchDetail.awayTeamPlayers?.count ?? 0 > 0 ? (matchDetail.awayTeamPlayers![0].playerDetails?.avatarImage ?? "") : (matchDetail.awayTeamId != 0 ? (matchDetail.awayTeam?.awayImage ?? "") : "")) : (matchDetail.awayTeamId != 0 ? (matchDetail.awayTeam?.awayImage ?? "") : "")
        imgOpponent.setImage(imageUrl: opponentImage)
        
        var hostTeamAndPlayer = ""
        var opponentTeamAndPlayer = ""
        if matchDetail.homeTeamId == 0 || matchDetail.awayTeamId == 0 {
            if matchDetail.homeTeamId == 0 {
                lblHostName.text = matchDetail.parentHomeTeamWinnerLabel
            }
            else {
                if matchDetail.homeTeam?.isJoinAsPlayer == 1 {
                    if matchDetail.homeTeamPlayers?.count ?? 0 > 0 {
                        lblHostName.attributedText = (matchDetail.homeTeamPlayers?[0].playerDetails?.displayName ?? "").setSemiboldString(semiboldString: (matchDetail.homeTeamPlayers?[0].playerDetails?.displayName ?? ""), fontSize: 13.0)
                    }
                    else {
                        lblHostName.text = matchDetail.parentHomeTeamWinnerLabel
                    }
                }
                else {
                    if matchDetail.homeTeamPlayers?.count ?? 0 > 0 {
                        lblHostName.attributedText = (homeTeamName).setSemiboldString(semiboldString: (homeTeamName), fontSize: 13.0)
                    }
                    else {
                        lblHostName.attributedText = (matchDetail.parentHomeTeamWinnerLabel ?? "").setSemiboldString(semiboldString: (matchDetail.parentHomeTeamWinnerLabel ?? ""), fontSize: 13.0)
                    }
                }
            }
            
            if matchDetail.awayTeamId == 0 {
                lblOpponentName.text = matchDetail.parentAwayTeamWinnerLabel
            }
            else {
                if matchDetail.awayTeam?.isJoinAsPlayer == 1 {
                    if matchDetail.awayTeamPlayers?.count ?? 0 > 0 {
                        lblOpponentName.attributedText = (matchDetail.awayTeamPlayers?[0].playerDetails?.displayName ?? "").setSemiboldString(semiboldString: (matchDetail.awayTeamPlayers?[0].playerDetails?.displayName ?? ""), fontSize: 13.0)
                    }
                    else {
                        lblOpponentName.text = matchDetail.parentAwayTeamWinnerLabel
                    }
                }
                else {
                    if matchDetail.awayTeamPlayers?.count ?? 0 > 0 {
                        lblOpponentName.attributedText = (awayTeamName).setSemiboldString(semiboldString: (awayTeamName), fontSize: 13.0)
                    }
                    else {
                        lblOpponentName.attributedText = (matchDetail.parentAwayTeamWinnerLabel ?? "").setSemiboldString(semiboldString: (matchDetail.parentAwayTeamWinnerLabel ?? ""), fontSize: 13.0)
                    }
                }
            }
        }
        else {
            if matchDetail.homeTeam?.isJoinAsPlayer == 0 || matchDetail.awayTeam?.isJoinAsPlayer == 0 {
                hostTeamAndPlayer = "\(homeTeamName)\n\(matchDetail.homeTeamPlayers?.count ?? 0 > 0 ? (matchDetail.homeTeamPlayers![0].playerDetails?.displayName ?? "") : "")"
                opponentTeamAndPlayer = "\(awayTeamName)\n\(matchDetail.awayTeamPlayers?.count ?? 0 > 0 ? (matchDetail.awayTeamPlayers![0].playerDetails?.displayName ?? "") : "")"
                getHeaderHeight(player1Team: matchDetail.homeTeam?.isJoinAsPlayer == 0 ? (homeTeamName) : "", player1Name: (matchDetail.homeTeamPlayers?.count ?? 0 > 0 ? (matchDetail.homeTeamPlayers![0].playerDetails?.displayName ?? "") : ""), player2Team: matchDetail.awayTeam?.isJoinAsPlayer == 0 ? (awayTeamName) : "", player2Name: (matchDetail.awayTeamPlayers?.count ?? 0 > 0 ? (matchDetail.awayTeamPlayers![0].playerDetails?.displayName ?? "") : ""))
            }
            
            if matchDetail.homeTeam?.isJoinAsPlayer == 1 {
                lblHostName.text = (matchDetail.homeTeamPlayers?.count ?? 0 > 0 ? (matchDetail.homeTeamPlayers![0].playerDetails?.displayName ?? "") : "")
            }
            else {
                lblHostName.attributedText = hostTeamAndPlayer.setSemiboldString(semiboldString: (homeTeamName), fontSize: 13.0)
            }
            
            if matchDetail.awayTeam?.isJoinAsPlayer == 1  {
                lblOpponentName.text = (matchDetail.awayTeamPlayers?.count ?? 0 > 0 ? (matchDetail.awayTeamPlayers![0].playerDetails?.displayName ?? "") : "")
            }
            else {
                lblOpponentName.attributedText = opponentTeamAndPlayer.setSemiboldString(semiboldString: (awayTeamName), fontSize: 13.0)
            }
        }
        if (matchDetail.matchTime == "" || matchDetail.matchTime == "TBD") {
            self.lblGameTime.text = "Game Time: TBD"
        }
        else {
            //self.lblGameTime.attributedText = "Game Time: \(matchDetail.matchTime ?? "") \(matchDetail.league?.timeZone ?? "") \(matchDetail.stationName ?? "")".setAttributedString(boldString: "Game Time:", fontSize: 13.0)    //  Comment by Pranay
            // By Pranay
            self.lblGameTime.attributedText = "Game Time: \(matchDetail.matchTime ?? "") \(matchDetail.stationName ?? "")".setAttributedString(boldString: "Game Time:", fontSize: 13.0)
            // .
        }
        
        if APIManager.sharedManager.match?.leagueId != 0 {
            // 442 - By Pranay
            if matchDetail.scheduleType == "Matchups_Only" {
                self.lblTitle.text = Messages.arenaOpen
                self.btnEnterArena.backgroundColor = Colors.theme.returnColor()
                self.btnEnterArena.isEnabled = true
                self.btnEnterArena.titleLabel?.textColor = UIColor.white
            }
            else {
                if (matchDetail.matchTime == "" || matchDetail.matchTime == "TBD") {
                    self.lblGameCountDown.text = "Game Time Countdown: TBD"
                }
                else {
                    /*// 1 By Ashish
                    let date = Date()
                    let currSecFromGMT = (TimeZone.current).secondsFromGMT()
                    
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd hh:mm a"
                    let dateString = df.string(from: date)
                    let convertedDate = df.date(from: dateString)
                    let currDt = (convertedDate?.addingTimeInterval(TimeInterval(currSecFromGMT)))!
                    print("Current Date : \(String(describing: currDt))")

                    let strMatchTime = "\(matchDetail.matchTime ?? "")"
                    
                    let Dateformatter = DateFormatter()
                    Dateformatter.dateFormat = "yyyy-MM-dd hh:mm a"
                    let mDate = Dateformatter.date(from: strMatchTime)!
                    
                    let dateF = DateFormatter()
                    dateF.dateFormat = "yyyy-MM-dd hh:mm a"
                    let mtDate = dateF.date(from: matchDetail.matchTime!)
                    let matchDate = mtDate?.addingTimeInterval(TimeInterval(currSecFromGMT))
                    print("Converted Match Date: \(String(describing: matchDate))")
                    
                    let myTimeStamp = matchDate?.timeIntervalSince1970
                    let current = currDt.timeIntervalSince1970
                    timeSeconds = Int(myTimeStamp!) - Int(current)
                    
                    let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
                    let differenceOfDate = Calendar.current.dateComponents(components, from: matchDate!, to: currDt)
                    print ("Difference Betweenn Date: \(differenceOfDate)")
                    // 1
                    /// */
                    
                    timeSeconds = (matchDetail.remainingMiliSeconds ?? 0) / 1000
                    
                    if self.timeSeconds >= 1800 {
                        self.lblTitle.text = "" //Messages.arenaBefore30Min
                        self.btnEnterArena.backgroundColor = Colors.disableButton.returnColor()
                        self.btnEnterArena.isEnabled = false
                        self.btnEnterArena.titleLabel?.textColor = UIColor.white
                    } else {
                        self.lblTitle.text = Messages.arenaOpen
                        self.btnEnterArena.backgroundColor = Colors.theme.returnColor()
                        self.btnEnterArena.isEnabled = true
                        self.btnEnterArena.titleLabel?.textColor = UIColor.white
                    }
                    if timeSeconds > 0 {
                        lblGameCountDown.attributedText = timeFormatted(seconds: timeSeconds).setAttributedString(boldString: "Game Time Countdown:", fontSize: 13.0)
                        self.timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    }
                }
            }
            // 442 .
            
            //remove below 3 lines to disable enater arena button to work condition vise
//            self.btnEnterArena.backgroundColor = Colors.theme.returnColor()
//            self.btnEnterArena.isEnabled = true
//            self.btnEnterArena.titleLabel?.textColor = UIColor.white
            
            if matchDetail.homeTeamId == 0 || matchDetail.awayTeamId == 0 {
                self.btnEnterArena.backgroundColor = Colors.disableButton.returnColor()
                self.btnEnterArena.isEnabled = false
                self.btnEnterArena.titleLabel?.textColor = UIColor.white
            }
        } else {
            closeArena()
        }
        
        // default values from api
        self.imgCharacter.layer.cornerRadius = self.imgCharacter.frame.size.height / 2
        
        imgCharacter.setImage(imageUrl: self.leagueTabVC!().playerChar?.imagePath != nil ? (self.leagueTabVC!().playerChar?.imagePath ?? "") : "")
        isCharSelect = self.leagueTabVC!().playerChar?.name != nil ? true : false
        isDefaultCharSelected = self.leagueTabVC!().playerChar?.name != nil ? true : false
        lblCharacter.text = self.leagueTabVC!().playerChar?.name != nil ? self.leagueTabVC!().playerChar?.name : Messages.selectChar
        arrStagePicked = self.leagueTabVC!().playerStage.count != 0 ? self.leagueTabVC!().playerStage : []
        
        // By Pranay
        //if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count == 0 {
        if APIManager.sharedManager.stagePickBan ?? "" == "No" {
            self.btnStageRanking.isUserInteractionEnabled = false
            self.btnStageRanking.backgroundColor = Colors.disableButton.returnColor()
            lblModeTitle.isHidden = true
            lblMapTitle.isHidden = true
        } else {
            lblModeTitle.isHidden = false
            lblMapTitle.isHidden = false
        }
        // .
        
        if arrCounterStage.count > arrStarterStage.count {
            tvCounterHeight.constant = CGFloat(arrCounterStage.count * 28)
            tvStarterHeight.constant = CGFloat(arrCounterStage.count * 28)
        } else {
            tvCounterHeight.constant = CGFloat(arrStarterStage.count * 28)
            tvStarterHeight.constant = CGFloat(arrStarterStage.count * 28)
        }
        
        self.tvMap.reloadData()
        self.tvMode.reloadData()
        
    }
    
    // Display player with teamname as per view height
    func getHeaderHeight(player1Team: String, player1Name: String, player2Team: String, player2Name: String) {
        var count = 0
            count = self.view.frame.size.width == 320 ? 10 : self.view.frame.size.width == 375 ? 14 : 18
        var h1 = 0
        var h2 = 0
        if player1Team != "" {
            let team1 = player1Team
            let team1Length = team1.count
            var player1 = 0
            if team1Length > count {
                player1 = (team1Length/count)
            }
            let name1 = player1Name
            let name1Length = name1.count
            var player1name = 1
            if name1Length > count {
                player1name += ((name1Length/count) + player1)
            }
            h1 = 54 + (player1name * 15)
        } else if player2Team != "" {
            let team2 = player2Team
            let team2Length = team2.count
            var player2 = 0
            if team2Length > count {
                player2 = (team2Length/count)
            }
            let name2 = player2Name
            let name2Length = name2.count
            var player2name = 1
            if name2Length > count {
                player2name += ((name2Length/count) + player2)
            }
            h2 = 54 + (player2name * 15)
        }
        headerHeight.constant = CGFloat((h1 > h2) ? h1 : h2)
    }
    
    func openStageRankingDialog() {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
        dialog.arrSelectedStageIndex = self.arrSelectedStageIndex
        dialog.teamId = self.leagueTabVC!().teamId
        dialog.arrSwaped = self.arrStagePicked
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.tapOk = { arr in
            if(arr[0] as! Bool == false){
                let dialog1 = self.storyboard?.instantiateViewController(withIdentifier: "StageUnselectPopupVC") as! StageUnselectPopupVC
                dialog1.arrSelectedStageIndex = dialog.arrSelectedStageIndex
                dialog1.modalPresentationStyle = .overCurrentContext
                dialog1.modalTransitionStyle = .crossDissolve
                dialog1.tapOk = {
                    self.arrStagePicked = arr[1] as? [Int] ?? []
                    self.arrSelectedStageIndex = dialog1.arrSelectedStageIndex
                    self.openStageRankingDialog()
                }
                self.view!.tusslyTabVC.present(dialog1, animated: true, completion: nil)
            } else {
                if (arr[1] as? [Int])?.count ?? 0 > 0 {
                    self.arrStagePicked = arr[1] as! [Int]
                    self.arrSelectedStageIndex.removeAll()
                }
            }
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    func activeNextScheduledMatchTimer() {
        print("Timer Active for \(APIManager.sharedManager.nextScheduledMatchTimer) second.")
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(APIManager.sharedManager.nextScheduledMatchTimer), repeats: false) { timer in
            print("Refresh timer call after \(APIManager.sharedManager.nextScheduledMatchTimer) sec.")
            self.btnRefreshMatchDetail.isUserInteractionEnabled = true
            self.btnRefreshMatchDetail.setImage(UIImage(named: "refresh"), for: .normal)
            self.lblRefreshMsg.isHidden = true
            
            self.btnRefreshMatchDetail1.isUserInteractionEnabled = true
            self.btnRefreshMatchDetail1.setImage(UIImage(named: "refresh"), for: .normal)
            
            self.refreshTimer.invalidate()
        }
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
            
            dialog.tapOk = { arr in
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
 
    // MARK: - Button Click Events
    
    @IBAction func enterArenaTapped(_ sender: UIButton) {
        if(self.btnEnterArena.isEnabled == true && isTap == false){
            isTap = true
            self.enterArena()
        }
    }
    
    @IBAction func lobbySetupTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.arrLoby = self.arrLoby
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func characterSelectionTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CharacterSelectionPopupVC") as! CharacterSelectionPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.teamId = self.leagueTabVC!().teamId
        dialog.strCharName = self.lblCharacter.text!
        dialog.tapOk = { arr in
            self.isCharSelect = true
            APIManager.sharedManager.arrDefaultChar = arr
            let array : [[Characters]] = arr[0] as! [[Characters]]
            self.lblCharacter.text = array[arr[1] as! Int][arr[2] as! Int].name
            self.imgCharacter.setImage(imageUrl: array[arr[1] as! Int][arr[2] as! Int].imagePath ?? "")
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func stagedPickOrBanTapped(_ sender: UIButton) {
        openStageRankingDialog()
    }
    
    @IBAction func setDefaultTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaSetDefaultPopupVC") as! ArenaSetDefaultPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func navigateToSchedule(_ sender: UIButton) {
//        let matchId = APIManager.sharedManager.match?.matchId ?? 0
//        let matchNo = APIManager.sharedManager.match?.matchNo ?? 0
//        self.leagueTabVC!().navigateToBracket(matchId: matchId, matchNo: matchNo)
    }
    
    @IBAction func btnRefreshMatchDetailTap(_ sender: UIButton) {
        //APIManager.sharedManager.match?.resetMatch = 1
        APIManager.sharedManager.isMatchRefresh = false
        self.leagueTabVC!().getTournamentContent()
    }
    
    @IBAction func btnHostUsedCharTap(_ sender: UIButton) {
        self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.homeTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter ?? [])
    }
    
    @IBAction func btnAwayUsedCharTap(_ sender: UIButton) {
        self.openUsedCharacterPopup(name: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.displayName ?? "", image: APIManager.sharedManager.match?.awayTeamPlayers?[0].playerDetails?.avatarImage ?? "", characters: APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter ?? [])
    }
}

extension ArenaStepOneVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == tvMode ? arrStarterStage.count : arrCounterStage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModeTVCell") as! ModeTVCell
            cell.lblModeName.text = arrStarterStage[indexPath.row].stageName
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapTVCell") as! MapTVCell
            cell.lblMapName.text = arrCounterStage[indexPath.row].stageName
            return cell
        }
    }
}

// MARK: Webservices
extension ArenaStepOneVC {
    func enterArena() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.enterArena()
                }
            }
            return
        }
        
        self.showLoading()
        
        var randomArr = [Int]()
        for i in 0 ..< (APIManager.sharedManager.content?.characters?.count ?? 0) {
            randomArr.append(i)
        }
        
        for i in 0 ..< randomArr.count {
            if (APIManager.sharedManager.content?.characters?[i].name)! == lblCharacter.text! {
                randomChar = (APIManager.sharedManager.content?.characters?[i])!
                self.isCharSelect = true
                break
            }
            self.isCharSelect = false
        }
        if self.isCharSelect == false {
            let index = randomArr.randomElement() ?? 0
            randomChar = (APIManager.sharedManager.content?.characters?[index])!
        }
        
        if(self.arrStagePicked.count == 0) {
            for i in 0 ..< (APIManager.sharedManager.content?.stages?.count ?? 0) {
                self.arrStagePicked.append((APIManager.sharedManager.content?.stages?[i].id)!)
            }
        }
        
        let param = ["leagueId": leagueTabVC!().tournamentDetail?.id ?? 0,"matchId":self.matchDetail.matchId as Any, "teamId": leagueTabVC!().teamId, "defaultCharacterId": randomChar.id as Any, "stageId": self.arrStagePicked, "device": "ios"]
//        self.log.i("ENTER_ARENA api call. - \(APIManager.sharedManager.user?.userName ?? "") --- \(param)")  //  By Pranay.
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ENTER_ARENA, parameters: ["leagueId": leagueTabVC!().tournamentDetail?.id ?? 0,"matchId":self.matchDetail.matchId ?? 0, "teamId": leagueTabVC!().teamId, "defaultCharacterId": randomChar.id ?? 0, "stageId": self.arrStagePicked, "device": "ios"]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                DispatchQueue.main.async {
//                    self.log.i("ENTER_ARENA api call success. - \(APIManager.sharedManager.user?.userName ?? "") = \(response?.result)")  //  By Pranay.
                    self.hideLoading()
                    self.arrFirestore = (response?.result?.fireBaseInfo)!
                    APIManager.sharedManager.firebaseId = response?.result?.fireStoreId ?? ""
                    APIManager.sharedManager.match?.joinStatus = 1
                    APIManager.sharedManager.previousMatch?.joinStatus = 1
                    var playerArr = [[String:AnyObject]]()
                    do {
                        let encodedData = try JSONEncoder().encode(self.arrFirestore?.playerDetails ?? [])
                        let jsonString = String(data: encodedData,encoding: .utf8)
                        if let data = jsonString?.data(using: String.Encoding.utf8) {
                            do {
                                playerArr = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] ?? []
                                
                                var myPlayerIndex = 0
                                if(APIManager.sharedManager.user?.id == (playerArr[0]["playerId"] as!Int)){
                                    myPlayerIndex = 0
                                } else {
                                    myPlayerIndex = 1
                                }
                                
                                if self.isCharSelect == true {
                                    if self.isDefaultCharSelected {
                                        playerArr[myPlayerIndex]["characterId"] = self.leagueTabVC!().playerChar?.id as AnyObject
                                        playerArr[myPlayerIndex]["characterImage"] = self.leagueTabVC!().playerChar?.imagePath as AnyObject
                                        
                                        playerArr[myPlayerIndex]["defaultCharId"] = self.leagueTabVC!().playerChar?.id as AnyObject //  By Pranay
                                        playerArr[myPlayerIndex]["defaultCharImage"] = self.leagueTabVC!().playerChar?.imagePath as AnyObject //  By Pranay
                                    } else {
                                        let array : [[Characters]] = APIManager.sharedManager.arrDefaultChar[0] as! [[Characters]]
                                        playerArr[myPlayerIndex]["characterId"] = array[APIManager.sharedManager.arrDefaultChar[1] as! Int][APIManager.sharedManager.arrDefaultChar[2] as! Int].id as AnyObject
                                        playerArr[myPlayerIndex]["characterImage"] = array[APIManager.sharedManager.arrDefaultChar[1] as! Int][APIManager.sharedManager.arrDefaultChar[2] as! Int].imagePath as AnyObject
                                        
                                        playerArr[myPlayerIndex]["defaultCharId"] = array[APIManager.sharedManager.arrDefaultChar[1] as! Int][APIManager.sharedManager.arrDefaultChar[2] as! Int].id as AnyObject
                                        playerArr[myPlayerIndex]["defaultCharImage"] = array[APIManager.sharedManager.arrDefaultChar[1] as! Int][APIManager.sharedManager.arrDefaultChar[2] as! Int].imagePath as AnyObject
                                    }
                                    playerArr[myPlayerIndex]["characterName"] = self.lblCharacter.text as AnyObject
                                    playerArr[myPlayerIndex]["defaultCharName"] = self.lblCharacter.text as AnyObject //  By Pranay
                                    
                                    playerArr[myPlayerIndex]["characterCurrent"] = false as AnyObject
                                    playerArr[myPlayerIndex == 0 ? 1 : 0]["characterCurrent"] = false as AnyObject
                                }
                                if(self.arrStagePicked.count > 0){
                                    playerArr[myPlayerIndex]["stages"] = self.arrStagePicked as AnyObject
                                }
                                APIManager.sharedManager.isMatchRefresh = true
                                self.selectData = playerArr
                                self.navigate(isManualUpdate: (response?.result?.fireBaseInfo?.manualUpdate ?? 0) == 1 ? true : false)
                            } catch let error as NSError {
                                print(error)
                            }
                        }
                    } catch {
                        print("error")
                    }
                }
            }
            else {
//                self.log.e("ENTER_ARENA api call fail. - \(APIManager.sharedManager.user?.userName ?? "") = \(response)")  //  By Pranay.
                DispatchQueue.main.async {
                    if APIManager.sharedManager.user?.id == (self.matchDetail.homeTeamPlayers![0].userId ?? 0)  {
                        self.isMyIdBlock = self.matchDetail.homeTeamPlayers![0].playerDetails?.isBlockForLeague == 1 ? true : false
                        self.isOppoIdBlock = self.matchDetail.awayTeamPlayers![0].playerDetails?.isBlockForLeague == 1 ? true : false
                    } else {
                        self.isMyIdBlock = self.matchDetail.awayTeamPlayers![0].playerDetails?.isBlockForLeague == 1 ? true : false
                        self.isOppoIdBlock = self.matchDetail.homeTeamPlayers![0].playerDetails?.isBlockForLeague == 1 ? true : false
                    }

                    if self.isOppoIdBlock {
                        var arr = [Any]()
                        arr.append(self.lblHostName.text!)
                        arr.append(self.lblOpponentName.text!)
                        arr.append(self.hostImage)
                        arr.append(self.opponentImage)
                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaScoreConfirmPopupVC") as! ArenaScoreConfirmPopupVC
                        dialog.modalPresentationStyle = .overCurrentContext
                        dialog.modalTransitionStyle = .crossDissolve
                        dialog.winnerId = APIManager.sharedManager.user?.id == (self.matchDetail.homeTeamPlayers![0].userId ?? 0) ? 0 : 1
                        dialog.isOpponentBlock = true
                        dialog.playerDetail = arr
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                    self.hideLoading()
                    self.isTap = false
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
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
            }
        }
    }
    
    func navigate(isManualUpdate : Bool) {
        self.isTap = false
        if !isManualUpdate {
            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaLobbyTournamentVC") as! ArenaLobbyTournamentVC
            arenaLobby.tusslyTabVC = self.tusslyTabVC
            arenaLobby.leagueTabVC = self.leagueTabVC
            arenaLobby.selectedData = self.selectData
            self.navigationController?.pushViewController(arenaLobby, animated: true)
        } else {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
            objVC.tusslyTabVC = self.tusslyTabVC
            objVC.leagueTabVC = self.leagueTabVC
            objVC.isAdminUpdate = true
            self.navigationController?.pushViewController(objVC, animated: true)
        }   //  */
    }
}

extension Notification.Name {
    static let tournamentNotificationObserver = Notification.Name("TournamentNotificationObserver")
}
