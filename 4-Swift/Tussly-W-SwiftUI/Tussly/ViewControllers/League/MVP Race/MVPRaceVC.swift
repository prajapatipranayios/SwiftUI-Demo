//
//  MVPRaceVC.swift
//  - Designed MVP Race screen for League module

//  Tussly
//
//  Created by Auxano on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MVPRaceVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var tvMVP : UITableView!
    @IBOutlet weak var btnVote : UIButton!
    @IBOutlet weak var lblVotedUserName : UILabel!
    @IBOutlet weak var viewVotedUser : UIView!
    
    
    // MARK: - Variables
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var mvpData = [Player]()
    var getAllPlayer = [Player]()
    var sortedArray: [Player]?
    var maxVote = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvMVP.delegate = self
        self.tvMVP.dataSource = self
        self.tvMVP.reloadData()
        getMVPData()
        btnVote.isHidden = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? false : true
        viewVotedUser.isHidden = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? true : false
        DispatchQueue.main.async {
            self.btnVote.layer.cornerRadius = self.btnVote.frame.size.height/2
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapVoteUser(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VoteVC") as! VoteVC
        objVC.didSelectItem = { playerName,id in
            self.voteMVPPlayer(playerId: id, playerName: playerName)
        }
        objVC.arrPlayer = getAllPlayer
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        
    }
}
// MARK: - UITableViewDelegate

extension MVPRaceVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArray?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MVPCell", for: indexPath) as! MVPCell
        
        if sortedArray != nil {
//            cell.hideAnimation()
            cell.viewContainer.layoutIfNeeded()
            cell.lblProgress.text = "\(self.sortedArray![indexPath.row].votes ?? 0)"
            let widthViewProgress = cell.viewContainer.frame.size.width - 16 - cell.lblProgress.intrinsicContentSize.width
            let scalFactor = Float(widthViewProgress) / Float(self.maxVote)
            let progress = Float(self.sortedArray![indexPath.row].votes!) * scalFactor
            cell.widthProgressView.constant = CGFloat(progress)
            cell.lblPlayerName.text = (self.sortedArray![indexPath.row].displayName!)
            cell.ivAvtar.setImage(imageUrl: self.sortedArray![indexPath.row].avatarImage!)
            cell.ivTeamLogo.setImage(imageUrl: self.sortedArray![indexPath.row].logoImage ?? "")
        }else {
//            cell.showAnimation()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

// MARK: Webservices

extension MVPRaceVC {
    func getMVPData() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getMVPData()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_MVP, parameters: ["leagueId":leagueTabVC!().tournamentDetail?.id ?? 0,"teamId":self.leagueTabVC!().teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.mvpData = (response?.result?.mvp)!
                let mySortedArray = self.mvpData.sorted(by: {(int1, int2)  -> Bool in
                    return int1.votes! > int2.votes!
                })
                self.sortedArray = mySortedArray
                if mySortedArray.count > 0 {
                    self.maxVote = mySortedArray[0].votes ?? 0
                } else {
                    self.maxVote = 0
                }
                
                DispatchQueue.main.async {
                    self.tvMVP.reloadData()
                    if response?.result?.recentVoted != "" {
                        self.lblVotedUserName.text = response?.result?.recentVoted
                        self.btnVote.isHidden = true
                        self.viewVotedUser.isHidden = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? false : true
                    } else {
                        self.viewVotedUser.isHidden = true
                        self.btnVote.isHidden = self.leagueTabVC!().userRole!.canVoteMvp == 1 ? false : true
                        self.getMVPPlayer()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.sortedArray = [Player]()
                    self.tvMVP.reloadData()
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_MVP_PLAYER, parameters: ["leagueId":leagueTabVC!().tournamentDetail?.id ?? 0,"teamId":self.leagueTabVC!().teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                //self.getAllPlayer = (response?.result?.players)!
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.VOTE_MVP, parameters: ["leagueId":leagueTabVC!().tournamentDetail?.id ?? 0,"teamId":self.leagueTabVC!().teamId,"playerId":playerId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.lblVotedUserName.text = playerName
                    self.btnVote.isHidden = true
                    self.viewVotedUser.isHidden = false
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

