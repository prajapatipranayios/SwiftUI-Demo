//
//  BracketTabVC.swift
//  Tussly
//
//  Created by Auxano on 23/09/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import Foundation
import WebKit       //  By Pranay

class BracketTabVC: UIViewController {
    
    // MARK: - Variables
    var arrRound = [String]()
    var arrBracket = [BracketData]()
    var arrBracketDetail = [BracketDetail]()
    var roundIndex = 0
    var arrNextMatch = [[Int]]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isScrollAsSchedule = false
    var scrollMatchID = 0
    var scrollmatchNo = 0
    
    // By Pranay
    var arrAllBracket = [BracketData]()
    var arrFilterPool : [filterPoolBracket] = []
    //var strBracketType : String?
    var myPoolType: String? = "Upper"
    var myPoolTypeLabel: String? = "Upper Bracket"
    var isBracketFilterActive : Bool? = false
    var currentPoolType: String? = ""
    var isTeamsMoreThan32 : Bool? = false
    var isMyPool : Bool = false
    //.
    
    // MARK: - Outlets
    @IBOutlet weak var tvMatch: UITableView!
    @IBOutlet weak var cvRound : UICollectionView!
    @IBOutlet weak var viewBracketDropDown: UIView!
    @IBOutlet weak var lblBracketPool: UILabel!
    @IBOutlet weak var imgFilterDownArrow: UIImageView!
    @IBOutlet weak var constrFilterMainViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var viewWebView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBracketDropDown.layer.cornerRadius = 10
        imgFilterDownArrow.setImageColor(color: .white)
        constrFilterMainViewWidth.priority = .required
        viewBracketDropDown.isHidden = true
        
        //getTournament()
        //self.viewWebView.isHidden = true
        //let bracketUrl: String = HTTP_BRACKET_URL + "\(APIManager.sharedManager.user?.id ?? 0)/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        
        let bracketUrl: String = "\(self.leagueTabVC!().getLeagueMatches?.bracketBaseUrl ?? "")\(APIManager.sharedManager.user?.id ?? 0)/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
        self.setupWebView(htmlContent: bracketUrl)
        print("Bracket URL -> \(bracketUrl)")
        
