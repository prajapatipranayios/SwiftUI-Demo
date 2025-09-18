//
//  ArenaPreRoundVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 19/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ArenaPreRoundVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var cvBoxScore: UICollectionView!
    @IBOutlet weak var cvBoxScoreGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvBoxScoreGridLayout.stickyRowsCount = 1
            cvBoxScoreGridLayout.stickyColumnsCount = 1
        }
    }
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var pageControl: TLPageControl!
    @IBOutlet weak var cvRounds: UICollectionView!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var lblRoundComplete: UILabel!
    @IBOutlet weak var btnRoundComplete: UIButton!
    
    let contentCellIdentifier = "ContentCollectionViewCell"
    var arrLeagueRound = [LeagueRounds]()
    var arrLeagueScor:[RoundScor]?
    var matchData : Match?
    
    var leagueConsoleId = -1
    var teamId = -1
    var matchId = -1
    var roundId = -1
    var gameId = -1
    var canVoteMvp = false
    var role = ""
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        cvBoxScore.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvBoxScore.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        DispatchQueue.main.async {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.scorboard
            dialog.message = "At the end of each round, do not close the scoreboard until you have scanned the game statistics using Tussly's Image Recognition"
            dialog.btnYesText = "Continue"
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            
            self.setupUI()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.layoutCVRounds()
        })
        
        self.getAreanResult()
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupUI() {
        ivArrow.layer.cornerRadius = ivArrow.frame.size.height / 2
        btnRoundComplete.layer.cornerRadius = btnRoundComplete.frame.size.height / 2
        lblRoundComplete.attributedText = "When round is complete at least one player must tap below and use the OCR".setAttributedString(boldString: "at least one player must tap below and use the OCR", fontSize: 16.0)
        //lblSeconds.attributedText = "Your team has 60 seconds to use OCR".setAttributedString(boldString: "60")
    }
    
    @objc func callTimer() {
        self.getAreanResult()
    }
    
    func layoutCVRounds() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvRounds.frame.size.width, height: cvRounds.frame.size.height)
        layout.scrollDirection = .horizontal
        self.cvRounds.setCollectionViewLayout(layout, animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Button Click Events
    
    @IBAction func fullBoxScoreTapped(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FullBoxScoreVC") as! FullBoxScoreVC
        objVC.leagueConsoleId = self.leagueConsoleId
        objVC.gameId = self.gameId
        objVC.matchId = self.matchId
        objVC.matchData = self.matchData
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func roundCompleteTapped(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            self.timer.invalidate()
            let startCam = self.storyboard?.instantiateViewController(withIdentifier: "StartCamVC") as! StartCamVC
            startCam.teamId = self.teamId
            startCam.matchId = self.matchId
            startCam.roundId = self.roundId
            startCam.score = 0 //self.score
            startCam.dismiss = {
                appDelegate.myOrientation = .portrait
                DispatchQueue.main.async {
                   let value = UIInterfaceOrientation.portrait.rawValue
                   UIDevice.current.setValue(value, forKey: "orientation")
                    
                   self.getAreanResult()
                   self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                }
            }
            startCam.modalPresentationStyle = .overCurrentContext
            startCam.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(startCam, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
}

extension ArenaPreRoundVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 0 {
            return 2 + 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return (arrLeagueScor?.count ?? SKELETON_ROWHEADER_COUNT) + 1
        } else {
            return self.arrLeagueRound.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            if indexPath.row == 0 && indexPath.section != 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                                                              for: indexPath) as! PlayerCVCell
                cell.horizontalSeperater.backgroundColor = Colors.border.returnColor()
                cell.horizontalSeperater.isHidden = false
                if arrLeagueScor != nil && arrLeagueScor?.count != 0 {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = indexPath.section == 1 ? arrLeagueScor?[indexPath.section].homeTeamName : arrLeagueScor?[indexPath.section].awayTeamName
                    cell.ivPlayer.setImage(imageUrl: (indexPath.section == 1 ? arrLeagueScor?[indexPath.section].homeImage : arrLeagueScor?[indexPath.section].awayImage)!)
                    cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.width/2
                    cell.ivCaptainCap.isHidden = true
                }else {
//                    cell.showAnimation()
                }
                cell.lblPlayerName.font = Fonts.Bold.returnFont(size: 14.0)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                              for: indexPath) as! ContentCollectionViewCell
                if indexPath.section == 0 {
                    if arrLeagueScor != nil {
//                        cell.hideAnimation()
                        cell.contentLabel.text = indexPath.item == 0 ? "Teams" : arrLeagueScor![indexPath.item-1].roundNo
                    } else {
//                        cell.showAnimation()
                    }
                    cell.horizontalSeprater.isHidden = indexPath.item == 0 ? false : true
                    cell.contentLabel.textColor = UIColor.white
                    cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
                    cell.contentLabel.minimumScaleFactor = 0.5
                    cell.backgroundColor = Colors.black.returnColor()
                } else {
                    cell.backgroundColor = UIColor.white
                    if arrLeagueScor != nil {
//                        cell.hideAnimation()
                        cell.contentLabel.text = indexPath.section == 1 ? "\(arrLeagueScor?[indexPath.item-1].homeTeamScore ?? 0)" : "\(arrLeagueScor?[indexPath.item-1].awayTeamScore ?? 0)"
                    }else {
//                        cell.showAnimation()
                    }
                    cell.contentLabel.textColor = Colors.black.returnColor()
                    cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
                }
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArenaRoundCVCell", for: indexPath) as! ArenaRoundCVCell
            cell.lblRound.text = "Round \(indexPath.item+1)"
            cell.lblGameMode.attributedText = "Game Mode: \(self.arrLeagueRound[indexPath.item].gameModeTitle ?? "" )".setAttributedString(boldString: "Game Mode:", fontSize: 16.0)
            cell.lblGameMap.attributedText = "Map: \(self.arrLeagueRound[indexPath.item].mapTitle ?? "")".setAttributedString(boldString: "Map:", fontSize: 16.0)
            cell.ivBg.setImage(imageUrl: self.arrLeagueRound[indexPath.item].mapImage!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((arrLeagueScor?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 100)) > CGFloat(self.view.frame.width) ? 55.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((arrLeagueScor?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
            
            return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 120 : indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 90 : 55 : currentWidth, height: 40)
        } else {
            return collectionView.frame.size
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}


// MARK: Webservices
extension ArenaPreRoundVC {
    
    func getAreanResult() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getAreanResult()
                }
            }
            return
        }
        
        showLoading()//121
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ARENA_RESULT, parameters: ["leagueConsoleId":self.leagueConsoleId,"matchId":self.matchId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrLeagueRound = (response?.result?.rounds)!
                    self.arrLeagueScor = (response?.result?.roundScore)!
                    
                    let foundItems = self.arrLeagueRound.filter { $0.status! < 7}
                    self.roundId = foundItems.count > 0 ? foundItems[0].id! : -1
                    
                    self.pageControl.numberOfPages = self.arrLeagueRound.count
                    if self.arrLeagueRound.count > 0 {
                        self.cvRounds.isHidden = false
                        self.cvRounds.delegate = self
                        self.cvRounds.dataSource = self
                        self.cvRounds.reloadData()
                    } else {
                        self.cvRounds.isHidden = true
                    }
                    if self.arrLeagueScor!.count > 0 {
                        self.cvBoxScore.isHidden = false
                        self.cvBoxScore.reloadData()
                    } else {
                        self.cvBoxScore.isHidden = true
                    }
                    
                    if self.arrLeagueRound.last?.status == 7 {
                        let arenaFinal = self.storyboard?.instantiateViewController(withIdentifier: "ArenaFinalScoreVC") as! ArenaFinalScoreVC
                        arenaFinal.arrLeagueRound = self.arrLeagueRound
                        arenaFinal.arrLeagueScor = self.arrLeagueScor!
                        arenaFinal.teamId = self.teamId
                        arenaFinal.leagueConsoleId = self.leagueConsoleId
                        arenaFinal.gameId = self.gameId
                        arenaFinal.matchId = self.matchId
                        arenaFinal.matchData = self.matchData
                        arenaFinal.canVoteMvp  = self.canVoteMvp
                        arenaFinal.role = self.role
                        self.navigationController?.pushViewController(arenaFinal, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.cvRounds.isHidden = true
                    self.cvBoxScore.isHidden = true
                }
            }
        }
    }
}
