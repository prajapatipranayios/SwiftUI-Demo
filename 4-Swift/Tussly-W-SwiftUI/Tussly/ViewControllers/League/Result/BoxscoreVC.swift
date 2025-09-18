//
//  BoxscoreVC.swift
//  Tussly
//
//  Created by Auxano on 13/09/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class BoxscoreVC: UIViewController {

    // MARK: - Variables
    let contentCellIdentifier = "ContentCollectionViewCell"
    var rowHeaders: [String]!
    var leaderboardData: [[String: Any]]!
    var matchId = 0
    var scoreInfo = ScoreInfo()
    // By Pranay
    var isGameWithStage : Bool = false
    // .
    
    @IBOutlet weak var cvResult: UICollectionView!
    @IBOutlet weak var cvResultGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvResultGridLayout.stickyRowsCount = 1
            cvResultGridLayout.stickyColumnsCount = 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rowHeaders = ["Players", "R1", "R2", "R3", "Final"]
        leaderboardData = []
            /*[
                "Players": "JD Molson",
                "avatarImage": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R1": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R2": "",
                "R3": "",
                "score1": "",
                "score2": "",
                "score3": "",
                "Final": ""
            ], [
                "Players": "Zedrick",
                "avatarImage": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R1": "http://14.99.147.155:9898/tussly/app/public/images/AvatarImage/AvatarImage_1582795791_atjxuh.jpg",
                "R2": "",
                "R3": "",
                "score1": "",
                "score2": "",
                "score3": "",
                "Final": ""
            ]
        ]*/
        
        self.cvResult.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: self.contentCellIdentifier)
        self.cvResult.register(UINib(nibName: "ResultUsersCVCell", bundle: nil), forCellWithReuseIdentifier: "ResultUsersCVCell")
        self.cvResult.register(UINib(nibName: "ImgScoreCVCell", bundle: nil), forCellWithReuseIdentifier: "ImgScoreCVCell")
        
        cvResult.isHidden = true
        
        getResult()
    }
    
    func setUI() {
        self.rowHeaders = ["Players"]
        for i in 0 ..< (self.scoreInfo.rounds?.count ?? 0) {
            self.rowHeaders.append("R\(i+1)")
        }
        self.rowHeaders.append("Final")
        
        self.leaderboardData = []
        for i in 0 ..< 2 {
            var arr = [String:Any]()
            var final = 0
            for j in 0 ..< (self.scoreInfo.rounds?.count ?? 0) {
                
                arr["R\(j+1)"] = i == 0 ? self.scoreInfo.rounds?[j].homeCharLogo : self.scoreInfo.rounds?[j].awayCharLogo
                arr["score\(j+1)"] = self.scoreInfo.rounds?[j].winnerTeamId == 0 ? "-" : (i == 0 ? String(self.scoreInfo.rounds?[j].homeTeamScore ?? 0) : String(self.scoreInfo.rounds?[j].awayTeamScore ?? 0))
                
                if i == 0 {
                    final = self.scoreInfo.homeTeamRoundWin ?? 0
                }
                if i == 1 {
                    final = self.scoreInfo.awayTeamRoundWin ?? 0
                }
                arr["Final"] = final
            }
            arr["Players"] = i == 0 ? scoreInfo.homeUserName : scoreInfo.awayUserName
            arr["avatarImage"] = i == 0 ? scoreInfo.homeUserLogo : scoreInfo.awayUserLogo
            self.leaderboardData.append(arr)
        }
        self.cvResult.reloadData()
        self.cvResult.isHidden = false
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Webservices
    
    func getResult() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getResult()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_MATCH_SCOR_INFO, parameters: ["matchId": self.matchId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.scoreInfo = (response?.result?.scoreInfo)!
                DispatchQueue.main.async {
                    // By Pranay
                    //self.isGameWithStage = self.scoreInfo.rounds!.count > 0 ? ((self.scoreInfo.rounds![0].stageName ?? "") != "" ? true : false) : true
                    self.isGameWithStage = false
                    for i in 0 ..< self.scoreInfo.rounds!.count {
                        if !self.isGameWithStage {
                            self.isGameWithStage = (self.scoreInfo.rounds![i].stageName ?? "") != "" ? true : false
                        }
                    }
                    // .
                    self.setUI()
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
                
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension BoxscoreVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return (leaderboardData?.count ?? 1) + 2
        return isGameWithStage ? (leaderboardData?.count ?? 1) + 2 : (leaderboardData?.count ?? 1) + 1
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
            //cell.backgroundColor = Colors.blueTheme.returnColor() //  By Pranay - comment by pranay
            
            /// 333 - By Pranay
            cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
            /// 333 .   */
            
            return cell
        } else if indexPath.section == (leaderboardData.count + 1) {
            if(indexPath.row == 0){
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier, for: indexPath) as! ContentCollectionViewCell
                
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    cell.contentLabel.text = "Stages"
                }else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
                //cell.backgroundColor = Colors.blueTheme.returnColor() //  By Pranay - comment by pranay
                
                /// 333 - By Pranay
                cell.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
                /// 333 .   */
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                cell.ivCheck.isHidden = true
                if rowHeaders != nil {
//                    cell.ivIcon.hideSkeleton()
                    
                    if(indexPath.row != rowHeaders.count - 1){
                        if self.scoreInfo.rounds?[indexPath.row - 1].winnerTeamId == 0 {
                            cell.ivIcon.sd_setImage(with: URL(string: ""))
                        } else {
                            cell.ivIcon.setImage(imageUrl: self.scoreInfo.rounds?[indexPath.row - 1].stageImage ?? "")
                        }
                    }
                    if(indexPath.row == rowHeaders.count - 1){
                        cell.ivIcon.sd_setImage(with: URL(string: ""))
                    }
                    cell.lblScore.text = ""
                    cell.lblScoreBottom.constant = 30
                    cell.ivIconTop.constant = 10
                } else {
//                    cell.ivIcon.showAnimatedSkeleton()
                }
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultUsersCVCell",
                for: indexPath) as! ResultUsersCVCell
                
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
            } else if indexPath.row == rowHeaders.count - 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil {
//                    cell.hideAnimation()
                    let row = leaderboardData[indexPath.section - 1]
                    cell.contentLabel.text = "\(row[rowHeaders[indexPath.row]]!)" == "" ? "-" : "\(row[rowHeaders[indexPath.row]]!)"
                }else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgScoreCVCell",
                for: indexPath) as! ImgScoreCVCell
                if rowHeaders != nil {
//                    cell.ivIcon.hideSkeleton()
                    if self.scoreInfo.rounds?[indexPath.row - 1].winnerTeamId == 0 {
                        cell.ivIcon.sd_setImage(with: URL(string: ""))
                        cell.lblScore.text = "-"
                    } else {
                        cell.ivIcon.setImage(imageUrl: (leaderboardData[indexPath.section - 1][rowHeaders[indexPath.row]] ?? "") as! String)
                        cell.lblScore.text = leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as? String
                    }
                    
                    if indexPath.section == 1 {
                        cell.lblScoreBottom.constant = 4.5
                        cell.ivIconTop.constant = 4
                    } else {
                        cell.lblScoreBottom.constant = 36
                        cell.ivIconTop.constant = 27
                    }
                    
                    if leaderboardData[indexPath.section - 1]["score\(indexPath.row)"] as! String == "-" {
                        cell.ivCheck.isHidden = true
                    }
                    else if(self.scoreInfo.rounds?[indexPath.row - 1].winnerTeamId != nil) {
                        if indexPath.section == 1
                        {
                            if self.scoreInfo.rounds?[indexPath.row - 1].winnerTeamId == self.scoreInfo.rounds?[indexPath.row - 1].homeTeamId {
                                cell.ivCheck.isHidden = false
                            } else {
                                cell.ivCheck.isHidden = true
                            }
                        } else {
                            if self.scoreInfo.rounds?[indexPath.row - 1].winnerTeamId == self.scoreInfo.rounds?[indexPath.row - 1].awayTeamId
                            {
                                cell.ivCheck.isHidden = false
                            } else {
                                cell.ivCheck.isHidden = true
                            }
                        }
                    }
                } else {
//                    cell.ivIcon.showAnimatedSkeleton()
                }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 60)) > CGFloat(self.view.frame.width) ? 60 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100 : currentWidth, height: indexPath.section == 0 ? 40 : indexPath.section == (leaderboardData.count + 1) ? 40 : 60)
    }
    
}

