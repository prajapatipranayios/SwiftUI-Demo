//
//  ArenaVC.swift
//  Tussly
//
//  Created by Auxano on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import MarqueeLabel

class ArenaVC: UIViewController {
    
    // MARK: - Variables
    var leagueTabVC: (()->LeagueTabVC)?
    var timer = Timer()
    var timeSeconds = 0
    var arrLeagueRound = [LeagueRounds]()
    var matchDetail = Match()
    var arrLoby = [GameLobby]()
 
    //Outlets
    @IBOutlet weak var tvHeightConst : NSLayoutConstraint!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var tvMode: UITableView!
    @IBOutlet weak var tvMap: UITableView!
    @IBOutlet weak var lblModeTitle: UILabel!
    @IBOutlet weak var lblMapTitle : UILabel!
    @IBOutlet weak var lblSeprator : UILabel!
    
    @IBOutlet weak var btnEnterArena: UIButton!
    @IBOutlet weak var btnLobbySetup: UIButton!
    
    @IBOutlet weak var lblMarque: MarqueeLabel!
    @IBOutlet weak var lblGameCountDown: UILabel!
    
    @IBOutlet weak var ivMode: UIImageView!
    @IBOutlet weak var ivMap: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.getLobySetupData()
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tvMode.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.getArenaDetail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //tvMode.removeObserver(self, forKeyPath: "contentSize")
        timer.invalidate()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.tvHeightConst.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 60
        if timeSeconds < 60 {
            timer.invalidate()
        } else {
            lblGameCountDown.attributedText = timeFormatted(seconds: timeSeconds).setAttributedString(boldString: "Game Time Countdown:", fontSize: 14.0)
            if timeSeconds < 1800 {
                lblTitle.text = "The arena is open"
                btnEnterArena.isEnabled = true
                btnEnterArena.backgroundColor = Colors.theme.returnColor()
                self.btnEnterArena.titleLabel?.textColor = UIColor.white
            }
        }
    }
    
    func  timeFormatted(seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        if days == 0 {
            if hours == 0 {
                return String(format: "Game Time Countdown: %d m", minutes)
            } else {
                return String(format: "Game Time Countdown: %d h %d m",hours, minutes)
            }
        }
        return String(format: "Game Time Countdown: %d d %d h %d m",days, hours, minutes)
    }
    
    func setupUI() {
        lblSeprator.isHidden = true
        lblModeTitle.isHidden = true
        lblMapTitle.isHidden = true
        lblTitle.isHidden = true
        ivMode.image = nil
        ivMap.image = nil
        btnEnterArena.layer.cornerRadius = btnEnterArena.frame.size.height / 2
        btnLobbySetup.layer.cornerRadius = btnLobbySetup.frame.size.height / 2
        self.btnLobbySetup.backgroundColor = Colors.theme.returnColor()
        btnEnterArena.isHidden = true
        btnLobbySetup.isHidden = true
        ivMap.layer.cornerRadius = ivMap.frame.size.width/2
        ivMode.layer.cornerRadius = ivMode.frame.size.width/2
    }
    
    // MARK: - Button Click Events
    
    @IBAction func enterArenaTapped(_ sender: UIButton) {
        self.enterArena()
    }
    
    @IBAction func lobbySetupTapped(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "LobbySetupDialog") as! LobbySetupDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.arrLoby = self.arrLoby
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
}

extension ArenaVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLeagueRound.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModeTVCell") as! ModeTVCell
            cell.lblRound.text = arrLeagueRound[indexPath.row].roundNo
            cell.lblModeName.text = arrLeagueRound[indexPath.row].gameModeTitle
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapTVCell") as! MapTVCell
            cell.lblMapName.text = arrLeagueRound[indexPath.row].mapTitle
            return cell
        }
    }
}


// MARK: Webservices

