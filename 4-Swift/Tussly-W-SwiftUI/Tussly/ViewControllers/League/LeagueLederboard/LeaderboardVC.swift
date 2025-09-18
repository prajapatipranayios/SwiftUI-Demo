//
//  LeaderboardVC.swift
//  - Designed Leaderboard screen to display current standing of all teams

//  Tussly
//
//  Created by Auxano on 12/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class LeaderboardVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var cvLeaderBoard: UICollectionView!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var cvLeaderBoardGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvLeaderBoardGridLayout.stickyRowsCount = 1
            cvLeaderBoardGridLayout.stickyColumnsCount = 1
        }
    }
    
    // MARK: - Variables
    
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var leaderboardData: [[String: Any]]!
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoData.isHidden = true
        cvLeaderBoard.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvLeaderBoard.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        cvLeaderBoard.register(UINib(nibName: "LeaguePlayerCell", bundle: nil), forCellWithReuseIdentifier: "LeaguePlayerCell")
        cvLeaderBoard.register(UINib(nibName: "ImgCVCell", bundle: nil), forCellWithReuseIdentifier: "ImgCVCell")
        cvLeaderBoard.reloadData()
        setbtnRight()
        getLeaderboardDetails()

    }
    
    // MARK: - UI Methods
    
    func setbtnRight() {
        if self.view.frame.size.width >= self.cvLeaderBoard.collectionViewLayout.collectionViewContentSize.width {
            self.btnRight?.isHidden = true
        } else {
            self.btnRight.isHidden = false
        }
        
        if self.cvLeaderBoard.collectionViewLayout.collectionViewContentSize.height > self.cvLeaderBoard.frame.size.height - 40 { self.heightBtnRight.constant = self.cvLeaderBoard.frame.size.height - 40
        } else {
            self.heightBtnRight.constant = self.cvLeaderBoard.collectionViewLayout.collectionViewContentSize.height - 40
        }
    }
    
    // MARK: Webservices
    
    func getLeaderboardDetails() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLeaderboardDetails()
                }
            }
            return
        }
        
//        self.navigationController?.view.tusslyTabVC.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_LEADERBOARD, parameters: ["leagueId" : leagueTabVC!().tournamentDetail?.id ?? 0, "gameId": (leagueTabVC!().gameDetails?.id)!]) { (response: ApiResponse?, error) in
            
//            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
//            }
            
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.cvLeaderBoard.isHidden = false
                    self.rowHeaders = (response?.result?.leaderBoardHeader)!
                    let result = (response?.result?.leaderBoardResult)!
                    self.leaderboardData = result["leaderBoard"] as? [[String : Any]]
                    self.lblNoData.isHidden = true
                    self.cvLeaderBoard.reloadData()
                    self.setbtnRight()
                } else {
                    self.cvLeaderBoard.isHidden = true
                    self.lblNoData.isHidden = false
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
            
        }
    }
}

// MARK: - UICollectionViewDelegate

extension LeaderboardVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (leaderboardData?.count ?? 10) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
            
            if rowHeaders != nil {
//                cell.hideAnimation()
                cell.contentLabel.text = rowHeaders[indexPath.row]
            }else {
                cell.contentLabel.text = ""
//                cell.showAnimation()
            }
            
            cell.contentLabel.textColor = UIColor.white
            cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
            cell.backgroundColor = Colors.black.returnColor()
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                for: indexPath) as! PlayerCVCell
                cell.ivCaptainCap.isHidden = true
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] as? String
                    cell.ivPlayer.setImage(imageUrl: leaderboardData[indexPath.section - 1]["avatarImage"] as! String)
                    cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.width/2
                }else {
                    cell.lblPlayerName.text = ""
//                    cell.showAnimation()
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCVCell",
                for: indexPath) as! ImgCVCell
                if rowHeaders != nil {
//                    cell.ivIcon.hideSkeleton()
                    //cell.ivIcon.contentMode = .scaleAspectFit
                    cell.ivIcon.setImage(imageUrl: leaderboardData[indexPath.section - 1]["Team"] as! String)
////                    DispatchQueue.main.async {
                        cell.ivIcon.layer.cornerRadius = 14
////                    }
                } else {
//                    cell.ivIcon.showAnimatedSkeleton()
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let row = leaderboardData[indexPath.section - 1]
                    cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)"
                }else {
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

        if (scrollOffset + scrollViewWidth == scrollContentSizeWidth) {
            // then we are at the end
            btnRight?.isHidden = true
        } else {
            btnRight.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 150.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 80)) > CGFloat(self.view.frame.width) ? 80.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 150.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 150 : indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 90 : 60 : currentWidth, height: 40)
    }
    
}
