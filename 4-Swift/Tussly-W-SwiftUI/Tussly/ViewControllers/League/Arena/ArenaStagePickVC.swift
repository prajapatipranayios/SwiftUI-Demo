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

class ArenaStagePickVC: UIViewController, refreshTabDelegate {
    
    // MARK: - Variables
    var selectedType = -1
    var isClickOnProceed = false
    var isTie = false
    var isRoundHigherThanOne = false
    var isAllStageBan = false
    var arrStarter = [StarterStage]()
    var arrCounterPick = [StarterStage]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var arrStarterIndex = [Int]()
    var arrStarterIndexDuplicate = [Int]()
    var arrCounterIndexDuplicate = [Int]()
    var banCountUntilProceed = 0
    var pickCountUntilProceed = 0
    var arrCounterIndex = [Int]()
    var isWinner = false
    var stagePicked = ""
    var timeSeconds = 0
    var finalSeconds = 0
    let db = Firestore.firestore()
    var arrBann = [BanStage]()
    var arrPlayer = [ArenaPlayerData]()
    var myPlayerIndex = 1
    var opponent = 1
    var arrFire : FirebaseInfo?
    var stagePickedFromStarter = false
    var doc:DocumentSnapshot?
    var listner: ListenerRegistration?
    var lblMessageCount = UILabel()
    var viewNav = UINavigationBar()
    var btnForfeit = UIButton()
    var btnChat = UIButton()
    var isFromNextRound = false
    var isTapChat = false
    var isStageRemovedFromStack = false
    
    var gameId : Int = APIManager.sharedManager.gameSettings?.id ?? 0
    var arrRounds = [Rounds]()
    var arrAutoBann = [Int]()
    var totalStageToBan : Int = 0
    var banRoundId : Int = 0
    
    var isStageSelect: Bool = false
    var isRemainStageOne: Bool = false
    var isProceedBtnTap: Bool = true
    var hostIndex: Int = 0
//    var tempBannedStages = [Int]()
//    fileprivate let log = ShipBook.getLogger(ArenaStagePickVC.self)
    
    var isChatBtnTap: Bool = false
    
    
    // MARK: - Outlets
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblStarterStage : UILabel!
    @IBOutlet weak var lblCounterPickStage : UILabel!
    @IBOutlet weak var cvStarter: UICollectionView!
    @IBOutlet weak var cvCounterpick: UICollectionView!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var cvStarterHeightConst : NSLayoutConstraint!
    @IBOutlet weak var cvCounterpickHeightConst : NSLayoutConstraint!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewBottomHeightConst : NSLayoutConstraint!
    @IBOutlet weak var viewTimeLimit : UIView!
    @IBOutlet weak var viewRound2Header : UIView!
    @IBOutlet weak var lblRound2Player1Name : UILabel!
    @IBOutlet weak var lblRound2Player2Name : UILabel!
    @IBOutlet weak var lblTimer : UILabel!
    @IBOutlet weak var lblPlayStage : UILabel!
    @IBOutlet weak var lblPlayer1Name : UILabel!
    @IBOutlet weak var lblPlayer2Name : UILabel!
    @IBOutlet weak var lblPlayer1Char : UILabel!
    @IBOutlet weak var lblPlayer2Char: UILabel!
    @IBOutlet weak var imgPlayer1 : UIImageView!
    @IBOutlet weak var imgPlayer2 : UIImageView!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPlayerIndex = APIManager.sharedManager.myPlayerIndex
        cvStarter.isHidden = true
        cvCounterpick.isHidden = true
        opponent = myPlayerIndex == 0 ? 1 : 0
        btnProceed.layer.cornerRadius = 10
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        imgPlayer1.layer.cornerRadius = imgPlayer1.frame.size.height / 2
        imgPlayer2.layer.cornerRadius = imgPlayer2.frame.size.height / 2
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.itemSize = CGSize(width: ((self.view.frame.size.width - 24) / 2), height: 40)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        cvStarter!.collectionViewLayout = layout
        
        let layoutCounter: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layoutCounter.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutCounter.itemSize = CGSize(width: ((self.view.frame.size.width - 24) / 2), height: 40)
        layoutCounter.minimumInteritemSpacing = 0
        layoutCounter.minimumLineSpacing = 0
        cvCounterpick!.collectionViewLayout = layoutCounter
        
        arrStarter = APIManager.sharedManager.content?.starterStage ?? []
        arrCounterPick = APIManager.sharedManager.content?.counterStage ?? []
        
        let count = arrStarter.count % 2
        let count1 = arrCounterPick.count % 2
        let height = count == 0 ? 0 : 1
        let height1 = count1 == 0 ? 0 : 1
        cvStarterHeightConst.constant = CGFloat(((arrStarter.count/2)+height) * 50)
        cvCounterpickHeightConst.constant = CGFloat(((arrCounterPick.count/2)+height1) * 50)
        
        self.cvStarter.dataSource = self
        self.cvStarter.delegate = self
        self.cvCounterpick.dataSource = self
        self.cvCounterpick.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 333 - By Pranay
        self.isProceedBtnTap = true
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .
        
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        self.navigationItem.setTopbar()
        viewNav = UINavigationBar(frame: CGRect.init(x: 0, y: 0, width: 70, height: 50))
        