        self.showLoading()
        self.viewWebView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewWebView.isHidden = false
            self.hideLoading()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollMatchID = 0
        scrollmatchNo = 0
    }
    
    func setUI() {
        DispatchQueue.main.async {
            self.tvMatch.rowHeight = UITableView.automaticDimension
            self.tvMatch.estimatedRowHeight = 160.0
            
            //scroll to scheduleview from arena next match schedule
            if self.isScrollAsSchedule {
                self.isScrollAsSchedule = false
                
                for i in 0 ..< self.arrNextMatch.count {
                    if self.arrNextMatch[i].contains(self.scrollmatchNo) {
                        self.roundIndex = i
                        self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
                        break
                    }
                }
                
                self.cvRound.reloadData()
                self.tvMatch.reloadData()
                let indexPath:IndexPath = IndexPath(row: self.arrNextMatch[self.roundIndex].firstIndex(of: self.scrollmatchNo) ?? 0, section: 0)
                self.tvMatch.scrollToRow(at: indexPath, at: .none, animated: true)
            } else {
                self.cvRound.reloadData()
                self.tvMatch.reloadData()
            }
        }
    }
    
    // MARK: - UI Methods

    func setupWebView(htmlContent: String) {
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0'); document.getElementsByTagName('head')[0].appendChild(meta);"
        //'initial-scale=1.0, maximum-scale=1.0', 'user-scalable=no'

        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController

        let wkwebView = WKWebView(frame: viewWebView.frame, configuration: wkWebConfig)
        wkwebView.scrollView.bounces = false
        wkwebView.translatesAutoresizingMaskIntoConstraints = false
        wkwebView.scrollView.delegate = self
        wkwebView.scrollView.alwaysBounceHorizontal = false
        wkwebView.isMultipleTouchEnabled = false
        wkwebView.navigationDelegate = self
        wkwebView.scrollView.showsHorizontalScrollIndicator = false
        
        //wkwebView.loadHTMLString(htmlContent, baseURL: nil)
        let link = URL(string: htmlContent)!
        let request = URLRequest(url: link)
        wkwebView.load(request)
        
        viewWebView.addSubview(wkwebView)
        wkwebView.topAnchor.constraint(equalTo: viewWebView.topAnchor, constant: 0.0).isActive = true
        wkwebView.bottomAnchor.constraint(equalTo: viewWebView.bottomAnchor, constant: 0.0).isActive = true
        wkwebView.leadingAnchor.constraint(equalTo: viewWebView.leadingAnchor, constant: 0.0).isActive = true
        wkwebView.trailingAnchor.constraint(equalTo: viewWebView.trailingAnchor, constant: 0.0).isActive = true

        viewWebView.layoutIfNeeded()

    }
    
    // MARK: - Button Click Events
    // By Pranay
    @IBAction func btnBracketDropDwnPool(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "BracketFilterPopupVC") as! BracketFilterPopupVC
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.arrFilterPool = self.arrFilterPool
        dialog.myPoolTypeLabel = self.isMyPool ? self.myPoolTypeLabel : ""
        dialog.tapOk = { [self] arr in
            self.currentPoolType = (self.arrFilterPool[arr[0] as! Int].poolType)!
            DispatchQueue.main.async {
                self.lblBracketPool.text = self.currentPoolType!
            }
            
            self.roundIndex = 0
            self.setDataFromFilter(myPool: self.currentPoolType!)
            
            /*
            self.roundIndex = 0
            var strType : String = ""
            if self.currentPoolType!.contains("Upper") {
                strType = "Upper"
            } else {
                strType = "Lower"
            }
            if self.strBracketType != strType {
                self.strBracketType = strType
                //self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == self.strBracketType }
                //self.arrRound.removeAll()
            }
            
            self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == self.strBracketType }
            self.arrRound.removeAll()
            
            if self.arrBracket.count > 0 {
                self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
                
                self.arrRound.removeAll()
                self.arrNextMatch.removeAll()
                self.arrBracketDetail.removeAll()
                
                for i in 0 ..< self.arrBracket.count {
                    
                    var arrTemp = [BracketDetail]()
                    arrTemp = (self.arrBracket[0].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                    
                    if arrTemp.count > 0 {
                        break
                    } else {
                        self.arrBracket.remove(at: 0)
                        print("Removed objects -- \(i + 1)")
                    }
                }
                
                for i in 0 ..< self.arrBracket.count {
                    
                    var arrTempBracketDetail = [BracketDetail]()
                    arrTempBracketDetail = (self.arrBracket[i].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                    //self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
                    
                    if arrTempBracketDetail.count > 0 {
                        self.arrRound.append(self.arrBracket[i].tabName ?? "")
                        
                        var arr = [Int]()
                        var bracket = [BracketDetail]()
                        bracket = arrTempBracketDetail
                        for j in 0 ..< bracket.count {
                            arr.append(bracket[j].matchNo!)
                        }
                        self.arrNextMatch.append(arr)
                    }
                }
            }   //
            
            if self.arrBracket.count > 0 {
                self.arrBracketDetail = self.arrBracket[0].data ?? [BracketDetail]()
                self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
            }   //  */
            
            self.cvRound.reloadData()
            self.tvMatch.reloadData()
            self.cvRound.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    //.
    
    // MARK: Webservices
    func getTournament() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTournament()
                }
            }
            return
        }
        showLoading()
        //APIManager.sharedManager.match!.league!.id!
        
        // By Pranay - add param - timeZone
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TOURNAMENT_BRACKET, parameters: ["leagueId" : APIManager.sharedManager.match!.league!.id!, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                self.hideLoading()
                // By Pranay
                if ((response?.result?.filterPopup) != nil) && ((response?.result?.filterPopup?.count)! > 0) {
                    self.isBracketFilterActive = true
                    DispatchQueue.main.async {
                        self.lblBracketPool.text = "Select Bracket"
                        self.constrFilterMainViewWidth.priority = .defaultLow
                        self.viewBracketDropDown.isHidden = false
                    }
                    self.fillFilterTypesValues(values: (response?.result?.filterPopup)!)
                    
                    self.isMyPool = false
                    let myPool : String = (response?.result?.myPool)!
                    if myPool != "" {
                        let arrTypeValue = myPool.components(separatedBy: "@")
                        //let arrTypeValue = "Upper Pool A@Upper A".components(separatedBy: "@")
                        self.myPoolType = arrTypeValue[1]
                        self.myPoolTypeLabel = arrTypeValue[0]
                        self.isMyPool = true
                    }
                    self.isTeamsMoreThan32 = false
                    if (response?.result?.totalTeams)! > 32 {
                        self.isTeamsMoreThan32 = true
                        if myPool == "" {
                            self.myPoolType = "Upper A"
                            self.myPoolTypeLabel = "Upper Pool A"
                        }
                    }
                }
                self.arrAllBracket = (response?.result?.bracketData)!
                //.
                self.arrBracket = self.arrAllBracket
                
                self.arrRound.removeAll()
                if !(self.isBracketFilterActive!) {
                    for i in 0 ..< self.arrBracket.count {
                        self.arrRound.append(self.arrBracket[i].tabName ?? "")
                        
                        var arr = [Int]()
                        var bracket = [BracketDetail]()
                        bracket = self.arrBracket[i].data ?? [BracketDetail]()
                        for j in 0 ..< bracket.count {
                            arr.append(bracket[j].matchNo!)
                        }
                        self.arrNextMatch.append(arr)
                    }
                    if self.arrBracket.count > 0 {
                        self.arrBracketDetail = self.arrBracket[0].data ?? [BracketDetail]()
                    }   //  */
                }
                else
                {
                    self.setDataFromFilter(myPool: self.myPoolType!)
                }
                /*{
                    // By Pranay
                    self.currentPoolType = self.myPoolType!
                    DispatchQueue.main.async {
                        self.lblBracketPool.text = self.currentPoolType!
                    }
                    var strType : String = ""
                    if self.currentPoolType!.contains("Upper") {
                        strType = "Upper"
                    } else {
                        strType = "Lower"
                    }
                    if self.strBracketType != strType {
                        self.strBracketType = strType
                        //self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == self.strBracketType }
                        //self.arrRound.removeAll()
                    }
                    
                    self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == self.strBracketType }
                    self.arrRound.removeAll()
                    
                    if self.arrBracket.count > 0 {
                        //self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
                        
                        self.arrRound.removeAll()
                        self.arrNextMatch.removeAll()
                        self.arrBracketDetail.removeAll()
                        
                        for i in 0 ..< self.arrBracket.count {
                            var arrTemp = [BracketDetail]()
                            arrTemp = (self.arrBracket[0].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                            
                            if arrTemp.count > 0 {
                                break
                            } else {
                                self.arrBracket.remove(at: 0)
                                print("Removed objects -- \(i + 1)")
                            }
                        }
                        
                        for i in 0 ..< self.arrBracket.count {
                            
                            var arrTempBracketDetail = [BracketDetail]()
                            arrTempBracketDetail = (self.arrBracket[i].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                            
                            if arrTempBracketDetail.count > 0 {
                                self.arrRound.append(self.arrBracket[i].tabName ?? "")
                                let index = self.arrBracketDetail.count == 0 ? 0 : self.arrBracketDetail.count
                                //self.arrBracketDetail.append(contentsOf: arrTempBracketDetail)
                                
                                var arr = [Int]()
                                var bracket = [BracketDetail]()
                                bracket = arrTempBracketDetail
                                for j in 0 ..< bracket.count {
                                    arr.append(bracket[j].matchNo!)
                                }
                                self.arrNextMatch.append(arr)
                            }
                        }
                    }   //
                    
                    if self.arrBracket.count > 0 {
                        self.arrBracketDetail = self.arrBracket[0].data ?? [BracketDetail]()
                        self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
                    }
                    //.
                }       //  */
                self.setUI()
            } else {
                self.hideLoading()
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    // By Pranay
    func fillFilterTypesValues(values : [String]) {
        print("Called function.")
        for (i, item) in values.enumerated() {
            let arrTypeValue = item.components(separatedBy: "@")
            arrFilterPool.append(filterPoolBracket(poolType: arrTypeValue[1], poolTypeLabel: arrTypeValue[0], myPool: false))
        }
    }
    
    func setDataFromFilter(myPool : String) {
        // By Pranay
        self.currentPoolType = myPool
        DispatchQueue.main.async {
            self.lblBracketPool.text = self.currentPoolType!
        }
        var strType : String = ""
        if self.currentPoolType!.contains("Upper") {
            strType = "Upper"
        } else {
            strType = "Lower"
        }
//        if self.strBracketType != strType {
//            self.strBracketType = strType
//            //self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == self.strBracketType }
//            //self.arrRound.removeAll()
//        }
        
        self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == strType }
        self.arrRound.removeAll()
        
        if self.arrBracket.count > 0 {
            //self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
            
            self.arrRound.removeAll()
            self.arrNextMatch.removeAll()
            self.arrBracketDetail.removeAll()
            
            for i in 0 ..< self.arrBracket.count {
                var arrTemp = [BracketDetail]()
                arrTemp = (self.arrBracket[0].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                
                if arrTemp.count > 0 {
                    break
                } else {
                    self.arrBracket.remove(at: 0)
                    print("Removed objects -- \(i + 1)")
                }
            }
            
            for i in 0 ..< self.arrBracket.count {
                
                var arrTempBracketDetail = [BracketDetail]()
                arrTempBracketDetail = (self.arrBracket[i].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                
                if arrTempBracketDetail.count > 0 {
                    self.arrRound.append(self.arrBracket[i].tabName ?? "")
                    let index = self.arrBracketDetail.count == 0 ? 0 : self.arrBracketDetail.count
                    //self.arrBracketDetail.append(contentsOf: arrTempBracketDetail)
                    
                    var arr = [Int]()
                    var bracket = [BracketDetail]()
                    bracket = arrTempBracketDetail
                    for j in 0 ..< bracket.count {
                        arr.append(bracket[j].matchNo!)
                    }
                    self.arrNextMatch.append(arr)
                }
            }
        }   //  */
        
        if self.arrBracket.count > 0 {
            self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
            self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
        }
        //.
    }
    //.
    
    func moveToPreviousMatch(strMatchPool : String) {
        
        var strType : String = ""
        var strTempMatchPool : String = strMatchPool
        
        if strTempMatchPool.contains("Winner Final") {
            print("Winner Final")
        }
        else if strTempMatchPool.contains("Loser Final") {
            print("Loser Final")
        }
        else if strTempMatchPool.contains("Loser") {
            strTempMatchPool = String(strTempMatchPool.dropFirst(6))
            print(strTempMatchPool.first!)
            print((strTempMatchPool.prefix(3)).last!)
        } else {
            strTempMatchPool = String(strTempMatchPool.dropFirst(7))
        }
        
        if !(self.isTeamsMoreThan32!) {
            if (strTempMatchPool.first!).lowercased() == "u" {
                strType = "Upper"
                self.currentPoolType = "Upper"
            } else if (strTempMatchPool.first!).lowercased() == "l" {
                strType = "Lower"
                if (strTempMatchPool == "Loser Final")
                {
                    strType = "Upper"
                    self.currentPoolType = "Upper"
                }
                else
                {
                    self.currentPoolType = "Lower"
                }
            }
        }
        else
        {
            if (strTempMatchPool.first!).lowercased() == "u" {
                strType = "Upper"
                if strTempMatchPool.contains("RTF")
                {
                    self.currentPoolType = "Upper RTF"
                }
                else
                {
                    self.currentPoolType = "Upper \((strTempMatchPool.prefix(3)).last!)"
                    if ((strTempMatchPool.prefix(4)).last! != "-") {
                        self.currentPoolType = "\(self.currentPoolType!)\((strTempMatchPool.prefix(4)).last!)"
                    }
                }
            } else if (strTempMatchPool.first!).lowercased() == "l" {
                strType = "Lower"
                if (strTempMatchPool == "Loser Final")
                {
                    strType = "Upper"
                    self.currentPoolType = "Upper RTF"
                }
                else if strTempMatchPool.contains("RTF")
                {
                    self.currentPoolType = "Lower RTF"
                }
                else
                {
                    self.currentPoolType = "Lower \((strTempMatchPool.prefix(3)).last!)"
                    if ((strTempMatchPool.prefix(4)).last! != "-") {
                        self.currentPoolType = "\(self.currentPoolType!)\((strTempMatchPool.prefix(4)).last!)"
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.lblBracketPool.text = self.currentPoolType!
        }
        
        //if self.strBracketType != strType {
          //  self.strBracketType = strType
        //}
        
        self.arrBracket = self.arrAllBracket.filter{ $0.bracketType == strType }
        self.arrRound.removeAll()
        
        self.roundIndex = 0
        if self.arrBracket.count > 0 {
            //self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()

            self.arrRound.removeAll()
            self.arrNextMatch.removeAll()
            self.arrBracketDetail.removeAll()
            
            for i in 0 ..< self.arrBracket.count {
                var arrTemp = [BracketDetail]()
                arrTemp = (self.arrBracket[0].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                
                if arrTemp.count > 0 {
                    break
                } else {
                    self.arrBracket.remove(at: 0)
                }
            }
            
            for i in 0 ..< self.arrBracket.count {
                
                var arrTempBracketDetail = [BracketDetail]()
                arrTempBracketDetail = (self.arrBracket[i].data ?? [BracketDetail]()).filter { $0.poolType == self.currentPoolType! }
                //self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
                
                if arrTempBracketDetail.count > 0 {
                    self.arrRound.append(self.arrBracket[i].tabName ?? "")
                    
                    var arr = [Int]()
                    var bracket = [BracketDetail]()
                    bracket = arrTempBracketDetail
                    for j in 0 ..< bracket.count {
                        arr.append(bracket[j].matchNo!)
                    }
                    self.arrNextMatch.append(arr)
                }
            }
            
            if self.arrBracket.count > 0 {
                self.arrBracketDetail = self.arrBracket[0].data ?? [BracketDetail]()
                self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == self.currentPoolType! }
            }

            self.cvRound.reloadData()
            self.tvMatch.reloadData()
            self.cvRound.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
    }
}

//MARK:- UITableViewDataSource,UITableViewDelegate
extension BracketTabVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBracketDetail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BracketCell", for: indexPath) as! BracketCell
        cell.selectionStyle = .none
        let arr = arrBracketDetail
        
        var isBye = false
        isBye = ((arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) || (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1)) ? true : false
        if arr[indexPath.row].matchTime == "" || arr[indexPath.row].matchTime == "TBD" {
            cell.lblNextMatchTime.text = "TBD"
        } else {
            cell.lblNextMatchTime.text = "\(arr[indexPath.row].onlyDate ?? "")\n\(arr[indexPath.row].matchTime ?? "") \(arr[indexPath.row].stationName ?? "")"  //  By Pranay - add station name.
        }
        
        cell.lblPlayer1Score.text = isBye ? "" : "\(arr[indexPath.row].homeTeamRoundWin ?? 0)"
        cell.lblPlayer2Score.text = isBye ? "" : "\(arr[indexPath.row].awayTeamRoundWin ?? 0)"
        cell.lblNextGame.text = arr[indexPath.row].roundLabel
        
        cell.lblPlayer1TeamNo.text = (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) ? "" : ((arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 0) ? "" : "\(arr[indexPath.row].homeTeamSeedNumber ?? 0)")
        cell.lblPlayer2TeamNo.text = (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1) ? "" : ((arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 0) ? "" : "\(arr[indexPath.row].awayTeamSeedNumber ?? 0)")
        
        if arr[indexPath.row].awayTeamRoundWin ?? 0 > arr[indexPath.row].homeTeamRoundWin ?? 0 {
            cell.lblPlayer2Score.font = Fonts.Bold.returnFont(size: 18.0)
            cell.lblPlayer1Score.font = Fonts.Regular.returnFont(size: 18.0)
        } else {
            cell.lblPlayer1Score.font = Fonts.Bold.returnFont(size: 18.0)
            cell.lblPlayer2Score.font = Fonts.Regular.returnFont(size: 18.0)
        }
        
        // Away team details
        if (arr[indexPath.row].awayTeam?.id != 0) {
            var awayTeamName = (arr[indexPath.row].awayTeam?.teamName ?? "").count > 20 ? String((arr[indexPath.row].awayTeam?.teamName ?? "")[..<(arr[indexPath.row].awayTeam?.teamName ?? "").index((arr[indexPath.row].awayTeam?.teamName ?? "").startIndex, offsetBy: 20)]) : (arr[indexPath.row].awayTeam?.teamName ?? "")
            awayTeamName = (arr[indexPath.row].awayTeam?.teamName ?? "").count > 20 ? (awayTeamName + "...") : awayTeamName
            // By Pranay
            //let playerName = arr[indexPath.row].awayTeam?.userName ?? ""
            let playerName = arr[indexPath.row].awayTeam?.displayName ?? ""
            // .
            if arr[indexPath.row].awayTeam?.isJoinAsPlayer == 1 {
                //cell.btnPlayer2Next.setTitle(awayTeamName, for: .normal)  //  comment by Pranay
                //cell.lblPlayer2.text = awayTeamName   //  comment by Pranay
                // By Pranay
                cell.btnPlayer2Next.setTitle(playerName, for: .normal)
                cell.lblPlayer2.text = playerName
                // .
            } else {
                //let team = awayTeamName   //  comment by Pranay
                //let player = arr[indexPath.row].awayTeam?.userName ?? ""  //  Comment by Pranay
                let finalName = "\(awayTeamName)\n\(playerName)"
                cell.btnPlayer2Next.setAttributedTitle(finalName.setRegularString(string: playerName, fontSize: 13.0), for: .normal)
                cell.lblPlayer2.attributedText = finalName.setRegularString(string: playerName, fontSize: 13.0)
            }
            cell.imgNextPlayer2.setImage(imageUrl: arr[indexPath.row].awayTeam?.awayImage ?? "")
        } else if (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 0) {
            cell.btnPlayer2Next.setTitle("\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "") >", for: .normal)
            cell.lblPlayer2.text = "\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "") >"
            cell.imgNextPlayer2.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        } else if (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1) {
            let strLabel : String = "\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "")".count > 0 ? "\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "") >" : "Bye"
            cell.btnPlayer2Next.setTitle(strLabel, for: .normal)
            //cell.lblPlayer2.text = "Bye!"
            cell.lblPlayer2.text = strLabel
            cell.imgNextPlayer2.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        }
        
        // Home team details
        if (arr[indexPath.row].homeTeam?.id != 0) {
            var homeTeamName = (arr[indexPath.row].homeTeam?.teamName ?? "").count > 15 ? String((arr[indexPath.row].homeTeam?.teamName ?? "")[..<(arr[indexPath.row].homeTeam?.teamName ?? "").index((arr[indexPath.row].homeTeam?.teamName ?? "").startIndex, offsetBy: 15)]) : (arr[indexPath.row].homeTeam?.teamName ?? "")
            homeTeamName = (arr[indexPath.row].homeTeam?.teamName ?? "").count > 15 ? (homeTeamName + "...") : homeTeamName
            // By Pranay
            //let playerName = arr[indexPath.row].homeTeam?.userName ?? ""
            let playerName = arr[indexPath.row].homeTeam?.displayName ?? ""
            // .
            if arr[indexPath.row].homeTeam?.isJoinAsPlayer == 1 {
                //cell.btnPlayer1Next.setTitle(homeTeamName, for: .normal)  //  comment by Pranay
                //cell.lblPlayer1.text = homeTeamName   //  comment by Pranay
                // By Pranay
                cell.btnPlayer1Next.setTitle(playerName, for: .normal)
                cell.lblPlayer1.text = playerName
                // .
            } else {
                //let team = homeTeamName //  comment by Pranay
                //let player = arr[indexPath.row].homeTeam?.userName ?? ""  //  comment by Pranay
                let finalName = "\(homeTeamName)\n\(playerName)"
                cell.btnPlayer1Next.setAttributedTitle(finalName.setRegularString(string: playerName, fontSize: 13.0), for: .normal)
                cell.lblPlayer1.attributedText = finalName.setRegularString(string: playerName, fontSize: 13.0)
            }
            cell.imgNextPlayer1.setImage(imageUrl: arr[indexPath.row].homeTeam?.homeImage ?? "")
        } else if (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 0) {
            cell.btnPlayer1Next.setTitle("\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "") >", for: .normal)
            cell.lblPlayer1.text = "\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "") >"
            cell.imgNextPlayer1.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        } else if (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) {
            let strLabel : String = "\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "")".count > 0 ? "\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "") >" : "Bye"
            cell.btnPlayer1Next.setTitle(strLabel, for: .normal)
            //cell.lblPlayer1.text = "Bye!"
            cell.lblPlayer1.text = strLabel
            cell.imgNextPlayer1.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        }
        
        if arr[indexPath.row].isPlayed == 1 {
            //match completed
            cell.viewTime.isHidden = true
            cell.lblMyGame.isHidden = true
            cell.viewScore.isHidden = false
            cell.lblPlayer1Score.isHidden = false
            cell.lblPlayer2Score.isHidden = false
            cell.player1Trailing.constant = 44
            if arr[indexPath.row].isMyGame == "1" {
                cell.viewShadow.addshadowToView(top: true, left: false, bottom: true, right: false, shadowRadius: 8.0)
            } else {
                cell.viewShadow.addshadowToView(top: false, left: false, bottom: false, right: false, shadowRadius: 0.0)
            }
        } else {
            if arr[indexPath.row].matchStatus == 6 { //live match status 6
                if arr[indexPath.row].homeTeamRoundWin == 0 && arr[indexPath.row].awayTeamRoundWin == 0 {
                    cell.lblPlayer1Score.isHidden = true
                    cell.lblPlayer2Score.isHidden = true
                    cell.viewScore.isHidden = true
                    cell.viewTime.isHidden = false
                } else {
                    cell.lblPlayer1Score.isHidden = false
                    cell.lblPlayer2Score.isHidden = false
                    cell.viewScore.isHidden = false
                    cell.viewTime.isHidden = true
                }
//                cell.viewTime.isHidden = true
            } else {
                cell.lblPlayer1Score.isHidden = true
                cell.lblPlayer2Score.isHidden = true
                cell.viewScore.isHidden = true
                cell.viewTime.isHidden = false
            }
            if arr[indexPath.row].isMyGame == "1" {
                if arr[indexPath.row].homeTeamRoundWin == 0 && arr[indexPath.row].awayTeamRoundWin == 0 {
                    cell.player1Trailing.constant = 100
                    cell.lblMyGame.isHidden = false
                    cell.viewShadow.addshadowToView(top: true, left: false, bottom: true, right: false, shadowRadius: 8.0)
                } else {
                    cell.player1Trailing.constant = 44
                    cell.lblMyGame.isHidden = true
                }
//                if arr[indexPath.row].matchStatus == 6 {
//                    cell.player1Trailing.constant = 44
//                    cell.lblMyGame.isHidden = true
//                } else {
//                    cell.player1Trailing.constant = 100
//                    cell.lblMyGame.isHidden = false
//                }
//                cell.player1Trailing.constant = 100
//                cell.lblMyGame.isHidden = false
//                cell.viewShadow.addshadowToView(top: true, left: false, bottom: true, right: false, shadowRadius: 8.0)
            } else {
                cell.player1Trailing.constant = 44
                cell.lblMyGame.isHidden = true
                cell.viewShadow.addshadowToView(top: false, left: false, bottom: false, right: false, shadowRadius: 0.0)
            }
        }
        
        if arr[indexPath.row].decideBy == "PLAY" {
            cell.lblForfeit.isHidden = true
        } else {
            cell.lblForfeit.isHidden = false
            cell.viewTime.isHidden = true
            cell.viewScore.isHidden = true
        }
        
        if isBye {
            cell.viewScore.isHidden = true
            cell.viewTime.isHidden = true
        }
        
        cell.onTapBoxScore = { index in
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "BoxscoreVC") as! BoxscoreVC
            objVC.matchId = arr[indexPath.row].id
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        
        cell.onTapHomeMatch = { index in
            //if arr[indexPath.row].isPlayed == 0 {
                //if arr[indexPath.row].parentHomeTeamMatchNo != 0 && arr[indexPath.row].homeTeam?.id == 0 && (arr[indexPath.row].isBye == 0 || arr[indexPath.row].isBye == 1) {
            if arr[indexPath.row].parentHomeTeamMatchNo != 0 && arr[indexPath.row].homeTeam?.id == 0 {  //  By Pranay Condition
                var isInnerPool : Bool = false
                for i in 0 ..< self.arrNextMatch.count {
                    if self.arrNextMatch[i].contains(arr[indexPath.row].parentHomeTeamMatchNo!) {
                        self.roundIndex = i
                        self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
                        if self.isBracketFilterActive! {
                            self.arrBracketDetail = (self.arrBracket[self.roundIndex].data ?? [BracketDetail]()).filter{ $0.poolType == self.currentPoolType! }
                        }
                        self.cvRound.reloadData()
                        self.tvMatch.reloadData()
                        let indexPath:IndexPath = IndexPath(row: self.arrNextMatch[i].firstIndex(of: arr[indexPath.row].parentHomeTeamMatchNo!)!, section: 0)
                        self.tvMatch.scrollToRow(at: indexPath, at: .none, animated: true)
                        isInnerPool = true
                        break
                    }
                }
                // By Pranay
                if !isInnerPool {
                    print("From outer pool. - Home Team")
                    
                    let intParentHomeTeamMatchNo: Int = arr[indexPath.row].parentHomeTeamMatchNo!
                    
                    var strTempMatchPool : String = (arr[indexPath.row].parentHomeTeamWinnerLabel)!
                    
                    self.moveToPreviousMatch(strMatchPool: strTempMatchPool)
                    
                    for i in 0 ..< self.arrNextMatch.count {
                        if self.arrNextMatch[i].contains(intParentHomeTeamMatchNo) {
                            self.roundIndex = i
                            self.arrBracketDetail = (self.arrBracket[self.roundIndex].data ?? [BracketDetail]()).filter{ $0.poolType == self.currentPoolType! }
                            self.cvRound.reloadData()
                            self.tvMatch.reloadData()
                            let indexPath:IndexPath = IndexPath(row: self.arrNextMatch[i].firstIndex(of: intParentHomeTeamMatchNo)!, section: 0)
                            self.tvMatch.scrollToRow(at: indexPath, at: .none, animated: true)
                            self.cvRound.scrollToItem(at: IndexPath(item: i, section: 0), at: .left, animated: true)
                            isInnerPool = true
                            break
                        }
                    }
                }   //  .
                //}
            } else {
//                //tournament log
//                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "TournamentLogVC") as! TournamentLogVC
//                for i in 0 ..< self.arrRound.count {
//                    let total = self.arrBracket[i].data ?? [BracketDetail]()
//                    for j in 0 ..< total.count {
//                        if total[j].homeTeamId == arr[indexPath.row].homeTeam?.id && total[j].isPlayed == 1 {
//                            objVC.arrBracketDetail.append(total[j])
//                        }
//                    }
//                }
//                objVC.leagueTabVC = self.leagueTabVC
//                objVC.isHost = true
//                objVC.bracketDetail = arr[indexPath.row]
//                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
        
        cell.onTapAwayMatch = { index in
            //if arr[indexPath.row].isPlayed == 0 {
                //if arr[indexPath.row].parentAwayTeamMatchNo != 0 && arr[indexPath.row].awayTeam?.id == 0 && (arr[indexPath.row].isBye == 0 || arr[indexPath.row].isBye == 1) {
            if arr[indexPath.row].parentAwayTeamMatchNo != 0 && arr[indexPath.row].awayTeam?.id == 0 {
                var isInnerPool : Bool = false
                for i in 0 ..< self.arrNextMatch.count {
                    if self.arrNextMatch[i].contains(arr[indexPath.row].parentAwayTeamMatchNo!) {
                        self.roundIndex = i
                        self.arrBracketDetail = self.arrBracket[self.roundIndex].data ?? [BracketDetail]()
                        if self.isBracketFilterActive! {
                            self.arrBracketDetail = (self.arrBracket[self.roundIndex].data ?? [BracketDetail]()).filter{ $0.poolType == self.currentPoolType! }
                        }
                        self.cvRound.reloadData()
                        self.tvMatch.reloadData()
                        let indexPath:IndexPath = IndexPath(row: self.arrNextMatch[i].firstIndex(of: arr[indexPath.row].parentAwayTeamMatchNo!)!, section: 0)
                        self.tvMatch.scrollToRow(at: indexPath, at: .none, animated: true)
                        isInnerPool = true
                        break
                    }
                }
                //  By Pranay
                if !isInnerPool {
                    print("From outer pool. - Away Team")
                    
                    let intParentAwayTeamMatchNo: Int = arr[indexPath.row].parentAwayTeamMatchNo!
                    
                    var strTempMatchPool : String = (arr[indexPath.row].parentAwayTeamWinnerLabel)!
                    
                    // Here
                    self.moveToPreviousMatch(strMatchPool: strTempMatchPool)
                    //  */
                    
                    for i in 0 ..< self.arrNextMatch.count {
                        if self.arrNextMatch[i].contains(intParentAwayTeamMatchNo) {
                            self.roundIndex = i
                            self.arrBracketDetail = (self.arrBracket[self.roundIndex].data ?? [BracketDetail]()).filter{ $0.poolType == self.currentPoolType! }
                            self.cvRound.reloadData()
                            self.tvMatch.reloadData()
                            let indexPath:IndexPath = IndexPath(row: self.arrNextMatch[i].firstIndex(of: intParentAwayTeamMatchNo)!, section: 0)
                            self.tvMatch.scrollToRow(at: indexPath, at: .none, animated: true)
                            self.cvRound.scrollToItem(at: IndexPath(item: i, section: 0), at: .left, animated: true)
                            isInnerPool = true
                            break
                        }
                    }
                }   //  .
                //}
            } else {
//                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "TournamentLogVC") as! TournamentLogVC
//                for i in 0 ..< self.arrRound.count {
//                    let total = self.arrBracket[i].data ?? [BracketDetail]()
//                    for j in 0 ..< total.count {
//                        if total[j].awayTeamId == arr[indexPath.row].awayTeam?.id && total[j].isPlayed == 1 {
//                            objVC.arrBracketDetail.append(total[j])
//                        }
//                    }
//                }
//                objVC.leagueTabVC = self.leagueTabVC
//                objVC.bracketDetail = arr[indexPath.row]
//                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK:- UICollectionViewDelegate
extension BracketTabVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrRound.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BracketRoundCell", for: indexPath) as! BracketRoundCell
        cell.lblTitle.text = arrRound[indexPath.row]
        
        if roundIndex == indexPath.row {
            cell.lblSelected.isHidden = false
        } else {
            cell.lblSelected.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        roundIndex = indexPath.row
        // By Pranay - Only if condition
        if arrBracketDetail.count > 0 {
            let topIndex = IndexPath(row: 0, section: 0)
            self.tvMatch.scrollToRow(at: topIndex, at: .top, animated: true)
        }   //.
        self.arrBracketDetail = arrBracket[roundIndex].data ?? [BracketDetail]()
        // By Pranay
        if self.isBracketFilterActive! {
            self.arrBracketDetail = self.arrBracketDetail.filter { $0.poolType == (self.lblBracketPool.text)! }
        }
        //.
        cvRound.reloadData()
        tvMatch.reloadData()
        self.cvRound.scrollToItem(at: IndexPath(item: roundIndex, section: 0), at: .left, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return arrRound[indexPath.row].size(withAttributes: nil)
    }
}

extension BracketTabVC : WKNavigationDelegate, UIScrollViewDelegate {
    // WKWebViewNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            print("Link activated...")
            guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
                decisionHandler(.cancel)
                return
            }
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
