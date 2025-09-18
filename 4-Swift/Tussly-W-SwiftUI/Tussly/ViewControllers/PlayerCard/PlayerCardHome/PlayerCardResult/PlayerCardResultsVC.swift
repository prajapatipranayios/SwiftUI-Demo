//
//  TeamResultsVC.swift
//  - Contains information related to results of different Teams and its position

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class PlayerCardResultsVC: UIViewController {

    // MARK: - Variables
    var selectedSection = -1
    var rowHeaders: [String]!
    var rowFilter: [String]!
    var playerResultData: [[String: Any]]!
    var getAllGameData = [Game]()
    var teamDetailData: Team?
    var selectedGameId = -1
    var selectedGame = [Game]()
    var selectedType = "Tournament" //"League"
    var expandedIndex = -1
    let contentCellIdentifier = "ContentCollectionViewCell"
    var arrFilterValue: [[String: [String: String]]]!
    var selectedBase = ""
    var baseFilterIndex = 0
    var isBaseSelected = false
    var yMatrix = -1
    var xMatrix = -1
    var isAlternateSelected = false
    var charContentArr = [Characters]()
    var oppCharContentArr = [Characters]()
    var stageContentArr = [Stages]()
    var total : [String: Any]!
    var resultAverage = ResultAverage()
    var filterResult = [FilterResult]()
    var selectedStageId = ""
    var selectedCharId = ""
    var selectedOppCharId = ""
    var hasMore = -1
    var pageNumber = 1
    
    // 231 - By Pranay
    var intIdFromSearch : Int = 0
    // 231 .
    
    // MARK: - Controls
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var ivGameLogo: UIImageView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblLeaugeName: UILabel!
    @IBOutlet weak var viewGameSelection : UIView!
    @IBOutlet weak var viewCharacter : UIView!
    @IBOutlet weak var lblCharacterName : UILabel!
    @IBOutlet weak var imgCharacter : UIImageView!
    @IBOutlet weak var viewStage : UIView!
    @IBOutlet weak var lblStageName : UILabel!
    @IBOutlet weak var imgStage : UIImageView!
    @IBOutlet weak var viewOpposingCharacter : UIView!
    @IBOutlet weak var lblpposingCharacterName : UILabel!
    @IBOutlet weak var imgOpposingCharacter : UIImageView!
    @IBOutlet weak var viewTournament : UIView!
    @IBOutlet weak var lblTournamentName : UILabel!
    @IBOutlet weak var imgTournament : UIImageView!
    @IBOutlet weak var viewResultDetail : UIView!
    @IBOutlet weak var btnBackToResult : UIButton!
    @IBOutlet weak var btnReset : UIButton!
    @IBOutlet weak var btnApply : UIButton!
    @IBOutlet weak var btnSortViewDismiss : UIButton!
    @IBOutlet weak var lblAgainstFilter1 : UILabel!
    @IBOutlet weak var imgPlusAgainstFilter1 : UIImageView!
    @IBOutlet weak var cvPlayers: UICollectionView!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblBaseFilter : UILabel!
    @IBOutlet weak var imgBaseFilter : UIImageView!
    @IBOutlet weak var lblBaseRWRL : UILabel!
    @IBOutlet weak var lblBaseStock : UILabel!
    @IBOutlet weak var lblBaseRW : UILabel!
    @IBOutlet weak var btnBaseSort : UIButton!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var viewDetailHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cvFilterHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cvFilter: UICollectionView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewSort: UIView!
    @IBOutlet weak var lblMyRWRL : UILabel!
    @IBOutlet weak var lblMyStock : UILabel!
    @IBOutlet weak var lblMyWL : UILabel!
    @IBOutlet weak var lblTypeHeading : UILabel!
    @IBOutlet weak var lblGameHeading : UILabel!
    @IBOutlet weak var btnSelectGame : UIButton!
    @IBOutlet weak var imgLeagueType : UIImageView!
    @IBOutlet weak var cvFilterGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvFilterGridLayout.stickyRowsCount = 1
            cvFilterGridLayout.stickyColumnsCount = 1
        }
    }
    @IBOutlet weak var gridLayoutResultCV: StickyGridCollectionViewLayout! {
        didSet {
            gridLayoutResultCV.stickyRowsCount = 1
            gridLayoutResultCV.stickyColumnsCount = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.showAnimation()
        
        setUI()
        
        cvPlayers.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ContentCollectionViewCell")
        
        cvPlayers.register(UINib(nibName: "ImgCVCell", bundle: nil),forCellWithReuseIdentifier: "ImgCVCell")
        
         cvPlayers.register(UINib(nibName: "PlayerCVCenterCell", bundle: nil),forCellWithReuseIdentifier: "PlayerCVCenterCell")
        cvPlayers.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        cvPlayers.register(UINib(nibName: "ContentWithBlackBackgroundCell", bundle: nil), forCellWithReuseIdentifier: "ContentWithBlackBackgroundCell")
        
        cvFilter.register(UINib(nibName: "FilterCharacterImageCell", bundle: nil), forCellWithReuseIdentifier: "FilterCharacterImageCell")
        cvFilter.register(UINib(nibName: "AddCharacterCell", bundle: nil), forCellWithReuseIdentifier: "AddCharacterCell")
        cvFilter.register(UINib(nibName: "FilterResultCell", bundle: nil), forCellWithReuseIdentifier: "FilterResultCell")
        cvFilter.reloadData()
        
        rowFilter = ["Stage", "R1", "R2", "R3"] // Y
        arrFilterValue = [ // X
            [
                "R1": ["RW-RL": "55-60",
                    "RW":"80%",
                    "Stock": "+120"],
                "R2": ["RW-RL": "25-30",
                    "RW":"80%",
                    "Stock": "+130"],
                "R3": ["RW-RL": "33-44",
                    "RW":"80%",
                    "Stock": "+140"],
                
            ], [
                "R1": ["RW-RL": "65-70",
                    "RW":"90%",
                    "Stock": "+220"],
                "R2": ["RW-RL": "31-33",
                    "RW":"80%",
                    "Stock": "+30"],
                "R3": ["RW-RL": "98-99",
                    "RW":"80%",
                    "Stock": "+80"],
            ], [
                
                "R1": ["RW-RL": "10-20",
                    "RW":"30%",
                    "Stock": "+50"],
                "R2": ["RW-RL": "77-79",
                    "RW":"60%",
                    "Stock": "+50"],
                "R3": ["RW-RL": "43-56",
                    "RW":"10%",
                    "Stock": "+56"],
            ],
        ]
        
        setbtnRight()
        getGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UI Methods
    func setUI() {
        btnSortViewDismiss.isHidden = true
        imgCharacter.layer.cornerRadius = imgCharacter.frame.size.height/2
        imgStage.layer.cornerRadius = imgStage.frame.size.height/2
        imgOpposingCharacter.layer.cornerRadius = imgOpposingCharacter.frame.size.height/2
        viewCharacter.layer.cornerRadius = viewCharacter.frame.size.height/2
        self.viewCharacter.layer.borderColor = UIColor.lightGray.cgColor
        self.viewCharacter.layer.borderWidth = 1
        viewStage.layer.cornerRadius = viewStage.frame.size.height/2
        self.viewStage.layer.borderColor = UIColor.lightGray.cgColor
        self.viewStage.layer.borderWidth = 1
        viewOpposingCharacter.layer.cornerRadius = viewOpposingCharacter.frame.size.height/2
        self.viewOpposingCharacter.layer.borderColor = UIColor.lightGray.cgColor
        self.viewOpposingCharacter.layer.borderWidth = 1
        viewTournament.layer.cornerRadius = viewTournament.frame.size.height/2
        self.viewTournament.layer.borderColor = UIColor.lightGray.cgColor
        self.viewTournament.layer.borderWidth = 1
        btnReset.layer.cornerRadius = 5
        btnApply.layer.cornerRadius = 5
        imgPlusAgainstFilter1.setImageColor(color: Colors.theme.returnColor())
        viewSort.isHidden = true
        viewSort.addShadow(offset: CGSize(width: 0.0, height: 4.0), color: UIColor.black, radius: 5, opacity: 0.2)
        self.viewSort.layer.cornerRadius = 5
        
        // By Pranay  comment code
        ////Beta 1- disable option
        //btnReset.backgroundColor = Colors.disableButton.returnColor()
        //btnApply.backgroundColor = Colors.disableButton.returnColor()
        //viewTournament.backgroundColor = Colors.disableButton.returnColor()
        //viewOpposingCharacter.backgroundColor = Colors.disableButton.returnColor()
        //viewStage.backgroundColor = Colors.disableButton.returnColor()
        //viewCharacter.backgroundColor = Colors.disableButton.returnColor()
        //.
        
        cvPlayers.delegate = self
        cvPlayers.dataSource = self
        cvFilter.delegate = self
        cvFilter.dataSource = self
        viewDetailHeightConst.constant = 1280
        
        btnBackToResult.isHidden = true
        scrollview.isHidden = true
        
        //beta 1 ////hide league option and set tournament as default
        imgLeagueType.image =  UIImage(named: "Tournament") 
        lblLeaugeName.text = "Tournament"
    }
    
//    func showAnimation() {
//        ivGameLogo.showAnimatedSkeleton()
//        lblTeamName.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivGameLogo.hideSkeleton()
//        lblTeamName.hideSkeleton()
//    }
    
    func showFilterView() {
        cvPlayers.isHidden = true
        scrollview.isHidden = false
        btnBackToResult.isHidden = false
        lblGameHeading.isHidden = true
        lblTeamName.isHidden = true
        ivGameLogo.isHidden = true
        btnSelectGame.isHidden = true
        lblTypeHeading.text = "Select Game"
        lblLeaugeName.text = lblTeamName.text
        imgLeagueType.setImage(imageUrl: self.selectedGame[0].gameLogo ?? "")
    }
    
    func backToResult() {
        cvPlayers.isHidden = false
        scrollview.isHidden = true
        btnBackToResult.isHidden = true
        lblGameHeading.isHidden = false
        lblTeamName.isHidden = false
        ivGameLogo.isHidden = false
        btnSelectGame.isHidden = false
        lblTypeHeading.text = "Select Type"
        lblLeaugeName.text = self.selectedType
        imgLeagueType.image = UIImage(named: self.selectedType)
    }
    
    func setbtnRight() {
        if self.view.frame.size.width >= self.cvPlayers.collectionViewLayout.collectionViewContentSize.width {
            self.btnRight.isHidden = true
        } else {
            self.btnRight.isHidden = false
        }
        
        if self.cvPlayers.collectionViewLayout.collectionViewContentSize.height > self.cvPlayers.frame.size.height - 32 {
            heightBtnRight.constant = self.cvPlayers.frame.size.height - 32
        } else {
            heightBtnRight.constant = self.cvPlayers.collectionViewLayout.collectionViewContentSize.height - 32
        }
    }
    
    func openGameDropDown() {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectItem = { arrSelected in
            self.selectedGame = arrSelected
            self.ivGameLogo.setImage(imageUrl: arrSelected[0].gameLogo ?? "")
            self.lblTeamName.text = arrSelected[0].gameName
            //self.selectedSection = -1
            
            for i in 0 ..< self.getAllGameData.count {
                 arrSelected.map{
                    if $0.id == (self.getAllGameData[i].id)! {
                        self.selectedSection = i

                    }
                }
            }
            
            if self.scrollview.isHidden == false {
                self.imgLeagueType.setImage(imageUrl: arrSelected[0].gameLogo ?? "")
                self.lblLeaugeName.text = arrSelected[0].gameName
            }
            
            self.selectedGameId = arrSelected[0].id!
            self.pageNumber = 1
            self.getTeamResult(gameId: arrSelected[0].id!, type: self.selectedType)
        }
        objVC.arrGameList = getAllGameData
        objVC.arrSelected = self.selectedGame
        objVC.isSingleSelection = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapGame(_ sender: UIButton) {
        openGameDropDown()
    }
    
    @IBAction func onTapSelectType(_ sender: UIButton) {
        if self.scrollview.isHidden {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
            objVC.didSelectType = { type in
                self.imgLeagueType.image =  UIImage(named: type)
                self.lblLeaugeName.text = type
                self.selectedType = type
                self.pageNumber = 1
                self.getTeamResult(gameId: self.selectedGameId, type: type)
            }
            objVC.type = self.selectedType
            objVC.isSelectType = true
            objVC.isSingleSelection = true
            // By Pranay
            //objVC.lblTitle.text = "Select Type"
            // .
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        } else {
            openGameDropDown()
        }
    }
    
    @IBAction func onTapTypeFilter(_ sender: UIButton) {
        ////Beta 1- disable option
        /// By Pranay   Uncomment code
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectType = { type in
            self.lblTournamentName.text = type
            self.imgTournament.image = UIImage(named: "Default")
        }
        objVC.type = self.lblTournamentName.text ?? "All"
        objVC.isSelectType = true
        objVC.isSingleSelection = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        //.
    }
    
    @IBAction func onTapBackToResult(_ sender: UIButton) {
        backToResult()
    }
    
    @IBAction func onTapSort(_ sender: UIButton) {
        viewSort.isHidden = true
        btnSortViewDismiss.isHidden = true
        if(sender.tag == 0){
            btnBaseSort.setTitle("RW-RL", for: .normal)
            lblBaseRWRL.font = Fonts.Semibold.returnFont(size: 15.0)
            lblBaseRW.font = Fonts.Regular.returnFont(size: 12.0)
            lblBaseStock.font = Fonts.Regular.returnFont(size: 12.0)
        } else if(sender.tag == 1){
            btnBaseSort.setTitle("R-Win%", for: .normal)
            lblBaseRW.font = Fonts.Semibold.returnFont(size: 15.0)
            lblBaseRWRL.font = Fonts.Regular.returnFont(size: 12.0)
            lblBaseStock.font = Fonts.Regular.returnFont(size: 12.0)
        } else if(sender.tag == 2) {
            btnBaseSort.setTitle("Stock", for: .normal)
            lblBaseStock.font = Fonts.Semibold.returnFont(size: 15.0)
            lblBaseRW.font = Fonts.Regular.returnFont(size: 12.0)
            lblBaseRWRL.font = Fonts.Regular.returnFont(size: 12.0)
        } 
        cvFilter.reloadData()
    }
    
    @IBAction func onTapOpenSortView(_ sender: UIButton) {
        viewSort.isHidden = false
        btnSortViewDismiss.isHidden = false
    }
    
    @IBAction func onTapReset(_ sender: UIButton) {
        ////Beta 1- disable option
        ///     By Pranay Uncomment code
        viewDetailHeightConst.constant = 1280
        viewResultDetail.isHidden = false
        lblCharacterName.text = "All"
        imgCharacter.image = UIImage(named: "")
        lblStageName.text = "All"
        imgStage.image = UIImage(named: "")
        lblTournamentName.text = "All"
        imgTournament.image = UIImage(named: "")
        lblpposingCharacterName.text = "All"
        imgOpposingCharacter.image = UIImage(named: "")
        isBaseSelected = false
        isAlternateSelected = false
        viewSort.isHidden = true
        btnBaseSort.setTitle("", for: .normal)
        btnSortViewDismiss.isHidden = true
        selectedCharId = ""
        selectedStageId = ""
        selectedOppCharId = ""
        //.
    }
    
    @IBAction func onTapFilter(_ sender: UIButton) {
        ////Beta 1- disable option
        ////By Pranay uncomment code
        if sender.tag == 0 || sender.tag == 1 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CharacterSelectionPopupVC") as! CharacterSelectionPopupVC
            dialog.isFromPlayercard = true
            dialog.arrChars = sender.tag == 0 ? self.charContentArr : self.oppCharContentArr
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.tapOk = { filter in
                if(self.isBaseSelected == true && self.baseFilterIndex != 3){
                    self.isAlternateSelected = true
                    if(self.baseFilterIndex == 0){
                        if sender.tag == 1 {
                            self.yMatrix = 1
                        } else if(sender.tag != 0 ) {
                            self.xMatrix = 1
                        }
                    } else if(self.baseFilterIndex == 1){
                        if(sender.tag == 0){
                            self.xMatrix = 1
                        } else if sender.tag != 1 {
                            self.yMatrix = 1
                        }
                    } else if(self.baseFilterIndex == 2){
                        if sender.tag == 0 {
                            self.xMatrix = 0
                        } else if sender.tag != 2 {
                            self.yMatrix = 0
                        }
                    }
                }


                    let array : [[Characters]] = filter[0] as! [[Characters]]
                    if(sender.tag == 0){
                        self.lblCharacterName.text = array[filter[1] as! Int][filter[2] as! Int].name
                        self.imgCharacter.setImage(imageUrl: array[filter[1] as! Int][filter[2] as! Int].imagePath ?? "")
                        self.selectedCharId = "\(array[filter[1] as! Int][filter[2] as! Int].id!)"
                    } else if(sender.tag == 1){
                        self.lblpposingCharacterName.text = array[filter[1] as! Int][filter[2] as! Int].name
                        self.imgOpposingCharacter.setImage(imageUrl: array[filter[1] as! Int][filter[2] as! Int].imagePath ?? "")
                        self.selectedOppCharId = "\(array[filter[1] as! Int][filter[2] as! Int].id!)"
                    }

                if(self.isBaseSelected == false){
                    self.isBaseSelected = true
                    self.baseFilterIndex = sender.tag
                    self.selectedBase = "hellooo"
                }
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        } else if sender.tag == 2 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
            dialog.arrStage = self.stageContentArr
            dialog.isFromPlayerCard = true
            dialog.header = "Select Stage"
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.tapForFilter = { index in
                self.lblStageName.text = self.stageContentArr[index].name
                self.imgStage.setImage(imageUrl: self.stageContentArr[index].imagePath ?? "")
                self.selectedStageId = "\(self.stageContentArr[index].id!)"
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
        //.
    }
    
    @IBAction func onTapApply(_ sender: UIButton) {
        ////Beta 1- disable option
        self.getFilterData()        // By Pranay  uncomment code
    }
    
    // MARK: - Webservices
    func getGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGame()
                }
            }
            return
        }
        
        /// 232 - By Pranay
        let params = ["otherUserId": intIdFromSearch]    //   By Pranay - added param
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYERCARD_GAME, parameters: params) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.getAllGameData = (response?.result?.games)!
                if self.getAllGameData.count > 0 {
                    DispatchQueue.main.async {
                        self.lblError.isHidden = true
                        self.viewGameSelection.isHidden = false
//                        self.hideAnimation()
                        self.getAllGameData.insert(self.getAllGameData[0], at: 1)
                        
                        self.getAllGameData[0].id = 0
                        self.getAllGameData[0].gameName = "All"
                        self.getAllGameData[0].gameLogo = ""
                        
                        self.ivGameLogo.setImage(imageUrl: self.getAllGameData[0].gameLogo ?? "")
                        self.lblTeamName.text = self.getAllGameData[0].gameName
                        self.selectedSection = 0
                        self.selectedGameId = self.getAllGameData[0].id!
                        self.selectedGame = [self.getAllGameData[0]]
                        self.getTeamResult(gameId: self.getAllGameData[0].id!, type: self.selectedType)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.viewGameSelection.isHidden = true
//                    self.hideAnimation()
                    self.cvPlayers.isHidden = true
                    self.lblError.isHidden = false
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getTeamResult(gameId: Int, type: String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamResult(gameId: gameId, type:type)
                }
            }
            return
        }
        
        /// 232 - By Pranay
        /// ["gameId":gameId, "type": type, "page": self.pageNumber, "timeZone" : APIManager.sharedManager.timezone]
        let params = ["gameId":gameId, "type": type, "page": self.pageNumber, "timeZone" : APIManager.sharedManager.timezone, "otherUserId": intIdFromSearch] as [String : Any]    //   By Pranay - added param
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_RESULT, parameters: params) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.playerResultData?.removeAll()
                DispatchQueue.main.async {
                    self.lblError.isHidden = true
                    self.cvPlayers.isHidden = false
                    self.expandedIndex = -1
                    //self.rowHeaders = (response?.result?.resultHeader)!
                    //let result = (response?.result?.playerResult)!
                    //self.playerResultData = result["result"] as? [[String : Any]]
//                    if (response?.result?.average)!.count > 0 {
//                        self.playerResultData.append((response?.result?.average)!)
//                    }
                    
                    let playerR = (response?.result?.playerResult)!
                    self.playerResultData = playerR["result"] as? [[String : Any]]
                    self.rowHeaders = playerR["resultHeader"] as? [String]
                    self.hasMore = (response?.result?.hasMore)!
                    self.total = (response?.result?.careerTotal)!
                    if self.playerResultData.count > 0 {
                        self.playerResultData.append((response?.result?.careerTotal)!)
                    }
                    
                    if (self.playerResultData.count) > 0 {
                        self.pageNumber += 1
                    }
                    
                    if self.scrollview.isHidden == false {
                        if (self.playerResultData.count) > 0 {
                            self.onTapReset(self.btnReset)
                            self.showFilterView()
                        } else {
                            self.backToResult()
                        }
                    }
                    
                    self.cvPlayers.reloadData()
                    DispatchQueue.main.async {
                        self.setbtnRight()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.playerResultData = [[String: Any]]()
                    self.rowHeaders = [String]()
                    self.cvPlayers.reloadData()
                    self.cvPlayers.isHidden = true
                    self.lblError.isHidden = false
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getContent() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getContent()
                }
            }
            return
        }
        
        showLoading()
        
        /// 232 - By Pranay
        let params = ["otherUserId": intIdFromSearch]    //   By Pranay - added param
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_CARD_FILTER, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.showFilterView()
                    self.lblMyRWRL.text = self.total["RW-RL"] as? String
                    self.lblMyWL.text = self.total["W-L"] as? String
                    self.lblMyStock.text = self.total["totalStocks"] as? String
                    self.charContentArr = (response?.result?.characters)!
                    self.oppCharContentArr = (response?.result?.opposingCharacters)!
                    self.stageContentArr = (response?.result?.stages)!
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getFilterData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFilterData()
                }
            }
            return
        }
        
        let sortType : String = btnBaseSort.title(for: .normal) ?? ""
        
        /// 232 - By Pranay
        /// ["characterId" : selectedCharId,"stageId" : selectedStageId,"oppositeCharacterId" : selectedOppCharId,"type" : (self.lblTournamentName.text == "All" ? "League" : self.lblTournamentName.text) ?? "League","sortBy" : (sortType == "" ? "RW-RL" : sortType)]
        let params = ["characterId" : selectedCharId,"stageId" : selectedStageId,"oppositeCharacterId" : selectedOppCharId,"type" : (self.lblTournamentName.text == "All" ? "Tournament" : self.lblTournamentName.text) ?? "League","sortBy" : (sortType == "" ? "RW-RL" : sortType), "otherUserId": intIdFromSearch] as [String : Any]
        //let params = ["characterId" : selectedCharId,"stageId" : selectedStageId,"oppositeCharacterId" : selectedOppCharId,"type" : (self.lblTournamentName.text == "All" ? "League" : self.lblTournamentName.text) ?? "League","sortBy" : (sortType == "" ? "RW-RL" : sortType)] as [String : Any]
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYERCARD_RESULT_CAREER, parameters: params) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.resultAverage = (response?.result?.resultAverage)!
                self.filterResult = (response?.result?.filterResult)!
                
                DispatchQueue.main.async {
                    self.lblBaseFilter.text = self.resultAverage.characterOrStageInfo?.name
                    self.imgBaseFilter.setImage(imageUrl: self.resultAverage.characterOrStageInfo?.icon ?? "")
                    self.lblBaseRWRL.text = self.resultAverage.wl
                    self.lblBaseRW.text = self.resultAverage.percantage
                    self.lblBaseStock.text = "\(self.resultAverage.stocks ?? 0)"
                    self.lblAgainstFilter1.text = self.resultAverage.resultHeaderTitle
                    
                    self.rowFilter.removeAll()
                    self.arrFilterValue = []
                    
                    self.rowFilter.append(self.filterResult[0].title ?? "")
                    for i in 0 ..< (self.filterResult[0].filterData?.count ?? 0) {
                        self.rowFilter.append("R\(i+1)")
                    }
                    
                    for i in 1 ..< self.filterResult.count {
                        var arr = [String: [String: String]]()
                        for j in 0 ..< (self.filterResult[i].filterData?.count ?? 0) {
                            var arr1 = [String: String]()
                            arr1["RW-RL"] = self.filterResult[i].filterData?[j].rwrl
                            arr1["RW"] = self.filterResult[i].filterData?[j].per
                            arr1["Stock"] = self.filterResult[i].filterData?[j].stock
                            arr["R\(j+1)"] = arr1
                        }
                        self.arrFilterValue.append(arr)
                    }
                    
                    self.cvFilterHeightConst.constant = CGFloat((self.arrFilterValue.count + 1) * 60)
                    self.viewDetailHeightConst.constant = self.cvFilterHeightConst.constant + CGFloat(470)
                    self.viewResultDetail.isHidden = true
                    self.cvFilter.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PlayerCardResultsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == cvFilter {
            return (arrFilterValue?.count ?? 10) + 1
        }
        return ((expandedIndex != -1 ? (playerResultData?.count ?? 0)+1 : playerResultData?.count) ?? 5) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvFilter{
            return rowFilter?.count ?? SKELETON_ROWHEADER_COUNT
        }
        return (rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvFilter {
            if indexPath.section == 0 {
                if(indexPath.row != 0){
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCharacterImageCell",for: indexPath) as! FilterCharacterImageCell

                    if rowFilter != nil && self.filterResult.count > 0 {
//                        cell.hideAnimation()
                        cell.imgCharacter.layer.cornerRadius = cell.imgCharacter.frame.size.height/2
                        cell.imgWidthConst.constant = 30
                        cell.imgHeightConst.constant = 30
                        cell.imgCharacter.setImage(imageUrl: self.filterResult[0].filterData?[indexPath.row - 1].imagePath ?? "")
                    }else {
//                        cell.showAnimation()
                    }
                    
                    if(rowFilter.count < 3){
                        cell.btnRemove.isHidden = true
                    } else {
                        cell.btnRemove.isHidden = false
                    }
                    
                    cell.onTapRemove = {
                        self.rowFilter.remove(at: indexPath.row)
                        self.cvFilter.reloadData()
                    }
                    
                    cell.backgroundColor = UIColor.white
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCharacterCell", for: indexPath) as! AddCharacterCell
                    
                    if rowFilter != nil {
//                        cell.hideAnimation()
                        cell.lblFilterName.text = rowFilter[indexPath.row]
                    }else {
                        cell.lblFilterName.text = ""
//                        cell.showAnimation()
                    }
                    cell.backgroundColor = UIColor.white
                    return cell
                }
            }  else {
                if indexPath.row == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCharacterImageCell", for: indexPath) as! FilterCharacterImageCell
                    
                    if rowFilter != nil && self.filterResult.count > 0 {
//                        cell.hideAnimation()
                        cell.imgCharacter.layer.cornerRadius = 5.0
                        cell.imgWidthConst.constant = 45
                        cell.imgHeightConst.constant = 35
                        cell.imgCharacter.setImage(imageUrl: self.filterResult[indexPath.section].imagePath ?? "")
                        
                        if self.filterResult[indexPath.section].isSelectedColumn == 1 {
                            self.yMatrix = indexPath.section
                        }
//                        if self.filterResult[indexPath.section].filterData?[indexPath.row].isRowSelected {
//                            self.xMatrix = indexPath.section
//                        }
                    }else {
//                        cell.showAnimation()
                    }
                    
                    if(arrFilterValue.count < 2){
                        cell.btnRemove.isHidden = true
                    } else {
                        cell.btnRemove.isHidden = false
                    }
                    
                    cell.onTapRemove = {
                        self.arrFilterValue.remove(at: indexPath.section - 1)
                        self.cvFilterHeightConst.constant = CGFloat((self.arrFilterValue.count + 1) * 60)
                        self.viewDetailHeightConst.constant = self.cvFilterHeightConst.constant + CGFloat(470)
                        self.cvFilter.reloadData()
                    }
                    
                    cell.backgroundColor = UIColor.white
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterResultCell", for: indexPath) as! FilterResultCell
                    if rowFilter != nil {
//                        cell.hideAnimation()
                        let row = arrFilterValue[indexPath.section - 1]
                        let item = row[rowFilter[indexPath.row]]
                        cell.lblRWRL.text = item?["RW-RL"]
                        cell.lblRW.text = item?["RW"]
                        cell.lblStock.text = item?["Stock"]
                        
                        let sortType = btnBaseSort.title(for: .normal)
                        if(sortType == "RW-RL"){
                            cell.lblRWRL.font = Fonts.Semibold.returnFont(size: 15.0)
                            cell.lblRW.font = Fonts.Regular.returnFont(size: 12.0)
                            cell.lblStock.font = Fonts.Regular.returnFont(size: 12.0)
                        } else if(sortType == "R-Win%"){
                            cell.lblRW.font = Fonts.Semibold.returnFont(size: 15.0)
                            cell.lblRWRL.font = Fonts.Regular.returnFont(size: 12.0)
                            cell.lblStock.font = Fonts.Regular.returnFont(size: 12.0)
                        } else {
                            cell.lblStock.font = Fonts.Semibold.returnFont(size: 15.0)
                            cell.lblRW.font = Fonts.Regular.returnFont(size: 12.0)
                            cell.lblRWRL.font = Fonts.Regular.returnFont(size: 12.0)
                        }
                    } else {
//                        cell.showAnimation()
                    }

                    cell.viewMain.layer.borderWidth = 1.0
                    cell.viewMain.roundCorners(radius: 0.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.topRight, .bottomLeft,.bottomRight])

                    //both alternate filter selected
                    if(xMatrix != -1 && yMatrix != -1) {
                        if(indexPath.row == yMatrix && indexPath.section == xMatrix){
                            cell.viewMain.layer.borderColor = UIColor.blue.cgColor
                            cell.viewMain.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMaxXMinYCorner, .layerMinXMaxYCorner,.layerMaxXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                        }
                        else {
                            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
                        }
                    } else {
                        // single alternate filter selected
                        if(xMatrix != -1 && yMatrix == -1){
                            if(indexPath.section == xMatrix){
                                cell.viewMain.layer.borderColor = UIColor.blue.cgColor
                            } else {
                                cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
                            }
                        }
                        else if(yMatrix != -1 && xMatrix == -1){
                            if(indexPath.row == yMatrix){
                                cell.viewMain.layer.borderColor = UIColor.blue.cgColor
                            } else {
                                cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
                            }
                        } else {
                            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
                        }
                        if indexPath.section == 1 {
                            cell.viewMain.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMaxXMinYCorner], arrCornersBelowiOS11: [.topLeft,.topRight])
                        } else if indexPath.section == arrFilterValue?.count {
                            cell.viewMain.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomLeft,.bottomRight])
                        }
                        
                        if arrFilterValue?.count == 1 {
                            cell.viewMain.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.topRight,.bottomLeft,.bottomRight])
                        }
                    }
                     cell.viewMain.clipsToBounds = true
                    return cell
                }
            }
        } else {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
                
                if rowHeaders != nil && playerResultData != nil {
//                    cell.hideAnimation()
//                    if indexPath.row != 0 {
//                        cell.contentLabel.text = rowHeaders?[indexPath.row-1]
//                    }else {
//                        cell.contentLabel.text = ""
//                    }
                    if indexPath.row != rowHeaders.count {
                        cell.contentLabel.text = rowHeaders?[indexPath.row]
                    }else {
                        cell.contentLabel.text = ""
                    }
                }else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 13.0)
                cell.backgroundColor = Colors.black.returnColor()
                return cell
            } else if indexPath.section == playerResultData?.count ?? 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentWithBlackBackgroundCell", for: indexPath) as! ContentWithBlackBackgroundCell
                
                cell.btnPlayerDetail.isHidden = true
                
                if rowHeaders != nil && playerResultData != nil {
//                    cell.hideAnimation()
                    cell.contentLabel.text = ""
                    
                    if indexPath.row == 0 {
                        cell.contentLabel.text = "  Career Totals"
                    } else if indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 7 || indexPath.row == 6 {
                        cell.contentLabel.text = ""
                    } else {
                        let row = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1] : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2] : playerResultData?[indexPath.section - 1])
                        if indexPath.row == 5 {
                            cell.contentLabel.text = "\(row!["totalStocks"]!)"
                        } else {
                            cell.contentLabel.text = "\(row![rowHeaders![indexPath.row]]!)"
                        }
                        //cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                    }
                    cell.contentLabel.font = Fonts.Bold.returnFont(size: 13.0)
                    
