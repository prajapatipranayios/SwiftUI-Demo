//
//  DisplayPlayerCharacterPopup.swift
//  Tussly
//
//  Created by MAcBook on 19/06/23.
//  Copyright © 2023 Auxano. All rights reserved.
//

import UIKit
import FirebaseFirestore
//import FirebaseFirestoreSwift
//import ShipBookSDK

class DisplayPlayerCharacterPopup: UIViewController {

    // MARK: - Variables
    var isPopupRemovedFromStack = false
    var tapOk: (([Any])->Void)?
    var tapClose: (()->Void)?
    var strUserProfileImg: String = ""
    var strUserName: String = ""
    var playerCharacter: [Characters]?
    var maxCharacterLimit: Int? = 5
    var leagueTabVC: (()->LeagueTabVC)?
    var isFromHome = false
    var arrFirebase : FirebaseInfo?
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
//    fileprivate let log = ShipBook.getLogger(DisplayPlayerCharacterPopup.self)
    var isActivateListener: Bool = false
    var manageOnStatus: ((String)->Void)?
    
    // MARK: - Outlet
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewUserDetail: UIView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tblCharDetail: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblNoChar: UILabel!
    @IBOutlet weak var constraintHeightTblChar: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.lblTitle.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        self.viewUserDetail.backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.viewMain.layer.cornerRadius = 15
        self.btnClose.layer.cornerRadius = 15
        
        self.imgUserProfile.clipsToBounds = true
        self.imgUserProfile.layer.cornerRadius = self.imgUserProfile.frame.height / 2
        
        self.tblCharDetail.delegate = self
        self.tblCharDetail.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgUserProfile.setImage(imageUrl: strUserProfileImg)
        self.lblUserName.text = strUserName
        
        if isActivateListener {
            self.setListner()
        }
        
        self.lblNoChar.isHidden = true
        if playerCharacter?.count ?? 0 == 0 {
            self.lblNoChar.isHidden = false
            ///main constant value - 272
            self.constraintHeightTblChar.constant = 44
        } else {
            //self.constraintHeightTblChar.constant = CGFloat(44 * (playerCharacter?.count ?? 0))
            self.constraintHeightTblChar.constant = (playerCharacter?.count ?? 0) < 6 ? CGFloat(44 * (playerCharacter?.count ?? 0)) : 272
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPopupRemovedFromStack = true
        self.listner?.remove()
    }
    
    func reloadTab() {
    }
    
    func setListner() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.setListner()
                }
            }
            return
        }
        
//        self.log.i("DisplayPlayerCharacterPopup listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            
            if let err = err {
//                self.log.e("DisplayPlayerCharacterPopup listner call - \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("DisplayPlayerCharacterPopup listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
                    //self.log.i("DisplayPlayerCharacterPopup listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        do {
                            self.arrFirebase = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            
                            if (self.arrFirebase?.status ?? "" == Messages.stagePickBan) || (self.arrFirebase?.status ?? "" == Messages.characterSelection) {
                                self.btnCloseTap(UIButton())
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UI Action
    @IBAction func btnCloseTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.isActivateListener {
                print("Listener close.....")
                self.isActivateListener = false
                self.listner?.remove()
                if self.tapClose != nil {
                    self.tapClose!()
                }
            }
        })
    }
    
    // MARK: - Function
    func manageOnStatus(status: String) {
        self.listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.manageOnStatus != nil {
                self.manageOnStatus!(status)
            }
        })
    }
    
    func closePopup() {
        self.listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapClose != nil {
                self.tapClose!()
            }
        })
    }
    // MARK: -
}

extension DisplayPlayerCharacterPopup: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Tableview delegate/datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCharacter?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharCountTVCell", for: indexPath) as! CharCountTVCell
        cell.backgroundColor = .clear
        
        cell.viewCharName.layer.cornerRadius = 10.0
        cell.viewCharName.clipsToBounds = true
        cell.viewCharName.layer.borderWidth = 2
        cell.viewCharName.layer.borderColor = Colors.disable.returnColor().cgColor
        
        cell.imgCharacter.setImage(imageUrl: playerCharacter![indexPath.row].imagePath ?? "")
        cell.lblCharName.text = playerCharacter![indexPath.row].name ?? ""    //"\(indexPath.row + 1)"
        if playerCharacter![indexPath.row].characterUseCnt ?? 0 == maxCharacterLimit ?? 0 {
            cell.lblCharLimit.text = "Limit Reached"
            cell.lblCharLimit.textColor = UIColor(hexString: "ED1C25")
        } else if playerCharacter![indexPath.row].characterUseCnt ?? 0 >= ((maxCharacterLimit ?? 0)/2) + 1 {
            cell.lblCharLimit.text = "\(playerCharacter![indexPath.row].characterUseCnt ?? 0) of \(maxCharacterLimit ?? 0)"
            cell.lblCharLimit.textColor = UIColor(hexString: "FFCA19")
        } else if playerCharacter![indexPath.row].characterUseCnt ?? 0 < ((maxCharacterLimit ?? 0)/2) + 1 {
            cell.lblCharLimit.text = "\(playerCharacter![indexPath.row].characterUseCnt ?? 0) of \(maxCharacterLimit ?? 0)"
            cell.lblCharLimit.textColor = UIColor(hexString: "0DD146")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    // MARK: -
}
