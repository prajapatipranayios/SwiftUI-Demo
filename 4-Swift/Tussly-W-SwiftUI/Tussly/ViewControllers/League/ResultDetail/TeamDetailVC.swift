//
//  TeamDetailVC.swift
//  - Designed Team Details Screen for League Module

//  Tussly
//
//  Created by Auxano on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamDetailVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblTeamName : UILabel!
    @IBOutlet weak var ivTeamLogo : UIImageView!
    @IBOutlet weak var btnTeam: UIButton!
    @IBOutlet weak var cvTeamPlayerDetail: UICollectionView!
    @IBOutlet weak var cvTeamAvg: UICollectionView!
    @IBOutlet weak var heightCvTeamPlayerDetail : NSLayoutConstraint!
    @IBOutlet weak var heightCvTeamAvg : NSLayoutConstraint!
    @IBOutlet weak var cvTeamPlayerDetailGridlayout: StickyGridCollectionViewLayout! {
        didSet {
            cvTeamPlayerDetailGridlayout.stickyRowsCount = 1
            cvTeamPlayerDetailGridlayout.stickyColumnsCount = 1
        }
    }
    @IBOutlet weak var cvTeamAvgGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvTeamAvgGridLayout.stickyRowsCount = 1
            cvTeamAvgGridLayout.stickyColumnsCount = 1
        }
    }
    
    // MARK: - Variables
    
    var gameId = -1
    var teamId = -1
    var teamName = ""
    var teamIcon = ""
    var leagueConsoleId = -1
    
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var players: [[String: Any]]!
    var average:[String: Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTeamName.text = teamName
        ivTeamLogo.setImage(imageUrl: teamIcon)
        
        cvTeamPlayerDetail.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvTeamPlayerDetail.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        
        cvTeamAvg.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvTeamAvg.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        
        self.cvTeamPlayerDetail.dataSource = self
        self.cvTeamPlayerDetail.delegate = self
        self.cvTeamAvg.delegate = self
        self.cvTeamAvg.dataSource = self
        self.cvTeamPlayerDetail.reloadData()
        self.cvTeamAvg.reloadData()
        
        getTeamResult()
        DispatchQueue.main.async {
            self.btnTeam.layer.cornerRadius = self.btnTeam.frame.size.height/2
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.heightCvTeamPlayerDetail.constant = self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.height
        if self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.height >= self.view.frame.size.height-134 {
            self.heightCvTeamPlayerDetail.constant = self.view.frame.size.height-134
        }
        if self.view.frame.size.width >= self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.width {
            self.btnRight?.isHidden = true
        } else {
            self.btnRight?.isHidden = false
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapTeamPage(_ sender: UIButton) {
        
    }
    
    // MARK: Webservices
    
    func getTeamResult() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamResult()
                }
            }
            return
        }
        