//                    if (indexPath.row == 1 || indexPath.row == 3) && indexPath.row != 0 {
//                        let row = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1] : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2] : playerResultData?[indexPath.section - 1])
//                        cell.contentLabel.text = "\(row![rowHeaders![indexPath.row-1]]!)"
//                        cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
//                    }
//
//                    if indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 3 {
//                        let row = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1] : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2] : playerResultData?[indexPath.section - 1])
//                        cell.contentLabel.text = "\(row![rowHeaders![indexPath.row-1]]!)"
//                        cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
//                    }
                    
                    if(indexPath.row == 2){
                        cell.viewDetail.isHidden = false
                    } else {
                        cell.viewDetail.isHidden = true
                    }
                    
                    /// 421 By Pranay
                    cell.btnDetail.isUserInteractionEnabled = false
                    cell.btnDetail.backgroundColor = Colors.disableButton.returnColor()
                    /// 421 .
                    
                    cell.onTapRedirect = {
                        self.getContent()
                    }
                    
                } else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                return cell
            } else {
                if indexPath.row == 0 || indexPath.row == 2 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                                                                  for: indexPath) as! PlayerCVCell
                    cell.ivCaptainCap.isHidden = true
                    cell.horizontalSeperater.isHidden = true
                    
                    if rowHeaders != nil && playerResultData != nil {
//                        cell.hideAnimation()
                        if indexPath.row == 0 {
                            cell.lblPlayerName.text = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1]["Name"] as? String : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2]["Name"] as? String : playerResultData?[indexPath.section - 1]["Name"] as? String)
                            cell.ivPlayer.setImage(imageUrl: (expandedIndex > (indexPath.section+1) ? playerResultData?[indexPath.section - 1]["leagueLogo"] as? String : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2]["leagueLogo"] as? String : playerResultData?[indexPath.section - 1]["leagueLogo"] as? String))!)
                        } else {
                            cell.lblPlayerName.text = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1]["teamName"] as? String : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2]["teamName"] as? String : playerResultData?[indexPath.section - 1]["teamName"] as? String)
                            cell.ivPlayer.setImage(imageUrl: (expandedIndex > (indexPath.section+1) ? playerResultData?[indexPath.section - 1]["Team"] as? String : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2]["Team"] as? String : playerResultData?[indexPath.section - 1]["Team"] as? String))!)
                        }
                        cell.lblPlayerName.font = Fonts.Regular.returnFont(size: 12.0)
                    }else {
                        cell.lblPlayerName.text = ""
//                        cell.showAnimation()
                    }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
                    cell.backgroundColor = UIColor.white
                    if rowHeaders != nil && playerResultData != nil {
//                        cell.hideAnimation()
//                        if indexPath.row != 0 {
                        if indexPath.row != rowHeaders.count {
                            let row = expandedIndex > (indexPath.section) ? playerResultData?[indexPath.section - 1] : (((indexPath.section - 2 > -1) && (expandedIndex != -1)) ? playerResultData?[indexPath.section - 2] : playerResultData?[indexPath.section - 1])
//                            cell.contentLabel.text = "\(row![rowHeaders![indexPath.row - 1]]!)"
                            cell.contentLabel.text = "\(row![rowHeaders![indexPath.row]]!)"
                        }
                        
                    }else {
                        cell.contentLabel.text = ""
//                        cell.showAnimation()
                    }
                    
                    cell.contentLabel.textColor = Colors.black.returnColor()
                    cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
                    return cell
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x
        if (scrollOffset + scrollViewWidth == scrollContentSizeWidth) {
            btnRight?.isHidden = true
        } else {
            btnRight.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView != cvFilter {
            if rowHeaders != nil && playerResultData != nil {
                if (indexPath.row == self.playerResultData.count) {
                    if self.hasMore == 1 {
                        self.getTeamResult(gameId: self.selectedGameId, type: self.selectedType)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvFilter {
            let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((rowFilter?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 60)) > CGFloat(self.view.frame.width) ? 60 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((rowFilter?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
            
            //            return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100 : indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 60 : 60 : currentWidth, height: 50)
            return CGSize(width: UIDevice.current.userInterfaceIdiom == .pad ? 215 : 80, height: 60)
        } else {
            let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 100.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 80)) > CGFloat(self.view.frame.width) ? 80.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 100.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
            
//            return CGSize(width: indexPath.row == 1 ? 70.0 : (indexPath.row == 0 ? 25.0 : (indexPath.row == 3 ? UIDevice.current.userInterfaceIdiom == .pad ? 210 : 150 : currentWidth)), height: indexPath.section == 0 ? 32 : 40)
            return CGSize(width: indexPath.row == 0 ? 100.0 : (indexPath.row == 2 ? UIDevice.current.userInterfaceIdiom == .pad ? 180 : 120 : (indexPath.row == 6 ? 100.0 : currentWidth)), height: indexPath.section == 0 ? 32 : 40)
        }
    }
}
