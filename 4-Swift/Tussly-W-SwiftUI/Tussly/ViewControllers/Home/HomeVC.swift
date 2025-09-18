//
//  HomeVC.swift
//  - Home screen which will be visible to User if User is registered within League for specific Game.

//  Tussly
//
//  Created by Jaimesh Patel on 30/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import ShipBookSDK
import CometChatSDK
import PostHog

class HomeVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var cvTeam : UICollectionView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnLeftTeam: UIButton!
    @IBOutlet weak var btnRightTeam: UIButton!
    //@IBOutlet weak var btnLeftTech: UIButton!
    //@IBOutlet weak var btnRightTech: UIButton!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblTech : UILabel!
    @IBOutlet weak var lblMyLeague: UILabel!
    @IBOutlet weak var lblTechnology: UILabel!
    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var viewMyLeagues: UIView!
    @IBOutlet weak var imgMyTeam: UIImageView!
    @IBOutlet weak var imgNoLeague: UIImageView!
    @IBOutlet weak var viewMyTeams: UIView!
    @IBOutlet weak var btnCreateTeam: UIButton!
    @IBOutlet weak var btnJoinTeam: UIButton!
    @IBOutlet weak var scrlView: UIScrollView!
    //@IBOutlet weak var cvTech: UICollectionView!
    @IBOutlet weak var cvLeague: UICollectionView!
    
    @IBOutlet weak var btnSearchTournament: UIButton!
    @IBOutlet weak var btnCreateTournament: UIButton!
    
    
    // MARK: - Variables
    
    var isUpdatedArray = false
    var arrTeams = [Team]()
    var arrLeagues = [League]()
    var arrFinalLeague = [League]()
    var arrFinalTournament = [League]()
    //var didSelectLeague: ((Int)->Void)?
    var didSelectTeam: ((Int)->Void)?
    var didSelectPlayerCard: (()->Void)?
    //var arrTechnology = [[String: String]]()
    var pageControllerTech = TLPageControl()
    var pageControllerTeam = TLPageControl()
    var pageControllerLeague = TLPageControl()
    var tusslyTabVC: (()->TusslyTabVC)?
    
    var didSelectLeague: ((League)->Void)?
    var arrTechnology = [Game]()
    
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PostHogSDK.shared.stopSessionRecording()
        //PostHogSDK.shared.optOut()
        //PostHogSDK.shared.startSessionRecording()
        //PostHogSDK.shared.optIn()
        //PostHogSDK.shared.capture("iOS-Tussly-Events")
        //PostHogSDK.shared.screen("HomeVC", properties: [:])
        
        DispatchQueue.main.async {
            self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.height / 2
            
            self.viewMyLeagues.layer.cornerRadius = 15.0
            self.viewMyTeams.layer.cornerRadius = 15.0
            self.imgMyTeam.layer.cornerRadius = 15.0
            self.imgNoLeague.layer.cornerRadius = 15.0
            self.viewMyLeagues.addShadow(offset: CGSize(width: 3, height: 3), color: Colors.black.returnColor(), radius: 5, opacity: 0.1)
            
            self.cvLeague.dataSource = self
            self.cvLeague.delegate = self
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 0.0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: self.cvLeague.frame.width, height: self.cvLeague.frame.height)
            layout.scrollDirection = .horizontal
            self.cvLeague?.collectionViewLayout = layout
            
//            self.cvTech.dataSource = self
//            self.cvTech.delegate = self
//            let layout1 = UICollectionViewFlowLayout()
//            layout1.minimumInteritemSpacing = 0.0
//            layout1.minimumLineSpacing = 20.0
//            layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            layout1.itemSize = CGSize(width: 120, height: self.cvTech.frame.height)
//            layout1.scrollDirection = .horizontal
//            self.cvTech?.collectionViewLayout = layout1
            
            self.lblTechnology.text = "Create a Tournament"
            
            self.btnSearchTournament.layer.cornerRadius = self.btnSearchTournament.frame.size.height/2
            //print("Convert - \(Utilities.convertTimestamptoDateString(timestamp: 1675229408482))")
        }
        lblTech.isHidden = true
        viewMyLeagues.isHidden = true
        viewMyTeams.isHidden = true
        lblMyLeague.isHidden = true
        cvTeam.isHidden = true