extension BoxscoreVC {
    func getLog() {
        var summary = [[String:AnyObject]]()
        //summary = self.doc?.data()?["matchSummary"] as! [[String : AnyObject]]
        
        for (_, item) in summary.enumerated() {
            if item["playerId"] as! String == "\(APIManager.sharedManager.user?.id ?? 0)" {
                print("-")
                //print("\(self.arrFire?.playerDetails?[APIManager.sharedManager.myPlayerIndex].playerId as! Int) -- \(self.arrFire?.playerDetails?[APIManager.sharedManager.myPlayerIndex].avatarImage as! String) -- \(self.arrFire?.playerDetails?[APIManager.sharedManager.myPlayerIndex].teamName as! String)")
                
                print("Preparing for Game #1")
                //print("\(self.arrFire?.playerDetails?[APIManager.sharedManager.myPlayerIndex].teamName as! String)      \(item["log"] as! String)")
                
            } else {
                print("Not my user...")
            }
        }
        
        /*var log = [String:AnyObject]()
        log = [
            "log" : "Selects Dr. Mario",
            "playerId" : "11",
            "oppId" : ""
        ] as! [String : AnyObject]
        summary.append(log)
        
        log = [
            "log" : "Selects Asuka",
            "playerId" : "12",
            "oppId" : ""
        ] as! [String : AnyObject]
        summary.append(log)
        
        self.db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").updateData([
            "matchSummary" : summary
        ]) { err in
            if let err = err {
                self.btnProceed.isEnabled = true
            } else {
                
            }
        }
        /// */
    }
}