        self.btnForfeit = UIButton(frame: CGRect.init(x: 0, y: 10, width: 30, height: 30))
        self.btnForfeit.setImage(UIImage(named: "forfeit"), for: .normal)
        self.btnForfeit.addTarget(self, action: #selector(self.onTapForfeit), for: .touchUpInside)

        self.btnChat = UIButton(frame: CGRect.init(x: 40, y: 10, width: 30, height: 30))
        self.btnChat.setImage(UIImage(named: "Chat_Icon"), for: .normal)
        self.btnChat.addTarget(self, action: #selector(self.onTapChat), for: .touchUpInside)
        
        let btnForfeit = UIBarButtonItem(customView: self.btnForfeit)
        let btnChat = UIBarButtonItem(customView: self.btnChat)
        
        self.navigationItem.setRightBarButtonItems([btnChat, btnForfeit], animated: true)
        
        lblMessageCount = UILabel(frame: CGRect.init(x: 55, y: 2, width: 20, height: 20))
        lblMessageCount.backgroundColor = Colors.theme.returnColor()
        lblMessageCount.layer.cornerRadius = lblMessageCount.frame.size.height / 2
        lblMessageCount.font = Fonts.Bold.returnFont(size: 15.0)
        lblMessageCount.textColor = UIColor.white
        lblMessageCount.clipsToBounds = true
        lblMessageCount.text = "0"
        lblMessageCount.textAlignment = .center
        
        isStageRemovedFromStack = false
        
        finalSeconds = ((APIManager.sharedManager.match?.matchType == Messages.regular || APIManager.sharedManager.match?.matchType == Messages.tournament) ? APIManager.sharedManager.content?.regularArenaTimeSettings?.timerForBanOrPickStage : APIManager.sharedManager.content?.playoffArenaTimeSettings?.timerForBanOrPickStage) ?? 15
        timeSeconds = finalSeconds
        
        APIManager.sharedManager.timer.invalidate()
        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackInfo),
            name: NSNotification.Name(rawValue: "DismissInfo"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.chatCountUpdate),
            name: NSNotification.Name(rawValue: "newMessageNotification"),
            object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        
        if isTapChat {
            isTapChat = false
            callBackInfo()
        }
        else {
            DispatchQueue.main.async {
                self.setData()
                
                self.setNotificationCountObserver()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DismissInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .chatUnreadCountUpdated, object: nil)
        
        isStageRemovedFromStack = true
        self.listner?.remove()
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        if APIManager.sharedManager.isAppResigned == 0 {
            APIManager.sharedManager.isAppResigned = 1
            isStageRemovedFromStack = true
            APIManager.sharedManager.timer.invalidate()
            listner?.remove()
        }
    }
    
    @objc func didBecomeActive() {
        if APIManager.sharedManager.isAppActived == 0 {
            APIManager.sharedManager.isAppActived = 1
            self.callBackInfo()
        }
    }
    
    //MARK:- UI Methods
    @objc func chatCountUpdate() {
        self.lblMessageCount.removeFromSuperview()
        chatBadge()
    }
    
    @objc func onTapChat() {
        let chatUserId : String = (self.leagueTabVC!().matchDetail?.chatId ?? "-1")
        if chatUserId != "-1" && !self.isChatBtnTap {
            self.isChatBtnTap = true
            self.isTapChat = true
            self.openArenaGroupConvorsation(id: chatUserId, type: .group, isFromArena: true, tusslyTabVC: self.tusslyTabVC) { success in
                if success {
                    self.isChatBtnTap = true
                    self.leagueTabVC!().showUnreadCount = false
                }
                else {
                    self.isTapChat = false
                }
            }
        }
        else {
            Utilities.showPopup(title: "Your match not scheduled yet.", type: .error)
        }
    }
    
    @objc func onTapForfeit() {
        print("Forfeit - button tap.")
        
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.forfeitMatch
        dialog.message = Messages.forfeitMsg
        dialog.btnYesText = Messages.yes
        dialog.isMsgCenter = true
        dialog.tapOK = {
            print("Forfeit button tapped.")
            self.declareForfeitTeam()
        }
        dialog.btnNoText = Messages.close
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    func setNotificationCountObserver() {
        self.showChatRedDot(show: self.leagueTabVC!().showUnreadCount)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnreadUpdate(_:)), name: .chatUnreadCountUpdated, object: nil)
    }
    
    @objc func handleUnreadUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            guard self.isViewLoaded, self.view.window != nil else { return }
            
