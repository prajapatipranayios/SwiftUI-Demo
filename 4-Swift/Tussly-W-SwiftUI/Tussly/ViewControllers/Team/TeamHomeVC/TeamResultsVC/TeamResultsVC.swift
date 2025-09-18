//
//  TeamResultsVC.swift
//  - Contains information related to results of different Teams and its position

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamResultsVC: UIViewController, teamResultDelegate {

    // MARK: - Variables
    var selectedSection = -1
    var resultData: [TeamInfo]?
    var rowHeaders: [String]!
    var teamData = [PlayerInfo]()
    var getAllGameData = [Game]()
    var teamDetailData: Team?
    var selectedGameId = -1
    var selectedGame = [Game]()
    var arrFilterValue: [[String: [String: String]]]!
    var selectedBase = ""
    var baseFilterIndex = 0
    var isBaseSelected = false
    var yMatrix = -1
    var xMatrix = -1
    var isAlternateSelected = false
    var rowFilter: [String]!
    var selectedType = "Tournament"  //"League"
    var charContentArr = [Characters]()
    var oppCharContentArr = [Characters]()
    var stageContentArr = [Stages]()
    var playerArr = [TeamPlayer]()
    var total : [String: Any]!
    var selectedStageId = ""
    var selectedCharId = ""
    var selectedOppCharId = ""
    var selectedPlayerId = ""
    var resultAverage = ResultAverage()
    var filterResult = [FilterResult]()
    var headers: [String]!
    var hasMore = -1
    var pageNumber = 1
    
    var isNoResultData = false
    
    // MARK: - Controls
    @IBOutlet weak var tvResult: UITableView!
    @IBOutlet weak var ivGameLogo: UIImageView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var viewGameSelection : UIView!
    @IBOutlet weak var lblSelectType: UILabel!
    @IBOutlet weak var imgSelectType: UIImageView!
    @IBOutlet weak var viewCharacter : UIView!
    @IBOutlet weak var lblCharacterName : UILabel!
    @IBOutlet weak var imgCharacter : UIImageView!
    @IBOutlet weak var viewStage : UIView!
    @IBOutlet weak var lblStageName : UILabel!
    @IBOutlet weak var imgStage : UIImageView!
    @IBOutlet weak var viewPlayer : UIView!
    @IBOutlet weak var lblPlayerName : UILabel!
    @IBOutlet weak var imgPlayer : UIImageView!
    @IBOutlet weak var viewOpposingCharacter : UIView!
    @IBOutlet weak var lblpposingCharacterName : UILabel!
    @IBOutlet weak var imgOpposingCharacter : UIImageView!
    @IBOutlet weak var viewTournament : UIView!
    @IBOutlet weak var lblTournamentName : UILabel!
    @IBOutlet weak var imgTournament : UIImageView!
    @IBOutlet weak var btnBackToResult : UIButton!
    @IBOutlet weak var btnReset : UIButton!
    @IBOutlet weak var lblAgainstFilter1 : UILabel!
    @IBOutlet weak var imgPlusAgainstFilter1 : UIImageView!
    @IBOutlet weak var lblBaseFilter : UILabel!
    @IBOutlet weak var imgBaseFilter : UIImageView!
    @IBOutlet weak var lblBaseRWRL : UILabel!
    @IBOutlet weak var lblBaseStock : UILabel!
    @IBOutlet weak var lblBaseRW : UILabel!
    @IBOutlet weak var btnBaseSort : UIButton!
    @IBOutlet weak var cvFilterHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cvFilter: UICollectionView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var viewSort: UIView!
    @IBOutlet weak var lblMyRWRL : UILabel!
    @IBOutlet weak var lblMyStock : UILabel!
    @IBOutlet weak var lblMyWL : UILabel!
    @IBOutlet weak var lblTypeHeading : UILabel!
    @IBOutlet weak var lblGameHeading : UILabel!
    @IBOutlet weak var viewResultDetail : UIView!
    @IBOutlet weak var btnApply : UIButton!
    @IBOutlet weak var btnSelectGame : UIButton!
    @IBOutlet weak var btnSortViewDismiss : UIButton!
    @IBOutlet weak var viewDetailHeightConst: NSLayoutConstraint!
    @IBOutlet weak var cvFilterGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvFilterGridLayout.stickyRowsCount = 1
            cvFilterGridLayout.stickyColumnsCount = 1
        }
    }
    
    // 231 - By Pranay
    var intIdFromSearch : Int = 0
    // 231 .
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.showAnimation()
        tvResult.register(UINib(nibName: "TeamResultCell", bundle: nil), forCellReuseIdentifier: "TeamResultCell")
        tvResult.register(UINib(nibName: "ResultSecHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ResultSecHeaderView")
        tvResult.register(UINib(nibName: "TeamPlayerCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "TeamPlayerCell")
        tvResult.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "ContentCollectionViewCell")
        
        tvResult.register(UINib(nibName: "TeamNoResultTCell", bundle: nil), forCellReuseIdentifier: "TeamNoResultTCell")
        //DispatchQueue.main.async {
        //    self.ivGameLogo.layer.cornerRadius = self.ivGameLogo.frame.size.width/2
        //}
        self.tvResult.delegate = self
        self.tvResult.dataSource = self
        if #available(iOS 15.0, *){
            self.tvResult.sectionHeaderTopPadding = 0.0
        }
        if teamDetailData?.id == nil {
            self.tvResult.reloadData()
        } else {
            getGame()
        }
        
        setUI()
        
        cvFilter.register(UINib(nibName: "FilterCharacterImageCell", bundle: nil), forCellWithReuseIdentifier: "FilterCharacterImageCell")
        cvFilter.register(UINib(nibName: "AddCharacterCell", bundle: nil), forCellWithReuseIdentifier: "AddCharacterCell")
        cvFilter.register(UINib(nibName: "FilterResultCell", bundle: nil), forCellWithReuseIdentifier: "FilterResultCell")
        cvFilter.reloadData()
        
        rowFilter = ["Stage", "R1", "R2", "R3"]
        arrFilterValue = [
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
    }
    
    // MARK: - UI Methods
    func setUI() {
        btnSortViewDismiss.isHidden = true
        viewDetailHeightConst.constant = 1300
        viewCharacter.layer.cornerRadius = viewCharacter.frame.size.height/2
        self.viewCharacter.layer.borderColor = UIColor.lightGray.cgColor
        self.viewCharacter.layer.borderWidth = 1
        viewPlayer.layer.cornerRadius = viewPlayer.frame.size.height/2
        self.viewPlayer.layer.borderColor = UIColor.lightGray.cgColor
        self.viewPlayer.layer.borderWidth = 1
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
        
        cvFilter.delegate = self
        cvFilter.dataSource = self
        
        scrollview.isHidden = true
        btnBackToResult.isHidden = true
        
        //beta 1 ////hide league option and set tournament as default
        imgSelectType.image =  UIImage(named: "Tournament")
        lblSelectType.text = "Tournament"
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
        scrollview.isHidden = false
        btnBackToResult.isHidden = false
        lblGameHeading.isHidden = true
        lblTeamName.isHidden = true
        ivGameLogo.isHidden = true
        btnSelectGame.isHidden = true
        lblTypeHeading.text = "Select Game"
        lblSelectType.text = lblTeamName.text
        imgSelectType.setImage(imageUrl: self.selectedGame[0].gameLogo ?? "")
    }
    
    func openGameDropDown() {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectItem = { arrSelected in
            self.selectedGame = arrSelected
            self.ivGameLogo.setImage(imageUrl: arrSelected[0].gameLogo ?? "")
            self.lblTeamName.text = arrSelected[0].gameName
            self.selectedSection = -1
            
//            for i in 0 ..< self.getAllGameData.count {
//                 arrSelected.map{
//                    if $0.id == (self.getAllGameData[i].id)! {
//                        self.selectedSection = i
//
//                    }
//                }
//            }
            
            if self.scrollview.isHidden == false {
                self.imgSelectType.setImage(imageUrl: arrSelected[0].gameLogo ?? "")
                self.lblSelectType.text = arrSelected[0].gameName
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
    
    func backToResult() {
        scrollview.isHidden = true
        btnBackToResult.isHidden = true
        lblGameHeading.isHidden = false
        lblTeamName.isHidden = false
        ivGameLogo.isHidden = false
        btnSelectGame.isHidden = false
        lblTypeHeading.text = "Select Type"
        lblSelectType.text = self.selectedType
        imgSelectType.image = UIImage(named: self.selectedType)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapGame(_ sender: UIButton) {
        openGameDropDown()
    }
    
    @IBAction func onTapSelectType(_ sender: UIButton) {
        if self.scrollview.isHidden {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
            objVC.didSelectType = { type in
                self.selectedSection = -1
                self.imgSelectType.image =  UIImage(named: type)
                self.lblSelectType.text = type
                self.selectedType = type
                self.pageNumber = 1
                self.getTeamResult(gameId: self.selectedGameId, type: type)
            }
            objVC.type = self.selectedType
            objVC.isSelectType = true
            objVC.isSingleSelection = true
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        } else {
            openGameDropDown()
        }
    }
    
    @IBAction func onTapTypeFilter(_ sender: UIButton) {
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
        } else {
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
        viewDetailHeightConst.constant = 1300
        lblCharacterName.text = "All"
        imgCharacter.image = UIImage(named: "")
        lblStageName.text = "All"
        imgStage.image = UIImage(named: "")
        lblTournamentName.text = "All"
        imgTournament.image = UIImage(named: "")
        lblpposingCharacterName.text = "All"
        imgOpposingCharacter.image = UIImage(named: "")
        lblPlayerName.text = "All"
        imgPlayer.image = UIImage(named: "")
        isBaseSelected = false
        isAlternateSelected = false
        btnSortViewDismiss.isHidden = true
        viewResultDetail.isHidden = false
        viewSort.isHidden = true
        btnBaseSort.setTitle("", for: .normal)
        selectedCharId = ""
        selectedStageId = ""
        selectedOppCharId = ""
        selectedPlayerId = ""
    }
    
    @IBAction func onTapFilter(_ sender: UIButton) {
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
        } else if sender.tag == 2 || sender.tag == 4 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "StageRankingDialog") as! StageRankingDialog
            dialog.arrStage = self.stageContentArr
            dialog.arrForPlayer = self.playerArr
            dialog.isFromPlayerCard = true
            dialog.header = sender.tag == 2 ? "Select Stage" : "Select Player"
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.tapForFilter = { index in
                if sender.tag == 2 {
                    self.lblStageName.text = self.stageContentArr[index].name
                    self.imgStage.setImage(imageUrl: self.stageContentArr[index].imagePath ?? "")
                    self.selectedStageId = "\(self.stageContentArr[index].id!)"
                } else {
                    self.lblPlayerName.text = "\(self.playerArr[index].firstName ?? "") \(self.playerArr[index].lastName ?? "")"
                    self.selectedPlayerId = "\(self.playerArr[index].id!)"
                }
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
        
    @IBAction func onTapApply(_ sender: UIButton) {
        self.getFilterData()
    }
    
    // MARK: - Webservices
    
    func getGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGame()
                }
                return
                     }
           }
        showLoading()
        
        let param = ["" : ""]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.getAllGameData = (response?.result?.games)!
                if self.getAllGameData.count > 0 {
                    DispatchQueue.main.async {
                        self.viewGameSelection.isHidden = false
//                        self.hideAnimation()
                        self.getAllGameData.insert(self.getAllGameData[0], at: 1)
                        self.getAllGameData[0].id = 0
                        self.getAllGameData[0].gameName = "All"
                        self.getAllGameData[0].gameLogo = ""
                        self.ivGameLogo.setImage(imageUrl: self.getAllGameData[0].gameLogo ?? "")
                        self.lblTeamName.text = self.getAllGameData[0].gameName
                        self.selectedSection = -1
                        self.selectedGameId = self.getAllGameData[0].id!
                        self.selectedGame = [self.getAllGameData[0]]
                        self.getTeamResult(gameId: self.getAllGameData[0].id!, type: self.selectedType)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.viewGameSelection.isHidden = true
//                    self.hideAnimation()
                    self.resultData = [TeamInfo]()
                    self.tvResult.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getTeamResult(gameId: Int, type: String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamResult(gameId: gameId, type: type)
                }
            }
            return
        }
        
        // By Pranay - add param - timeZone
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_RESULT, parameters: ["teamId" : teamDetailData?.id as Any,"gameId":gameId, "type" : self.selectedType, "page": self.pageNumber, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.isNoResultData = false
                self.resultData?.removeAll()
                DispatchQueue.main.async {
                    self.resultData = (response?.result?.teamInfo)!
                    self.total = (response?.result?.total)!
                    self.hasMore = (response?.result?.hasMore)!
                    if self.scrollview.isHidden == false {
                        if (self.resultData?.count ?? 0) > 0 {
                            self.onTapReset(self.btnReset)
                            self.showFilterView()
                        } else {
                            self.backToResult()
                        }
                    }
                    
                    if (self.resultData?.count ?? 0) > 0 {
                        self.pageNumber += 1
                    }
                    self.tvResult.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.resultData = [TeamInfo]()
                    self.isNoResultData = true
                    self.tvResult.reloadData()
                }
            }
        }
    }
    
    func getTeamResultDetail(leagueConsoleId: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamResultDetail(leagueConsoleId: leagueConsoleId)
                }
            }
            return
        }
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_PLAYER_RESULT, parameters: ["leagueId": leagueConsoleId,"teamId":teamDetailData?.id as Any]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.teamData = (response?.result?.playerInfo)!
                    self.headers = (response?.result?.playerHeader)!
                    self.tvResult.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_PLAYER_FILTER, parameters: ["teamId":teamDetailData?.id as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.showFilterView()
                    self.lblMyRWRL.text = "\(self.total["totalWin"] as? Int ?? 0)-\(self.total["totalLose"] as? Int ?? 0)"
                    self.lblMyWL.text = self.total["avg"] as? String
                    self.lblMyStock.text = self.total["stock"] as? String
                    self.charContentArr = (response?.result?.characters)!
                    self.oppCharContentArr = (response?.result?.opposingCharacters)!
                    self.stageContentArr = (response?.result?.stages)!
                    self.playerArr = (response?.result?.teamPlayers)!
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_PLAYER_DETAIL, parameters: ["teamId": teamDetailData?.id as Any, "playerId" : selectedPlayerId, "characterId" : selectedCharId,"stageId" : selectedStageId,"oppositeCharacterId" : selectedOppCharId,"type" : (self.lblTournamentName.text == "All" ? "League" : self.lblTournamentName.text) ?? "League","sortBy" : (sortType == "" ? "RW-RL" : sortType)]) { (response: ApiResponse?, error) in
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
                    self.viewDetailHeightConst.constant = self.cvFilterHeightConst.constant + CGFloat(490)
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TeamResultsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isNoResultData == true {
            return 1
        } else {
            return (self.resultData?.count ?? 0) + ((self.resultData?.count ?? 0) > 0 ? 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNoResultData == true {
            return 1
        } else {
        return section == selectedSection ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isNoResultData == true {
            return 0
        }
        return 40.0
    }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if isNoResultData == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamNoResultTCell", for: indexPath) as! TeamNoResultTCell
                cell.btnDetails.layer.cornerRadius = 3.0
                cell.btnDetails.backgroundColor = Colors.disableButton.returnColor()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TeamResultCell", for: indexPath) as! TeamResultCell
                cell.delegate = self
                cell.setupResultCollectionData(resultData: teamData, header: headers)
                return cell
            }
        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.isNoResultData == true {
            return nil
        } else {
            guard let customeView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ResultSecHeaderView") as? ResultSecHeaderView else { assertionFailure("Section header shouldn't be nil")
                return ResultSecHeaderView()
            }
            if self.resultData != nil {
//                customeView.hideAnimation()
                if section != self.resultData?.count {
                    customeView.viewTotal.isHidden = true
                    customeView.ivArrow.image = self.selectedSection == section ? UIImage(named: "Arrow_up") : UIImage(named: "Arrow_down")
                    customeView.index = section
                    customeView.lblDate.text = resultData![section].date
                    customeView.lblName.text = resultData![section].leagueName
                    customeView.lblWL.text = resultData![section].wl
                    customeView.lblStandings.text = ""//"\(resultData![section].standings ?? 0)"
                    customeView.lblPlayoffs.text = resultData![section].playOffs
                    customeView.ivLeague.setImage(imageUrl: resultData![section].leagueLogo ?? "")
                    customeView.openResultDetails = { index in
                        self.selectedSection = self.selectedSection == index ? -1 : index
                        self.tvResult.reloadData()
                        self.getTeamResultDetail(leagueConsoleId: self.resultData![section].leagueId ?? 0)
                    }
                } else {
                    customeView.lblTotalWL.text = "\(self.total["totalWin"] ?? "0")-\(self.total["totalLose"] ?? "0")"
                    if (self.resultData?.count ?? 0) > 0 {
                        customeView.viewTotal.isHidden = false
                        customeView.btnDetail.backgroundColor = Colors.disableButton.returnColor()
                        customeView.onTapDetail = {
                            ////Beta 1 - Disable option
                            //self.getContent()
                        }
                    }
                }
            } else {
//                customeView.showAnimation()
            }
            return customeView
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.resultData != nil {
            if (indexPath.row == (self.resultData?.count ?? 0) - 1) {
                if self.hasMore == 1 {
                    self.getTeamResult(gameId: self.selectedGameId, type: self.selectedType)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isNoResultData == true {
            return 120
        } else {
            return CGFloat(40 * (self.teamData.count + 1))
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension TeamResultsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (arrFilterValue?.count ?? 10) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowFilter?.count ?? SKELETON_ROWHEADER_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if(indexPath.row != 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCharacterImageCell",
                                                              for: indexPath) as! FilterCharacterImageCell
                
                if rowFilter != nil && self.filterResult.count > 0 {
//                    cell.hideAnimation()
                    cell.imgCharacter.layer.cornerRadius = cell.imgCharacter.frame.size.height/2
                    cell.imgWidthConst.constant = 30
                    cell.imgHeightConst.constant = 30
                    cell.imgCharacter.setImage(imageUrl: self.filterResult[0].filterData?[indexPath.row - 1].imagePath ?? "")
                }else {
//                    cell.showAnimation()
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
//                    cell.hideAnimation()
                    cell.lblFilterName.text = rowFilter[indexPath.row]
                }else {
                    cell.lblFilterName.text = ""
//                    cell.showAnimation()
                }
                cell.backgroundColor = UIColor.white
                return cell
            }
        }  else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCharacterImageCell",
                    for: indexPath) as! FilterCharacterImageCell
                
                if rowFilter != nil && self.filterResult.count > 0 {
//                    cell.hideAnimation()
                    cell.imgCharacter.layer.cornerRadius = 5.0
                    cell.imgWidthConst.constant = 45
                    cell.imgHeightConst.constant = 35
                    cell.imgCharacter.setImage(imageUrl: self.filterResult[indexPath.section].imagePath ?? "")
                    
                    if self.filterResult[indexPath.section].isSelectedColumn == 1 {
                        self.yMatrix = indexPath.section
                    }
                }else {
//                    cell.showAnimation()
                }
                
                if(arrFilterValue.count < 2){
                    cell.btnRemove.isHidden = true
                } else {
                    cell.btnRemove.isHidden = false
                }
                
                cell.onTapRemove = {
                    self.arrFilterValue.remove(at: indexPath.section)
                    self.cvFilterHeightConst.constant = CGFloat((self.arrFilterValue.count + 1) * 60)
                    self.viewDetailHeightConst.constant = self.cvFilterHeightConst.constant + CGFloat(490)
                    self.cvFilter.reloadData()
                }
                
                cell.backgroundColor = UIColor.white
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterResultCell",
                    for: indexPath) as! FilterResultCell
                if rowFilter != nil {
//                    cell.hideAnimation()
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
//                    cell.showAnimation()
                }
                
//                let rectShape = CAShapeLayer()
//                rectShape.bounds = cell.viewMain.frame
//                rectShape.position = cell.viewMain.center
//                if(indexPath.section == 1){
//                    rectShape.path = UIBezierPath(roundedRect: cell.viewMain.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 10, height: 10)).cgPath
//                }
//                else if(indexPath.section == arrFilterValue.count){
//                    rectShape.path = UIBezierPath(roundedRect: cell.viewMain.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
//                }
//                else {
//                    rectShape.path = UIBezierPath(roundedRect: cell.viewMain.bounds, byRoundingCorners: [.bottomLeft , .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 0, height: 0)).cgPath
//                }
//                cell.viewMain.layer.mask = rectShape
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        _ = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((rowFilter?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 60)) > CGFloat(self.view.frame.width) ? 60 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((rowFilter?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
//            return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100 : indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 60 : 60 : currentWidth, height: 50)
        //return CGSize(width: indexPath.row == 0 ? 80 : UIDevice.current.userInterfaceIdiom == .pad ? 215 : 60, height: 60)
        return CGSize(width: UIDevice.current.userInterfaceIdiom == .pad ? 215 : 80, height: 60)
    }
}



