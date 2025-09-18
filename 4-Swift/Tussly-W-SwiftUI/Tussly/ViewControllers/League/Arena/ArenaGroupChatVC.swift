//
//  ArenaGroupChatVC.swift
//  Tussly
//
//  Created by Auxano on 10/09/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift

class ArenaGroupChatVC: UIViewController {
    
    // MARK: - Variables
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var playerArr = [[String:AnyObject]]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    
    //Outlets
    @IBOutlet weak var btnNext: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.layer.cornerRadius = btnNext.frame.size.height / 2
        self.navigationController?.navigationBar.isHidden = true
        
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setTopbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listner?.remove()
    }
    
    // MARK: - UI Method
    func setUI() {
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    self.playerArr = self.doc?.data()?["playerDetails"] as! [[String : AnyObject]]
                    //opponent is ready and click yes to join or close to dismiss dialog
                    if self.doc?.data()?["weAreReadyBy"] as! Int != 0 && self.doc?.data()?["weAreReadyBy"] as! Int != self.playerArr[APIManager.sharedManager.myPlayerIndex]["playerId"] as! Int {
                        self.listner?.remove()
                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                        dialog.modalPresentationStyle = .overCurrentContext
                        dialog.modalTransitionStyle = .crossDissolve
                        dialog.titleText = "Confirm"
                        dialog.message = Messages.readyToJoinMatch
                        dialog.highlightString = ""
                        dialog.isFromBattleId = true
                        dialog.tapOkForBattleId = { isReady in
                            if isReady {
                                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                arenaLobby.tusslyTabVC = self.tusslyTabVC
                                arenaLobby.leagueTabVC = self.leagueTabVC
                                self.navigationController?.pushViewController(arenaLobby, animated: true)
                            } else {
                                self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                    "status" : Messages.characterSelection
                                ]) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                    } else {
                                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                                        arenaLobby.leagueTabVC = self.leagueTabVC
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    }
                                }
                            }
                        }
                        dialog.tapCancel = {
                            self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
                                "weAreReadyBy" : 0
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    self.setUI()
                                }
                            }
                        }
                        dialog.btnYesText = Messages.yes
                        dialog.btnNoText = Messages.close
                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func nextTapped(_ sender: UIButton) {
        self.listner?.remove()
        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWeAreBothInVC") as! ArenaWeAreBothInVC
        arenaLobby.tusslyTabVC = self.tusslyTabVC
        arenaLobby.leagueTabVC = self.leagueTabVC
        self.navigationController?.pushViewController(arenaLobby, animated: true)
    }
    
}