extension ArenaVC {
    func getArenaDetail() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getArenaDetail()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ARENA_DETAIL, parameters: ["leagueConsoleId":leagueTabVC!().tournamentDetail?.id ?? 0,"teamId":self.leagueTabVC!().teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.matchDetail = (response?.result?.match)!
                    if (response?.result?.arenaEntered == 0) {
                        self.btnEnterArena.isHidden = false
                        self.btnLobbySetup.isHidden = false
                        self.lblSeprator.isHidden = false
                        self.lblModeTitle.isHidden = false
                        self.lblMapTitle.isHidden = false
                        self.lblTitle.isHidden = false
                        self.arrLeagueRound = (response?.result?.leagueRounds)!
                        self.ivMap.setImage(imageUrl: self.matchDetail.awayImage!)
                        self.ivMode.setImage(imageUrl: self.matchDetail.homeImage!)
                        let gameDay = " Game Day: \(self.matchDetail.matchDate ?? "")".setAttributedString(boldString: "Game Day:", fontSize: 14.0)
                        let gameTime = " Game Time: \(self.matchDetail.matchTime ?? "")".setAttributedString(boldString: "Game Time:", fontSize: 14.0)
                        let opponent = " Opponent: \(self.matchDetail.opponent ?? "")".setAttributedString(boldString: "Opponent:", fontSize: 14.0)
                        
                        let result = NSMutableAttributedString()
                        result.append(gameDay)
                        result.append(gameTime)
                        result.append(opponent)
                        self.lblMarque.attributedText = result

                        self.tvMode.dataSource = self
                        self.tvMode.delegate = self
                        self.tvMap.dataSource = self
                        self.tvMap.delegate = self
                        self.tvMap.reloadData()
                        self.tvMode.reloadData()
                        
                        self.timeSeconds = (self.matchDetail.duration!) * 60
                        if(self.timeSeconds < 0) {
                            self.timeSeconds = abs(self.timeSeconds)
                        }
                        
                        if self.timeSeconds > 1800 {
                            self.lblTitle.text = "The arena opens 30 minutes before gametime"
                            self.btnEnterArena.backgroundColor = Colors.disable.returnColor()
                            self.btnEnterArena.isEnabled = false
                            self.btnEnterArena.titleLabel?.textColor = UIColor.gray
                        } else {
                            self.lblTitle.text = "The arena is open"
                            self.btnEnterArena.backgroundColor = Colors.theme.returnColor()
                            self.btnEnterArena.isEnabled = true
                            self.btnEnterArena.titleLabel?.textColor = UIColor.white
                        }
                        self.lblGameCountDown.attributedText = self.timeFormatted(seconds: self.timeSeconds).setAttributedString(boldString: "Game Time Countdown:", fontSize: 14.0)
                        self.timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    } else {
                        let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaLobbyVC") as! ArenaLobbyVC
                        arenaLobby.gameId  = (self.leagueTabVC!().gameDetails?.id!)!
                        arenaLobby.timeSeconds = self.matchDetail.duration! * 60
                        //arenaLobby.leagueConsolId = self.leagueTabVC!().leagueId  //  By Pranay - Comment by Pranay.
                        arenaLobby.leagueConsolId = self.leagueTabVC!().tournamentDetail?.id ?? 0
                        arenaLobby.matchData = self.matchDetail
                        arenaLobby.teamId = self.leagueTabVC!().teamId
                        arenaLobby.canVoteMvp = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? false : true
                        arenaLobby.role = self.leagueTabVC!().userRole!.role ?? ""
                        self.navigationController?.pushViewController(arenaLobby, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func enterArena() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.enterArena()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ENTER_ARENA, parameters: ["matchId":self.matchDetail.matchId as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    let arenaLobby = self.storyboard?.instantiateViewController(withIdentifier: "ArenaLobbyVC") as! ArenaLobbyVC
                    arenaLobby.gameId  = (self.leagueTabVC!().gameDetails?.id!)!
                    arenaLobby.timeSeconds = self.timeSeconds
                    //arenaLobby.leagueConsolId = self.leagueTabVC!().leagueId  //  By Pranay - Comment by Pranay.
                    arenaLobby.leagueConsolId = self.leagueTabVC!().tournamentDetail?.id ?? 0
                    arenaLobby.matchData = self.matchDetail
                    arenaLobby.teamId = self.leagueTabVC!().teamId
                    arenaLobby.canVoteMvp = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? false : true
                    self.navigationController?.pushViewController(arenaLobby, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LOBY_SETUP, parameters: ["gameId":(leagueTabVC!().gameDetails?.id)!]) { (response: ApiResponse?, error) in
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
