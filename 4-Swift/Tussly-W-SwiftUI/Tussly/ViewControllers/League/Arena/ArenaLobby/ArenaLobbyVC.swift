//
//  ArenaLobbyVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 18/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ArenaLobbyVC: UIViewController {

    //Outlets
    @IBOutlet weak var cvRosters: UICollectionView!
    @IBOutlet weak var heightCVRosters: NSLayoutConstraint!

    @IBOutlet weak var lblGameTime: UILabel!

    @IBOutlet weak var viewHomeTeam: UIView!
    @IBOutlet weak var viewAwayTeam: UIView!
    
    @IBOutlet weak var ivHomeTeam: UIImageView!
    @IBOutlet weak var ivAwayTeam: UIImageView!
    
    @IBOutlet weak var lblHomeTeamName: UILabel!
    @IBOutlet weak var lblAwayTeamName: UILabel!
    
    @IBOutlet weak var lblHomeTeamScore: UILabel!
    @IBOutlet weak var lblAwayTeamScore: UILabel!
    
    @IBOutlet weak var lblNoteSelector: UILabel!
    @IBOutlet weak var lblNote: UILabel!

    @IBOutlet weak var btnLobbySetup: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    // By Pranay
    // .
    
    var matchData : Match?
    var leagueConsolId = -1
    var teamId = -1
    var gameId = -1
    var canVoteMvp = false
    var role = ""
    var matchPlayer = [MatchPlayer]()
    var allPlayer = [MatchPlayer]()
    var arrLoby = [GameLobby]()
    
    var timerRoster = Timer()
    var timer = Timer()
    var timeSeconds = -1
    var isStop = false
    var isHomeSelected = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLobySetupData()
        layoutCells()
        DispatchQueue.main.async {
            self.setupUI()
            self.getArenaPlayerDetail(isFirst: true)
            self.timerRoster = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.callRosterTimer), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cvRosters.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cvRosters.removeObserver(self, forKeyPath: "contentSize")
        timer.invalidate()
        timerRoster.invalidate()
    }
    
    // MARK: - UI Methods
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 1 {
            timer.invalidate()
        } else {
            let gameTime = " Game Time: \(self.matchData?.matchTime ?? "") | ".setAttributedString(boldString: "Game Time:", fontSize: 14.0)
            let countDown = " CountDown: \(timeFormatted(totalSeconds: timeSeconds))".setAttributedString(boldString: "CountDown:", fontSize: 14.0)
            let result = NSMutableAttributedString()
            result.append(gameTime)
            result.append(countDown)
            lblGameTime.attributedText = result
        }
    }
    
    @objc func callRosterTimer() {
        if isStop == false {
            self.getArenaPlayerDetail(isFirst: false)
        } else {
            timerRoster.invalidate()
            timer.invalidate()
        }
    }
    
    func  timeFormatted(totalSeconds: Int) -> String {
        let seconds  = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        _  = totalSeconds / 3600
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    func setupUI() {
        self.ivHomeTeam.layer.cornerRadius = self.ivHomeTeam.frame.size.width/2
        self.ivAwayTeam.layer.cornerRadius = self.ivAwayTeam.frame.size.width/2
        ivHomeTeam.setImage(imageUrl: matchData!.homeImage!)
        ivAwayTeam.setImage(imageUrl: matchData!.awayImage!)
        lblHomeTeamName.text = matchData!.homeTeamName!
        lblAwayTeamName.text = matchData!.awayTeamName!
        lblHomeTeamScore.text = matchData!.homeResult!
        lblAwayTeamScore.text = matchData!.awayResult!
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
        
        btnLobbySetup.layer.cornerRadius = btnLobbySetup.frame.size.height / 2
        btnNext.layer.cornerRadius = btnNext.frame.size.height / 2
        viewHomeTeam.backgroundColor = Colors.disable.returnColor()
        viewAwayTeam.backgroundColor = UIColor.white
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightCVRosters.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
        
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16.0
        layout.minimumLineSpacing = 16.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cellWidth = (cvRosters.frame.size.width - 32) / 3
        let cellHeight = cellWidth * 0.35 + 20 + 34
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.scrollDirection = .vertical
        self.cvRosters.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func teamTapped(_ sender: UIButton) {
        viewHomeTeam.backgroundColor = sender.tag == 0 ? Colors.disable.returnColor() : UIColor.white
        viewAwayTeam.backgroundColor = sender.tag == 1 ? Colors.disable.returnColor() : UIColor.white
        if sender.tag == 0 {
            isHomeSelected = true
            let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.homeTeamId}
            self.matchPlayer = foundItems
            self.cvRosters.reloadData()
        } else {
            isHomeSelected = false
            //let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.teamId}
            let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.leagueId}
            self.matchPlayer = foundItems
            self.cvRosters.reloadData()
        }
    }
    
    @IBAction func onTapLobbySetup(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.arrLoby = self.arrLoby
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        isStop = true
        timer.invalidate()
        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaPreRoundVC") as! ArenaPreRoundVC
        arenaLobby.leagueConsoleId = leagueConsolId
        arenaLobby.teamId = teamId
        arenaLobby.matchId = matchData!.matchId!
        arenaLobby.gameId = self.gameId
        arenaLobby.matchData = self.matchData
        arenaLobby.canVoteMvp = self.canVoteMvp
        arenaLobby.role = self.role
        self.navigationController?.pushViewController(arenaLobby, animated: true)
    }

}

extension ArenaLobbyVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matchPlayer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArenaLobbyRosterCell", for: indexPath) as! ArenaLobbyRosterCell
        cell.ivPlayer.setImage(imageUrl: matchPlayer[indexPath.item].avatarImage!)
        cell.ivCaptainCap.image = UIImage(named: matchPlayer[indexPath.item].role! == 2 ? "Captain" : matchPlayer[indexPath.item].role! == 5 ? "AssistantCaptain" : "")
        cell.lblPlayerName.text = matchPlayer[indexPath.item].displayName
        cell.lblTags.text = matchPlayer[indexPath.item].gamerTags
        if matchPlayer[indexPath.item].arenaEntered == 0 {
            cell.ivBg.isHidden = true
        } else {
            cell.ivBg.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (cvRosters.frame.size.width - 32) / 3
        let cellHeight = cellWidth * 0.35 + 20 + 34
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


// MARK: Webservices

extension ArenaLobbyVC {
    func getArenaPlayerDetail(isFirst: Bool) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getArenaPlayerDetail(isFirst: isFirst)
                }
            }
            return
        }
        
        if isFirst {
            showLoading()
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ARENA_PLAYER_DETAIL, parameters: ["leagueConsoleId":leagueConsolId,"matchId":matchData?.matchId as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
//                    self.allPlayer = (response?.result?.matchPlayers)!
//                    if self.isHomeSelected {
//                        let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.homeTeamId}
//                        self.matchPlayer = foundItems
//                    } else {
////                        let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.teamId}
//                        let foundItems = self.allPlayer.filter { $0.teamId == self.matchData?.leagueId}
//                        self.matchPlayer = foundItems
//                    }
//                    self.cvRosters.delegate = self
//                    self.cvRosters.dataSource = self
//                    self.cvRosters.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func getLobySetupData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLobySetupData()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LOBY_SETUP, parameters: ["gameId":self.gameId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrLoby = (response?.result?.gameLobby)!
                }
            } else {
//                DispatchQueue.main.async {
//                    Utilities.showPopup(title: response?.message ?? "", type: .error)
//                }
            }
        }
    }
}
