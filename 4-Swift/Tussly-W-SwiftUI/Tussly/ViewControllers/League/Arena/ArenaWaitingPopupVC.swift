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

class ArenaWaitingPopupVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var descriptionString: String = ""
    var tapOk: (()->Void)?
    var manageOnStatus: ((String)->Void)?
    var status = ""
    let db = Firestore.firestore()
    var arenaFlow = ""
    var myPlayerIndex = 0
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var timeSeconds = -1
    var isLoader = false
    var timer = Timer()
    var opponentIndex = 0
    var arrFire : FirebaseInfo?
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var finalTime = 0
    var isHost: Bool = false
    var opponent = 1
//    fileprivate let log = ShipBook.getLogger(ArenaWaitingPopupVC.self)
    var isWaitingPopupActive: Bool = true
    var intMaxNoOfCharSelect: Int = APIManager.sharedManager.maxCharacterLimit ?? 0
    var arrAllCharacters: [Characters]? = APIManager.sharedManager.content?.characters ?? [Characters]()
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewLoading : UIView!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var lblTimer : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewMain)
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        opponentIndex = myPlayerIndex == 0 ? 1 : 0
        viewMain.layer.cornerRadius = 15
        self.lblDescription.text = descriptionString
        viewLoading.showLoading()
        
        if isLoader {
            //Hide time label and show loader
            lblTimer.isHidden = true
        } else {
            //Show left time and hide loader
            if arenaFlow == "WeAreBothIn" {
                lblTimer.isHidden = true
            } else {
                viewLoading.isHidden = true
            }
            finalTime = timeSeconds
            APIManager.sharedManager.timerPopup = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.opponentTimer), userInfo: nil, repeats: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isWaitingPopupActive = true   //  By Pranay
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 442 - By Pranay
        self.isWaitingPopupActive = false
        listner?.remove()
        /// 442 .
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        listner?.remove()
        APIManager.sharedManager.timerPopup.invalidate()
        self.viewLoading.hideLoading()
        self.isWaitingPopupActive = false   //  By Pranay
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    func setUI(){
//        self.log.i("ArenaWaitingPopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { [self] (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaWaitingPopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaWaitingPopupVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaWaitingPopupVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            let playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                            let roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                            // By Pranay
                            self.myPlayerIndex = (APIManager.sharedManager.user?.id == playerArr[0]["playerId"] as? Int) ? 0 : 1
                            self.opponent = self.myPlayerIndex == 0 ? 1 : 0
                            // .
                            
                            // wait for opponent to match id or deny
//                            if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
//                                /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
//                                if APIManager.sharedManager.timer.isValid == true {
//                                    APIManager.sharedManager.timer.invalidate()
//                                }
//                                self.listner?.remove()
//                                self.leagueTabVC!().getTournamentContent()
//                            }
//                            else
                            if self.arenaFlow == "HostBattleId" && (self.doc?.data()?["status"] as? String == Messages.battleIdFail || self.doc?.data()?["status"] as? String == Messages.characterSelection) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> HostBattleId - Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                            }
                            //Waiting for opponent's rpc reply
                            else if self.arenaFlow == "WaitingOpponentRPC" {
                                
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingOpponentRPC -- Tie -- Remain time -> \(self.timeSeconds) -- scheduleRemoved -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingOpponentRPC -- Tie -- Remain time -> \(self.timeSeconds) -- scheduleRemoved -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")
                                    
                                    APIManager.sharedManager.isMatchForfeit = true
                                    //self.manageOnStatus(status: "Match Forfeit")
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if (playerArr[self.opponentIndex]["rpc"] as? String == "" && playerArr[self.myPlayerIndex]["rpc"] as? String == "") {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingOpponentRPC -- Tie -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Tie")
                                }
                                else if(playerArr[self.opponentIndex]["rpc"] as? String != "") {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingOpponentRPC -- Opp player select -> \(playerArr[self.opponentIndex]["rpc"] as? String ?? "") -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: playerArr[self.opponentIndex]["rpc"] as! String)
                                }
                            }
                            // check which player needs to ban first stage
                            else if self.arenaFlow == "FirstStageBan" {
                                
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    //self.manageOnStatus(status: "Schedule Removed")
                                    self.callBack()
                                }
                                else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                    //self.manageOnStatus(status: "Schedule Removed")
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.callBack()
                                }
                                else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> FirstStageBan -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    self.callBack()
                                }
                                else if self.doc?.data()?["stagePicBanPlayerId"] as? Int == playerArr[self.myPlayerIndex]["playerId"] as? Int {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> FirstStageBan -- change stagePicBanPlayerId -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.arenaFlow = ""
                                    self.callBack()
                                }
                            }
                            else if self.arenaFlow == "WaitingScoreConfirm" && (self.doc?.data()?["status"] as? String == Messages.enteredScore) && (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: "Schedule Removed")
                            }
                            else if self.arenaFlow == "WaitingScoreConfirm" && (self.doc?.data()?["status"] as? String == Messages.enteredScore) && (self.doc?.data()?["matchForfeit"] as? Int == 1) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                APIManager.sharedManager.isMatchForfeit = true
                                //self.manageOnStatus(status: "Match Forfeit")
                                self.manageOnStatus(status: "Schedule Removed")
                            }
                            else if self.arenaFlow == "WaitingScoreConfirm" && (self.doc?.data()?["status"] as? String == Messages.enteredScore) && (self.doc?.data()?["resetMatch"] as? Int == 1) {
                                if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Match Reset")
                                }
                            }
                            // wait for host to confirm/dispute the score
                            else if self.arenaFlow == "WaitingScoreConfirm" && (self.doc?.data()?["status"] as? String == Messages.scoreConfirm || self.doc?.data()?["status"] as? String == Messages.enterDisputeScore || self.doc?.data()?["status"] as? String == Messages.enteredScore) {
                                
                                if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                    self.arenaFlow = "ConfirmedRound"
                                }
                                /// 223 - By Pranay
                                else if self.doc?.data()?["status"] as? String == Messages.enteredScore {
                                    if ((self.arrFire?.enteredScoreBy ?? 0) != (playerArr[self.myPlayerIndex]["playerId"] as? Int)) && ((self.arrFire?.enteredScoreBy ?? 0) != 0) {
//                                        self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                        self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                                    }
                                }
                                /// 223 .
                                else {
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                                }
                            }
                            //redirect to character screen after completion of first round
                            else if self.arenaFlow == "NextRound" && (self.doc?.data()?["status"] as? String == Messages.characterSelection) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> NextRound --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.callBack()
                            }
                            else if self.arenaFlow == "WaitingScoreConfirmOrDispute" && (self.doc?.data()?["status"] as? String == Messages.enterDisputeScore) && (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
//                                self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirmOrDispute -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: "Schedule Removed")
                            }
                            else if self.arenaFlow == "WaitingScoreConfirmOrDispute" && (self.doc?.data()?["status"] as? String == Messages.enterDisputeScore) && (self.doc?.data()?["matchForfeit"] as? Int == 1) {
//                                self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirmOrDispute -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                APIManager.sharedManager.isMatchForfeit = true
                                //self.manageOnStatus(status: "Match Forfeit")
                                self.manageOnStatus(status: "Schedule Removed")
                            }
                            else if self.arenaFlow == "WaitingScoreConfirmOrDispute" && (self.doc?.data()?["status"] as? String == Messages.enterDisputeScore) && (self.doc?.data()?["resetMatch"] as? Int == 1) {
                                if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirmOrDispute -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Match Reset")
                                }
                            }
                            // wait for score to get confirmed/disputed
                            else if self.arenaFlow == "WaitingScoreConfirmOrDispute" && (self.doc?.data()?["status"] as? String == Messages.scoreConfirm || self.doc?.data()?["status"] as? String == Messages.dispute ) {
                                if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                    self.arenaFlow = "ConfirmedRound"
                                } else {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirmOrDispute --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                                }
                            }
                            //check winner has selected character for next round
                            else if self.arenaFlow == "CharacterSelected" {
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
//                                    self.log.i("Waiting Dialog -- Arena flow.-> CharacterSelected -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                                else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
//                                    self.log.i("Waiting Dialog -- Arena flow.-> CharacterSelected -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.callBack()
                                }
                                else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> CharacterSelected -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                                else if (roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == playerArr[self.myPlayerIndex]["teamId"] as? Int && (playerArr[self.myPlayerIndex]["characterCurrent"] as? Bool == true) && (playerArr[self.opponentIndex]["characterCurrent"] as? Bool == true) || (roundArr[(self.doc?.data()?["currentRound"] as! Int) - 2]["winnerTeamId"] as? Int == playerArr[self.opponentIndex]["teamId"] as? Int && (playerArr[self.opponentIndex]["characterCurrent"] as? Bool == true))){
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> CharacterSelected --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                            }
                            //we are both in id selected
                            else if self.arenaFlow == "WeAreBothIn" {
                                if (self.doc?.data()?["status"] as? String == Messages.characterSelection || self.doc?.data()?["weAreReadyBy"] as? Int == 0) {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> WeAreBothIn --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "")
                                    //self.callBack()
                                }
                            }
                            //First round character
                            else if self.arenaFlow == "FirstRoundCharacter" {
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> FirstRoundCharacter -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                                if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> FirstRoundCharacter -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.callBack()
                                }
                                else if (self.doc?.data()?["status"] as? String == Messages.playinRound || self.doc?.data()?["status"] as? String == Messages.selectRPC) {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> FirstRoundCharacter --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                            }
                            //last stage pick
                            else if self.arenaFlow == "lastStageToPick" {
                                
                                if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> lastStageToPick -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> lastStageToPick -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    APIManager.sharedManager.isMatchForfeit = true
                                    //self.manageOnStatus(status: "Match Forfeit")
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> lastStageToPick -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Match Reset")
                                }
                                else if (self.doc?.data()?["status"] as? String == Messages.characterSelection || self.doc?.data()?["status"] as? String == Messages.playinRound) {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> lastStageToPick --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.arenaFlow = ""
                                    self.callBack()
                                }
                            }
                            //declare api call
                            else if self.arenaFlow == "ConfirmedRound" {
                                if self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> ConfirmedRound -- ConfirmedRoundByOpp -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "ConfirmedRoundByOpp")
                                } else if self.doc?.data()?["status"] as? String == Messages.matchFinished {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> ConfirmedRound -- MatchFinishByOpp -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "MatchFinishByOpp")
                                }
                            }
                            //host double confirm the battle ID
                            else if self.arenaFlow == "IdDoubleConfirmation" {
                                if (self.doc?.data()?["weAreReadyBy"] as? Int == playerArr[self.opponentIndex]["playerId"] as? Int) {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> IdDoubleConfirmation --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.callBack()
                                }
                            }
                            else if self.arenaFlow == "waitForOpponentToNextRound" && (self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan) && (self.doc?.data()?["resetMatch"] as? Int == 1) {
                                if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound -- resetMatch -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Match Reset")
                                }
                            }
                            //wait for opponent too proceed for next round
                            else if self.arenaFlow == "waitForOpponentToNextRound" {
                                if (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
//                                    self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if (self.doc?.data()?["matchForfeit"] as? Int == 1) {
//                                    self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.manageOnStatus(status: "Schedule Removed")
                                }
                                else if (self.doc?.data()?["status"] as? String == Messages.stagePickBan) {
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: self.doc?.data()?["status"] as? String ?? "")
                                }
                                else if (self.doc?.data()?["status"] as? String == Messages.characterSelection) { //  Else if condition added by Pranay.
                                    
//                                    self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                    
                                    self.manageOnStatus(status: self.doc?.data()?["status"] as? String ?? "")
                                }
                            }
                            //check status to redirect
                            else if self.doc?.data()?["status"] as? String == self.status {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> -  -- check status to redirect -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.callBack()
                            }
                            // wait for opponent to match id or deny
                            else if self.arenaFlow == "directCharacterSelection" && (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> directCharacterSelection --  -- Remain time -> \(self.timeSeconds) -- scheduleRemoved -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                            }
                            else if self.arenaFlow == "directCharacterSelection" && (self.doc?.data()?["matchForfeit"] as? Int == 1) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> directCharacterSelection --  -- Remain time -> \(self.timeSeconds) -- matchForfeit -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                APIManager.sharedManager.isMatchForfeit = true
                                self.manageOnStatus(status: "Schedule Removed")
                            }
                            else if self.arenaFlow == "directCharacterSelection" && (self.doc?.data()?["status"] as? String == Messages.characterSelection) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> directCharacterSelection --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                            }
                            else if (self.arenaFlow == "directCharacterSelection") && (self.doc?.data()?["status"] as? String == Messages.readyToProceed) && (playerArr[self.myPlayerIndex]["playerId"] as? Int != self.doc?.data()?["weAreReadyBy"] as? Int) {
                                
//                                self.log.i("Waiting Dialog -- Arena flow.-> directCharacterSelection --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                                
                                self.manageOnStatus(status: self.doc?.data()?["status"] as! String)
                            }
                        } catch {
                            print("error")
                        }
                    }
                }
            }
        }
    }
    
    func callBack() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        listner?.remove()
        APIManager.sharedManager.timerPopup.invalidate()
        self.viewLoading.hideLoading()
        self.isWaitingPopupActive = false   //  By Pranay
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!()
            }
        })
    }
    
    func manageOnStatus(status: String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        listner?.remove()
        APIManager.sharedManager.timerPopup.invalidate()
        self.viewLoading.hideLoading()
        self.isWaitingPopupActive = false   //  By Pranay
        self.dismiss(animated: true, completion: {
            if self.manageOnStatus != nil {
                self.manageOnStatus!(status)
            }
        })
    }
    
    @objc func opponentTimer()
    {
        // By Pranay
        if (arenaFlow == "ConfirmedRound" && self.doc?.data()?["status"] as? String == Messages.scoreConfirm && arrFire?.disputeConfirmBy == 1) {
            
//            self.log.i("Waiting Dialog -- Arena flow.-> ConfirmedRound -- ScorConfirmedByAdmin -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
            
            manageOnStatus(status: "ScorConfirmedByAdmin")
        }
        //.
        
        timeSeconds -= 1
        if timeSeconds < 0 {
            APIManager.sharedManager.timerPopup.invalidate()
            lblTimer.isHidden = true
            if !Network.reachability.isReachable {
                self.isRetryInternet { (isretry) in
                    if isretry! {
                        self.callBackInfo()
                    }
                }
                return
            }
            
//            self.log.i("Waiting Dialog -- Arena flow.-> \(self.arenaFlow) -- Timer is over. --  -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
            
            //Both player tap "We are both in" at same time then there is probability of displaying waiting dialog to both player, To dismiss one player's dialog...
            if self.arenaFlow == "WeAreBothIn" {
                APIManager.sharedManager.timerPopup.invalidate()
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        if self.doc?.data()?["weAreReadyBy"] as! Int != playerArr[APIManager.sharedManager.myPlayerIndex]["playerId"] as! Int {
                            self.manageOnStatus(status: "ready by opponent")
                        }
                    }
                }
            }
            // waiting for other player to confirm/dispute your entered score
            // if after time completes and still got no reply from other player then auto confirm score
            else if self.arenaFlow == "WaitingScoreConfirm" || self.arenaFlow == "WaitingScoreConfirmOrDispute" {
                APIManager.sharedManager.timerPopup.invalidate()    //  By Pranay
                var param = [String:AnyObject]()
                var roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                self.viewLoading.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if self.isWaitingPopupActive {
                        /// If condition added by pranay. - If popup is close and timer is over then after delay for 10 sec then this code execute and update firestore.
                        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["played"] = 1 as AnyObject
                        param = ["rounds" : roundArr, "status" : Messages.scoreConfirm] as [String:AnyObject]
                        self.listner?.remove()
                        // other player confirm score in between time
                        if self.doc?.data()?["status"] as? String == Messages.scoreConfirm || self.doc?.data()?["status"] as? String == Messages.matchFinished || self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan {
                        } else {
                            //other player still not confirmed score
//                            self.log.i("ArenaWaitingPopupVC - opponentTimer() -- Timer is over. -- -- arenaFlow = WaitingScoreConfirm/WaitingScoreConfirmOrDispute --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param)")  //  By Pranay.
                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                if let err = err {
//                                    self.log.e("ArenaWaitingPopupVC - opponentTimer() -- Timer is over. ---- arenaFlow = WaitingScoreConfirm/WaitingScoreConfirmOrDispute fail -- \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                                    print("Error writing document: \(err)")
                                }
                                else {
                                    self.manageOnStatus(status: "")
                                }
                            }
                        }
                    }
                }
            }
            else {
                APIManager.sharedManager.timerPopup.invalidate()    //  By Pranay
                var playerArr = [[String:AnyObject]]()
                playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                self.viewLoading.isHidden = false   //  By Pranay
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    if self.isWaitingPopupActive {
                        /// If condition added by pranay. - If popup is close and timer is over then after delay for 10 sec then this code execute and update firestore.
                        var param = [String:Any]()
                        //First round character
                        if self.arenaFlow == "FirstRoundCharacter" {
                            if playerArr[self.opponentIndex]["characterCurrent"] as? Bool != true {
                                playerArr[self.opponentIndex]["characterCurrent"] = true as AnyObject?
                                
                                /// 114 - By Pranay -- set character id in round array for display character
                                let host = playerArr[0]["host"] as! Int == 1 ? 0 : 1
                                let otherPlayer = host == 0 ? 1 : 0
                                var roundArr = [[String:AnyObject]]()
                                roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                                
                                playerArr[self.opponentIndex]["characterId"] = playerArr[self.opponentIndex]["defaultCharId"]
                                playerArr[self.opponentIndex]["characterName"] = playerArr[self.opponentIndex]["defaultCharName"]
                                playerArr[self.opponentIndex]["characterImage"] = playerArr[self.opponentIndex]["defaultCharImage"]
                                
                                if self.isHost {
                                    roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = playerArr[otherPlayer]["defaultCharId"] as AnyObject
                                    
                                    let tempChar = APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter?.filter({ $0.id == playerArr[self.opponentIndex]["defaultCharId"] as? Int })
                                    if (((APIManager.sharedManager.isShoesCharacter ?? "No") == "Yes") && (tempChar!.count > 0)) {
                                        if (tempChar![0].characterUseCnt ?? 0 >= APIManager.sharedManager.maxCharacterLimit ?? 0) {
                                            let tChar: [Characters] = (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.filter({
                                                $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit ?? 0
                                            }))!
                                            ///let abc: [Characters] = (APIManager.sharedManager.content?.characters?.enumerated().filter{ !tChar.contains(where: $0.offset) }.map{ $0.element })!
                                            if tChar.count > 0 {
                                                for i in 0 ..< tChar.count {
                                                    for j in 0 ..< (self.arrAllCharacters?.count ?? 0) {
                                                        if self.arrAllCharacters![j].id == tChar[i].id {
                                                            self.arrAllCharacters?.remove(at: j)
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                            let tempChar: [Characters] = self.arrAllCharacters!.filter({ $0.characterUseCnt != self.intMaxNoOfCharSelect })
                                            let randNo: Int = Int.random(in: 0 ..< tempChar.count)
                                            
                                            playerArr[self.opponentIndex]["characterName"] = tempChar[randNo].name as AnyObject
                                            playerArr[self.opponentIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject
                                            playerArr[self.opponentIndex]["characterId"] = tempChar[randNo].id as AnyObject

                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = tempChar[randNo].id as AnyObject
                                        }
                                    }
                                    
                                    param = ["playerDetails": playerArr,
                                             "status": (APIManager.sharedManager.stagePickBan ?? "" == "No") ? Messages.playinRound : Messages.selectRPC,
                                             "rounds" : roundArr,
                                             "awayCharSelect": 1] as [String: Any]
                                }
                                else {
                                    roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = playerArr[host]["defaultCharId"] as AnyObject
                                    
                                    let tempChar = APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter?.filter({ $0.id == playerArr[self.opponentIndex]["defaultCharId"] as? Int })
                                    if (((APIManager.sharedManager.isShoesCharacter ?? "No") == "Yes") && (tempChar!.count > 0)) {
                                        if (tempChar![0].characterUseCnt ?? 0 >= APIManager.sharedManager.maxCharacterLimit ?? 0) {
                                            let tChar: [Characters] = (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.filter({
                                                $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit ?? 0
                                            }))!
                                            ///let abc: [Characters] = (APIManager.sharedManager.content?.characters?.enumerated().filter{ !tChar.contains(where: $0.offset) }.map{ $0.element })!
                                            if tChar.count > 0 {
                                                for i in 0 ..< tChar.count {
                                                    for j in 0 ..< (self.arrAllCharacters?.count ?? 0) {
                                                        if self.arrAllCharacters![j].id == tChar[i].id {
                                                            self.arrAllCharacters?.remove(at: j)
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                            let tempChar: [Characters] = self.arrAllCharacters!.filter({ $0.characterUseCnt != self.intMaxNoOfCharSelect })
                                            let randNo: Int = Int.random(in: 0 ..< tempChar.count)
                                            
                                            playerArr[self.opponentIndex]["characterName"] = tempChar[randNo].name as AnyObject
                                            playerArr[self.opponentIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject
                                            playerArr[self.opponentIndex]["characterId"] = tempChar[randNo].id as AnyObject
                                            
                                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = tempChar[randNo].id as AnyObject
                                        }
                                    }
                                    
                                    param = ["playerDetails": playerArr,
                                             "status": (APIManager.sharedManager.stagePickBan ?? "" == "No") ? Messages.playinRound : Messages.selectRPC,
                                             "rounds" : roundArr] as [String: Any]
                                }
                            }
                            else {
                                if self.doc?.data()?["status"] as? String != Messages.selectRPC {
                                    param = [
                                        "status": (APIManager.sharedManager.stagePickBan ?? "" == "No") ? Messages.playinRound : Messages.selectRPC
                                    ] as [String:AnyObject]
                                } else {
                                    self.callBack()
                                }
                            }
                        }
                        //Waiting for opponent's rpc reply
                        else if self.arenaFlow == "WaitingOpponentRPC" {
                            var rpc = ""
                            rpc = playerArr[self.myPlayerIndex]["rpc"] as! String == "R" ? "S" : (playerArr[self.myPlayerIndex]["rpc"] as! String == "P" ? "R" : "P")
                            playerArr[self.opponentIndex]["rpc"] = rpc as AnyObject
                            param = ["playerDetails": playerArr, "status": Messages.rpcResultDone, "stagePicBanPlayerId":playerArr[self.myPlayerIndex]["playerId"]] as [String:AnyObject]
                        }
                        //Ban stages
                        else if self.arenaFlow == "FirstStageBan" {
                            self.listner?.remove()
                            
                            //Check availability of starter/counter stages in firestore stage array
                            //5/10/2021
                            var tempArr = [Int]()
                            var tempStarterArr = [Int]()
                            var tempCounterArr = [Int]()
                            
                            for i in 0 ..< (APIManager.sharedManager.content?.starterStage?.count ?? 0) {
                                tempStarterArr.append((APIManager.sharedManager.content?.starterStage?[i].id)!)
                            }
                            let oppStages : [Int] = playerArr[self.opponentIndex]["stages"] as! [Int]
                            for i in 0 ..< oppStages.count {
                                if tempStarterArr.contains(oppStages[i]) {
                                    tempArr.append(oppStages[i])
                                }
                            }
                            if self.doc?.data()?["currentRound"] as! Int != 1 {
                                for i in 0 ..< (APIManager.sharedManager.content?.counterStage?.count ?? 0) {
                                    tempCounterArr.append((APIManager.sharedManager.content?.counterStage?[i].id)!)
                                }
                                for i in 0 ..< oppStages.count {
                                    if tempCounterArr.contains(oppStages[i]) {
                                        if tempArr.contains(oppStages[i]) {
                                            
                                        } else {
                                            tempArr.append(oppStages[i])
                                        }
                                    }
                                }
                                
                                //set order as firestore
                                var arrDB = [Int]()
                                for i in 0 ..< (oppStages.count) {
                                    if tempArr.contains(oppStages[i]) {
                                        arrDB.append(oppStages[i])
                                    }
                                }
                                tempArr = arrDB
                            } //5/10/2021
                            
                            var arrBann = [BanStage]()
                            arrBann = self.arrFire?.bannedStages ?? []
                            
                            var bannTotal = [[String:Int]]()
                            bannTotal = self.doc?.data()?["bannedStages"] as! [[String : Int]]
                            
                            //var isRoundHigherThanOne = (self.arrFire?.currentRound)! == 1 ? false : true
                            var banRoundId : Int = 0
                            var isAllStageBan : Bool = false
                            var totalStageToBan : Int = 0
                            //if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! != 0 {
                            if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                                if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! >= (self.arrFire?.currentRound)! {
                                    banRoundId = (self.arrFire?.currentRound)! - 1
                                } else {
                                    banRoundId = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! - 1
                                }
                                
                                if ((APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![banRoundId].banCount?.count)! - 1) >= (self.arrFire?.banRound)! {
                                    if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![banRoundId].totalBanStage)! == bannTotal.count {
                                        isAllStageBan = true
                                    } else {
                                        isAllStageBan = false
                                        totalStageToBan = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![banRoundId].banCount?[self.arrFire?.banRound ?? 0])!
                                    }
                                } else {
                                    isAllStageBan = true
                                }
                            }
                            if (bannTotal.count) == 0 {
                                for i in 0 ..< totalStageToBan {
                                    var arr = BanStage()
                                    arr.playerId = playerArr[self.opponentIndex]["playerId"] as? Int
                                    arr.stageId = tempArr.reversed()[i]
                                    arrBann.append(arr)
                                }
                            } else {
                                var selectedCount = 0
                                for _ in 0 ..< totalStageToBan {
                                    var arr = BanStage()
                                    let stageNo : Int = tempArr.count
                                    arr.playerId = playerArr[self.opponentIndex]["playerId"] as? Int
                                    
                                    var arrNo = [Int]()
                                    for j in 0 ..< arrBann.count {
                                        arrNo.append(arrBann[j].stageId ?? 0)
                                    }
                                    
                                    for j in 0 ..< arrNo.count {
                                        print("\(j)")
                                        for k in 0 ..< stageNo {
                                            if arrNo.contains(tempArr.reversed()[k])
                                            {
                                                
                                            } else {
                                                arr.stageId = tempArr.reversed()[k]
                                                selectedCount += 1
                                                break
                                            }
                                        }
                                        if selectedCount == totalStageToBan {
                                            break
                                        }
                                    }
                                    arrBann.append(arr)
                                }
                            }
                            
                            var arrLatest = [[String:AnyObject]]()
                            var jsonString = ""
                            do {
                                let encodedData = try JSONEncoder().encode(arrBann)
                                jsonString = String(data: encodedData,encoding: .utf8)!
                            } catch {
                                print(error)
                            }
                            
                            if let data = jsonString.data(using: String.Encoding.utf8) {
                                do {
                                    arrLatest = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] ?? []
                                } catch let error as NSError {
                                    print(error)
                                }
                            }
                            
                            param = ["bannedStages" : arrLatest,
                                     "stagePicBanPlayerId" : playerArr[self.myPlayerIndex]["playerId"]!,
                                     "banRound": (self.arrFire?.banRound)! + 1] as [String:AnyObject]   // "banRound" Added by Pranay.
                        }
                        //pick stage to play
                        else if self.arenaFlow == "lastStageToPick" {
                            self.listner?.remove()
                            
                            //Check availability of starter/counter stages in firestore stage array
                            //5/10/2021
                            var tempArr = [Int]()
                            var tempStarterArr = [Int]()
                            var tempCounterArr = [Int]()
                            
                            for i in 0 ..< (APIManager.sharedManager.content?.starterStage?.count ?? 0) {
                                tempStarterArr.append((APIManager.sharedManager.content?.starterStage?[i].id)!)
                            }
                            let oppStages : [Int] = playerArr[self.opponentIndex]["stages"] as! [Int]
                            for i in 0 ..< oppStages.count {
                                if tempStarterArr.contains(oppStages[i]) {
                                    tempArr.append(oppStages[i])
                                }
                            }
                            if self.doc?.data()?["currentRound"] as! Int != 1 {
                                for i in 0 ..< (APIManager.sharedManager.content?.counterStage?.count ?? 0) {
                                    tempCounterArr.append((APIManager.sharedManager.content?.counterStage?[i].id)!)
                                }
                                for i in 0 ..< oppStages.count {
                                    if tempCounterArr.contains(oppStages[i]) {
                                        if tempArr.contains(oppStages[i]) {
                                            
                                        } else {
                                            tempArr.append(oppStages[i])
                                        }
                                    }
                                }
                            } //5/10/2021
                            
                            var arrBann = [BanStage]()
                            arrBann = self.arrFire?.bannedStages ?? []
                            
                            var arr2 = [String: AnyObject]()
                            var pickArr = Stages()
                            //var stageNo : Int = arrFire.playerDetails?[self.myPlayerIndex].stages!.count as! Int
                            var bannIdArr = [Int]()
                            for i in 0 ..< arrBann.count {
                                bannIdArr.append(arrBann[i].stageId ?? 0)
                            }
                            //let originalStage = APIManager.sharedManager.content?.stages?.count ?? 0
                            //for m in 0 ..< originalStage {
                            for m in 0 ..< tempArr.count {
                                if (!(bannIdArr.contains(tempArr[m]))) {
                                    for x in 0 ..< (APIManager.sharedManager.content?.stages?.count ?? 0) {
                                        if APIManager.sharedManager.content?.stages?[x].id == tempArr[m] {
                                            pickArr.id = APIManager.sharedManager.content?.stages?[x].id
                                            pickArr.stageName = APIManager.sharedManager.content?.stages?[x].mapTitle
                                            pickArr.imagePath = APIManager.sharedManager.content?.stages?[x].imagePath
                                            break
                                        }
                                    }
                                    break
                                }
                            }
                            
                            var jsonString = ""
                            do {
                                let encodedData = try JSONEncoder().encode(pickArr)
                                jsonString = String(data: encodedData,encoding: .utf8)!
                                //all fine with jsonData here
                            } catch {
                                //handle error
                                print(error)
                            }
                            
                            if let data = jsonString.data(using: String.Encoding.utf8) {
                                do {
                                    arr2 = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject])!
                                } catch let error as NSError {
                                    print(error)
                                }
                            }
                            
                            var roundArr = [[String:AnyObject]]()
                            roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["finalStage"] = arr2 as AnyObject
                            
                            param = ["status": (self.arrFire?.currentRound ?? 1) > 1 ? Messages.characterSelection : Messages.playinRound,
                                     "rounds" : roundArr,
                                     "stagePicBanPlayerId" : playerArr[self.myPlayerIndex]["playerId"]!,
                                     "banRound" : 0] as [String:AnyObject]   //  "banRound" Added by Pranay.
                        }
                        //check winner has selected character for next round
                        else if self.arenaFlow == "CharacterSelected" {
                            playerArr[self.opponentIndex]["characterCurrent"] = true as AnyObject?
                            /// 114 - By Pranay -- set default character to previous character
                            playerArr[self.opponentIndex]["characterId"] = playerArr[self.opponentIndex]["defaultCharId"]
                            playerArr[self.opponentIndex]["characterName"] = playerArr[self.opponentIndex]["defaultCharName"]
                            playerArr[self.opponentIndex]["characterImage"] = playerArr[self.opponentIndex]["defaultCharImage"]
                            /// 114 .
                            let host = playerArr[0]["host"] as! Int == 1 ? 0 : 1
                            let otherPlayer = host == 0 ? 1 : 0
                            var roundArr = [[String:AnyObject]]()
                            roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                            
                            /*if self.opponentIndex == host {
                                roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = playerArr[host]["defaultCharId"] as AnyObject
                            } else {
                                roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = playerArr[otherPlayer]["defaultCharId"] as AnyObject
                            }   //  */
                            
                            if self.opponentIndex == host {
                                roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = playerArr[host]["defaultCharId"] as AnyObject
                                
                                let tempChar = APIManager.sharedManager.match?.homeTeamPlayers?[0].playedCharacter?.filter({ $0.id == playerArr[self.opponentIndex]["defaultCharId"] as? Int })
                                if (((APIManager.sharedManager.isShoesCharacter ?? "No") == "Yes") && (tempChar!.count > 0)) {
                                    if (tempChar![0].characterUseCnt ?? 0 >= APIManager.sharedManager.maxCharacterLimit ?? 0) {
                                        /*let tChar: [Characters] = (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.filter({
                                            $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit ?? 0
                                        }))!
                                        ///let abc: [Characters] = (arrAllCharacters?.enumerated().filter{ !tChar.contains(where: $0.offset) }.map{ $0.element })!
                                        if tChar.count > 0 {
                                            for i in 0 ..< tChar.count {
                                                for j in 0 ..< (self.arrAllCharacters?.count ?? 0) {
                                                    if arrAllCharacters![j].id == tChar[i].id {
                                                        arrAllCharacters?.remove(at: j)
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        let tempChar: [Characters] = (arrAllCharacters!.filter({ $0.characterUseCnt != self.intMaxNoOfCharSelect }))!
                                        let randNo: Int = Int.random(in: 0 ..< tempChar.count)  //  */
                                        
                                        let tempChar: [Characters] = self.getRemainCharacters(playedCharacters: (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter)!)
                                        let randNo: Int = Int.random(in: 0 ..< tempChar.count)
                                        
                                        playerArr[self.opponentIndex]["characterName"] = tempChar[randNo].name as AnyObject
                                        playerArr[self.opponentIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject
                                        playerArr[self.opponentIndex]["characterId"] = tempChar[randNo].id as AnyObject
                                        
                                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["homeCharacterId"] = tempChar[randNo].id as AnyObject
                                    }
                                }
                            } else {
                                roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = playerArr[otherPlayer]["defaultCharId"] as AnyObject
                                
                                let tempChar = APIManager.sharedManager.match?.awayTeamPlayers?[0].playedCharacter?.filter({ $0.id == playerArr[self.opponentIndex]["defaultCharId"] as? Int })
                                if (((APIManager.sharedManager.isShoesCharacter ?? "No") == "Yes") && (tempChar!.count > 0)) {
                                    if (tempChar![0].characterUseCnt ?? 0 >= APIManager.sharedManager.maxCharacterLimit ?? 0) {    
                                        /*let tChar: [Characters] = (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter?.filter({
                                            $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit ?? 0
                                        }))!
                                        ///let abc: [Characters] = (arrAllCharacters?.enumerated().filter{ !tChar.contains(where: $0.offset) }.map{ $0.element })!
                                        if tChar.count > 0 {
                                            for i in 0 ..< tChar.count {
                                                for j in 0 ..< (self.arrAllCharacters?.count ?? 0) {
                                                    if arrAllCharacters![j].id == tChar[i].id {
                                                        arrAllCharacters?.remove(at: j)
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        let tempChar: [Characters] = (arrAllCharacters!.filter({ $0.characterUseCnt != self.intMaxNoOfCharSelect }))!
                                        let randNo: Int = Int.random(in: 0 ..< tempChar.count)  /// */
                                        
                                        let tempChar: [Characters] = self.getRemainCharacters(playedCharacters: (APIManager.sharedManager.match?.awayTeamPlayers![0].playedCharacter)!)
                                        let randNo: Int = Int.random(in: 0 ..< tempChar.count)
                                        
                                        playerArr[self.opponentIndex]["characterName"] = tempChar[randNo].name as AnyObject
                                        playerArr[self.opponentIndex]["characterImage"] = tempChar[randNo].imagePath as AnyObject
                                        playerArr[self.opponentIndex]["characterId"] = tempChar[randNo].id as AnyObject

                                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["awayCharacterId"] = tempChar[randNo].id as AnyObject
                                    }
                                }
                            }
                            
                            if playerArr[self.myPlayerIndex]["characterCurrent"] as! Bool == true {
                                param = ["playerDetails": playerArr, "status": Messages.playinRound, "rounds" : roundArr] as [String:AnyObject]
                            } else {
                                param = ["playerDetails": playerArr, "rounds" : roundArr] as [String:AnyObject]
                            }
                        }
                        else if self.arenaFlow == "waitForOpponentToNextRound" {
                            self.manageOnStatus(status: "")
                        }
                        
                        if self.arenaFlow == "waitForOpponentToNextRound" {
                        }
                        else {
//                            self.log.i("ArenaWaitingPopupVC - opponentTimer() over - 'Update data to firestore' --- Remain time -> \(self.timeSeconds) -- \(APIManager.sharedManager.user?.userName ?? ""). --- param-> \(param)")  //  By Pranay.
                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                if let err = err {
//                                    self.log.e("ArenaWaitingPopupVC - opponentTimer() over - 'Update data to firestore' - \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                                    print("Error writing document: \(err)")
                                }
                                else {
                                    if self.arenaFlow == "FirstStageBan" || self.arenaFlow == "lastStageToPick" {
                                        self.listner?.remove()  //  Addded by Pranay.
                                        self.setUI()
                                    }
                                }
                            }
                        }
                    } else {
                        print("Timer is over and dispatch delay executed and get flag false.")
                    }
                }
            }
        }
        else {    //  - Added by Pranay - Main timer complete else part
            let (m,s) = secondsToHoursMinutesSeconds(seconds: timeSeconds)
            lblTimer.text = "Opponent's time limit: \(m):\(s)"
            //same time both player tap procced then check after 3 seconds and dismiss timer
            if self.arenaFlow == "WaitingScoreConfirm" && (self.doc?.data()?["status"] as? String == Messages.enteredScore) && (timeSeconds == finalTime - 8) && (self.doc?.data()?["disputeBy"] as? Int == 0) {
                
//                self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingScoreConfirm --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
//                        self.log.e("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingScoreConfirm fail -- \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                        print("Error getting documents: \(err)")
                    }
                    else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        
//                        self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingScoreConfirm --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                        
                        let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        
                        if (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
//                            self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                            
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if (self.doc?.data()?["matchForfeit"] as? Int == 1) {
//                            self.log.i("Waiting Dialog -- Arena flow.-> WaitingScoreConfirm -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                            
                            APIManager.sharedManager.isMatchForfeit = true
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if newDoc?.data()?["enteredScoreBy"] as? Int != playerArr[self.myPlayerIndex]["playerId"] as? Int {
                            self.manageOnStatus(status: "Entered by opponent")
                        }
                    }
                }
            }
            //Same time both player proceed to next round
            else if self.arenaFlow == "waitForOpponentToNextRound" && (self.doc?.data()?["status"] as? String == Messages.waitingToStagePickBan) && (timeSeconds == finalTime - 5) {
//                self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = waitForOpponentToNextRound --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
//                        self.log.e("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = waitForOpponentToNextRound fail -- \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                        print("Error getting documents: \(err)")
                    }
                    else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        
//                        self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = waitForOpponentToNextRound --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                        
                        let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        
                        if (self.doc?.data()?["scheduleRemoved"] as? Int == 1) {
//                            self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound -- scheduleRemoved -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                            
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if (self.doc?.data()?["matchForfeit"] as? Int == 1) {
//                            self.log.i("Waiting Dialog -- Arena flow.-> waitForOpponentToNextRound -- matchForfeit -- Remain time -> \(self.timeSeconds) -- Status - \(self.doc?.data()?["status"] as? String ?? "") - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
                            
                            APIManager.sharedManager.isMatchForfeit = true
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if newDoc?.data()?["readyToStagePickBanBy"] as? Int != playerArr[self.myPlayerIndex]["playerId"] as? Int {
                            self.manageOnStatus(status: "Proceed by opponet first")
                        }
                    }
                }
            }
            //Both player tap proceed after selecting option in RPS screen
            else if self.arenaFlow == "WaitingOpponentRPC" && (timeSeconds == finalTime - 3) {
                
//                self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingOpponentRPC --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
//                        self.log.e("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingOpponentRPC fail -- \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                        print("Error getting documents: \(err)")
                    }
                    else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        
//                        self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = WaitingOpponentRPC --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                        
                        let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        
                        if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                            APIManager.sharedManager.isMatchForfeit = true
                            self.manageOnStatus(status: "Schedule Removed")
                        }
                        else if(playerArr[self.opponentIndex]["rpc"] as? String == "" && playerArr[self.myPlayerIndex]["rpc"] as? String == ""){
                            self.manageOnStatus(status: "Tie")
                        }
                        else if(playerArr[self.opponentIndex]["rpc"] as? String != "") {
                            self.manageOnStatus(status: playerArr[self.opponentIndex]["rpc"] as! String)
                        }
                    }
                }
            }
            /// 222 - By Pranay. Comment if make any change or not
            //Both player tap proceed after selecting option in Character screen
            else if self.arenaFlow == "FirstRoundCharacter" && (timeSeconds == finalTime - 5) {
//                self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = FirstRoundCharacter --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "").")  //  By Pranay.
                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
                    if let err = err {
//                        self.log.e("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = FirstRoundCharacter fail -- \(APIManager.sharedManager.user?.userName ?? ""). -- Error-> \(err)")  //  By Pranay.
                        print("Error getting documents: \(err)")
                    }
                    else {
                        var newDoc:DocumentSnapshot?
                        newDoc = querySnapshot!
                        
//                        self.log.i("ArenaWaitingPopupVC - opponentTimer() -- arenaFlow = FirstRoundCharacter --- Remain time -> \(self.timeSeconds) --- \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(newDoc?.data())")  //  By Pranay.
                        
                        let playerArr = newDoc?.data()?["playerDetails"] as! [[String : AnyObject]]
                        
                        /// Add and conditoin for check opponent update awayCharSelect = 1 then host understand opponent's character selected.
                        if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                            self.callBack()
                        }
                        else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                            APIManager.sharedManager.isMatchForfeit = true
                            self.callBack()
                        }
                        else if playerArr[self.opponentIndex]["characterCurrent"] as? Bool == true {
                            if self.isHost {
                                if self.doc?.data()?["awayCharSelect"] as! Int == 1 {
                                    self.callBack()
                                }
                            }
                            else {
                                self.callBack()
                            }
                        }
                    }
                }
            }
            else if self.arenaFlow == "FirstRoundCharacter" && isHost {
                if self.doc?.data()?["awayCharSelect"] as! Int == 1 {
                    self.callBack()
                }
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
      return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func getRemainCharacters(playedCharacters : [Characters]) -> [Characters] {
        //let tChar: [Characters] = (APIManager.sharedManager.match?.homeTeamPlayers![0].playedCharacter?.filter({
        //  $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit ?? 0
        //}))!
        let tempChar: [Characters] = playedCharacters.filter({ $0.characterUseCnt == APIManager.sharedManager.maxCharacterLimit })
        ///let abc: [Characters] = (APIManager.sharedManager.content?.characters?.enumerated().filter{ !tChar.contains(where: $0.offset) }.map{ $0.element })!
        for i in 0 ..< tempChar.count {
            for j in 0 ..< (self.arrAllCharacters?.count ?? 0) {
                if arrAllCharacters![j].id == tempChar[i].id {
                    arrAllCharacters?.remove(at: j)
                    break
                }
            }
        }
        return arrAllCharacters!.filter({ $0.characterUseCnt ?? 0 < self.intMaxNoOfCharSelect })
    }
}
