
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

class ArenaReportScorePopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var isComeFromEnterID = false
    var arrStock = ["0","1", "2", "3"]
    var selectedStock1Index = 0
    var selectedStock2Index = 0
    var tapOk: (([Any], _ isMatchReset : Bool)->Void)?
    // [Any] = [Bool(true-Opponent submit score, false-This player manually submit                                      score),
                                            //Bool(0-tie, 1-no tie),
                                            //String- host player score,
                                            //String- opponent player score]
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var arrFire : FirebaseInfo?
    var otherPlayer = 0
    var isFromEnterScore = false
    var isFromDisputeScore = false
    var isTieByMistake = false
    var tieScore = ""
    
//    fileprivate let log = ShipBook.getLogger(ArenaReportScorePopupVC.self)
    var tapDismiss: (()->Void)?
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var tvStock1 : UITableView!
    @IBOutlet weak var tvStock2 : UITableView!
    @IBOutlet weak var lblStock1 : UILabel!
    @IBOutlet weak var lblStock2 : UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    //@IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var viewTvStock1: UIView!
    @IBOutlet weak var viewTvStock2: UIView!
    
    @IBOutlet weak var viewGameBar: UIView!
    @IBOutlet weak var lblSubHeader: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblScoreTitleH: UILabel!
    @IBOutlet weak var lblScoreTitleA: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // By Pranay
        arrStock.removeAll()
        for i in 0 ... APIManager.sharedManager.customizeScore! {
            arrStock.append("\(i)")
        }   //  */
        //.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        //view.bringSubviewToFront(tvStock1)
        //view.bringSubviewToFront(tvStock2)
        view.bringSubviewToFront(viewTvStock1)
        view.bringSubviewToFront(viewTvStock2)
        
        view.bringSubviewToFront(self.btnClose)
        
        btnSubmit.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        //tvStock1.isHidden = true
        //tvStock2.isHidden = true
        viewTvStock1.isHidden = true
        viewTvStock2.isHidden = true
        
        if arrStock.count <= 5 {
            heightTableView.constant = CGFloat(arrStock.count * 50)
        } else {
            heightTableView.constant = CGFloat(4 * 70)
        }
        
        //tvStock1.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        //tvStock2.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        viewTvStock1.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        viewTvStock2.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        
        //tvStock1.layer.cornerRadius = 8
        //tvStock2.layer.cornerRadius = 8
        viewTvStock1.layer.cornerRadius = 8
        viewTvStock2.layer.cornerRadius = 8
        
        if isTieByMistake {
            lblStock1.text = tieScore
            lblStock2.text = tieScore
        }
        
        
        //self.lblSubHeader.text = APIManager.sharedManager.gameSettings?.scoreReportSubHeader ?? ""
        self.lblMsg.text =  APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreReportMsg ?? ""
        self.lblScoreTitleH.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        self.lblScoreTitleA.text = APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreTitle ?? ""
        
        self.imgPlayer1.layer.cornerRadius = self.imgPlayer1.frame.size.height / 2
        self.imgPlayer2.layer.cornerRadius = self.imgPlayer2.frame.size.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        otherPlayer = APIManager.sharedManager.myPlayerIndex == 0 ? 1 : 0
        
//        self.log.i("ArenaReportScorePopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaReportScorePopupVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                self.doc =  querySnapshot!
                
//                self.log.i("ArenaReportScorePopupVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data()!,options: []) {
                    //let theJSONText = String(data: theJSONData,encoding: .ascii)
                    //let jsonData = Data(theJSONText!.utf8)
                    let decoder = JSONDecoder()
                    do {
                        self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                        //self.lblTitle.text = "Round \(self.arrFire?.currentRound ?? 0)"
                        self.lblTitle.text = "\(APIManager.sharedManager.gameSettings?.scorePopupInfo?.scoreHeader ?? "") \(self.arrFire?.currentRound ?? 0)"
                        let hostIndex : Int = self.arrFire?.playerDetails?[0].host == 0 ? 1 : 0
                        let opponentIndex : Int = hostIndex == 1 ? 0 : 1
                        
                        self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[hostIndex].displayName ?? "") : (self.arrFire?.playerDetails?[hostIndex].teamName ?? "")
                        self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrFire?.playerDetails?[opponentIndex].displayName ?? "") : (self.arrFire?.playerDetails?[opponentIndex].teamName ?? "")
                        self.lblPlayer2Char.text = self.arrFire?.playerDetails?[opponentIndex].characterName
                        self.lblPlayer1Char.text = self.arrFire?.playerDetails?[hostIndex].characterName
                        self.imgPlayer1.setImage(imageUrl: self.arrFire?.playerDetails?[hostIndex].characterImage ?? "")
                        self.imgPlayer2.setImage(imageUrl: self.arrFire?.playerDetails?[opponentIndex].characterImage ?? "")
                        
                        
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
                                    //self.tapOk!(["Match Forfeit"], true)
                                    self.tapOk!(["Schedule Removed"], true)
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
                        //screen opens by enterig score
                        else if self.isFromEnterScore {
                            /// add status condition for manage while submit report score button same time while opponent submit score then player can not report the score.
                            if (self.doc?.data()?["enteredScoreBy"] as? Int == self.arrFire?.playerDetails?[self.otherPlayer].playerId) && (self.doc?.data()?["status"] as? String == Messages.enteredScore) {
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        self.tapOk!([true], false)
                                    }
                                })
                            }
                        }
                        //screen opens by dispute and enterig new score
                         else if self.isFromDisputeScore {
                            if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                self.listner?.remove()
                                self.dismiss(animated: true, completion: {
                                    if self.tapOk != nil {
                                        self.tapOk!([true], false)
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
    }
    
    // By Pranay
    override func viewDidAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    // .
    
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
    
    // MARK: - Button Click Events
    @IBAction func submitTapped(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                //if tie = true else tie = false
                let tie : Bool = self.lblStock1.text == self.lblStock2.text ? true : false
                self.tapOk!([false,tie,self.lblStock1.text ?? "0", self.lblStock2.text ?? "0"], false)
            }
        })
    }
    
    @IBAction func stocksTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            //self.tvStock1.isHidden = false
            //self.tvStock2.isHidden = true
            self.viewTvStock1.isHidden = false
            self.viewTvStock2.isHidden = true
        }else {
            //self.tvStock1.isHidden = true
            //self.tvStock2.isHidden = false
            self.viewTvStock1.isHidden = true
            self.viewTvStock2.isHidden = false
        }
    }
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapDismiss != nil {
                self.tapDismiss!()
            }
        })
    }
}

// MARK: - UITableViewDelegate

extension ArenaReportScorePopupVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStock.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportScoreCVCell", for: indexPath) as! ReportScoreCVCell
        cell.index = indexPath.row
        cell.lblTitle.text = arrStock[indexPath.row]
        cell.lblTitle.textColor = UIColor.black
        let selectedStock = tableView == tvStock1 ? selectedStock1Index : selectedStock2Index
        if selectedStock == indexPath.row {
            cell.lblTitle.textColor = UIColor.blue
        }
        
        cell.onTapStock = { index in
            if tableView == self.tvStock1 {
                self.lblStock1.text = self.arrStock[index]
                self.selectedStock1Index = index
                //self.tvStock1.isHidden = true
                self.viewTvStock1.isHidden = true
                self.tvStock1.reloadData()
            }else {
                self.lblStock2.text = self.arrStock[index]
                self.selectedStock2Index = index
                //self.tvStock2.isHidden = true
                self.viewTvStock2.isHidden = true
                self.tvStock2.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