//        cvTech.isHidden = true
        self.btnLeft.isHidden = true
        self.btnRight.isHidden = true
        btnCreateTeam.isHidden = true
        btnJoinTeam.isHidden = true
        btnLeftTeam.isHidden = true
        btnRightTeam.isHidden = true
//        btnLeftTech.isHidden = true
//        btnRightTech.isHidden = true
        
//        getHomeData()
        
        //let device = UIDevice.current.name
        //let iosVersion = UIDevice.current.systemVersion     //device.systemVersion
        //print("Device -> \(UIDevice.modelName)")
        //print("Device -> \(UIDevice.current.name)")
        //print("iOS Version -> \(iosVersion)")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //fatalError("🔥 Manual crash for testing")
        
        lblUserName.text = APIManager.sharedManager.user?.displayName ?? ""
        ivProfile.setImage(imageUrl: APIManager.sharedManager.user?.avatarImage ?? "")
        scrlView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        
        getHomeData()
        getGames()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActiveTusslyTab),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackgroundTusslyTab),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("HomeVC - View will disappear.")
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appDidBecomeActiveTusslyTab() {
        print("HomeVC - App moved to active.")
        if appDelegate.isAutoLogin {
            getHomeData()
        }
    }
    
    @objc func appDidEnterBackgroundTusslyTab() {
        print("HomeVC - App moved to background.")
    }
    
    
    // MARK: - UI Methods
    
    func setCollectionUI()
    {
//        DispatchQueue.main.async {
//            if self.arrTechnology.count == 0 || self.arrTechnology.count == 1 {
//                self.btnRightTech.isHidden = true
//            }
//            else {
//                self.btnRightTech.isHidden = false
//            }
//            self.cvTech.isHidden = false
//            self.cvTech.isPagingEnabled = true
//            self.pageControllerTech.numberOfPages = self.arrTechnology.count
//            cvTech.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
//            self.cvTech.reloadData()
//        }
    }
    
    func setUI()
    {
        if self.arrLeagues.count == 0 || self.arrLeagues.count == 1 {
            self.btnRight.isHidden = true
        } else {
            self.btnRight.isHidden = false
        }
        self.cvLeague.isHidden = false
        
        pageControllerLeague.numberOfPages = arrLeagues.count
        cvLeague.reloadData()
        //cvLeague.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
        setUpCell()
    }
    
    func setUpCell()
    {
        if self.arrTeams.count == 0 || self.arrTeams.count == 1 {
            self.btnRightTeam.isHidden = true
        } else {
            self.btnRightTeam.isHidden = false
        }
        self.cvTeam.isHidden = false
        self.cvTeam.dataSource = self
        self.cvTeam.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvTeam.frame.width, height: cvTeam.frame.height)
        layout.scrollDirection = .horizontal
        cvTeam?.collectionViewLayout = layout
        pageControllerTeam.numberOfPages = arrTeams.count
        cvTeam.reloadData()
        cvTeam.isPagingEnabled = true
        //cvTeam.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: false)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapregisterLeague(_ sender: UIButton)
    {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.registerForLeague
        dialog.message = Messages.registrationPageYourBrowser
        dialog.btnYesText = Messages.ok
        dialog.btnNoText = Messages.cancel
        dialog.tapOK = {
            if let link = URL(string: APIManager.sharedManager.registerLeagueUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link)
                } else {
                    UIApplication.shared.openURL(link)
                }
            }
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//        dialog.modalPresentationStyle = .overCurrentContext
//        dialog.modalTransitionStyle = .crossDissolve
//        dialog.titleText = Messages.myLeagues
//        dialog.message = Messages.notYetRegisterLeagues
//        dialog.btnYesText = Messages.registerNow
//        dialog.btnNoText = Messages.close
//        dialog.tapOK = {
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//            dialog.modalPresentationStyle = .overCurrentContext
//            dialog.modalTransitionStyle = .crossDissolve
//            dialog.titleText = Messages.registerForLeague
//            dialog.message = Messages.registrationPageYourBrowser
//            dialog.btnYesText = Messages.ok
//            dialog.btnNoText = Messages.cancel
//            dialog.tapOK = {
//                if let link = URL(string: APIManager.sharedManager.registerLeagueUrl) {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(link)
//                    } else {
//                        UIApplication.shared.openURL(link)
//                    }
//                }
//            }
//            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//        }
//        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func onTapCreatTeam(_ sender: UIButton)
    {
        if sender.tag == 0 {
            if APIManager.sharedManager.user == nil {
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = Messages.tussly
                dialog.message = Messages.loginTussly
                dialog.tapOK = {
                }
                dialog.btnYesText = Messages.login
                dialog.btnNoText = Messages.close
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            } else {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateTeamVC") as! CreateTeamVC
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        } else if sender.tag == 1 {
            self.tusslyTabVC!().openSearchView(selectedIndex: 2, fromPlayer: false, fromTournaments: false)
        }
    }
    
    @IBAction func onTapPlayerCard(_ sender: UIButton)
    {
        if self.didSelectPlayerCard != nil {
            self.didSelectPlayerCard!()
        }
    }
    
    @IBAction func nextPrevTeam(_ sender: UIButton)
    {
        var contentOffset = CGFloat()
        let collectionBounds = self.cvTeam.bounds
        if sender.tag == 0 {
            if self.pageControllerTeam.currentPage == 1 {
                btnLeftTeam.isHidden = true
                if(arrTeams.count == 1){
                    btnRightTeam.isHidden = true
                } else {
                    btnRightTeam.isHidden = false
                }
            } else {
                btnRightTeam.isHidden = false
                btnLeftTeam.isHidden = false
            }
            contentOffset = CGFloat(floor(self.cvTeam.contentOffset.x - collectionBounds.size.width))
            self.pageControllerTeam.currentPage -= 1
        } else {
            if self.pageControllerTeam.currentPage == arrTeams.count - 2 {
                btnRightTeam.isHidden = true
                if(arrTeams.count == 1){
                    btnLeftTeam.isHidden = true
                } else {
                    btnLeftTeam.isHidden = false
                }
            }else {
                btnRightTeam.isHidden = false
                btnLeftTeam.isHidden = false
            }
            contentOffset = CGFloat(floor(self.cvTeam.contentOffset.x + collectionBounds.size.width))
            self.pageControllerTeam.currentPage += 1
        }
        let frame: CGRect = CGRect(x : contentOffset ,y : self.cvTeam.contentOffset.y ,width : self.cvTeam.frame.width,height : self.cvTeam.frame.height)
        self.cvTeam.scrollRectToVisible(frame, animated: true)
        cvTeam.reloadData()
    }
    
    @IBAction func nextPrevTech(_ sender: UIButton)
    {
//        if sender.tag == 0 {
//            btnRightTech.isHidden = false
//            btnLeftTech.isHidden = true
////            self.cvTech.contentOffset = CGPoint(x: 0, y: 0)
//        }
//        else {
//            btnRightTech.isHidden = true
//            btnLeftTech.isHidden = false
////            self.cvTech.contentOffset = CGPoint(x: self.cvTech.contentSize.width - self.cvTech.frame.size.width, y: 0)
//        }
//        var contentOffset = CGFloat()
//        let collectionBounds = self.cvTech.bounds
//        if sender.tag == 0 {
//            if self.pageControllerTech.currentPage == 1 {
//                btnLeftTech.isHidden = true
//                if(arrTechnology.count == 1){
//                    btnRightTech.isHidden = true
//                } else {
//                    btnRightTech.isHidden = false
//                }
//            } else {
//                btnRightTech.isHidden = false
//                btnLeftTech.isHidden = false
//            }
//            contentOffset = CGFloat(floor(self.cvTech.contentOffset.x - collectionBounds.size.width))
//            self.pageControllerTech.currentPage -= 1
//        } else {
//            if self.pageControllerTech.currentPage == arrTechnology.count - 2 {
//                btnRightTech.isHidden = true
//                if(arrTechnology.count == 1){
//                    btnLeftTech.isHidden = true
//                } else {
//                    btnLeftTech.isHidden = false
//                }
//            }else {
//                btnRightTech.isHidden = false
//                btnLeftTech.isHidden = false
//            }
//            contentOffset = CGFloat(floor(self.cvTech.contentOffset.x + collectionBounds.size.width))
//            self.pageControllerTech.currentPage += 1
//        }
//        let frame: CGRect = CGRect(x : contentOffset ,y : self.cvTech.contentOffset.y ,width : self.cvTech.frame.width,height : self.cvTech.frame.height)
//        self.cvTech.scrollRectToVisible(frame, animated: true)
//        cvTech.reloadData()
    }
    
    @IBAction func nextPrevLeague(_ sender: UIButton)
    {
        var contentOffset = CGFloat()
        let collectionBounds = self.cvLeague.bounds
        if sender.tag == 0 {
            if self.pageControllerLeague.currentPage == 1 {
                btnLeft.isHidden = true
                if(arrLeagues.count == 1){
                    btnRight.isHidden = true
                } else {
                    btnRight.isHidden = false
                }
            } else {
                btnRight.isHidden = false
                btnLeft.isHidden = false
            }
            contentOffset = CGFloat(floor(self.cvLeague.contentOffset.x - collectionBounds.size.width))
            self.pageControllerLeague.currentPage -= 1
        } else {
            if self.pageControllerLeague.currentPage == arrLeagues.count - 2 {
                btnRight.isHidden = true
                if(arrLeagues.count == 1){
                    btnLeft.isHidden = true
                } else {
                    btnLeft.isHidden = false
                }
            }else {
                btnRight.isHidden = false
                btnLeft.isHidden = false
            }
            contentOffset = CGFloat(floor(self.cvLeague.contentOffset.x + collectionBounds.size.width))
            self.pageControllerLeague.currentPage += 1
        }
        let frame: CGRect = CGRect(x : contentOffset ,y : self.cvLeague.contentOffset.y ,width : self.cvLeague.frame.width,height : self.cvLeague.frame.height)
        self.cvLeague.scrollRectToVisible(frame, animated: true)
        cvLeague.reloadData()
    }
    
    @IBAction func btnSearchTournamentTap(_ sender: UIButton)
    {
        self.tusslyTabVC!().openSearchView(selectedIndex: 3, fromPlayer: false, fromTournaments: true)
    }
    
    @IBAction func btnCreateTournamentTap(_ sender: UIButton) {
        self.getCrossLoginToken()
    }
    
    
    // MARK: APIs
    
    func getHomeData()
    {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getHomeData()
                }
            }
            return
        }
        
        self.tusslyTabVC!().disableTabButtons()
        showLoading()
        
        let param = ["timeZone": APIManager.sharedManager.timezone
                     //"deviceName": UIDevice.modelName,
                     //"deviceOS": "iOS",
                     //"osVersion": UIDevice.current.systemVersion
        ] as [String: Any]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_HOME_DATA, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                self.tusslyTabVC!().enableTabButtons()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.guideLine = (response?.result?.isShowGuidline)!
                    APIManager.sharedManager.registerLeagueUrl = (response?.result?.registerLeagueUrl)!
                    APIManager.sharedManager.activeLeagueUrl = (response?.result?.activeLeagueUrl)!
                    APIManager.sharedManager.pastLeagueUrl = (response?.result?.pastLeagueUrl)!
                    
                    //let shipBookKey : ShipBookKeys? = (response?.result?.shipBookKeys)!
                    //ShipBook.start(appId:(shipBookKey?.ios?.appId)!, appKey:(shipBookKey?.ios?.appKey)!)
                    
                    APIManager.sharedManager.appVersion = response?.result?.version
                    if APIManager.sharedManager.GET_HOME_DATA.contains("api.tussly.com") {
                        self.showVersionPopup()
                    }
                    
                    if (response?.result?.isFcmTokenExpire ?? 0) == 1 {
                        self.updateFCMToken()
                    }
                    
                    self.arrTeams = (response?.result?.teams)!
                    self.arrLeagues = (response?.result?.leagues)!
                    
                    //self.btnRightTech.isHidden = false
                    self.lblMyLeague.isHidden = false
                    self.lblTech.isHidden = false
                    if self.arrTeams.count == 0 {
                        //No teams registered yet
                        self.viewMyTeams.isHidden = false
                        self.btnCreateTeam.isHidden = false
                        self.btnJoinTeam.isHidden = false
                        self.view!.tusslyTabVC.teamConsoleId = -1
                    }
                    else {
                        // By Pranay
                        self.viewMyTeams.isHidden = true
                        self.btnCreateTeam.isHidden = true
                        self.btnJoinTeam.isHidden = true
                        // .
                        //self.view!.tusslyTabVC.teamConsoleId = self.arrTeams[0].id
                        self.view!.tusslyTabVC.teamConsoleId = self.arrTeams[0].id ?? 0
                        self.view!.tusslyTabVC.arrTotalTeams = self.arrTeams
                    }
                    if self.arrLeagues.count == 0 {
                        //we have no league
                        self.viewMyLeagues.isHidden = false
                        self.view!.tusslyTabVC.leagueConsoleId = -1
                        self.view!.tusslyTabVC.tournamentConsoleId = -1
                        self.view!.tusslyTabVC.totalLeagues.removeAll()
                        self.view!.tusslyTabVC.totalTournaments.removeAll()
                        self.setUpCell()
                    }
                    else {
                        self.viewMyLeagues.isHidden = true
                        
                        self.arrFinalLeague.removeAll()
                        self.arrFinalTournament.removeAll()
                        for i in 0 ..< self.arrLeagues.count {
                            if self.arrLeagues[i].type == "League" {
                                self.arrFinalLeague.append(self.arrLeagues[i])
                                self.view!.tusslyTabVC.leagueConsoleId = (self.arrFinalLeague[0].id)
                            } else {
                                self.arrFinalTournament.append(self.arrLeagues[i])
                                self.view!.tusslyTabVC.tournamentConsoleId = (self.arrFinalTournament[0].id)
                            }
                        }
                        self.view!.tusslyTabVC.totalLeagues = self.arrFinalLeague
                        self.view!.tusslyTabVC.totalTournaments = self.arrFinalTournament
                        self.setUI()
                    }
                    
                    let notificatoinCount = response?.result?.unreadNotificationCnt ?? 0
                    self.tusslyTabVC!().feedbackLink = response?.result?.feedbackUrl ?? "https://tussly.com"
                    DispatchQueue.main.async {
                        if (UserDefaults.standard.value(forKey: UserDefaultType.notificationCount) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.notificationCount)! is Int {
                            UserDefaults.standard.set(notificatoinCount, forKey: UserDefaultType.notificationCount)
                            //UIApplication.shared.applicationIconBadgeNumber = notificatoinCount
                            self.view!.tusslyTabVC.notificationCount()
                        }
                        
                        if APIManager.sharedManager.isNotificationClick {
                            APIManager.sharedManager.isNotificationClick = false
                            if APIManager.sharedManager.isNextMatch {
                                APIManager.sharedManager.isNextMatch = false
                                self.view!.tusslyTabVC.isFromSerchPlayerTournament = true
                                self.view!.tusslyTabVC.tournamentDetail = APIManager.sharedManager.tournamentDetail
                                self.view!.tusslyTabVC.isLeagueJoinStatus = true
                                self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[5])
                            }
                            else if APIManager.sharedManager.isPlayerCardOpen {
                                self.tusslyTabVC!().selectedIndex = 8
                                self.tusslyTabVC!().buttons[8].isSelected = true
                                self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[8])
                            }
                            else if APIManager.sharedManager.isForChatNotification {
                                //APIManager.sharedManager.isForChatNotification = false
                                //self.tusslyTabVC!().selectedIndex = 2
                                self.tusslyTabVC!().buttons[2].isSelected = true
                                self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[2])
                            }
                            else {
                                self.tusslyTabVC!().selectedIndex = 3
                                self.tusslyTabVC!().buttons[3].isSelected = true
                                self.tusslyTabVC!().didPressTab(self.tusslyTabVC!().buttons[3])
                            }
                        }
                        
                        self.getChatUnreadCount()
                    }
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getChatUnreadCount() {
        CometChat.getUnreadMessageCountForAllUsers { dictUnreadCount in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intUsersUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
        
        CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount /*<#[String : Any]#>*/ in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intGroupsUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
    }
    
    func getGames()
    {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGames()
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: ["isHomePage": 1]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.arrTechnology = (response?.result?.games)!
                APIManager.sharedManager.baseUrl = response?.result?.baseUrl ?? BASE_HTTP_URL
                //self.setCollectionUI()
            }
        }
    }
    
    func getCrossLoginToken()
    {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getCrossLoginToken()
                }
                return
            }
        }
        
        let param = ["type": "tournament-create"
        ] as [String: Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CROSS_PLATFORM_TOKEN, parameters: param) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                if response?.status == 1 {
                    guard let url = URL(string: response?.result?.crossLoginUrl ?? "") else {
                        return
                    }
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// MARK:- UICollectionViewDelegate
extension HomeVC : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
//        if collectionView == cvTech {
//            return arrTechnology.count
//        } else
        if collectionView == cvLeague {
            return arrLeagues.count
        }
        return arrTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
//        if collectionView == cvTech {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTechCell", for: indexPath) as! MyTeamCell
//            
//            cell.lblTeamName.text = arrTechnology[indexPath.item].gameFullName ?? ""
//            cell.ivLogo.setImage(imageUrl: arrTechnology[indexPath.item].gameLogo ?? "")
//            
//            if arrTechnology[indexPath.item].status ?? 23 == 23 {
//                cell.lblTeamName.textColor = Colors.border.returnColor()
//                cell.ivLogo.alpha = 0.5
//            } else {
//                cell.lblTeamName.textColor = Colors.black.returnColor()
//                cell.ivLogo.alpha = 1
//            }
//            
//            return cell
//        } else
        if collectionView == cvLeague {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyLeagueCell", for: indexPath) as! MyLeagueCell
            
            if (arrLeagues[indexPath.item].leagueMatch?.id == 0) {
                cell.viewNextLiveleague.isHidden = true
                cell.lblTBD.isHidden = false
                cell.lblTBD.text = ""
            } else if (arrLeagues[indexPath.item].leagueMatch?.status == 7) {
                cell.viewNextLiveleague.isHidden = true
                cell.lblTBD.isHidden = false
                cell.lblTBD.text = "Waiting for Result"
            } else {
                cell.viewNextLiveleague.isHidden = false
                cell.lblTBD.isHidden = true
                
                if (arrLeagues[indexPath.item].leagueMatch?.matchTime ?? "") == "TBD" {
                    cell.lblMatchTime.isHidden = true
                } else {
                    cell.lblMatchTime.isHidden = false
                }
                
                cell.lblMatchDate.text = arrLeagues[indexPath.item].leagueMatch?.matchDate ?? ""
                cell.lblMatchTime.text = "\(arrLeagues[indexPath.item].leagueMatch?.matchTime ?? "") \(arrLeagues[indexPath.item].leagueMatch?.stationName ?? "")"  //  By Pranay - add station name
                //let oppTeam = arrLeagues[indexPath.item].leagueMatch?.teamName == "" ? arrLeagues[indexPath.item].leagueMatch?.winnerLabel : arrLeagues[indexPath.item].leagueMatch?.teamName //  Comment by Pranay.
                // By Pranay
                let oppTeam = (arrLeagues[indexPath.item].leagueMatch?.displayName ?? "") == "" ? arrLeagues[indexPath.item].leagueMatch?.winnerLabel : (arrLeagues[indexPath.item].leagueMatch?.displayName ?? "")
                // .
                cell.lblTeamName.text = "VS \(oppTeam ?? "")"
                
                if (arrLeagues[indexPath.item].leagueMatch?.status == 5) {
                    cell.lblLeagueStatus.text = "Next Game"
                } else if (arrLeagues[indexPath.item].leagueMatch?.status == 6) {
                    cell.lblLeagueStatus.text = "Live"
                }
                
                cell.imgGameLogo.setImage(imageUrl: arrLeagues[indexPath.item].leagueMatch?.teamLogo ?? "")
            }
            
            if arrLeagues[indexPath.item].bannerImage == "" {
                cell.imgLogo.setImage(imageUrl: arrLeagues[indexPath.item].gameImage ?? "")
            } else {
                cell.imgLogo.setImage(imageUrl: arrLeagues[indexPath.item].bannerImage ?? "")
            }
            if arrLeagues[indexPath.item].profileImage == "" {
                cell.ImgTournament.setImage(imageUrl: arrLeagues[indexPath.item].gameImage ?? "")
            } else {
                cell.ImgTournament.setImage(imageUrl: arrLeagues[indexPath.item].profileImage ?? "")
            }
            cell.lblTournamentName.text = arrLeagues[indexPath.item].leagueName ?? ""
            cell.lblTournament.text = arrLeagues[indexPath.item].type ?? ""
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTeamCell", for: indexPath) as! MyTeamCell
            cell.lblTeamName.text = arrTeams[indexPath.row].teamName
            cell.ivLogo.setImage(imageUrl: arrTeams[indexPath.row].teamLogo ?? "")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == cvTeam
        {
            if self.didSelectTeam != nil
            {
                //self.didSelectTeam!(arrTeams[indexPath.row].id)
                self.didSelectTeam!(arrTeams[indexPath.row].id ?? 0)
            }
        }
        else if collectionView == cvLeague
        {
            if self.didSelectLeague != nil
            {
                if arrLeagues[indexPath.item].leagueMatch?.status != 7
                {
                    self.didSelectLeague!(arrLeagues[indexPath.row])
                }
            }
        }
//        else
//        {
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ArenaInfoVC") as! ArenaInfoVC
//            var isOpenDialog : Bool = true
//            switch arrTechnology[indexPath.item].id ?? 0
//            {
//            case 11:
//                ///SSBU
//                dialog.currentPage = 0
//                dialog.infoType = 0
//                break
//            case 13:
//                ///SSBM
//                dialog.currentPage = 0
//                dialog.infoType = 3
//                break
//            case 16:
//                ///NASB2
//                dialog.currentPage = 0
//                dialog.infoType = 6
//                break
//            case 14:
//                ///Tekken
//                dialog.currentPage = 0
//                dialog.infoType = 4
//                break
//            case 15:
//                ///VF5
//                dialog.currentPage = 0
//                dialog.infoType = 5
//                break
//            default:
//                isOpenDialog = false
//                break
//            }
//            
//            if isOpenDialog && arrTechnology[indexPath.item].status ?? 23 != 23
//            {
//                dialog.modalPresentationStyle = .overCurrentContext
//                dialog.modalTransitionStyle = .crossDissolve
//                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {   }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == cvTeam {
            return CGSize(width: cvTeam.frame.width, height: cvTeam.frame.height)
        }
//        else if(collectionView == cvTech) {
//            return CGSize(width: 120, height: cvTech.frame.height)
//        }
        else {
            return CGSize(width: cvLeague.frame.width, height: cvLeague.frame.height)
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//        if scrollView == cvTech {
//            if scrollView.contentOffset.x > 0 {
//                btnRightTech.isHidden = true
//                btnLeftTech.isHidden = false
//            } else {
//                btnRightTech.isHidden = false
//                btnLeftTech.isHidden = true
//            }
//        }
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
//        if(scrollView == cvTech){
//            pageControllerTech.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//            if self.pageControllerTech.currentPage == arrTechnology.count - 1 {
//                btnRightTech.isHidden = true
//                if(arrTechnology.count == 1){
//                    btnLeftTech.isHidden = true
//                } else {
//                    btnLeftTech.isHidden = false
//                }
//            }else if(self.pageControllerTech.currentPage == 0){
//                btnRightTech.isHidden = false
//                btnLeftTech.isHidden = true
//            } else {
//                btnRightTech.isHidden = false
//                btnLeftTech.isHidden = false
//            }
//        }
        if(scrollView == cvTeam){
            pageControllerTeam.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            if self.pageControllerTeam.currentPage == arrTeams.count - 1 {
                btnRightTeam.isHidden = true
                if(arrTeams.count == 1){
                    btnLeftTeam.isHidden = true
                } else {
                    btnLeftTeam.isHidden = false
                }
            }else if(self.pageControllerTeam.currentPage == 0){ 
                btnRightTeam.isHidden = false
                btnLeftTeam.isHidden = true
            } else {
                btnRightTeam.isHidden = false
                btnLeftTeam.isHidden = false
            }
        }
        if(scrollView == cvLeague){
            pageControllerLeague.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            if self.pageControllerLeague.currentPage == arrLeagues.count - 1 {
                btnRight.isHidden = true
                if(arrLeagues.count == 1){
                    btnLeft.isHidden = true
                } else {
                    btnLeft.isHidden = false
                }
            }else if(self.pageControllerLeague.currentPage == 0){
                btnRight.isHidden = false
                btnLeft.isHidden = true
            } else {
                btnRight.isHidden = false
                btnLeft.isHidden = false
            }
        }
    }
}


