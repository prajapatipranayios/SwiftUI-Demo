//
//  ArenaFinalScoreVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 20/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ArenaFinalScoreVC: UIViewController {
    //Outlets
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var viewHomeLayer: UIView!
    @IBOutlet weak var viewAwayLayer: UIView!
    @IBOutlet weak var ivHomeTeam: UIImageView!
    @IBOutlet weak var ivAwayTeam: UIImageView!
    @IBOutlet weak var lblHomeTeamName: UILabel!
    @IBOutlet weak var lblAwayTeamName: UILabel!
    
    @IBOutlet weak var lblHomeTeamScor: UILabel!
    @IBOutlet weak var lblAwayTeamScor: UILabel!
    
    @IBOutlet weak var lblGameDay: UILabel!
    @IBOutlet weak var lblGameTime: UILabel!
    @IBOutlet weak var lblOpponent: UILabel!
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var lblTimer : UILabel!
    
    @IBOutlet weak var cvBoxScore: UICollectionView!
    @IBOutlet weak var cvBoxScoreGridLayout: StickyGridCollectionViewLayout! {
        didSet {
            cvBoxScoreGridLayout.stickyRowsCount = 1
            cvBoxScoreGridLayout.stickyColumnsCount = 1
        }
    }
    
    let contentCellIdentifier = "ContentCollectionViewCell"
    var arrLeagueRound = [LeagueRounds]()
    var arrLeagueScor = [RoundScor]()
    var nextMatch = Match()
    
    var leagueConsoleId = -1
    var teamId = -1
    var gameId = -1
    var matchId = -1
    var matchData : Match?
    var canVoteMvp = false
    var role = ""
    var isVoted = false
    var timer = Timer()
    var timeSeconds = 600

    var getAllPlayer = [Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cvBoxScore.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: contentCellIdentifier)
        cvBoxScore.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        DispatchQueue.main.async {
            self.setupUI()
        }
        getMVPPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getNextMatch()
    }
    
    func setupUI() {
        ivArrow.layer.cornerRadius = ivArrow.frame.size.height / 2
        viewHomeLayer.layer.cornerRadius = viewHomeLayer.frame.size.height / 2
        viewAwayLayer.layer.cornerRadius = viewAwayLayer.frame.size.height / 2
        
        ivHomeTeam.layer.cornerRadius = ivHomeTeam.frame.size.height / 2
        ivAwayTeam.layer.cornerRadius = ivAwayTeam.frame.size.height / 2
        btn.layer.cornerRadius = btn.frame.size.height / 2
        
        ivHomeTeam.setImage(imageUrl: arrLeagueScor[0].homeImage!)
        ivAwayTeam.setImage(imageUrl: arrLeagueScor[0].awayImage!)
        
        lblHomeTeamName.text = arrLeagueScor[0].homeTeamName!
        lblAwayTeamName.text = arrLeagueScor[0].awayTeamName!
        
        lblHomeTeamScor.text = "\(self.arrLeagueScor.last?.homeTeamScore ?? 0)"
        lblAwayTeamScor.text = "\(self.arrLeagueScor.last?.awayTeamScore ?? 0)"
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
        
        if self.canVoteMvp && self.role == "CAPTAIN" {
            btn.setTitle("Vote for MVP", for: .normal)
        } else {
            btn.setTitle("Close Arena", for: .normal)
        }
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 1 {
            timer.invalidate()
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            lblTimer.text = timeFormatted(totalSeconds: timeSeconds)
        }
    }
    
    func  timeFormatted(totalSeconds: Int) -> String {
        let seconds  = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        _  = totalSeconds / 3600
        return String(format: "The Arena will close in %01d minutes and %01d seconds", minutes, seconds)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapButton(_ sender: UIButton) {
        if isVoted == false {
            if canVoteMvp && self.role == "CAPTAIN" {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
                objVC.didSelectItem = { playerName,id in
                    self.voteMVPPlayer(playerId: id, playerName: playerName)
                }
                objVC.arrPlayer = getAllPlayer
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func fullBoxScoreTapped(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FullBoxScoreVC") as! FullBoxScoreVC
        objVC.leagueConsoleId = self.leagueConsoleId
        objVC.gameId = self.gameId
        objVC.matchId = self.matchId
        objVC.matchData = self.matchData
        self.navigationController?.pushViewController(objVC, animated: true)
    }
}

extension ArenaFinalScoreVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrLeagueScor.count ) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && indexPath.section != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                                                          for: indexPath) as! PlayerCVCell
            cell.horizontalSeperater.backgroundColor = Colors.border.returnColor()
            cell.horizontalSeperater.isHidden = false
            cell.lblPlayerName.text = indexPath.section == 1 ? arrLeagueScor[indexPath.section].homeTeamName : arrLeagueScor[indexPath.section].awayTeamName
            cell.ivPlayer.setImage(imageUrl: (indexPath.section == 1 ? arrLeagueScor[indexPath.section].homeImage : arrLeagueScor[indexPath.section].awayImage)!)
                cell.ivCaptainCap.isHidden = true
            cell.lblPlayerName.font = Fonts.Bold.returnFont(size: 14.0)
            cell.ivPlayer.layer.cornerRadius = cell.ivPlayer.frame.size.width/2
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                          for: indexPath) as! ContentCollectionViewCell
            if indexPath.section == 0 {
//                    cell.hideAnimation()
                cell.contentLabel.text = indexPath.item == 0 ? "Teams" : arrLeagueScor[indexPath.item-1].roundNo
                
                cell.horizontalSeprater.isHidden = indexPath.item == 0 ? false : true
                cell.contentLabel.textColor = UIColor.white
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
                cell.contentLabel.minimumScaleFactor = 0.5
                cell.backgroundColor = Colors.black.returnColor()
            } else {
                cell.backgroundColor = UIColor.white
//                    cell.hideAnimation()
                cell.contentLabel.text = indexPath.section == 1 ? "\(arrLeagueScor[indexPath.item-1].homeTeamScore ?? 0)" : "\(arrLeagueScor[indexPath.item-1].awayTeamScore ?? 0)"
                
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 215 : 100.0) + CGFloat(((arrLeagueScor.count ) - 1) * 100)) > CGFloat(self.view.frame.width) ? 55.0 : (CGFloat(self.view.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 215.0 : 100.0)) / CGFloat((arrLeagueScor.count ) - 1)
            
            return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 215 : 120 : indexPath.row == 1 ? UIDevice.current.userInterfaceIdiom == .pad ? 90 : 55 : currentWidth, height: 40)
        } else {
            return collectionView.frame.size
        }
    }
}

// MARK: Webservices

extension ArenaFinalScoreVC {
    func getNextMatch() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getNextMatch()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ARENA_NEXT_MATCH, parameters: ["leagueConsoleId":self.leagueConsoleId,"teamId":self.teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.nextMatch = (response?.result?.nextMatch)!
                    self.lblGameDay.text = self.nextMatch.matchDate
                    self.lblGameTime.text = self.nextMatch.matchTime
                    self.lblOpponent.text = self.nextMatch.opponent
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func getMVPPlayer() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getMVPPlayer()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_MVP_PLAYER, parameters: ["leagueId":self.leagueConsoleId,"teamId":self.teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                //self.getAllPlayer = (response?.result?.players)!
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func voteMVPPlayer(playerId :Int,playerName: String) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.voteMVPPlayer(playerId: playerId, playerName: playerName)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.VOTE_MVP, parameters: ["leagueId":self.leagueConsoleId,"teamId":self.teamId,"playerId":playerId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.isVoted = true
                    self.btn.setTitle("Close Arena", for: .normal)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
