
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

class ArenaDisputeVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var tapOk: ((Int)->Void)?
    // (Int) = (0-manually confirm, 1-manually dispute, 2-view photo dialog, 3-other player confirm score, 4-automatically score confirmed by you, 9-match reset by organizer)
    var arrPlayer = [ArenaPlayerData]()
    var score1 = ""
    var score2 = ""
    var round = 0
    var arrFire : FirebaseInfo?
    let db = Firestore.firestore()
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var roundVC = ArenaRoundResultVC()
    var winnerId = 0
    var timeSeconds = 0
//    fileprivate let log = ShipBook.getLogger(ArenaDisputeVC.self)
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var lblStock1 : UILabel!
    @IBOutlet weak var lblStock2 : UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnDispute: UIButton!
    @IBOutlet weak var btnViewPhoto: UIButton!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var lblRound: UILabel!
    @IBOutlet weak var viewPlayer1 : UIView!
    @IBOutlet weak var viewPlayer2 : UIView!
    @IBOutlet weak var lblWinner1 : UILabel!
    @IBOutlet weak var lblWinner2 : UILabel!
    @IBOutlet weak var lblCofirmTimeMessage : UILabel!
    @IBOutlet weak var lblTop : NSLayoutConstraint!
    
    
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
        
        btnConfirm.layer.cornerRadius = 20
        btnDispute.layer.cornerRadius = 20
        viewMain.layer.cornerRadius = 15
        viewPlayer1.layer.cornerRadius = 8
        viewPlayer2.layer.cornerRadius = 8
        
        viewPlayer1.layer.borderWidth = 1.0
        viewPlayer1.layer.borderColor = Colors.gray.returnColor().cgColor
        
        viewPlayer2.layer.borderWidth = 1.0
        viewPlayer2.layer.borderColor = Colors.gray.returnColor().cgColor
        
        lblWinner1.isHidden = true
        lblWinner2.isHidden = true
        lblStock1.text = score1
        lblStock2.text = score2
        
        if winnerId == 0 {
            self.viewPlayer1.layer.borderColor = UIColor.systemGreen.cgColor
            self.lblWinner1.isHidden = false
        } else {
            self.viewPlayer2.layer.borderColor = UIColor.systemGreen.cgColor
            self.lblWinner2.isHidden = false
        }
        
        
        self.lblMsg.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreDisputeMsg ?? ""
        self.lblScoreTitleH.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        self.lblScoreTitleA.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        
        self.imgPlayer1.layer.cornerRadius = self.imgPlayer1.frame.size.height / 2
        self.imgPlayer2.layer.cornerRadius = self.imgPlayer2.frame.size.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
//        self.log.i("ArenaDisputeVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaDisputeVC listner call - \(APIManager.sharedManager.user?.userName ?? "") ")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaDisputeVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("ArenaDisputeVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
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
                            
                            if self.doc?.data()?["disputeImagePath"] as? String == "" {
                                self.btnViewPhoto.isHidden = true
                                self.lblTop.constant = 24
                            } else {
                                self.btnViewPhoto.isHidden = false
                                self.lblTop.constant = 45
                            }
                            
                            if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                /// Schedule Removed by organizer. Then navigate to ArenaStepOneVC
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        //self.tapOk!(["Schedule Removed"], true)
                                        self.tapOk!(10)
                                    }
                                })
                            }
                            else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                /// Schedule Removed by organizer. Then navigate to ArenaStepOneVC
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        //self.tapOk!(["Match Forfeit"], true)
                                        APIManager.sharedManager.isMatchForfeit = true
                                        self.tapOk!(10)
                                        //self.tapOk!(11)
                                    }
                                })
                            }
                            else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        //self.tapOk!(["Match Reset"], true)
                                        self.tapOk!(9)
                                    }
                                })
                            }
                            else if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                APIManager.sharedManager.timer.invalidate()
                                self.listner?.remove()
                                //score confirm by other player
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        self.tapOk!(3)
                                    }
                                })
                            }
                            
                        } catch {
                            print("error")
                        }
                    }
                }
            }
        }
        
        timeSeconds = 60
        lblCofirmTimeMessage.attributedText = String(format: Messages.timerToConfirm ,timeSeconds).setAttributedString(boldString: "60 seconds", fontSize: 14.0)
        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        // .
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
            //score confirms automatically
            self.dismiss(animated: true, completion: {
                if self.tapOk != nil {
                    self.tapOk!(4)
                }
            })
        } else {
            lblCofirmTimeMessage.attributedText = String(format: "You have %d seconds to confirm the scores",timeSeconds).setAttributedString(boldString: "\(timeSeconds) seconds", fontSize: 14.0)
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func confirmTapped(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(0)
            }
        })
    }
    
    @IBAction func disputeTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(1)
            }
        })
    }
    
    @IBAction func viewPhotoTapped(_ sender: UIButton) {
        APIManager.sharedManager.timer.invalidate()
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(2)
            }
        })
    }
}