// MARK: - Show Version Popup
extension HomeVC
{
    func showVersionPopup()
    {
        DispatchQueue.main.async
        {
            //Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0"
            //Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
            
            var isAppUpdate : Bool = false
            let appVersion : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let apiVersion : String = APIManager.sharedManager.appVersion?.ios ?? ""
            print("currentVersion - \(appVersion) == storeVersion - \(apiVersion)")
            //UserDefaults.standard.set("1.0", forKey: UserDefaultType.updateVersion)
            
            if (UserDefaults.standard.value(forKey: UserDefaultType.updateVersion) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! is String
            {
                //UserDefaults.standard.set(appVersion, forKey: UserDefaultType.updateVersion)
            }
            else
            {
                UserDefaults.standard.set(appVersion, forKey: UserDefaultType.updateVersion)
                UserDefaults.standard.set(false , forKey: "isSkip")
            }
            
            if appVersion.compare(UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! as! String, options: .numeric) == .orderedDescending
            {
                UserDefaults.standard.set(appVersion, forKey: UserDefaultType.updateVersion)
            }
            
            if (UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! as! String == apiVersion) && (UserDefaults.standard.value(forKey: "isSkip")! as! Bool == true)
            {
                isAppUpdate = false
            }
            else if (UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! as! String == apiVersion) && (UserDefaults.standard.value(forKey: "isSkip")! as! Bool == false)
            {
                isAppUpdate = false
            }
            else if (apiVersion.compare(UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! as! String, options: .numeric) == .orderedDescending) && (UserDefaults.standard.value(forKey: "isSkip")! as! Bool == true)
            {
                UserDefaults.standard.set(false , forKey: "isSkip")
                isAppUpdate = true
            }
            else if (apiVersion.compare(UserDefaults.standard.value(forKey: UserDefaultType.updateVersion)! as! String, options: .numeric) == .orderedDescending) && (UserDefaults.standard.value(forKey: "isSkip")! as! Bool == false)
            {
                isAppUpdate = true
            }
            
            if isAppUpdate && (UserDefaults.standard.value(forKey: "isSkip")! as! Bool == false)
            {
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = Messages.updateTitle
                dialog.message = Messages.updateMsg
                dialog.isForVersionPopup = true
                dialog.btnYesText = Messages.updateBtnTitle
                dialog.tapOK = {
                    //"itms-apps://itunes.apple.com/app/id1613878817"
                    //"https://apps.apple.com/us/app/tussly/id1613878817"
                    if let url = URL(string: APIManager.sharedManager.appVersion?.iosNavigationUrl ?? "itms-apps://itunes.apple.com/app/id1613878817")
                    {
                        UIApplication.shared.open(url)
                    }
                }
                if APIManager.sharedManager.appVersion?.iosForceUpdate ?? "" == "0"
                {
                    dialog.btnNoText = "Skip"
                    dialog.tapCancel = {
                        UserDefaults.standard.set(true , forKey: "isSkip")
                        UserDefaults.standard.set(apiVersion, forKey: UserDefaultType.updateVersion)
                    }
                }
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }
        }
    }
    
    func updateFCMToken() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGames()
                }
                return
            }
        }
        
        let param = [
            "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
            "platform": AppInfo.Platform.returnAppInfo(),
            "deviceId": AppInfo.DeviceId.returnAppInfo(),
            "deviceName": UIDevice.modelName,
            "deviceOS": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ] as [String : Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.UPDATE_FCM_TOKEN, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                print("FCM Token Updated Successfully...")
            }
        }
    }
}
