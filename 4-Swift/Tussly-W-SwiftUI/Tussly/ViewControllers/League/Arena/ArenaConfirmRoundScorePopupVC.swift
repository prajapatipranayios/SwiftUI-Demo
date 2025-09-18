
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

class ArenaConfirmRoundScorePopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var tapOk: (([Any], _ isMatchReset : Bool)->Void)?
    // [Any] = [Bool(true-Opponent confirm score, false-manually confirm score),
                                            //Bool(0-confirm, 1-dispute)]
    var timeSeconds = 0
    var score1 = ""
    var score2 = ""
    var arrFire : FirebaseInfo?
    let db = Firestore.firestore()
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    
//    fileprivate let log = ShipBook.getLogger(ArenaConfirmRoundScorePopupVC.self)
    
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var lblStock1 : UILabel!
    @IBOutlet weak var lblStock2 : UILabel!
    @IBOutlet weak var lblCofirmScoreMessage : UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var lblRound: UILabel!
    @IBOutlet weak var lblWinner1 : UILabel!
    @IBOutlet weak var lblWinner2 : UILabel!
    @IBOutlet weak var viewPlayer1 : UIView!
    @IBOutlet weak var viewPlayer2 : UIView!
    
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblSubHeader: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblScoreTitleH: UILabel!
    @IBOutlet weak var lblScoreTitleA: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        
        btnSubmit.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        lblStock1.text = score1
        lblStock2.text = score2
        
        viewPlayer1.layer.cornerRadius = 8
        viewPlayer2.layer.cornerRadius = 8
        
        viewPlayer1.layer.borderWidth = 1.0
        viewPlayer2.layer.borderWidth = 1.0
        
        
        self.lblSubHeader.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreConfirmSubHeader ?? ""
        self.lblScoreTitleH.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        self.lblScoreTitleA.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        
        self.imgPlayer1.layer.cornerRadius = self.imgPlayer1.frame.size.height / 2
        self.imgPlayer2.layer.cornerRadius = self.imgPlayer2.frame.size.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
//        self.log.i("ArenaConfirmRoundScorePopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaConfirmRoundScorePopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
                self.doc =  querySnapshot!
                
//                self.log.i("ArenaConfirmRoundScorePopupVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                
                if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data()!,options: []) {
                    //let theJSONText = String(data: theJSONData,encoding: .ascii)
                    //let jsonData = Data(theJSONText!.utf8)
                    let decoder = JSONDecoder()
                    do {
                        self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                        
                        //self.lblRound.text = "Round \(self.arrFire?.currentRound ?? 0)"
                        self.lblRound.text = "\(APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreHeader ?? "") \(self.arrFire?.currentRound ?? 0)"
                        let hostIndex = self.arrFire?.playerDetails?[0].host == 1 ? 0 : 1
                        let opponentIndex = hostIndex == 1 ? 0 : 1
                        
                        let homeTeamName = (self.arrFire?.playerDetails?[hostIndex].teamName ?? "").count > 30 ? String((self.arrFire?.playerDetails?[hostIndex].teamName ?? "")[..<(self.arrFire?.playerDetails?[hostIndex].teamName ?? "").index((self.arrFire?.playerDetails?[hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrFire?.playerDetails?[hostIndex].teamName ?? "")
                        let awayTeamName = (self.arrFire?.playerDetails?[opponentIndex].teamName ?? "").count > 30 ? String((self.arrFire?.playerDetails?[opponentIndex].teamName ?? "")[..<(self.arrFire?.playerDetails?[opponentIndex].teamName ?? "").index((self.arrFire?.playerDetails?[opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrFire?.playerDetails?[opponentIndex].teamName ?? "")
                        
                        self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[hostIndex].displayName ?? "") : homeTeamName
                        self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[opponentIndex].displayName ?? "") : awayTeamName
                        self.lblPlayer2Char.text = self.arrFire?.playerDetails?[opponentIndex].characterName
                        self.lblPlayer1Char.text = self.arrFire?.playerDetails?[hostIndex].characterName
                        self.imgPlayer1.setImage(imageUrl: self.arrFire?.playerDetails?[hostIndex].characterImage ?? "")
                        self.imgPlayer2.setImage(imageUrl: self.arrFire?.playerDetails?[opponentIndex].characterImage ?? "")
                        
                        if self.arrFire?.rounds?[(self.arrFire?.currentRound ?? 1) - 1].winnerTeamId == self.arrFire?.playerDetails?[hostIndex].teamId {
                            self.lblWinner2.isHidden = true
                            self.viewPlayer2.layer.borderColor = Colors.gray.returnColor().cgColor
                            self.viewPlayer1.layer.borderColor = UIColor.systemGreen.cgColor
                        }
                        else {
                            self.lblWinner1.isHidden = true
                            self.viewPlayer1.layer.borderColor = Colors.gray.returnColor().cgColor
                            self.viewPlayer2.layer.borderColor = UIColor.systemGreen.cgColor
                        }
                        
                        if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                            self.dismiss(animated: true, completion: {
                                if self.tapOk != nil {
                                    self.listner?.remove()
                                    self.tapOk!(["Schedule Removed"], true)
                                }
                            })
                        }
                        else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                            self.dismiss(animated: true, completion: {
                                if self.tapOk != nil {
                                    self.listner?.remove()
                                    APIManager.sharedManager.isMatchForfeit = true
                                    self.tapOk!(["Schedule Removed"], true)
                                    //self.tapOk!(["Match Forfeit"], true)
                                }
                            })
                        }
                        else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                            self.dismiss(animated: true, completion: {
                                if self.tapOk != nil {
                                    self.listner?.remove()
                                    self.tapOk!(["Match Reset"], true)
                                }
                            })
                        }
                        else if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                            APIManager.sharedManager.timer.invalidate()
                            self.dismiss(animated: true, completion: {
                                if self.tapOk != nil {
                                    self.listner?.remove()
                                    self.tapOk!([true, 0], false)
                                }
                            })
                        }
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        timeSeconds = 60
        lblCofirmScoreMessage.attributedText = String(format: Messages.timerToConfirm ,timeSeconds).setAttributedString(boldString: "60 seconds", fontSize: 16.0)
        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        self.listner?.remove()
    }
    
    // MARK: - UI Method
    @objc func willResignActive() {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            APIManager.sharedManager.timer.invalidate()
            listner?.remove()
            self.dismiss(animated: true, completion: {
                if self.tapOk != nil {
                    self.tapOk!([false, 0], false)
                }
            })
        } else {
            lblCofirmScoreMessage.attributedText = String(format: "You have %d seconds to confirm the scores",timeSeconds).setAttributedString(boldString: "\(timeSeconds) seconds", fontSize: 16.0)
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func confirmTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!([false, 0], false)
            }
        })
    }
    
    @IBAction func disputeTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!([false, 1], false)
            }
        })
    }
    
}
