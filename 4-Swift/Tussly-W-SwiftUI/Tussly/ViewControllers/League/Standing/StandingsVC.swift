//
//  StandingsVC.swift
//  - Designed Standings screen to display current Standings of each team of League module

//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView
import WebKit

class StandingsVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var cvStanding: UICollectionView!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var cvStandingGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvStandingGridLayout.stickyRowsCount = 1
            cvStandingGridLayout.stickyColumnsCount = 2
        }
    }
    @IBOutlet weak var btnDispCharPlayer: UIButton!
    
    @IBOutlet weak var viewWebView: UIView!
    
    
    // MARK: - Variables
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var standingData: [[String: Any]]!
    
    
    /// 223 - By Pranay
    var isCharDisplay: Bool = false
    var isPopupRemovedFromStack = false
    var charRowHeaders: [String]!
    var charStandingData: [[String: Any]]!
    var isGetCharacterLeaderboards: Bool = false
    var isGetPlayerCharacter: Bool = false
    var maxCharacterLimit: Int? = 0
    var playerCharacter: [PlayerAllCharacter]?
    /// 223 .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoData.isHidden = true
        cvStanding.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvStanding.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
//        setbtnRight()
//        if leagueTabVC!().userRole != nil {
//            if (APIManager.sharedManager.isShoesCharacter ?? "") == "Yes" {
//                self.getPlayerCharacterDetails()
//            }
//            self.getStandingDetails()
//        }else {
//            cvStanding.reloadData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*setbtnRight()
        if leagueTabVC!().userRole != nil {
            if (APIManager.sharedManager.isShoesCharacter ?? "") == "Yes" {
                self.getPlayerCharacterDetails()
            }
            self.getStandingDetails()
        }else {
            cvStanding.reloadData()
        }
        
        if APIManager.sharedManager.leagueType != "League" {
            lblTitle.text = "Tournament Leaderboard"
        }   //  */
        
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        
        //let bracketUrl: String = "\(self.leagueTabVC!().getLeagueMatches?.bracketBaseUrl ?? "")\(APIManager.sharedManager.user?.id ?? 0)/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
        let bracketUrl: String = "\(self.leagueTabVC!().getLeagueMatches?.frontEndBaseUrl ?? "")mobile-leaderboard/\(APIManager.sharedManager.user?.id ?? 0)/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
        self.setupWebView(htmlContent: bracketUrl)
        print("Bracket URL -> \(bracketUrl)")
        
        self.showLoading()
        self.viewWebView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewWebView.isHidden = false
            self.hideLoading()
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
    
    func setbtnRight() {
        if self.view.frame.size.width >= self.cvStanding.collectionViewLayout.collectionViewContentSize.width {
            self.btnRight.isHidden = true
        } else {
            self.btnRight.isHidden = false
        }
        
        if self.cvStanding.collectionViewLayout.collectionViewContentSize.height > self.cvStanding.frame.size.height - 40 {
            heightBtnRight.constant = self.cvStanding.frame.size.height - 40
        } else {
            heightBtnRight.constant = self.cvStanding.collectionViewLayout.collectionViewContentSize.height - 40
        }
    }
    
    @IBAction func btnDispCharPlayerTap(_ sender: UIButton) {
        self.showLoading()
        if isCharDisplay {
            lblNoData.isHidden = (standingData?.count ?? 0) == 0 ? false : true
            btnDispCharPlayer.setTitle("Characters >", for: .normal)
            isCharDisplay = false
            self.cvStanding.reloadData()
            self.cvStanding.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            self.hideLoading()
        } else {
            btnDispCharPlayer.setTitle("Players >", for: .normal)
            isCharDisplay = true
            if isGetCharacterLeaderboards {
                lblNoData.isHidden = (charStandingData?.count ?? 0) == 0 ? false : true
                self.cvStanding.reloadData()
                self.cvStanding.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                self.hideLoading()
            } else {
                self.getCharacterStandingDetails()
            }
        }
        self.btnRight.isHidden = self.isCharDisplay ? true : false
    }
    
    // MARK: Webservices
    
    func getStandingDetails() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getStandingDetails()
                }
            }
            return
        }
        
//        self.navigationController?.view.tusslyTabVC.showLoading()
        //APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_STANDING, parameters: ["leagueId" : leagueTabVC!().tournamentDetail?.id ?? 0]) { (response: ApiResponse?, error) in
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TOURNAMENT_LEADERBOARD, parameters: ["leagueId" : leagueTabVC!().tournamentDetail?.id ?? 0]) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.rowHeaders = (response?.result?.header)!
                    
                    let stands = (response?.result?.standings)!
                    self.standingData = stands["stands"] as? [[String : Any]]
                    self.lblTitle.isHidden = false  
                    if self.standingData.count == 0 {
                        self.lblNoData.isHidden = false
                        //self.lblTitle.isHidden = true
                    } else {
                        self.lblNoData.isHidden = true
                        //self.lblTitle.isHidden = false
                    }
                    self.lblNoData.isHidden = true
                    self.cvStanding.reloadData()
                    self.cvStanding.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    self.setbtnRight()
                } else {
                    self.lblTitle.isHidden = true
                    self.lblNoData.isHidden = false
                    self.standingData = [[String: Any]]()
                    self.cvStanding.reloadData()
                }
            }
        }
    }
    
    /// 3344 - By Pranay
    func getCharacterStandingDetails() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getCharacterStandingDetails()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_CHARACTER_LEADERBOARD, parameters: ["leagueId" : leagueTabVC!().tournamentDetail?.id ?? 0]) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.charRowHeaders = (response?.result?.header)!
                   
                    let stands = (response?.result?.standings)!
                    //self.standingData = stands["stands"] as? [[String : Any]]
                    self.charStandingData = stands["stands"] as? [[String : Any]]
                    
                    if self.charStandingData.count == 0 {
                        self.lblNoData.isHidden = false
                        //self.lblTitle.isHidden = true
                    } else {
                        self.lblNoData.isHidden = true
                        self.lblTitle.isHidden = false
                    }
                    self.cvStanding.reloadData()
                    self.cvStanding.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                    self.isGetCharacterLeaderboards = true
                    //self.setbtnRight()
                } else {
                    self.charRowHeaders = [String]()
                    //self.charRowHeaders = ["Rank", "Character", "RW", "RL", "S +/-"]
                    self.charStandingData = [[String: Any]]()
                    self.cvStanding.reloadData()
                    //self.lblTitle.isHidden = true
                    self.lblNoData.isHidden = false
                }
                self.hideLoading()
            }
        }
    }
    
    func getPlayerCharacterDetails() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayerCharacterDetails()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_CHARACTER, parameters: ["leagueId" : leagueTabVC!().tournamentDetail?.id ?? 0]) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.maxCharacterLimit = response?.result?.maxCharLimit
                    self.playerCharacter = response?.result?.playerAllCharacters
                    self.isGetPlayerCharacter = true
                } else {
                    
                }
            }
        }
    }
    /// 3344 .
}


