//
//  GamePlayedVC.swift
//  Tussly
//
//  Created by Auxano on 17/08/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class GamePlayedVC: UIViewController {
    
    // MARK: - Variables.
    var playerTabVC: (()->PlayerCardTabVC)?
    var arrGetGames = [Game]()
    var arrGames = [Int]()
    var arrPlayerGame = [PlayerGames]()
    var selectedIndex = -1
    
    var intIdFromSearch : Int = 0
    
    // MARK: - Controls
    @IBOutlet weak var tvGames : UITableView!
    @IBOutlet weak var btnAddGame : UIButton!
    
    @IBOutlet weak var lblNoGame: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()     //  By Pranay - comment by pranay
        //getGames()    //  By Pranay - comment by pranay
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 311 - By Pranay
        self.lblNoGame.isHidden = true
        btnAddGame.isHidden = intIdFromSearch != 0 ? true : false
        
        setupUI()
        getGames()
        /// 311  .
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        tvGames.rowHeight = UITableView.automaticDimension
        tvGames.estimatedRowHeight = 80
        btnAddGame.layer.cornerRadius = btnAddGame.frame.size.height / 2
    }
    
    // MARK: - IB Actions
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
        playerTabVC!().cvPlayerTabs.selectedIndex = -1  //  By Pranay - added by pranay
        playerTabVC!().cvPlayerTabs.reloadData()        //  By Pranay - added by pranay
    }
    
    @IBAction func onTapAddGame(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
        objVC.didSelectGame = {
            self.getPlayedGames()
        }
        //self.arrGames = Array(Set(self.arrGames))
        objVC.titleString = Messages.addGame
        objVC.buttontitle = Messages.add
        objVC.placeHolderString = Messages.searchGameToAdd
        objVC.arrGameList = self.arrGetGames
        objVC.arrSelectedGame = self.arrGames
        objVC.isForGame = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
            
    // MARK: - Webservices
    func getGames() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGames()
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.arrGetGames = (response?.result?.games)!
                self.getPlayedGames()
            } else {
                self.getPlayedGames()
            }
        }
    }
    
    func getPlayedGames() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayedGames()
                }
                return
                     }
           }
        showLoading()
        /// 232 - By Pranay
        let params = ["otherUserId": intIdFromSearch]    //   By Pranay - added param
        /// 232 .
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_GAME, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrPlayerGame = (response?.result?.playerGames)!
                    self.arrGames.removeAll()
                    for i in 0 ..< self.arrPlayerGame.count {
                        self.arrGetGames.map {
                            if $0.id == (self.arrPlayerGame[i].id)! {
                                self.arrGames.append(self.arrPlayerGame[i].id!)
                            }
                        }
                    }
                    self.tvGames.reloadData()
                    self.lblNoGame.isHidden = true
                    
                    if self.intIdFromSearch != 0 {
                        if self.arrPlayerGame.count == 0 {
                            self.lblNoGame.isHidden = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func removeGames(index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removeGames(index: index)
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_PLAYER_GAME, parameters: ["gameId" : arrPlayerGame[index].id!]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1
            {
                DispatchQueue.main.async
                {
                    self.arrGames.remove(at: self.arrGames.firstIndex(of: self.arrPlayerGame[index].id!)!)
                    self.arrPlayerGame.remove(at: index)
                    
                    if self.arrPlayerGame.count <= 0
                    {
                        self.arrGames.removeAll()
                    }
                    self.tvGames.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}

// MARK: - TableView Methods
extension GamePlayedVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrPlayerGame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamePlayedCell", for: indexPath) as! GamePlayedCell
        cell.index = indexPath.row
        cell.lblGame.text = arrPlayerGame[indexPath.row].gameName
        cell.ivProfile.setImage(imageUrl: arrPlayerGame[indexPath.row].gameImage ?? "")
        cell.btnRemove.isHidden = intIdFromSearch != 0 ? true : false
        cell.onTapRemove = { index in
            self.removeGames(index: index)
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

