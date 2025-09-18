//
//  ResultDetailVC.swift
//  - Designed Result Details screen for League Module

//  Tussly
//
//  Created by Auxano on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultDetailVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var cvTeamPlayers: UICollectionView!
    @IBOutlet weak var heightCvTeamPlayer : NSLayoutConstraint!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnRightPlayer: UIButton!
    @IBOutlet weak var heightBtnRightPlayer: NSLayoutConstraint!
    @IBOutlet weak var viewImageTeam1: UIView!
    @IBOutlet weak var viewImageTeam2: UIView!
    @IBOutlet weak var ivTeam1: UIImageView!
    @IBOutlet weak var ivTeam2: UIImageView!
    @IBOutlet weak var lblTeam1Won: UILabel!
    @IBOutlet weak var lblTeam2Won: UILabel!
    @IBOutlet weak var lblTeam1Name: UILabel!
    @IBOutlet weak var lblTeam2Name: UILabel!
    @IBOutlet weak var cvTeamOverview: UICollectionView!
    @IBOutlet weak var heightCvTeamOverview : NSLayoutConstraint!
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
    var selectedResult:Result?
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]?
    var players: [[String: Any]]?
    var tempPlayer = [[String: Any]]()
    var teamHeaders = [String]()
    var teams: [Result]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvTeamPlayers.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        cvTeamPlayers.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        
        cvTeamOverview.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: contentCellIdentifier)
        cvTeamOverview.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        
        DispatchQueue.main.async {
            self.setupUI()
            self.viewImageTeam1.layer.cornerRadius = self.viewImageTeam1.frame.width/2
            self.viewImageTeam2.layer.cornerRadius = self.viewImageTeam2.frame.width/2
        }
        
        self.cvTeamPlayers.reloadData()
        self.cvTeamOverview.reloadData()
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
        btnTeams[0].setTitle(selectedResult?.homeTeamName ?? "", for: .normal)
        btnTeams[1].setTitle(selectedResult?.awayTeamName ?? "", for: .normal)
        self.lblTeam1Won.text = "\(selectedResult?.homeTeamRoundWin ?? 0)"
        self.lblTeam1Name.text = "\(selectedResult?.homeTeamName ?? "")"
        self.ivTeam1.setImage(imageUrl: selectedResult?.homeTeamLogoImage ?? "")
        self.lblTeam1Won.layer.borderWidth = 2.0
        self.lblTeam1Won.layer.cornerRadius = self.lblTeam1Won.frame.size.width / 2
        self.lblTeam1Won.layer.borderColor = UIColor.white.cgColor
        self.lblTeam1Won.layer.masksToBounds = true
        
        self.lblTeam2Won.text = "\(selectedResult?.awayTeamRoundWin ?? 0)"
        self.lblTeam2Name.text = "\(selectedResult?.awayTeamName ?? "")"
        self.ivTeam2.setImage(imageUrl: selectedResult?.awayTeamLogoImage ?? "")
        self.lblTeam2Won.layer.borderWidth = 2.0
        self.lblTeam2Won.layer.cornerRadius = self.lblTeam1Won.frame.size.width / 2
        self.lblTeam2Won.layer.borderColor = UIColor.white.cgColor
        self.lblTeam2Won.layer.masksToBounds = true
        self.ivTeam1.layer.cornerRadius = self.ivTeam1.frame.size.width/2
        self.ivTeam2.layer.cornerRadius = self.ivTeam2.frame.size.width/2
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openTeamDetails(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamDetailVC") as! TeamDetailVC
        objVC.leagueConsoleId = leagueConsoleId
        objVC.gameId = gameId
        objVC.teamId = (sender.tag == 0 ? self.selectedResult?.homeTeamId : self.selectedResult?.awayTeamId) ?? -1
        objVC.teamName = (sender.tag == 0 ? self.selectedResult?.homeTeamName : self.selectedResult?.awayTeamName) ?? ""
        objVC.teamIcon = (sender.tag == 0 ? self.selectedResult?.homeTeamLogoImage : self.selectedResult?.awayTeamLogoImage) ?? ""
        self.navigationController?.pushViewController(objVC, animated: true)
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
                $0["teamId"] as? Int == self.selectedResult?.homeTeamId
            }
        } else {
            self.players = self.tempPlayer.filter {
                $0["teamId"] as? Int == self.selectedResult?.awayTeamId
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_BOX_SCOR_RESULT, parameters: ["matchId" : selectedResult?.id as Any,"gameId":gameId]) { (response: ApiResponse?, error) in
//            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
//            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    let resultDic = (response?.result?.playerResults)!
                    self.tempPlayer = (resultDic["results"] as? [[String : Any]])!
                    if self.tempPlayer.count > 0 {
                        self.cvTeamPlayers.isHidden = false
                        self.cvTeamOverview.isHidden = false
                        self.btnRight.isHidden = false
                        self.btnRightPlayer.isHidden = false
                        self.viewTab.isHidden = false
                        
                        self.rowHeaders = (resultDic["playerHeader"] as? [String])!
                        self.teams = (response?.result?.roundResults)!
                        self.players = self.tempPlayer.filter {
                            $0["teamId"] as? Int == self.selectedResult?.homeTeamId
                        }
                        self.cvTeamPlayers.reloadData()
                        self.cvTeamOverview.reloadData()
                        DispatchQueue.main.async {
                            self.heightCvTeamOverview.constant = self.cvTeamOverview.collectionViewLayout.collectionViewContentSize.height
                            self.heightBtnRightPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height - 40
                            self.heightBtnRight.constant = self.cvTeamOverview.collectionViewLayout.collectionViewContentSize.height - 40
                            self.heightCvTeamPlayer.constant = self.cvTeamPlayers.collectionViewLayout.collectionViewContentSize.height
                            self.view.layoutIfNeeded()
                        }
                    } else {
                        self.cvTeamPlayers.isHidden = true
                        self.cvTeamOverview.isHidden = true
                        self.btnRight.isHidden = true
                        self.btnRightPlayer.isHidden = true
                        self.viewTab.isHidden = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.cvTeamPlayers.isHidden = true
                    self.cvTeamOverview.isHidden = true
                    self.btnRight.isHidden = true
                    self.btnRightPlayer.isHidden = true
                    self.viewTab.isHidden = true
                }
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ResultDetailVC: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 0 {
            return 3
        } else {
            return (players?.count ?? 5) + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return (teams?.count ?? SKELETON_ROWHEADER_COUNT) + 1
        } else {
            return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && indexPath.section != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
            for: indexPath) as! PlayerCVCell
            cell.horizontalSeperater.backgroundColor = Colors.border.returnColor()
            cell.horizontalSeperater.isHidden = collectionView.tag == 0 ? false : true
            if teams != nil {
//                cell.hideAnimation()
                cell.lblPlayerName.text = collectionView.tag == 0 ? indexPath.section == 1 ? selectedResult?.homeTeamName : selectedResult?.awayTeamName : players![indexPath.section - 1][rowHeaders![indexPath.row]] as? String
                if collectionView.tag == 1 {
                    cell.ivPlayer.setImage(imageUrl: players![indexPath.section - 1]["avatarImage"] as! String)
                    cell.ivCaptainCap.image = UIImage(named: players![indexPath.section - 1]["role"] as! Int == 2 ? "Captain" : players![indexPath.section - 1]["role"] as! Int == 5 ? "AssistantCaptain" : "")
                } else {
                    cell.ivCaptainCap.isHidden = true
                }
            }else {
//                cell.showAnimation()
            }
            
            cell.trailIVPlayer.constant = collectionView.tag == 0 ? 0 : 8
            cell.widthIVPlayer.constant = collectionView.tag == 0 ? 0 : 20
            cell.lblPlayerName.font = collectionView.tag == 0 ? Fonts.Bold.returnFont(size: 14.0): Fonts.Regular.returnFont(size: 12.0)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
            for: indexPath) as! ContentCollectionViewCell
            if indexPath.section == 0 {
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.contentLabel.text = collectionView.tag == 0 ? indexPath.item == 0 ? "Teams" : "R\(indexPath.item)" : rowHeaders![indexPath.item]
                }else {
//                    cell.showAnimation()
                }
                
                cell.horizontalSeprater.isHidden = collectionView.tag == 0 ? indexPath.item == 0 ? false : true : true
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = collectionView.tag == 0 ? Fonts.Bold.returnFont(size: 12.0) : Fonts.Bold.returnFont(size: 14.0)
                cell.contentLabel.minimumScaleFactor = 0.5
                cell.backgroundColor = Colors.black.returnColor()
            } else {
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let playerRow = players![indexPath.section - 1]
                    cell.contentLabel.text = collectionView.tag == 0 ? indexPath.section == 1 ? "\(teams![indexPath.item-1].homeTeamRoundWin)" : "\(teams![indexPath.item-1].awayTeamRoundWin)" : "\(playerRow[rowHeaders![indexPath.row]]!)"
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
            // then we are at the end
            if scrollView == cvTeamOverview {
                btnRight.isHidden = true
            } else {
                btnRightPlayer.isHidden = true
            }
        } else {
            if scrollView == cvTeamOverview {
                btnRight.isHidden = false
            } else {
                btnRightPlayer.isHidden = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentWidth = CGFloat((collectionView.tag == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 120 : 70 : UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 80)) > CGFloat(self.view.frame.width) ? 80.0 : (CGFloat(self.view.frame.width) - CGFloat(collectionView.tag == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 120 : 70 : UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
            
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 210 : 150 : collectionView.tag == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 120 : 50 : currentWidth, height: 40)
    }
}