// MARK: - UICollectionViewDelegate

extension StandingsVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isCharDisplay ? ((charStandingData?.count ?? 10) + 1) : ((standingData?.count ?? 10) + 1)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCharDisplay ? (charRowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) : (rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                          for: indexPath) as! ContentCollectionViewCell
            if rowHeaders != nil {
//                cell.hideAnimation()
                cell.contentLabel.text = self.isCharDisplay ? charRowHeaders[indexPath.row] : rowHeaders[indexPath.row]
            }else {
                cell.contentLabel.text = ""
//                cell.showAnimation()
            }
            cell.contentLabel.textColor = UIColor.white
            cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
            //cell.backgroundColor = Colors.black.returnColor() // Comment by pranay
            /// 322 - By Pranay - added for change header color
            cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
            /// 322 .   */
            return cell
        } else {
            if indexPath.row == 1 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                for: indexPath) as! PlayerCVCell
                cell.ivCaptainCap.isHidden = true
                cell.horizontalSeperater.isHidden = true
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = self.isCharDisplay ? (charStandingData[indexPath.section - 1][charRowHeaders[indexPath.row]] ?? "") as? String : (standingData[indexPath.section - 1][rowHeaders[indexPath.row]] as? String)
                    cell.ivPlayer.setImage(imageUrl: self.isCharDisplay ? (charStandingData[indexPath.section - 1]["characterImage"] as! String) : (standingData[indexPath.section - 1]["logoImage"] as! String))
                    cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.height/2
                }else {
                    cell.lblPlayerName.text = ""
//                    cell.showAnimation()
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let standingRow = self.isCharDisplay ? charStandingData[indexPath.section - 1] : standingData[indexPath.section - 1]
                    cell.contentLabel.text = self.isCharDisplay ? "\(standingRow[charRowHeaders[indexPath.row]]!)" : "\(standingRow[rowHeaders[indexPath.row]]!)"
                } else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
                return cell
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x
        if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth) {
            btnRight.isHidden = true
        } else {
            btnRight.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150.0) + CGFloat((((self.isCharDisplay ? charRowHeaders?.count : rowHeaders?.count) ?? SKELETON_ROWHEADER_COUNT) - 1) * 40)) > CGFloat(self.view.frame.width) ? 40.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150.0)) / CGFloat(((self.isCharDisplay ? charRowHeaders?.count : rowHeaders?.count) ?? SKELETON_ROWHEADER_COUNT) - 1)
        
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150.0) + CGFloat((((self.isCharDisplay ? charRowHeaders?.count : rowHeaders?.count) ?? SKELETON_ROWHEADER_COUNT) - 1) * 40)) > CGFloat(self.view.frame.width) ? 40.0 : ((CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150.0)) / CGFloat(((self.isCharDisplay ? charRowHeaders?.count : rowHeaders?.count) ?? SKELETON_ROWHEADER_COUNT) - 1))
        
        //return CGSize(width: indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150 : (indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? currentWidth : 60.0 : currentWidth), height: 40)
        return CGSize(width: indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 150 : (indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? currentWidth : 60.0 : indexPath.row == 6 ? 50.0 : currentWidth ), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isCharDisplay && self.isGetPlayerCharacter && (indexPath.row == 1) && ((APIManager.sharedManager.isShoesCharacter ?? "") == "Yes") {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "DisplayPlayerCharacterPopup") as! DisplayPlayerCharacterPopup
            //dialog.isFromNextRound = true
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            //dialog.strCharName = self.lblCharacter.text!
            let tChar: [PlayerAllCharacter] = (self.playerCharacter?.filter({ $0.playerId == (standingData[indexPath.section - 1]["playerId"] as? Int)! }))!
            dialog.playerCharacter = (tChar.count > 0) ? tChar[0].characters : []
            dialog.maxCharacterLimit = self.maxCharacterLimit
            //dialog.playerCharacter = self.playerCharacter![0].characters
            dialog.strUserName = (standingData[indexPath.section - 1][rowHeaders[indexPath.row]] as? String)!
            dialog.strUserProfileImg = standingData[indexPath.section - 1]["logoImage"] as! String
            
            dialog.tapOk = { arr in
            }
            
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        } else {
            if !isCharDisplay {
                self.getPlayerCharacterDetails()
            }
        }
    }
}

extension StandingsVC : WKNavigationDelegate, UIScrollViewDelegate {
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
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }   //  */
}
