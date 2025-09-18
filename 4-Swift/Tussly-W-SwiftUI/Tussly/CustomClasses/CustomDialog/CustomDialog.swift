//
//  CustomDialog.swift
//  - This is a Popup which is used within multiple screens named below:
//      1. Initial
//      2. Login
//      3. Tussly Tab
//      4. Team Tab
//      5. Team Videos
//      6. Delete Video
//      7. Make Admin
//      8. Remove Admin
//      9. Manage League Roster
//      10. Manage Roster
//      11. Highlight
//      12. Settings
//      13. Admin Tools

//  Tussly
//
//  Created by Jaimesh Patel on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class CustomDialog: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var heightBtnCancel : NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    // MARK: - Variables
    
    var titleText: String = ""
    var message: String = ""
    var highlightString = ""
    var btnYesText: String = ""
    var btnNoText: String = ""
    var tapOK: (()->Void)?
    var tapOKForArenaScore: ((Bool)->Void)?
    var tapOkForBattleId: ((Bool)->Void)?
    var tapCancel: (()->Void)?
    var isFromArenaScore = false
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var arrFire : FirebaseInfo?
    var otherPlayer = 0
    var isFromEnterScore = false
    var isFromBattleId = false
    var isFromDisputeScore = false
    var isFromIDDoubleConfirm = false
    
    // By Pranay
    var arrHighlightString : [String] = []
    var isMsgCenter : Bool = false
    var isForVersionPopup = false
    // .
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = titleText
        
        // By Pranay
        if arrHighlightString.count > 0 {
            lblMessage.attributedText = message.setMultiBoldString(boldString: arrHighlightString, fontSize: 16.0)
        }
        else {
            lblMessage.attributedText = message.setAttributedString(boldString: highlightString, fontSize: 16.0)
        }
        
        lblMessage.textAlignment = .left
        if isMsgCenter {
            lblMessage.textAlignment = .center
        }
        // .
        
        btnYes.setTitle(btnYesText, for: .normal)
        btnNo.setTitle(btnNoText, for: .normal)
        if btnNoText == "" {
            heightBtnCancel.constant = 0
        }
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark) //UIBlurEffect.Style.dark
//
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        view.addSubview(blurEffectView)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        btnYes.layer.cornerRadius = 15.0
        btnNo.layer.cornerRadius = 15.0
        
        if message == Messages.areYouSureCofirmOpponentScore {
            btnNo.setTitleColor(UIColor.blue, for: .normal)
        }
        
        if isFromArenaScore || isFromDisputeScore {
            otherPlayer = APIManager.sharedManager.myPlayerIndex == 0 ? 1 : 0
            
            listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.doc =  querySnapshot!
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data()!,options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            
                            if self.isFromEnterScore {
                                if self.doc?.data()?["enteredScoreBy"] as? Int == self.arrFire?.playerDetails?[self.otherPlayer].playerId {
                                    self.listner?.remove()
                                    self.dismiss(animated: true, completion: {
                                        if self.tapOKForArenaScore != nil {
                                            self.tapOKForArenaScore!(true)
                                        }
                                    })
                                }
                            }
                            else if self.isFromDisputeScore {
                                if self.doc?.data()?["status"] as? String == Messages.scoreConfirm {
                                    self.listner?.remove()
                                    self.dismiss(animated: true, completion: {
                                        if self.tapOKForArenaScore != nil {
                                            self.tapOKForArenaScore!(true)
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
        
        if isFromBattleId {
            listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.doc =  querySnapshot!
                    if self.doc?.data()?["status"] as? String == Messages.characterSelection {
                        self.listner?.remove()
                        self.dismiss(animated: true, completion: {
                            if self.tapOkForBattleId != nil {
                                self.tapOkForBattleId!(true)
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func yesTapped(_ sender: UIButton) {
        if isFromArenaScore || isFromDisputeScore {
            listner?.remove()
            self.dismiss(animated: true, completion: {
                if self.tapOKForArenaScore != nil {
                    self.tapOKForArenaScore!(false)
                }
            })
        } else if isFromBattleId {
            listner?.remove()
            self.dismiss(animated: true, completion: {
                if self.tapOkForBattleId != nil {
                    self.tapOkForBattleId!(false)
                }
            })
        } else if isForVersionPopup {
            //self.dismiss(animated: true, completion: {
                if self.tapOK != nil {
                    self.tapOK!()
                }
            //})
        } else {
            self.dismiss(animated: true, completion: {
                if self.tapOK != nil {
                    self.tapOK!()
                }
            })
        }
    }
    
    @IBAction func noTapped(_ sender: UIButton) {
        if isFromArenaScore || isFromBattleId || isFromDisputeScore {
            listner?.remove()
        }
        self.dismiss(animated: true, completion: {
            if self.tapCancel != nil {
                self.tapCancel!()
            }
        })
    }
}
