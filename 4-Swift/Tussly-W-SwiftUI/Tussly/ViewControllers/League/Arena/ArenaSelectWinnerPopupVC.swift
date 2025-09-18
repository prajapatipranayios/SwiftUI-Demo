
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

class ArenaSelectWinnerPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var secondMessage = ""
    var thirdMessage = ""
    var isSingleLifeRemath = false
    var isTieByDamagePercentage = false
    var isTieBySuddenDeath = false
    var tapOk: (([Any])->Void)? // [Any] = [Bool(true-Opponent submit score, false-This player manually submit                                      score),
                                            //Int(0-choose winner, 1-tie %same),
                                            //Int- winner index(0-host, 1- opponent)]
    var tapDismiss: (()->Void)?
    var winner = -1
    var score1 = ""
    var score2 = ""
    var hostIndex = 0
    var opponentIndex = 1
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var arrFire : FirebaseInfo?
    var otherPlayer = 0
    var isFromEnterScore = false
    var isFromDisputeScore = false
    var suddenDeathWinner = 0
    
//    fileprivate let log = ShipBook.getLogger(ArenaSelectWinnerPopupVC.self)
    
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var viewPlayer1 : UIView!
    @IBOutlet weak var viewPlayer2 : UIView!
    @IBOutlet weak var lblStock1 : UILabel!
    @IBOutlet weak var lblStock2 : UILabel!
    @IBOutlet weak var lblWinner1 : UILabel!
    @IBOutlet weak var lblWinner2 : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblSecondMessage : UILabel!
    @IBOutlet weak var lblThirdMessage : UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewStocks : UIView!
    @IBOutlet weak var thirdLableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewStocksHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var lblRound: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewTopConst: NSLayoutConstraint!
    @IBOutlet var btnWinner: [UIButton]!
    
    
    @IBOutlet weak var viewGameBar: UIView!
    //@IBOutlet weak var lblSubHeader: UILabel!
    //@IBOutlet weak var lblMsg: UILabel!
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
        btnSubmit.isEnabled = false
        btnSubmit.backgroundColor = Colors.disableButton.returnColor()
        
        viewPlayer1.layer.cornerRadius = 8
        viewPlayer2.layer.cornerRadius = 8
        
        viewPlayer1.layer.borderWidth = 1.0
        viewPlayer1.layer.borderColor = Colors.gray.returnColor().cgColor
        
        viewPlayer2.layer.borderWidth = 1.0
        viewPlayer2.layer.borderColor = Colors.gray.returnColor().cgColor
        
        lblWinner1.isHidden = true
        lblWinner2.isHidden = true
        
        lblSecondMessage.text = secondMessage
        lblThirdMessage.text = thirdMessage
        
        lblStock1.text = score1
        lblStock2.text = score2
        
        
        self.lblScoreTitleH.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        self.lblScoreTitleA.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        
        self.imgPlayer1.layer.cornerRadius = self.imgPlayer1.frame.size.height / 2
        self.imgPlayer2.layer.cornerRadius = self.imgPlayer2.frame.size.height / 2
        
        let main_string = lblThirdMessage.text
        let clickHereRange = (main_string! as NSString).range(of: " click here > ")
        let attributedString = NSMutableAttributedString(string:main_string!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue.cgColor, range: clickHereRange)
        lblThirdMessage.attributedText = attributedString
        
        self.lblThirdMessage.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.lblThirdMessage.addGestureRecognizer(tapgesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        otherPlayer = APIManager.sharedManager.myPlayerIndex == 0 ? 1 : 0
        
//        self.log.i("ArenaSelectWinnerPopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaSelectWinnerPopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                self.doc =  querySnapshot!
                
//                self.log.i("ArenaSelectWinnerPopupVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                
                if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data()!,options: []) {
                    //let theJSONText = String(data: theJSONData,encoding: .ascii)
                    //let jsonData = Data(theJSONText!.utf8)
                    let decoder = JSONDecoder()
                    do {
                        self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                        
                        //self.lblRound.text = "Round \(self.arrFire?.currentRound ?? 0)"
                        self.lblRound.text = "\(APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreHeader ?? "") \(self.arrFire?.currentRound ?? 0)"
                        self.hostIndex = self.arrFire?.playerDetails?[0].host == 1 ? 0 : 1
                        self.opponentIndex = self.hostIndex == 1 ? 0 : 1
                        
                        let homeTeamName = (self.arrFire?.playerDetails?[self.hostIndex].teamName ?? "").count > 30 ? String((self.arrFire?.playerDetails?[self.hostIndex].teamName ?? "")[..<(self.arrFire?.playerDetails?[self.hostIndex].teamName ?? "").index((self.arrFire?.playerDetails?[self.hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrFire?.playerDetails?[self.hostIndex].teamName ?? "")
                        let awayTeamName = (self.arrFire?.playerDetails?[self.opponentIndex].teamName ?? "").count > 30 ? String((self.arrFire?.playerDetails?[self.opponentIndex].teamName ?? "")[..<(self.arrFire?.playerDetails?[self.opponentIndex].teamName ?? "").index((self.arrFire?.playerDetails?[self.opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrFire?.playerDetails?[self.opponentIndex].teamName ?? "")
                       
                        self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[self.hostIndex].displayName ?? "") : homeTeamName
                        self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[self.opponentIndex].displayName ?? "") : awayTeamName
                        self.lblPlayer2Char.text = self.arrFire?.playerDetails?[self.opponentIndex].characterName
                        self.lblPlayer1Char.text = self.arrFire?.playerDetails?[self.hostIndex].characterName
                        self.imgPlayer1.setImage(imageUrl: self.arrFire?.playerDetails?[self.hostIndex].characterImage ?? "")
                        self.imgPlayer2.setImage(imageUrl: self.arrFire?.playerDetails?[self.opponentIndex].characterImage ?? "")
                        
                        //screen opens by entering score
                        if self.isFromEnterScore {
                            if self.doc?.data()?["enteredScoreBy"] as? Int == self.arrFire?.playerDetails?[self.otherPlayer].playerId {
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        self.tapOk!([true])
                                    }
                                })
                            }
                        }
                        
                        //screen opens by dispute and entering new score
                        else if self.isFromDisputeScore {
                            if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        self.tapOk!([true])
                                    }
                                })
                            }
                        }
                    } catch {
                        print("error")
                    }
                }
            }
        }
        
        if isTieByDamagePercentage {
            lblThirdMessage.isHidden = false
            viewStocks.isHidden = false
            
            thirdLableHeight.constant = 70
            viewStocksHeight.constant = 110
            
        }else if isTieBySuddenDeath {
            lblThirdMessage.isHidden = false
            viewStocks.isHidden = false
            viewTopConst.constant = 0
            btnBack.isHidden = true
            thirdLableHeight.constant = 70
            viewStocksHeight.constant = 110
            winner = suddenDeathWinner
            btnWinner[suddenDeathWinner].tag = suddenDeathWinner
            selectWinnerTapped(btnWinner[suddenDeathWinner])
            
        }else if isSingleLifeRemath {
            lblThirdMessage.isHidden = false
            viewStocks.isHidden = true
            viewTopConst.constant = 0
            btnBack.isHidden = true
            thirdLableHeight.constant = 70
            viewStocksHeight.constant = 0
            
        }
        
        self.view.layoutIfNeeded()
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
        listner?.remove()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        if isSingleLifeRemath == false && isTieBySuddenDeath == false {
            guard let text = self.lblThirdMessage.text else { return }
            _ = (text as NSString).range(of: " click here > ")
            
            listner?.remove()
            self.dismiss(animated: true, completion: {
                if self.tapOk != nil {
                    self.tapOk!([false,1,self.winner ])
                }
            })
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func submitTapped(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                if self.winner == -1 {
                    self.winner = self.hostIndex
                }
                self.tapOk!([false,0,self.winner])
            }
        })
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapDismiss != nil {
                self.tapDismiss!()
            }
        })
    }
    
    @IBAction func selectWinnerTapped(_ sender: UIButton) {
        viewPlayer1.layer.borderColor = Colors.gray.returnColor().cgColor
        viewPlayer2.layer.borderColor = Colors.gray.returnColor().cgColor
        lblWinner1.isHidden = true
        lblWinner2.isHidden = true
        btnSubmit.isEnabled = true
        btnSubmit.backgroundColor = Colors.theme.returnColor()
        if sender.tag == 0 {
            viewPlayer1.layer.borderColor = UIColor.systemGreen.cgColor
            lblWinner1.isHidden = false
            winner = 0
        }else {
            viewPlayer2.layer.borderColor = UIColor.systemGreen.cgColor
            lblWinner2.isHidden = false
            winner = 1
        }
    }
}
