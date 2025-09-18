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

class ArenaBattleArenaFailPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var isComeFromEnterID = false
    var tapOk: ((Bool)->Void)? //false - enter group chat manually, true - opponent is ready to chat
    var id = ""
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    
    // MARK: - Outlets
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var lblBattleArenaID : UILabel!
    @IBOutlet weak var btnEnterGroupChat: UIButton!
    @IBOutlet weak var heightTopView : NSLayoutConstraint!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
        
        lblTitle.text = APIManager.sharedManager.content?.arenaContents?.battle_arena_id_fail?.heading
        lblDesc.text = APIManager.sharedManager.content?.arenaContents?.battle_arena_id_fail?.data?.description
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewMain)
        
        btnEnterGroupChat.layer.cornerRadius = 15
        viewMain.layer.cornerRadius = 15
        
        lblBattleArenaID.text = "BattleArena ID: \(id)"
        lblBattleArenaID.attributedText = lblBattleArenaID.text?.setAttributedString(boldString: "BattleArena ID:", fontSize: 18.0)
        
        if isComeFromEnterID {
            self.viewTop.isHidden = false
            self.heightTopView.constant = 70.0
        }else {
            self.viewTop.isHidden = true
            self.heightTopView.constant = 0.0
        }
        
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.doc =  querySnapshot!
                // if player is ready for chat then dismiss dialog
                if self.doc?.data()?["weAreReadyBy"] as! Int != 0 {
                    self.listner?.remove()
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            self.tapOk!(true)
                        }
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Button Click Events
    @IBAction func enterGroupChatTapped(_ sender: UIButton) {
        listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(false)
            }
        })
    }
    
}
