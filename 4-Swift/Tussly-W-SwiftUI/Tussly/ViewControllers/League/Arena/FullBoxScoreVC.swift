//
//  ResultDetailVC.swift
//  - Designed Result Details screen for League Module

//  Tussly
//
//  Created by Auxano on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class FullBoxScoreVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var cvTeamPlayers: UICollectionView!
    @IBOutlet weak var heightCvTeamPlayer : NSLayoutConstraint!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var btnRightPlayer: UIButton!
    @IBOutlet weak var heightBtnRightPlayer: NSLayoutConstraint!
    @IBOutlet weak var lblTeam1Name: UILabel!
    @IBOutlet weak var lblTeam2Name: UILabel!
    @IBOutlet var btnTeams: [UIButton]!
    @IBOutlet weak var viewTab: UIView!
    @IBOutlet var cvTeamOverviewGridLayout: [StickyGridCollectionViewLayout]! {
        didSet {
            for layout in cvTeamOverviewGridLayout {
                layout.stickyRowsCount = 1
                layout.stickyColumnsCount = 1
            }
        }
    }
    
    // MARK: - Variables
    
    var leagueConsoleId = -1
    var gameId = -1
    var matchId = -1
    var matchData : Match?
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]?
    var players: [[String: Any]]?
    var tempPlayer = [[String: Any]]()
    var teamHeaders = [String]()
    //var teams: [Result]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvTeamPlayers.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        cvTeamPlayers.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        self.cvTeamPlayers.reloadData()
        getBoxScorResultData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.heightCvTeamPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height
        self.heightBtnRightPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height - 40
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        btnTeams[0].isSelected = true
        btnTeams[0].setTitle(matchData?.homeTeamName ?? "", for: .normal)
        btnTeams[1].setTitle(matchData?.awayTeamName ?? "", for: .normal)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapTeam(_ sender: UIButton) {
        if sender.isSelected != true {
            sender.isSelected = !sender.isSelected
            for btn in btnTeams {
                if sender.tag == btn.tag {
                    btn.backgroundColor = Colors.black.returnColor()
                    btn.setTitleColor(UIColor.white, for: .normal)
                } else {
                    btn.isSelected = false
                    btn.backgroundColor = Colors.lightGray.returnColor()
                    btn.setTitleColor(Colors.black.returnColor(), for: .normal)
                }
            }
        }
        
        if btnTeams[0].isSelected {
            self.players = self.tempPlayer.filter {
                $0["teamId"] as? Int == self.matchData?.homeTeamId
            }
        } else {
            self.players = self.tempPlayer.filter {
                //$0["teamId"] as? Int == self.matchData?.teamId
                $0["teamId"] as? Int == self.matchData?.leagueId
            }
        }
        cvTeamPlayers.reloadData()
    }
    
    // MARK: Webservices
    
    func getBoxScorResultData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getBoxScorResultData()
                }
            }
            return
        }
        
//        self.navigationController?.view.tusslyTabVC.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_BOX_SCOR_RESULT, parameters: ["matchId" : self.matchId,"gameId":self.gameId]) { (response: ApiResponse?, error) in
//            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
//            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    let resultDic = (response?.result?.playerResults)!
                    self.tempPlayer = (resultDic["results"] as? [[String : Any]])!
                    if self.tempPlayer.count > 0 {
                        self.cvTeamPlayers.isHidden = false
                        self.btnRightPlayer.isHidden = false
                        self.viewTab.isHidden = false
                        
                        self.rowHeaders = (resultDic["playerHeader"] as? [String])!
                        //self.teams = (response?.result?.roundResults)!
                        self.players = self.tempPlayer.filter {
                            $0["teamId"] as? Int == self.matchData?.homeTeamId
                        }
                        self.cvTeamPlayers.reloadData()
                        DispatchQueue.main.async {
                            self.heightBtnRightPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height - 40
                            self.heightCvTeamPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height
                            self.view.layoutIfNeeded()
                        }
                    } else {
                        self.cvTeamPlayers.isHidden = true
                        self.btnRightPlayer.isHidden = true
                        self.viewTab.isHidden = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.cvTeamPlayers.isHidden = true
                    self.btnRightPlayer.isHidden = true
                    self.viewTab.isHidden = true
                }
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FullBoxScoreVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (players?.count ?? 5) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && indexPath.section != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
            for: indexPath) as! PlayerCVCell
            cell.horizontalSeperater.backgroundColor = Colors.border.returnColor()
            cell.horizontalSeperater.isHidden = true
            if players != nil {
//                cell.hideAnimation()
                cell.lblPlayerName.text = players![indexPath.section - 1][rowHeaders![indexPath.row]] as? String
                if collectionView.tag == 1 {
                    cell.ivPlayer.setImage(imageUrl: players![indexPath.section - 1]["avatarImage"] as! String)
                    cell.ivCaptainCap.image = UIImage(named: players![indexPath.section - 1]["role"] as! Int == 2 ? "Captain" : players![indexPath.section - 1]["role"] as! Int == 5 ? "AssistantCaptain" : "")
                }
            }else {
//                cell.showAnimation()
            }
            
            cell.trailIVPlayer.constant = 8
            cell.widthIVPlayer.constant = 20
            cell.lblPlayerName.font = Fonts.Regular.returnFont(size: 12.0)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
            for: indexPath) as! ContentCollectionViewCell
            if indexPath.section == 0 {
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.contentLabel.text = rowHeaders![indexPath.item]
                }else {
//                    cell.showAnimation()
                }
                
                cell.horizontalSeprater.isHidden = true
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                cell.contentLabel.minimumScaleFactor = 0.5
                cell.backgroundColor = Colors.black.returnColor()
            } else {
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let playerRow = players![indexPath.section - 1]
                    cell.contentLabel.text = "\(playerRow[rowHeaders![indexPath.row]]!)"
                }else {
//                    cell.showAnimation()
                }
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
            }
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x

        if (scrollOffset + scrollViewWidth == scrollContentSizeWidth) {
            btnRightPlayer.isHidden = true
        } else {
            btnRightPlayer.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 80)) > CGFloat(self.view.frame.width) ? 80.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
            
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 210 : 150 :  currentWidth, height: 40)
    }
}
