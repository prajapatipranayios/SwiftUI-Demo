//
//  TournamentLogVC.swift
//  Tussly
//
//  Created by Auxano on 17/12/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import Foundation
import UIKit

class TournamentLogVC: UIViewController, openTeamPageDelegate {
    
    // MARK: - Variables
    var arrBracket = [BracketData]()
    var arrBracketDetail = [BracketDetail]()
    var bracketDetail : BracketDetail?
    var isHost = false
    var leagueTabVC: (()->LeagueTabVC)?
    
    //Outlets
    @IBOutlet weak var tvLogs: UITableView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnTeam: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTeam.layer.cornerRadius = btnTeam.frame.size.height/2
        imgUser.layer.cornerRadius = imgUser.frame.size.height/2
        imgUser.setImage(imageUrl: (isHost ? bracketDetail?.homeTeam?.homeImage : bracketDetail?.awayTeam?.awayImage) ?? "")
        lblUserName.text = isHost ? bracketDetail?.homeTeam?.teamName : bracketDetail?.awayTeam?.teamName
        setUI()
    }
    
    func setUI() {
        DispatchQueue.main.async {
            self.tvLogs.rowHeight = UITableView.automaticDimension
            self.tvLogs.estimatedRowHeight = 160.0
            self.tvLogs.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func openTeamFromTournament() {
        print("redirect to team")
    }
    
    // MARK: - Button Click Events
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapTeam(_ sender: UIButton) {
        self.leagueTabVC!().delegateTeam = self
        var teamId : Int = 0
        teamId = (isHost ? bracketDetail?.homeTeamId : bracketDetail?.awayTeamId) ?? 0
        self.leagueTabVC!().redirectToTeam(teamId: teamId)
    }
    
    // MARK: Webservices
}

//MARK:- UITableViewDataSource,UITableViewDelegate
extension TournamentLogVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBracketDetail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BracketCell", for: indexPath) as! BracketCell
        cell.selectionStyle = .none
        
        let arr = arrBracketDetail
        
        var isBye = false
        isBye = ((arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) || (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1)) ? true : false
        if arr[indexPath.row].matchTime == "" || arr[indexPath.row].matchTime == "TBD" {
            cell.lblNextMatchTime.text = "TBD"
        } else {
            cell.lblNextMatchTime.text = "\(arr[indexPath.row].onlyDate ?? "")\n\(arr[indexPath.row].matchTime ?? "")"
        }
        cell.lblPlayer1Score.text = isBye ? "" : "\(arr[indexPath.row].homeTeamRoundWin ?? 0)"
        cell.lblPlayer2Score.text = isBye ? "" : "\(arr[indexPath.row].awayTeamRoundWin ?? 0)"
        cell.lblNextGame.text = arr[indexPath.row].roundLabel
        cell.lblPlayer1TeamNo.text = (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) ? "" : ((arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 0) ? "" : "\(arr[indexPath.row].homeTeamSeedNumber ?? 0)")
        cell.lblPlayer2TeamNo.text = (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1) ? "" : ((arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 0) ? "" : "\(arr[indexPath.row].awayTeamSeedNumber ?? 0)")
        if arr[indexPath.row].awayTeamScore ?? 0 > arr[indexPath.row].homeTeamScore ?? 0 {
            cell.lblPlayer2Score.font = Fonts.Bold.returnFont(size: 18.0)
        } else {
            cell.lblPlayer1Score.font = Fonts.Bold.returnFont(size: 18.0)
        }
        
        if (arr[indexPath.row].awayTeam?.id != 0) {
            var awayTeamName = (arr[indexPath.row].awayTeam?.teamName ?? "").count > 20 ? String((arr[indexPath.row].awayTeam?.teamName ?? "")[..<(arr[indexPath.row].awayTeam?.teamName ?? "").index((arr[indexPath.row].awayTeam?.teamName ?? "").startIndex, offsetBy: 20)]) : (arr[indexPath.row].awayTeam?.teamName ?? "")
            awayTeamName = (arr[indexPath.row].awayTeam?.teamName ?? "").count > 20 ? (awayTeamName + "...") : awayTeamName
            if arr[indexPath.row].awayTeam?.isJoinAsPlayer == 1 {
                cell.btnPlayer2Next.setTitle(awayTeamName, for: .normal)
                cell.lblPlayer2.text = awayTeamName
            } else {
                let team = awayTeamName
                let player = arr[indexPath.row].awayTeam?.userName ?? ""
                let finalName = "\(team)\n\(player)"
                cell.btnPlayer2Next.setAttributedTitle(finalName.setRegularString(string: player, fontSize: 13.0), for: .normal)
                cell.lblPlayer2.attributedText = finalName.setRegularString(string: player, fontSize: 13.0)
            }
            cell.imgNextPlayer2.setImage(imageUrl: arr[indexPath.row].awayTeam?.awayImage ?? "")
        } else if (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 0) {
            cell.btnPlayer2Next.setTitle("\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "") >", for: .normal)
            cell.lblPlayer2.text = "\(arr[indexPath.row].parentAwayTeamWinnerLabel ?? "") >"
            cell.imgNextPlayer2.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        } else if (arr[indexPath.row].awayTeam?.id == 0 && arr[indexPath.row].isBye == 1) {
            cell.btnPlayer2Next.setTitle("Bye!", for: .normal)
            cell.lblPlayer2.text = "Bye!"
            cell.imgNextPlayer2.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        }
        
        if (arr[indexPath.row].homeTeam?.id != 0) {
            var homeTeamName = (arr[indexPath.row].homeTeam?.teamName ?? "").count > 15 ? String((arr[indexPath.row].homeTeam?.teamName ?? "")[..<(arr[indexPath.row].homeTeam?.teamName ?? "").index((arr[indexPath.row].homeTeam?.teamName ?? "").startIndex, offsetBy: 15)]) : (arr[indexPath.row].homeTeam?.teamName ?? "")
            homeTeamName = (arr[indexPath.row].homeTeam?.teamName ?? "").count > 15 ? (homeTeamName + "...") : homeTeamName
            
            if arr[indexPath.row].homeTeam?.isJoinAsPlayer == 1 {
                cell.btnPlayer1Next.setTitle(homeTeamName, for: .normal)
                cell.lblPlayer1.text = homeTeamName
            } else {
                let team = homeTeamName
                let player = arr[indexPath.row].homeTeam?.userName ?? ""
                let finalName = "\(team)\n\(player)"
                cell.btnPlayer1Next.setAttributedTitle(finalName.setRegularString(string: player, fontSize: 13.0), for: .normal)
                cell.lblPlayer1.attributedText = finalName.setRegularString(string: player, fontSize: 13.0)
            }
            cell.imgNextPlayer1.setImage(imageUrl: arr[indexPath.row].homeTeam?.homeImage ?? "")
        } else if (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 0) {
            cell.btnPlayer1Next.setTitle("\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "") >", for: .normal)
            cell.lblPlayer1.text = "\(arr[indexPath.row].parentHomeTeamWinnerLabel ?? "") >"
            cell.imgNextPlayer1.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        } else if (arr[indexPath.row].homeTeam?.id == 0 && arr[indexPath.row].isBye == 1) {
            cell.btnPlayer1Next.setTitle("Bye!", for: .normal)
            cell.lblPlayer1.text = "Bye!"
            cell.imgNextPlayer1.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: ""))
        }
        
        if arr[indexPath.row].isPlayed == 1 {
            //match completed
            cell.viewTime.isHidden = true
            cell.lblMyGame.isHidden = true
            cell.viewScore.isHidden = false
            cell.lblPlayer1Score.isHidden = false
            cell.lblPlayer2Score.isHidden = false
            cell.player1Trailing.constant = 44
            if arr[indexPath.row].isMyGame == "1" {
                cell.viewShadow.addshadowToView(top: true, left: false, bottom: true, right: false, shadowRadius: 8.0)
            } else {
                cell.viewShadow.addshadowToView(top: false, left: false, bottom: false, right: false, shadowRadius: 0.0)
            }
        } else {
            if arr[indexPath.row].matchStatus == 6 {
                if (((arr[indexPath.row].homeTeamRoundWin ?? 0) == 0) || ((arr[indexPath.row].awayTeamRoundWin ?? 0) == 0)) {
                    cell.lblPlayer1Score.isHidden = true
                    cell.lblPlayer2Score.isHidden = true
                    cell.viewScore.isHidden = true
                } else {
                    cell.lblPlayer1Score.isHidden = false
                    cell.lblPlayer2Score.isHidden = false
                    cell.viewScore.isHidden = false
                }
                cell.viewTime.isHidden = true
            } else {
                cell.lblPlayer1Score.isHidden = true
                cell.lblPlayer2Score.isHidden = true
                cell.viewScore.isHidden = true
                cell.viewTime.isHidden = false
            }
            if arr[indexPath.row].isMyGame == "1" {
                if arr[indexPath.row].matchStatus == 6 {
                    cell.player1Trailing.constant = 44
                    cell.lblMyGame.isHidden = true
                } else {
                    cell.player1Trailing.constant = 100
                    cell.lblMyGame.isHidden = false
                }
                cell.viewShadow.addshadowToView(top: true, left: false, bottom: true, right: false, shadowRadius: 8.0)
            } else {
                cell.player1Trailing.constant = 44
                cell.lblMyGame.isHidden = true
                cell.viewShadow.addshadowToView(top: false, left: false, bottom: false, right: false, shadowRadius: 0.0)
            }
        }
        
        if arr[indexPath.row].decideBy == "PLAY" {
            cell.lblForfeit.isHidden = true
        } else {
            cell.lblForfeit.isHidden = false
            cell.viewTime.isHidden = true
            cell.viewScore.isHidden = true
        }
        
        if isBye {
            cell.viewScore.isHidden = true
            cell.viewTime.isHidden = true
        }
        
        cell.onTapBoxScore = { index in
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "BoxscoreVC") as! BoxscoreVC
            objVC.matchId = arr[indexPath.row].id
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
