//
//  ArenaMatchResetVC.swift
//  Tussly
//
//  Created by MAcBook on 16/02/23.
//  Copyright © 2023 Auxano. All rights reserved.
//
//  //  By Pranay - whole screen Added

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
//import ShipBookSDK

class ArenaMatchResetVC: UIViewController, refreshTabDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblResetMatchTitle: UILabel!
    @IBOutlet weak var lblResetMatchMsg1: UILabel!
    @IBOutlet weak var lblResetMatchMsg2: UILabel!
    @IBOutlet weak var btnContactOrganizer: UIButton!
    
    // MARK: - Variables
    var isFromHome = false
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var arrFirebase : FirebaseInfo?
    let db = Firestore.firestore()
    var myPlayerIndex = 0
    var opponent = 1
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var isLobbyRemovedFromStack = false
//    fileprivate let log = ShipBook.getLogger(ArenaMatchResetVC.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationController?.isNavigationBarHidden = true
        //self.navigationItem.hideBackBtn()
        
        //self.lblTitle.text = Messages.arenaReset
        //self.lblResetMatchMsg1.text = Messages.arenaResetMsg1
        //self.lblResetMatchMsg2.text = Messages.arenaResetMsg2
        
        self.btnContactOrganizer.isHidden = true
        self.lblTitle.text = "Arena Close"//Messages.arenaReset
        self.lblResetMatchMsg1.text = APIManager.sharedManager.match?.manualUpdateFromUpcomingMsg ?? ""//Messages.arenaResetMsg1
        self.lblResetMatchMsg2.text = ""//Messages.arenaResetMsg2   //  */
        
        self.lblTitle.backgroundColor = UIColor(hexString: APIManager.sharedManager.gameSettings?.colorCode ?? "")
        
        self.setListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isLobbyRemovedFromStack = true
        listner?.remove()
    }
    
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isLobbyRemovedFromStack = true
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
    }
    
    func setListner() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaMatchResetVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaMatchResetVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            
            if let err = err {
//                self.log.e("ArenaMatchResetVC listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            }
            else {
//                self.log.i("ArenaMatchResetVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    let doc: DocumentSnapshot =  querySnapshot!
                    
                    //self.log.i("ArenaMatchResetVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(doc.data())")  //  By Pranay.
                    
                    let source = (doc.metadata.hasPendingWrites) ? "Local" : "Server"
                    print("\(source) --- data: \(doc.data() ?? [:])")
                    
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: doc.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            //self.arrFirebase = nil
                            self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            if (self.arrFirebase?.resetMatch ?? 0 == 1) && ((self.arrFirebase?.status ?? "" == Messages.matchFinished) || (self.arrFirebase?.matchFinished ?? 0 == 1)) {
                                print("Match Finished...")
                                self.leagueTabVC!().isNewMatch = true
                                self.navigateToArenaMatchReset()
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func navigateToArenaMatchReset() {
        self.listner?.remove()
        APIManager.sharedManager.match?.resetMatch = 1
        self.leagueTabVC!().getTournamentContent()
    }
}