//        showLoading()
        // By Pranay - add param - timeZone
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_RESULT, parameters: ["leagueId": leagueConsoleId,"gameId":gameId,"teamId":teamId, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
//            self.hideLoading()
            if response?.status == 1 {
                
                DispatchQueue.main.async {
                    self.cvTeamPlayerDetail.isHidden = false
                    self.cvTeamAvg.isHidden = false
                    
                    self.rowHeaders = (response?.result?.playerHeader)!
                    let result = (response?.result?.playerResults)!
                    self.players = result["results"] as? [[String : Any]]
                    self.average = (response?.result?.average)!
                    
                    self.cvTeamPlayerDetail.reloadData()
                    self.cvTeamAvg.reloadData()
                    
                    DispatchQueue.main.async {
                        self.heightCvTeamPlayerDetail.constant = self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.height
                        if self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.height >= self.view.frame.size.height-134 {
                            self.heightCvTeamPlayerDetail.constant = self.view.frame.size.height-134
                        }
                        if self.view.frame.size.width >= self.cvTeamPlayerDetail.collectionViewLayout.collectionViewContentSize.width {
                            self.btnRight?.isHidden = true
                        } else {
                            self.btnRight?.isHidden = false
                        }
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                self.cvTeamPlayerDetail.isHidden = true
                self.cvTeamAvg.isHidden = true
                
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TeamDetailVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == cvTeamPlayerDetail {
            return (players?.count ?? 5) + 1
        } else {
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvTeamPlayerDetail {
            if indexPath.row == 0 && indexPath.section != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                for: indexPath) as! PlayerCVCell
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = players[indexPath.section - 1][rowHeaders[indexPath.row]] as? String
                    cell.ivPlayer.setImage(imageUrl: players[indexPath.section - 1]["avatarImage"] as! String)
//                    cell.ivCaptainCap.image = UIImage(named: players[indexPath.section - 1]["role"] as! Int == 2 ? "Captain" : players[indexPath.section - 1]["role"] as! Int == 5 ? "AssistantCaptain" : "")
                    cell.ivCaptainCap.isHidden = true
                }else {
//                    cell.showAnimation()
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                if indexPath.section == 0 {
                    if rowHeaders != nil {
//                        cell.hideAnimation()
                        cell.contentLabel.text = rowHeaders[indexPath.row]
                    }else {
//                        cell.showAnimation()
                    }
                    
                    cell.contentLabel.textColor = UIColor.white
                    cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                    cell.backgroundColor = Colors.black.returnColor()
                } else {
                    if rowHeaders != nil {
//                        cell.hideAnimation()
                        let playerRow = players[indexPath.section - 1]
                        cell.contentLabel.text = "\(playerRow[rowHeaders[indexPath.row]]!)"
                    }else {
//                        cell.showAnimation()
                    }
                    cell.backgroundColor = UIColor.white
                    cell.contentLabel.textColor = Colors.black.returnColor()
                    cell.contentLabel.font = Fonts.Regular.returnFont(size: 14.0)
                }
                return cell
            }
        } else {
            if indexPath.row == 0 && indexPath.section != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                for: indexPath) as! PlayerCVCell
                cell.bottomSeprater.isHidden = true
                cell.ivCaptainCap.isHidden = true
                cell.ivPlayer.isHidden = true
                cell.horizontalSeperater.isHidden = true
                cell.lblPlayerName.font = Fonts.Semibold.returnFont(size: 14.0)
                cell.lblPlayerName.textColor = Colors.black.returnColor()
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = average[rowHeaders[indexPath.row]] as? String
                }else {
//                    cell.showAnimation()
                }
                                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.bottomSeprater.isHidden = true
                if indexPath.section == 0 {
                    if rowHeaders != nil {
//                        cell.hideAnimation()
//                        cell.contentLabel.text = rowHeaders[indexPath.row]
                        cell.contentLabel.text = indexPath.item == 0 ? "Team Avg" : rowHeaders[indexPath.row]
                    }else {
//                        cell.showAnimation()
                    }
                    
                    cell.contentLabel.textColor = UIColor.white
                    cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                    cell.backgroundColor = Colors.black.returnColor()
                } else {
                    cell.backgroundColor = UIColor.white
                    if rowHeaders != nil {
//                        cell.hideAnimation()
                        cell.contentLabel.text = average[rowHeaders[indexPath.row]] as? String
                    }else {
//                        cell.showAnimation()
                    }
                    
                    cell.contentLabel.textColor = Colors.black.returnColor()
                    cell.contentLabel.font = Fonts.Semibold.returnFont(size: 14.0)
                }
                return cell
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x

        if (scrollOffset + scrollViewWidth == scrollContentSizeWidth) {
            // then we are at the end
            btnRight?.isHidden = true
        } else {
            btnRight.isHidden = false
        }
        
        if scrollView == cvTeamPlayerDetail {
            cvTeamAvg.contentOffset.x = scrollView.contentOffset.x
        } else {
            cvTeamPlayerDetail.contentOffset.x = scrollView.contentOffset.x
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 110)) > CGFloat(self.view.frame.width) ? 110.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 210 : 150 : currentWidth, height: 40)
    }
}