            if let hasUnread = notification.userInfo?["hasUnread"] as? Bool {
                self.showChatRedDot(show: hasUnread)
            }
        }
    }
    
    func showChatRedDot(show: Bool) {
        DispatchQueue.main.async {
            // Remove existing red dot if any
            if let existingDot = self.btnChat.viewWithTag(999) {
                existingDot.removeFromSuperview()
            }

            guard show else { return }

            let redDotSize: CGFloat = 13
            let redDot = UIView(frame: CGRect(x: self.btnChat.frame.width - redDotSize / 2,
                                              y: -redDotSize / 2,
                                              width: redDotSize,
                                              height: redDotSize))
            redDot.backgroundColor = .red
            redDot.layer.cornerRadius = redDotSize / 2
            redDot.clipsToBounds = true
            redDot.tag = 999

            self.btnChat.addSubview(redDot)
        }
    }
    
    func chatBadge() {
        let chatCount = self.getUnreadChatCount(id: self.arrPlayer[self.opponent].playerId ?? 0).stringValue
        if chatCount == "0"{
            self.lblMessageCount.isHidden = true
        } else {
            self.lblMessageCount.isHidden = false
            self.lblMessageCount.text = chatCount
            self.viewNav.addSubview(self.lblMessageCount)
        }
    }
    
    @objc func onTapInfo() {
        listner?.remove()
        APIManager.sharedManager.timer.invalidate()
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
        dialog.currentPage = 5
        dialog.infoType = 0
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        if isStageRemovedFromStack == false {
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @objc func callBackInfo() {
        self.leagueTabVC!().delegate = self
        self.leagueTabVC!().showUnreadCount = false
        self.leagueTabVC!().getStatus()
    }
    
    func reloadTab() {
        print("refresh arena tab")
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            APIManager.sharedManager.timer.invalidate()
            if self.doc != nil {
                if !Network.reachability.isReachable {
                    self.isRetryInternet { (isretry) in
                        if isretry! {
                            self.callBackInfo()
                        }
                    }
                    return
                }
                
                if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                    //let theJSONText = String(data: theJSONData,encoding: .ascii)
                    //let jsonData = Data(theJSONText!.utf8)
                    let decoder = JSONDecoder()
                    do {
                        let arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                        
                        //Check availability of starter/counter stages in firestore stage array
                        //5/10/2021
                        var tempArr = [Int]()
                        var tempStarterArr = [Int]()
                        var tempCounterArr = [Int]()
                        
                        //add starter stages from firestore data
                        for i in 0 ..< (APIManager.sharedManager.content?.starterStage?.count ?? 0) {
                            tempStarterArr.append((APIManager.sharedManager.content?.starterStage?[i].id)!)
                        }   //  add all starter stage to tempStarter
                        for i in 0 ..< (arrFire.playerDetails?[self.myPlayerIndex].stages?.count ?? 0) {
                            if tempStarterArr.contains((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!) {
                                tempArr.append((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!)
                            }   //  which stages contains by the player from starter that will add to temp array.
                        }
                        
                        //add counter stages if match round is higher than one
                        if self.doc?.data()?["currentRound"] as! Int != 1 {
                            for i in 0 ..< (APIManager.sharedManager.content?.counterStage?.count ?? 0) {
                                tempCounterArr.append((APIManager.sharedManager.content?.counterStage?[i].id)!)
                            }   //  add all stage to counter stages
                            for i in 0 ..< (arrFire.playerDetails?[self.myPlayerIndex].stages?.count ?? 0) {
                                if tempCounterArr.contains((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!) {
                                    if tempArr.contains((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!) {
                                        
                                    } else {
                                        tempArr.append((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!)
                                    }
                                }   //  which counter stages contain in the playerDetails but not contain in temp array that add in temp array
                            }
                            
                            
                            // By Pranay
                            // If stages are already banned then not select in auto mode.
                            print(tempArr.count)
                            for i in 0 ..< (arrAutoBann.count) {
                                for j in 0 ..< (tempArr.count) {
                                    if tempArr[j] == arrAutoBann[i] {
                                        tempArr.remove(at: j)
                                        print("Stage Removed.")
                                        break
                                    }
                                }
                            }
                            print(tempArr.count)
                            
                            //set order as firestore
                            var arrDB = [Int]()
                            for i in 0 ..< (arrFire.playerDetails?[self.myPlayerIndex].stages?.count ?? 0) {
                                if tempArr.contains((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!) {
                                    arrDB.append((arrFire.playerDetails?[self.myPlayerIndex].stages?[i])!)
                                }
                            }
                            tempArr = arrDB
                        } //5/10/2021
                        
                        //final pick
                        if self.isAllStageBan && self.arrPlayer[self.myPlayerIndex].playerId == self.doc?.data()?["stagePicBanPlayerId"]  as? Int {
                            var arr2 = [String: AnyObject]()
                            var pickArr = Stages()
                            var bannIdArr = [Int]()
                            
                            bannIdArr = arrAutoBann
                            
                            for i in 0 ..< self.arrBann.count {
                                if !(bannIdArr.contains(self.arrBann[i].stageId ?? 0)) {
                                    bannIdArr.append(self.arrBann[i].stageId ?? 0)
                                }
                            }
                            for m in 0 ..< tempArr.count {
                                if (!(bannIdArr.contains(tempArr[m]))){
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
                            
                            let encodedData = try JSONEncoder().encode(pickArr)
                            let jsonString = String(data: encodedData,encoding: .utf8)
                            if let data = jsonString?.data(using: String.Encoding.utf8) {
                                do {
                                    arr2 = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject])!
                                } catch let error as NSError {
                                    print(error)
                                }
                            }
                            
                            var roundArr = [[String:AnyObject]]()
                            roundArr = doc?.data()?["rounds"] as! [[String : AnyObject]]
                            roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["finalStage"] = arr2 as AnyObject
                            
                            let param = [
                                "stagePicBanPlayerId" : arrFire.playerDetails?[self.opponent].playerId ?? 0,
                                "rounds" : roundArr,
                                "status": (self.arrFire?.currentRound ?? 1) > 1 ? Messages.characterSelection : Messages.playinRound,
                                "banRound": 0   //  Added by Pranay.
                            ] as [String: Any]
                            
//                            self.log.i("Update firestore in callTimer() timer over - All ban. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                            print("banRound === \((self.arrFire?.banRound)! + 1)")  //  Added by Pranay
                            db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                if let err = err {
//                                    self.log.e("Update firestore in callTimer() timer over - All ban. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                }
                            }  //  */
                        }
                        //ban stage before pick
                        else {
                            if self.arrPlayer[self.myPlayerIndex].playerId == self.doc?.data()?["stagePicBanPlayerId"]  as? Int {
                                if (arrFire.bannedStages?.count ?? 0) == 0 {
                                    self.arrBann.removeAll()
                                    for i in 0 ..< self.totalStageToBan {
                                        var arr = BanStage()
                                        arr.playerId = arrFire.playerDetails?[self.myPlayerIndex].playerId
                                        arr.stageId = tempArr.reversed()[i]
                                        self.arrBann.append(arr)
                                    }
                                }
                                else {
                                    var selectedCount = 0
                                    for _ in 0 ..< self.banCountUntilProceed {
                                        self.arrBann.removeLast()
                                    }
                                    
                                    print("Ban stage - \(self.banCountUntilProceed)")
                                    print("Totala stage to ban - \(self.totalStageToBan)")
                                    
                                    for _ in 0 ..< self.totalStageToBan {
                                        var arr = BanStage()
                                        let stageNo : Int = tempArr.count
                                        arr.playerId = arrFire.playerDetails?[self.myPlayerIndex].playerId
                                        
                                        var arrNo = [Int]()
                                        for j in 0 ..< self.arrBann.count {
                                            arrNo.append(self.arrBann[j].stageId ?? 0)
                                        }
                                        
                                        for j in 0 ..< arrNo.count {
                                            print("\(j)")
                                            for k in 0 ..< stageNo {
                                                if arrNo.contains(tempArr.reversed()[k]) {
                                                }else{
                                                    arr.stageId = tempArr.reversed()[k]
                                                    selectedCount += 1
                                                    break
                                                }
                                            }
                                            if (selectedCount == self.totalStageToBan) {
                                                break
                                            }
                                        }
                                        self.arrBann.append(arr)
                                    }
                                }
                                
                                //var arr1 = [[String:AnyObject]]()
                                var arrLatest = [[String:AnyObject]]()
                                let encodedData = try JSONEncoder().encode(self.arrBann)
                                let jsonString = String(data: encodedData,encoding: .utf8)
                                if let data = jsonString?.data(using: String.Encoding.utf8) {
                                    do {
                                        arrLatest = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] ?? []
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                }
                                
                                /*for i in 0 ..< self.arrBann.count {
                                 arrLatest.append(arr1[i])
                                 }   //  */
                                
                                self.arrStarterIndex.removeAll()
                                self.arrCounterIndex.removeAll()
                                
                                let param = [
                                    "bannedStages" : arrLatest,
                                    "stagePicBanPlayerId" : arrFire.playerDetails?[self.opponent].playerId ?? 0,
                                    "banRound": (self.arrFire?.banRound)! + 1   //  Added by Pranay.
                                ] as [String: Any]
                                
//                                self.log.i("Update firestore in callTimer() timer over. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                                print("banRound === \((self.arrFire?.banRound)! + 1)")  //  Added by Pranay
                                db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                                    if let err = err {
//                                        self.log.e("Update firestore in callTimer() timer over. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                    }
                                }  //  */
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            lblTimer.text = "Time Limit: \(timeFormatted(seconds: timeSeconds))"
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let newSeconds = ((seconds % 3600) % 60)
        return String(format: "%d:%d", minutes, newSeconds)
    }
    
    func setData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        guard let firebaseId = APIManager.sharedManager.firebaseId else { return  }
        print("FirebaseId ArenaStagePickVC >>>>>>>>>>>>>> \(firebaseId)")
        
//        self.log.i("ArenaStagePickVC listner call - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ArenaStagePickVC listner call - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
//                self.log.i("ArenaStagePickVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(querySnapshot?.data())")  //  By Pranay.
                
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    if let theJSONData = try? JSONSerialization.data(withJSONObject: self.doc?.data(),options: []) {
                        //let theJSONText = String(data: theJSONData,encoding: .ascii)
                        //let jsonData = Data(theJSONText!.utf8)
                        let decoder = JSONDecoder()
                        
                        //self.log.i("ArenaStagePickVC listner response - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                        
                        do {
                            self.arrBann.removeAll()
                            self.arrStarterIndexDuplicate.removeAll()
                            self.arrCounterIndexDuplicate.removeAll()
                            self.arrFire = try decoder.decode(FirebaseInfo.self, from: theJSONData)
                            self.arrBann = self.arrFire?.bannedStages ?? []
                            self.arrPlayer = self.arrFire?.playerDetails ?? []
                            // By Pranay
                            self.arrRounds = self.arrFire?.rounds ?? []
                            self.arrAutoBann = []
                            self.arrAutoBann.removeAll()
                            //.
                            self.chatBadge()
                            
                            self.hostIndex = self.arrPlayer[0].host == 1 ? 0 : 1
                            let opponentIndex = self.hostIndex == 1 ? 0 : 1
                            
                            let homeTeamName = (self.arrPlayer[self.hostIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[self.hostIndex].teamName ?? "")[..<(self.arrPlayer[self.hostIndex].teamName ?? "").index((self.arrPlayer[self.hostIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[self.hostIndex].teamName ?? "")
                            let awayTeamName = (self.arrPlayer[opponentIndex].teamName ?? "").count > 30 ? String((self.arrPlayer[opponentIndex].teamName ?? "")[..<(self.arrPlayer[opponentIndex].teamName ?? "").index((self.arrPlayer[opponentIndex].teamName ?? "").startIndex, offsetBy: 30)]) : (self.arrPlayer[opponentIndex].teamName ?? "")
                            
                            if (self.arrFire?.currentRound ?? 1) > 1 {
                                self.lblRound2Player1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : homeTeamName
                                self.lblRound2Player2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[opponentIndex].displayName ?? "") : awayTeamName
                            }
                            else {
                                self.viewRound2Header.isHidden = true
                                self.lblPlayer2Char.text = self.arrPlayer[opponentIndex].characterName
                                self.lblPlayer1Char.text = self.arrPlayer[self.hostIndex].characterName
                                self.imgPlayer1.setImage(imageUrl: self.arrPlayer[self.hostIndex].characterImage ?? "")
                                self.imgPlayer2.setImage(imageUrl: self.arrPlayer[opponentIndex].characterImage ?? "")
                            }
                            self.lblPlayer1Name.text = APIManager.sharedManager.match?.homeTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[self.hostIndex].displayName ?? "") : homeTeamName
                            self.lblPlayer2Name.text = APIManager.sharedManager.match?.awayTeam?.isJoinAsPlayer == 1 ? (self.arrPlayer[opponentIndex].displayName ?? "") : awayTeamName
                            
                            for i in 0 ..< self.arrBann.count {
                                for j in 0 ..< self.arrStarter.count {
                                    if self.arrBann[i].stageId == self.arrStarter[j].id {
                                        self.arrStarterIndexDuplicate.append(j)
                                        self.arrAutoBann.append(Int(self.arrBann[i].stageId!))
                                        break
                                    }
                                }
                                
                                //add counter stages only if round is higher than 1
                                if (self.arrFire?.currentRound ?? 1) > 1{
                                    for k in 0 ..< self.arrCounterPick.count {
                                        if self.arrBann[i].stageId == self.arrCounterPick[k].id {
                                            self.arrCounterIndexDuplicate.append(k)
                                            self.arrAutoBann.append(Int(self.arrBann[i].stageId!))
                                            break
                                        }
                                    }
                                }
                            }
                            
                            /// 334 - By Pranay
                            self.isRoundHigherThanOne = (self.arrFire?.currentRound)! == 1 ? false : true
                            
//                            self.log.i("Stage - customStageCharSettings. - \(APIManager.sharedManager.user?.userName ?? "") = \(APIManager.sharedManager.customStageCharSettings)")  //  By Pranay.
                            
                            //if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! != 0 {
                            if APIManager.sharedManager.stagePickBan ?? "" == "Yes" {
                                if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! >= (self.arrFire?.currentRound)! {
                                    self.banRoundId = (self.arrFire?.currentRound)! - 1
                                } else {
                                    self.banRoundId = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings?.count)! - 1
                                }
                                
                                if ((APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![self.banRoundId].banCount?.count)! - 1) >= (self.arrFire?.banRound)! {
                                    if (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![self.banRoundId].totalBanStage)! == self.arrBann.count {
                                        self.isAllStageBan = true
                                    } else {
                                        self.isAllStageBan = false
                                        self.totalStageToBan = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![self.banRoundId].banCount?[self.arrFire?.banRound ?? 0])!
                                    }
                                } else {
                                    self.isAllStageBan = true
                                }
                                /// 334 .
                                
                                let currRound = self.arrFire?.currentRound ?? 0
                                let dsr = (APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.dsr)!
                                
                                if (dsr != 0) && (currRound != 1) {
                                    let i : Int = 0
                                    let j : Int = currRound - 1
                                    var isPreviousStageSelect : Bool = false
                                    var arrTempRounds = [Rounds]()
                                    var pickTeamId : Int = 0
                                    var winTeamId : Int = 0
                                    
                                    for k in i ..< j {
                                        arrTempRounds.append(self.arrRounds[k])
                                    }
                                    
                                    for (_, item) in arrTempRounds.enumerated().reversed() {
                                        winTeamId = item.winnerTeamId!
                                        break
                                    }
                                    
                                    pickTeamId = self.arrPlayer[self.myPlayerIndex].teamId ?? 0
                                    if APIManager.sharedManager.customStageCharSettings?.stageBanSettings?.roundSettings![self.banRoundId].stagePickBy ?? "" == "W" {
                                        if winTeamId != pickTeamId {
                                            pickTeamId = self.arrPlayer[self.opponent].teamId ?? 0
                                        }
                                    } else {
                                        if winTeamId == pickTeamId {
                                            pickTeamId = self.arrPlayer[self.opponent].teamId ?? 0
                                        }
                                    }
                                    
                                    if dsr == 2 {
                                        arrTempRounds = arrTempRounds.reversed()
                                    }
                                    
                                    for k in i ..< j {
                                        if pickTeamId == arrTempRounds[k].winnerTeamId {
                                            isPreviousStageSelect = dsr == 2 ? true : false
                                            for m in 0 ..< self.arrStarter.count {
                                                if arrTempRounds[k].finalStage?.id == self.arrStarter[m].id {
                                                    //self.arrStarterIndexDuplicate.append(m)
                                                    if !self.arrAutoBann.contains(Int(self.arrStarter[m].id!)) {
                                                        self.arrStarterIndexDuplicate.append(m)
                                                        self.arrAutoBann.append(Int(self.arrStarter[m].id!))
                                                        break
                                                    }
                                                }
                                            }
                                            
                                            //add counter stages only if round is higher than 1
                                            for n in 0 ..< self.arrCounterPick.count {
                                                if arrTempRounds[k].finalStage?.id == self.arrCounterPick[n].id {
                                                    //self.arrCounterIndexDuplicate.append(n)
                                                    if !self.arrAutoBann.contains(Int(self.arrCounterPick[n].id!)) {
                                                        self.arrCounterIndexDuplicate.append(n)
                                                        self.arrAutoBann.append(Int(self.arrCounterPick[n].id!))
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                        if isPreviousStageSelect {
                                            break
                                        }
                                    }
                                }
                            }
                            
                            let totalStage : Int = self.isRoundHigherThanOne ? (self.arrStarter.count + self.arrCounterPick.count) : self.arrStarter.count
                            self.isRemainStageOne = false
                            if (self.isAllStageBan && self.arrAutoBann.count == (totalStage - 1)) && (self.doc?.data()?["stagePicBanPlayerId"] as? Int == self.arrPlayer[self.myPlayerIndex].playerId) {
                                self.isRemainStageOne = true
                                self.isProceedBtnTap = true
                            }
                            
                            if self.doc?.data()?["status"] as? String == Messages.stagePickBan {
                                self.cvStarter.reloadData()
                                self.cvCounterpick.reloadData()
                            }
                            else {
                                self.isAllStageBan = true
                            }
                            
                            self.cvStarter.isHidden = false
                            self.cvCounterpick.isHidden = false
                            
                            /*/// 554 - By Pranay
                            if self.doc?.data()?["status"] as? String != Messages.stagePickBan {
                                self.isAllStageBan = true
                            }   //  */
                            /// 554 .
                            
                            if self.doc?.data()?["scheduleRemoved"] as? Int == 1 {
                                /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                if APIManager.sharedManager.timer.isValid == true {
                                    APIManager.sharedManager.timer.invalidate()
                                }
                                self.listner?.remove()
                                self.leagueTabVC!().getTournamentContent()
                                
                                return
                            }
                            else if self.doc?.data()?["matchForfeit"] as? Int == 1 {
                                /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                if APIManager.sharedManager.timer.isValid == true {
                                    APIManager.sharedManager.timer.invalidate()
                                }
                                APIManager.sharedManager.isMatchForfeit = true
                                self.listner?.remove()
                                //self.navigateToArenaRoundResult()
                                self.leagueTabVC!().getTournamentContent()
                                
                                return
                            }
                            else if self.doc?.data()?["resetMatch"] as? Int == 1 {
                                /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaStepOneVC
                                self.navigateToArenaMatchReset()
                                
                                return
                            }
                            // if all stages are banned
                            else if self.isAllStageBan {
                                APIManager.sharedManager.timer.invalidate()
                                if self.doc?.data()?["status"] as? String == Messages.playinRound {
                                    //redirect to score screen if status is playing round
                                    self.listner?.remove()
                                    self.pickCountUntilProceed = 0
                                    let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                    arenaLobby.tusslyTabVC = self.tusslyTabVC
                                    arenaLobby.leagueTabVC = self.leagueTabVC
                                    if self.isStageRemovedFromStack == false {
                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                    }
                                } else if self.doc?.data()?["status"] as? String == Messages.characterSelection {
                                    self.listner?.remove()
                                    self.pickCountUntilProceed = 0
                                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                    for aViewController in viewControllers {
                                        if aViewController is ArenaCharacterSelectionVC {
                                            self.navigationController!.popToViewController(aViewController, animated: true)
                                            break
                                        } else {
                                            let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                            arenaLobby.tusslyTabVC = self.tusslyTabVC
                                            arenaLobby.leagueTabVC = self.leagueTabVC
                                            self.navigationController?.pushViewController(arenaLobby, animated: true)
                                            break
                                        }
                                    }
                                    
                                } else if self.doc?.data()?["status"] as? String == Messages.stagePickBan {
                                    if self.doc?.data()?["stagePicBanPlayerId"] as? Int != self.arrPlayer[self.myPlayerIndex].playerId {
                                        self.listner?.remove()
                                        APIManager.sharedManager.timer.invalidate()
                                        self.showLoading()
                                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                        dialog.modalPresentationStyle = .overCurrentContext
                                        dialog.modalTransitionStyle = .crossDissolve
                                        dialog.isLoader = false
                                        dialog.timeSeconds = self.finalSeconds
                                        dialog.descriptionString = Messages.opponentPicking
                                        //dialog.status = (self.arrFire?.currentRound ?? 1) > 1 ? Messages.characterSelection : Messages.playinRound
                                        dialog.arenaFlow = "lastStageToPick"
                                        dialog.tapOk = {
                                            self.hideLoading()
                                            self.pickCountUntilProceed = 0
                                            if (self.arrFire?.currentRound ?? 1) > 1 {
                                                let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                                                for aViewController in viewControllers {
                                                    if aViewController is ArenaCharacterSelectionVC {
                                                        //self.hideLoading()
                                                        self.navigationController!.popToViewController(aViewController, animated: true)
                                                        break
                                                    } else {
                                                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaCharacterSelectionVC") as! ArenaCharacterSelectionVC
                                                        arenaLobby.tusslyTabVC = self.tusslyTabVC
                                                        arenaLobby.leagueTabVC = self.leagueTabVC
                                                        //self.hideLoading()
                                                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                                                        break
                                                    }
                                                }
                                            }
                                            else {
                                                let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                                                arenaLobby.tusslyTabVC = self.tusslyTabVC
                                                arenaLobby.leagueTabVC = self.leagueTabVC
                                                //self.hideLoading()
                                                if self.isStageRemovedFromStack == false {
                                                    self.navigationController?.pushViewController(arenaLobby, animated: true)
                                                }
                                            }
                                        }
                                        dialog.manageOnStatus = { status in
                                            if status == "Schedule Removed" {
                                               self.scheduledRemoved()
                                            }
                                            else if status == "Match Forfeit" {
                                               self.navigateToArenaRoundResult()
                                            }
                                            else if status == "Match Reset" {
                                               self.navigateToArenaMatchReset()
                                            }
                                        }
                                        if self.isStageRemovedFromStack == false {
                                            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                        }
                                    } else {
                                        self.btnProceed.backgroundColor = Colors.border.returnColor()
                                        self.btnProceed.isEnabled = false
                                        self.timeSeconds = self.finalSeconds
                                        APIManager.sharedManager.timer.invalidate()
                                        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                                    }
                                }
                            }
                            // Stages are left to ban
                            else {
                                self.btnProceed.backgroundColor = Colors.border.returnColor()
                                self.btnProceed.isEnabled = false
                                if self.doc?.data()?["stagePicBanPlayerId"] as? Int != self.arrPlayer[self.myPlayerIndex].playerId {
                                    self.listner?.remove()
                                    APIManager.sharedManager.timer.invalidate()
                                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaWaitingPopupVC") as! ArenaWaitingPopupVC
                                    dialog.isLoader = false
                                    dialog.timeSeconds = self.finalSeconds
                                    dialog.modalPresentationStyle = .overCurrentContext
                                    dialog.modalTransitionStyle = .crossDissolve
                                    dialog.descriptionString = Messages.opponentSelecting
                                    dialog.arenaFlow = "FirstStageBan"
                                    dialog.tapOk = {
                                        self.timeSeconds = self.finalSeconds
                                        APIManager.sharedManager.timer.invalidate()
                                        APIManager.sharedManager.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                                        self.setData()
                                    }
                                    if self.isStageRemovedFromStack == false {
                                        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
                                    }
                                }
                            }
                            self.updateUI()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func updateUI() {
        if isAllStageBan {
            //lblMessage.text = Messages.selectToPlay
            lblMessage.attributedText = Messages.selectToPlay.setMultiBoldColorString(boldString: ["PICK"], color: [UIColor.init(hexString: "#50A952")], fontSize: 14.0)
            
            if arrStarterIndex.count > 0 || arrCounterIndex.count > 0 {
                viewBottom.isHidden = false
                viewBottomHeightConst.constant = 80
            }else {
                viewBottom.isHidden = true
                viewBottomHeightConst.constant = 0
            }
            lblPlayStage.text = stagePicked
        }
        else {
            if isRoundHigherThanOne == true {
                lblCounterPickStage.textColor = UIColor.black
                //lblMessage.text = "Select \(self.totalStageToBan) stage to ban"
                lblMessage.attributedText = "Select \(self.totalStageToBan) stage to BAN".setMultiBoldColorString(boldString: ["BAN"], color: [UIColor.init(hexString: "#880700")], fontSize: 14.0)    //  Added by Pranay.
                viewBottom.isHidden = true
                viewBottomHeightConst.constant = 0
            }
            else {
                lblCounterPickStage.textColor = Colors.border.returnColor()
                //lblMessage.text = "Select \(self.totalStageToBan) stage to ban"
                lblMessage.attributedText = "Select \(self.totalStageToBan) stage to BAN".setMultiBoldColorString(boldString: ["BAN"], color: [UIColor.init(hexString: "#880700")], fontSize: 14.0)    //  Added by Pranay.
                
                viewBottom.isHidden = true
                viewBottomHeightConst.constant = 0
                
                /*if(arrStarterIndexDuplicate.count >= 3){
                 lblMessage.text = Messages.pleaseSelectToPlay
                 isWinner = true
                 if(arrStarterIndex.count > 0){
                 viewBottom.isHidden = false
                 viewBottomHeightConst.constant = 80
                 }
                 }   //  */
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func proceedTapped(_ sender: UIButton) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callBackInfo()
                }
            }
            return
        }
        
        if !self.isProceedBtnTap {
            self.isProceedBtnTap = true
            self.proceedBtnTap()
        }
    }
    
    func proceedBtnTap() {
//        self.log.i("Stage ban proceed btn tap. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        timeSeconds = finalSeconds
        APIManager.sharedManager.timer.invalidate()
        var pickArr = Stages()
        var arr1 = [[String: AnyObject]]()
        var arr2 = [String: AnyObject]()
        
        //let tempBannedStages = self.arrBann.map(\.stageId)
//        var bannedStages = [String: [Int]]()
//        
//        var keyBannedStages: String = ""
//        if self.myPlayerIndex == self.hostIndex {
//            keyBannedStages = "hostBannedStages"
//            bannedStages = self.arrFire?.hostBannedStages ?? [:]
//        }
//        else {
//            keyBannedStages = "awayBannedStages"
//            bannedStages = self.arrFire?.awayBannedStages ?? [:]
//        }
        
//        for stageId in self.tempBannedStages {
//            bannedStages.append(stageId)
//        }
        
//        self.tempBannedStages.removeAll()
        
//        print("Player banned stages --> \(keyBannedStages) --", bannedStages)
        
        do {
            if isAllStageBan {
                pickArr.id = stagePickedFromStarter ? arrStarter[arrStarterIndex.first!].id : arrCounterPick[arrCounterIndex.first!].id
                pickArr.stageName = stagePickedFromStarter ? arrStarter[arrStarterIndex.first!].stageName : arrCounterPick[arrCounterIndex.first!].stageName
                pickArr.imagePath = stagePickedFromStarter ? arrStarter[arrStarterIndex.first!].imagePath : arrCounterPick[arrCounterIndex.first!].imagePath
                pickArr.playerId = APIManager.sharedManager.user?.id ?? 0
                
                let encodedData = try JSONEncoder().encode(pickArr)
                let jsonString = String(data: encodedData,encoding: .utf8)
                if let data = jsonString?.data(using: String.Encoding.utf8) {
                    do {
                        arr2 = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject])!
                    } catch let error as NSError {
                        print(error)
                    }
                }
            } else {
                let encodedData = try JSONEncoder().encode(self.arrBann)
                let jsonString = String(data: encodedData,encoding: .utf8)
                if let data = jsonString?.data(using: String.Encoding.utf8) {
                    do {
                        arr1 = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]] ?? []
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        } catch {
            print("error")
        }
        
        self.arrStarterIndex.removeAll()
        self.arrCounterIndex.removeAll()
        
        self.banCountUntilProceed = 0   //  Added by Pranay.
        
        self.callTimer()
        
        /// 444 - By Pranay
//        self.log.i("Stage ban proceed btn tap and getDocument. - \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").getDocument() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("Stage ban proceed btn tap and getDocument. - \(APIManager.sharedManager.user?.userName ?? "") Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
                self.btnProceed.isEnabled = true
            } else {
                if querySnapshot != nil {
                    self.doc =  querySnapshot!
                    
//                    self.log.i("Stage ban proceed btn tap and getDocument. - \(APIManager.sharedManager.user?.userName ?? "") --- response-> \(self.doc?.data())")  //  By Pranay.
                    self.banCountUntilProceed = 0   //  Added by Pranay.
                    if self.isAllStageBan {
                        var roundArr = [[String:AnyObject]]()
                        roundArr = self.doc?.data()?["rounds"] as! [[String : AnyObject]]
                        roundArr[self.doc?.data()?["currentRound"] as! Int - 1]["finalStage"] = arr2 as AnyObject
                        
                        var curretnStatus = ""
                        if (self.arrFire?.currentRound ?? 1) > 1 {
                            curretnStatus = Messages.characterSelection
                        } else {
                            curretnStatus = Messages.playinRound
                        }
                        
                        let param = [
                            "stagePicBanPlayerId" : self.arrPlayer[self.opponent].playerId ?? 0,
                            "rounds" : roundArr,
                            "status": curretnStatus,
                            "banRound": 0   //  Added by Pranay.
                        ] as [String: Any]
                        
//                        self.log.i("Stage select to pick and proceed tap. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                        print("banRound === \((self.arrFire?.banRound)! + 1)")  //  Added by Pranay
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                            if let err = err {
//                                self.log.e("Stage select to pick and proceed tap. - Remain time -> \(self.timeSeconds) - Fail - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                self.btnProceed.isEnabled = true
                            } else {
                                
                            }
                        }
                    } else {
                        let param = [
                            "stagePicBanPlayerId" : self.arrPlayer[self.opponent].playerId ?? 0,
                            "bannedStages" : arr1,
                            "banRound": (self.arrFire?.banRound)! + 1
                        ] as [String: Any]
                        
//                        self.log.i("Stage select to ban and proceed tap. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param)")  //  By Pranay.
                        self.listner?.remove()    //  Comment by Pranay.
                        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData(param) { err in
                            if let err = err {
//                                self.log.e("Stage select to ban and proceed tap. - Remain time -> \(self.timeSeconds) - \(APIManager.sharedManager.user?.userName ?? "") --- param-> \(param) --- Error-> \(err)")  //  By Pranay.
                                print("Error writing document: \(err)")
                            }
                            else {
                                print("banRound === \((self.arrFire?.banRound)! + 1)")  //  Added by Pranay
                                self.setData()
                                self.btnProceed.isEnabled = true
                            }
                        }
                    }
                } else {
                    self.btnProceed.isEnabled = true
                }
            }
        }
        /// 444 .   */
    }
    
    func navigateToArenaMatchReset() {
        /// Match stuck while playing, after that organizer reset the match. Then navigate to ArenaMatchResetVC
        self.listner?.remove()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            APIManager.sharedManager.match?.resetMatch = 1
            if aViewController is ArenaMatchResetVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            } else {
                let stagePickVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaMatchResetVC") as! ArenaMatchResetVC
                stagePickVC.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(stagePickVC, animated: true)
                break
            }
        }
    }
    
    func navigateToArenaRoundResult() {
        self.listner?.remove()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ArenaRoundResultVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            }
            else {
                let arenaRoundResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ArenaRoundResultVC") as! ArenaRoundResultVC
                arenaRoundResultVC.leagueTabVC = self.leagueTabVC
                self.navigationController?.pushViewController(arenaRoundResultVC, animated: true)
                break
            }
        }
    }
    
    func scheduledRemoved() {
        if APIManager.sharedManager.timer.isValid == true {
            APIManager.sharedManager.timer.invalidate()
        }
        self.listner?.remove()
        self.leagueTabVC!().getTournamentContent()
    }
}

extension ArenaStagePickVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView != cvCounterpick {
            return arrStarter.count
        }else {
            return arrCounterPick.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarterCVCell", for: indexPath) as! StarterCVCell
        
        if collectionView == cvStarter {
            cell.lblTitle.text = arrStarter[indexPath.row].stageName
            cell.index = indexPath.item
            let tmpArr = arrStarterIndex
            if isAllStageBan {
                cell.imgSelected.image = UIImage(named: "stage_picked")
            }
            else {
                cell.imgSelected.image = UIImage(named: "Check")
            }
            
            if tmpArr.contains(cell.index) {
                cell.imgSelected.isHidden = false
            }
            else {
                cell.imgSelected.isHidden = true
            }
            
            // Stage banned         //By Pranay
            cell.lblTitle.textColor = arrStarterIndexDuplicate.contains(indexPath.row) ? Colors.border.returnColor() : Colors.black.returnColor()
            cell.lblBanned.isHidden = arrStarterIndexDuplicate.contains(indexPath.row) ? false : true
            cell.isUserInteractionEnabled = arrStarterIndexDuplicate.contains(indexPath.row) ? false : true
            
            if self.isAllStageBan && self.isRemainStageOne && cell.lblBanned.isHidden {
                self.isProceedBtnTap = true
                cell.imgSelected.isHidden = false
                
                self.arrStarterIndex.append(indexPath.item)
                self.pickCountUntilProceed += 1
                self.stagePicked = self.arrStarter[self.arrStarterIndex[0]].stageName ?? ""
                self.stagePickedFromStarter = true
                
                self.btnProceed.backgroundColor = Colors.theme.returnColor()
                self.btnProceed.isEnabled = true
                
                self.updateUI()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    //self.proceedTapped(UIButton())
                    self.proceedBtnTap()
                })
            }
        }
        else {
            cell.lblTitle.text = arrCounterPick[indexPath.row].stageName
            cell.index = indexPath.item
            let tmpArr = arrCounterIndex
            if isAllStageBan {
                cell.imgSelected.image = UIImage(named: "stage_picked")
            }
            else {
                cell.imgSelected.image = UIImage(named: "Check")
            }
            
            if tmpArr.contains(cell.index) {
                cell.imgSelected.isHidden = false
            }
            else {
                cell.imgSelected.isHidden = true
            }
            
            if isRoundHigherThanOne {
                // Stage banned         //By Pranay
                cell.lblTitle.textColor = arrCounterIndexDuplicate.contains(indexPath.row) ? Colors.border.returnColor() : Colors.black.returnColor()
                cell.lblBanned.isHidden = arrCounterIndexDuplicate.contains(indexPath.row) ? false : true
                cell.isUserInteractionEnabled = arrCounterIndexDuplicate.contains(indexPath.row) ? false : true
                
                if isAllStageBan && isRemainStageOne && cell.lblBanned.isHidden {
                    self.isProceedBtnTap = true
                    cell.imgSelected.isHidden = false
                    
                    self.arrCounterIndex.append(indexPath.item)
                    self.pickCountUntilProceed += 1
                    self.stagePicked = self.arrCounterPick[self.arrCounterIndex[0]].stageName ?? ""
                    self.stagePickedFromStarter = false
                    
                    self.btnProceed.backgroundColor = Colors.theme.returnColor()
                    self.btnProceed.isEnabled = true
                    
                    self.updateUI()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        //self.proceedTapped(UIButton())
                        self.proceedBtnTap()
                    })
                }
            }
            else {
                cell.isUserInteractionEnabled = false
                cell.lblTitle.textColor = Colors.border.returnColor()
                cell.lblBanned.isHidden = true
            }
        }
        
        cell.onTapProfile = { [self] index in
            // cvStarter
            if collectionView == cvStarter {
                if arrStarterIndex.contains(index) {
                    if !self.isRemainStageOne {
                        arrStarterIndex.remove(at: arrStarterIndex.firstIndex(of: index)!)
                        
                        if(isRoundHigherThanOne && isAllStageBan){
                            pickCountUntilProceed = 0
                        }
                        
                        if (isRoundHigherThanOne && isAllStageBan == false) {
                            banCountUntilProceed -= 1
                            for i in 0 ..< arrBann.count {
                                if arrBann[i].stageId == arrStarter[index].id {
                                    arrBann.remove(at: i)
                                    break
                                }
                            }
                            
                            /*for j in 0 ..< tempBannedStages.count {
                                if tempBannedStages[j] == arrStarter[index].id {
                                    tempBannedStages.remove(at: j)
                                    break
                                }
                            }   //  */
                        }
                        else {
                            if isAllStageBan {
                                pickCountUntilProceed = 0
                            }
                            else {
                                banCountUntilProceed -= 1
                            }
                            
                            for i in 0 ..< arrBann.count {
                                if arrBann[i].stageId == arrStarter[index].id {
                                    arrBann.remove(at: i)
                                    break
                                }
                            }
                            
                            /*for j in 0 ..< tempBannedStages.count {
                                if tempBannedStages[j] == arrStarter[index].id {
                                    tempBannedStages.remove(at: j)
                                    break
                                }
                            }   //  */
                        }
                        btnProceed.backgroundColor = Colors.border.returnColor()
                        btnProceed.isEnabled = false
                        viewBottom.isHidden = true
                        viewBottomHeightConst.constant = 0
                        lblPlayStage.text = ""
                    }
                    self.isProceedBtnTap = true
                }
                else {
                    if isAllStageBan {
                        if arrStarterIndex.contains(index){
                            arrStarterIndex.remove(at: arrStarterIndex.firstIndex(of: index)!)
                            pickCountUntilProceed = 0
                        }
                        
                        if(pickCountUntilProceed == 0) {
                            arrStarterIndex.append(index)
                            pickCountUntilProceed += 1
                            stagePicked = arrStarter[arrStarterIndex[0]].stageName ?? ""
                            stagePickedFromStarter = true
                            updateUI()
                        }
                        
                        if(pickCountUntilProceed == 1) {
                            btnProceed.backgroundColor = Colors.theme.returnColor()
                            btnProceed.isEnabled = true
                            self.isProceedBtnTap = false
                        }
                        else {
                            btnProceed.backgroundColor = Colors.border.returnColor()
                            btnProceed.isEnabled = false
                            self.isProceedBtnTap = true
                        }
                    }
                    else {
                        //round 2 or greater
                        var arr = BanStage()
                        if isRoundHigherThanOne {
                            //var arr = BanStage()
                            if self.arrBann.count == 0 {
                                arrStarterIndex.append(index)
                                arr.playerId = arrPlayer[myPlayerIndex].playerId
                                arr.stageId = arrStarter[index].id
                                arrBann.append(arr)
                                //tempBannedStages.append(arr.stageId ?? 0)
                                banCountUntilProceed += 1
                            }
                            else {
                                if(banCountUntilProceed < self.totalStageToBan) {
                                    //if already banned by winner then cannot select
                                    if arrStarterIndex.contains(index) {
                                        arrStarterIndex.remove(at: arrStarterIndex.firstIndex(of: index)!)
                                    }
                                    var stageExist : Bool = false
                                    for i in 0 ..< arrBann.count {
                                        if arrStarter[indexPath.row].id == self.arrBann[i].stageId {
                                            stageExist = true
                                            break
                                        }
                                    }
                                    if !stageExist {
                                        arrStarterIndex.append(index)
                                        arr.playerId = arrPlayer[myPlayerIndex].playerId
                                        arr.stageId = arrStarter[index].id
                                        arrBann.append(arr)
                                        //tempBannedStages.append(arr.stageId ?? 0)
                                        banCountUntilProceed += 1
                                    }
                                }
                            }
                            if(banCountUntilProceed == self.totalStageToBan) {
                                btnProceed.backgroundColor = Colors.theme.returnColor()
                                btnProceed.isEnabled = true
                                self.isProceedBtnTap = false
                            }
                            else {
                                btnProceed.backgroundColor = Colors.border.returnColor()
                                btnProceed.isEnabled = false
                                self.isProceedBtnTap = true
                            }
                        }
                        else {
                            // For round 1.
                            //var arr = BanStage()
                            if self.arrBann.count == 0 {
                                arrStarterIndex.append(index)
                                arr.playerId = arrPlayer[myPlayerIndex].playerId
                                arr.stageId = arrStarter[index].id
                                arrBann.append(arr)
                                //tempBannedStages.append(arr.stageId ?? 0)
                                banCountUntilProceed += 1
                            }
                            else {
                                if(arrStarterIndex.count >= 0 && arrStarterIndex.count < self.totalStageToBan) {
                                    //if already banned by winner then cannot select
                                    if arrStarterIndex.contains(index) {
                                        arrStarterIndex.remove(at: arrStarterIndex.firstIndex(of: index)!)
                                    }
                                    var stageExist : Bool = false
                                    for i in 0 ..< arrBann.count {
                                        if arrStarter[indexPath.row].id == self.arrBann[i].stageId {
                                            stageExist = true
                                            break
                                        }
                                    }
                                    if !stageExist {
                                        arrStarterIndex.append(index)
                                        arr.playerId = arrPlayer[myPlayerIndex].playerId
                                        arr.stageId = arrStarter[index].id
                                        arrBann.append(arr)
                                        //tempBannedStages.append(arr.stageId ?? 0)
                                        banCountUntilProceed += 1
                                    }
                                }
                            }
                            if(arrStarterIndex.count == self.totalStageToBan) {
                                btnProceed.backgroundColor = Colors.theme.returnColor()
                                btnProceed.isEnabled = true
                                self.isProceedBtnTap = false
                            }
                            else {
                                btnProceed.backgroundColor = Colors.border.returnColor()
                                btnProceed.isEnabled = false
                                self.isProceedBtnTap = true
                            }
                        }
                    }
                }
            } 
            else {     ///   cvCounterpick
                if arrCounterIndex.contains(index) {
                    if !self.isRemainStageOne {
                        arrCounterIndex.remove(at: arrCounterIndex.firstIndex(of: index)!)
                        
                        if(isAllStageBan){
                            pickCountUntilProceed = 0
                        }
                        else {
                            banCountUntilProceed -= 1
                            for i in 0 ..< arrBann.count {
                                if arrBann[i].stageId == arrCounterPick[index].id {
                                    arrBann.remove(at: i)
                                    break
                                }
                            }
                            
                            /*for j in 0 ..< tempBannedStages.count {
                                if tempBannedStages[j] == arrCounterPick[index].id {
                                    tempBannedStages.remove(at: j)
                                    break
                                }
                            }   //  */
                        }
                        btnProceed.backgroundColor = Colors.border.returnColor()
                        btnProceed.isEnabled = false
                        lblPlayStage.text = ""
                    }
                    self.isProceedBtnTap = false
                }
                else {
                    if isAllStageBan {
                        if arrCounterIndex.contains(index){
                            arrCounterIndex.remove(at: arrCounterIndex.firstIndex(of: index)!)
                            pickCountUntilProceed = 0
                        }
                        if(pickCountUntilProceed == 0){
                            arrCounterIndex.append(index)
                            pickCountUntilProceed += 1
                            stagePicked = arrCounterPick[arrCounterIndex[0]].stageName ?? ""
                            stagePickedFromStarter = false
                            updateUI()
                        }
                        
                        if(pickCountUntilProceed == 1){
                            btnProceed.backgroundColor = Colors.theme.returnColor()
                            btnProceed.isEnabled = true
                            self.isProceedBtnTap = false
                        } else {
                            btnProceed.backgroundColor = Colors.border.returnColor()
                            btnProceed.isEnabled = false
                            self.isProceedBtnTap = true
                        }
                    } else {
                        var arr = BanStage()
                        //var arr = BanStage()
                        if self.arrBann.count == 0 {
                            arrCounterIndex.append(index)
                            arr.playerId = arrPlayer[myPlayerIndex].playerId
                            arr.stageId = arrCounterPick[index].id
                            arrBann.append(arr)
                            //tempBannedStages.append(arr.stageId ?? 0)
                            banCountUntilProceed += 1
                        } 
                        else {
                            if(banCountUntilProceed < self.totalStageToBan) {
                                if arrCounterIndex.contains(index) {
                                    arrCounterIndex.remove(at: arrStarterIndex.firstIndex(of: index)!)
                                }
                                    
                                var stageExist : Bool = false
                                for i in 0 ..< arrBann.count {
                                    if arrCounterPick[indexPath.row].id == self.arrBann[i].stageId {
                                        stageExist = true
                                    }
                                }
                                if !stageExist {
                                    arrCounterIndex.append(index)
                                    arr.playerId = arrPlayer[myPlayerIndex].playerId
                                    arr.stageId = arrCounterPick[index].id
                                    arrBann.append(arr)
                                    //tempBannedStages.append(arr.stageId ?? 0)
                                    banCountUntilProceed += 1
                                }
                            }
                        }
                        if(banCountUntilProceed == self.totalStageToBan) {
                            btnProceed.backgroundColor = Colors.theme.returnColor()
                            btnProceed.isEnabled = true
                            self.isProceedBtnTap = false
                        } else {
                            btnProceed.backgroundColor = Colors.border.returnColor()
                            btnProceed.isEnabled = false
                            self.isProceedBtnTap = true
                        }
                    }
                }
            }
            if !self.isRemainStageOne {
                self.cvStarter.reloadData()
                self.cvCounterpick.reloadData()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvStarter {
            return CGSize(width: ((self.cvStarter.frame.size.width - 24) / 2), height: 50)
        } else {
            return CGSize(width: ((self.cvCounterpick.frame.size.width - 24) / 2), height: 50)
        }
    }
}

extension ArenaStagePickVC {
    
    func declareForfeitTeam() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.declareForfeitTeam()
                }
            }
            return
        }
        
        self.showLoading()
        
        var winnerTeamId = APIManager.sharedManager.match?.homeTeamId ?? 0
        var losserTeamId = APIManager.sharedManager.match?.awayTeamId ?? 0
        
        if  APIManager.sharedManager.user?.id == (APIManager.sharedManager.match?.homeTeamPlayers![0].userId ?? 0) {
            winnerTeamId = APIManager.sharedManager.match?.awayTeamId ?? 0
            losserTeamId = APIManager.sharedManager.match?.homeTeamId ?? 0
        }
        
        let param = [
            "matchId": APIManager.sharedManager.match?.matchId ?? 0,
            "winnerTeamId": winnerTeamId,
            "losserTeamId": losserTeamId,
            "timeZone": APIManager.sharedManager.timezone
        ] as [String : Any]
        
        //self.listner?.remove()
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DECLARE_FORFEIT_TEAM, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.isMatchForfeitByMe = true
                //DispatchQueue.main.async {
                    //self.leagueTabVC!().getTournamentContent()
                //}
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
                //self.setData()
            }
        }
    }
}
