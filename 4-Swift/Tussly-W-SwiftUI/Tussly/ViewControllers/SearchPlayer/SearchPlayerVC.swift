//
//  SearchPlayerVC.swift
//  - Designed Search Player screen which will be used within Add Player & Tussly Tab Screen.

//  Tussly
//
//  Created by Auxano on 18/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SearchPlayerVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var tvPlayer : UITableView!
    @IBOutlet weak var heightTvPlayer : NSLayoutConstraint!
    @IBOutlet weak var heightLeagueView : NSLayoutConstraint!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var btnLeagueTitle : UIButton!
    @IBOutlet weak var viewPlayerLine : UIView!
    @IBOutlet weak var viewLeagueLine : UIView!
    @IBOutlet weak var viewLeague : UIView!
    @IBOutlet weak var viewTeamLine : UIView!
    @IBOutlet weak var viewPastLine : UIView!
    @IBOutlet weak var viewActiveLine : UIView!
    @IBOutlet weak var viewRegisterLine : UIView!
    @IBOutlet weak var lblMsg : UILabel!
    
    @IBOutlet weak var viewScrollInside : UIView!
    
    
    // MARK: - Variables
    
    var timer = Timer()
    var newSearchString = ""
    var arrPlayer = [PlayerData]()
    var arrTeam = [Team]()
    var isFromPlayer = true
    
    // By Pranay
    var tusslyTabVC: (()->TusslyTabVC)?
    var arrLeagueTournament = [League]()
    var isFromTournaments = false
    //var didSelectTeam: ((Int)->Void)?
    //var didSelectPlayerCard: (()->Void)?
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        
        // By Pranay - Cpmment code
        //by default player selected
        //heightLeagueView.constant = 0
        //viewPlayerLine.isHidden = false
        //viewLeagueLine.isHidden = true
        //viewTeamLine.isHidden = true
        //txtSearch.placeholder = "Search Players"
        //viewLeague.isHidden = true
        // .
        
        // By Pranay
        if isFromPlayer {
            heightLeagueView.constant = 0
            viewPlayerLine.isHidden = false
            viewLeagueLine.isHidden = true
            viewTeamLine.isHidden = true
            txtSearch.placeholder = "Search Players"
            viewLeague.isHidden = true
        }
        else if !isFromPlayer && !isFromTournaments {
            isFromPlayer = false
            heightLeagueView.constant = 0
            viewPlayerLine.isHidden = true
            viewLeagueLine.isHidden = true
            viewTeamLine.isHidden = false
            txtSearch.placeholder = "Search Teams"
            viewLeague.isHidden = true
            lblMsg.text = Messages.requestToJoin
        }
        else if isFromTournaments && !isFromPlayer {
            if isFromTournaments {
                isFromPlayer = false
                heightLeagueView.constant = 0
                viewPlayerLine.isHidden = true
                viewLeagueLine.isHidden = false
                viewTeamLine.isHidden = true
                //txtSearch.placeholder = "Search Leagues & Tournaments"
                txtSearch.placeholder = "Search Tournaments"
                viewLeague.isHidden = true
                lblMsg.text = Messages.searchLeague
            }
        }
        // .
        
        tvPlayer.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tvPlayer.rowHeight = UITableView.automaticDimension
        tvPlayer.estimatedRowHeight = 100.0
        tvPlayer.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvPlayer.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewScrollInside.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvPlayer.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                DispatchQueue.main.async {
                    self.heightTvPlayer.constant = newsize.height
                    self.updateViewConstraints()
                }
            }
        }
    }
    
    // MARK: - UI Methods
    
    @objc func update () {
        if txtSearch.text != ""{
            if txtSearch.text!.count > 0 {
                if newSearchString != txtSearch.text {
                    /*if isFromPlayer {
                        searchPlayer(searchText: txtSearch.text!)
                    } else {
                        searchTeam(searchText: txtSearch.text!)
                    }   //  */
                    
                    if isFromPlayer {
                        searchPlayer(searchText: txtSearch.text!)
                    } else if !isFromPlayer && !isFromTournaments {
                        searchTeam(searchText: txtSearch.text!)
                    } else if isFromTournaments && !isFromPlayer {
                        searchLeagueTournament(searchText: txtSearch.text!)
                    }
                }
            }
        } else {
            newSearchString = ""
            arrPlayer.removeAll()
            arrTeam.removeAll()
            tvPlayer.reloadData()
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        newSearchString = ""
        txtSearch.text = ""
        arrPlayer.removeAll()
        arrTeam.removeAll()
        // By Pranay
        arrLeagueTournament.removeAll()
        // .
        tvPlayer.reloadData()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if APIManager.sharedManager.user != nil {
            if sender.tag == 0 {
                isFromPlayer = true
                isFromTournaments = false
                heightLeagueView.constant = 0
                viewPlayerLine.isHidden = false
                viewLeagueLine.isHidden = true
                viewTeamLine.isHidden = true
                txtSearch.placeholder = "Search Players"
                viewLeague.isHidden = true
                lblMsg.text = Messages.addFriendRequest
            }
            else if sender.tag == 1 {
                isFromPlayer = false
                isFromTournaments = true
                heightLeagueView.constant = 0   //  By Pranay - constant = 0
                viewPlayerLine.isHidden = true
                viewLeagueLine.isHidden = false
                viewTeamLine.isHidden = true
                //txtSearch.placeholder = "Search Leagues & Tournaments"
                txtSearch.placeholder = "Search Tournaments"
                viewLeague.isHidden = true
                //viewRegisterLine.isHidden = true   //  By Pranay - comment
                //viewPastLine.isHidden = true   //  By Pranay - comment
                //viewActiveLine.isHidden = false   //  By Pranay - comment
                lblMsg.text = Messages.searchLeague
            }
            else if sender.tag == 2 {
                isFromPlayer = false
                isFromTournaments = false
                heightLeagueView.constant = 0
                viewPlayerLine.isHidden = true
                viewLeagueLine.isHidden = true
                viewTeamLine.isHidden = false
                txtSearch.placeholder = "Search Teams"
                viewLeague.isHidden = true
                lblMsg.text = Messages.requestToJoin
            }
            else if sender.tag == 3 {
                viewRegisterLine.isHidden = true
                viewActiveLine.isHidden = false
                viewPastLine.isHidden = true
                btnLeagueTitle.setTitle("View all Leagues & Tournaments Active >", for: .normal)
            }
            else if sender.tag == 4 {
                viewRegisterLine.isHidden = true
                viewActiveLine.isHidden = true
                viewPastLine.isHidden = false
                btnLeagueTitle.setTitle("View all Leagues & Tournaments Past >", for: .normal)
            }
            else {
                viewRegisterLine.isHidden = false
                viewActiveLine.isHidden = true
                viewPastLine.isHidden = true
                btnLeagueTitle.setTitle("View all Leagues & Tournaments Registering >", for: .normal)
            }
            sender.isSelected = false
            newSearchString = ""
            txtSearch.text = ""
            arrPlayer.removeAll()
            arrTeam.removeAll()
            arrLeagueTournament.removeAll() //  By Pranay - added
            tvPlayer.reloadData()
        }
    }
    
    // MARK: APIs
    
    func searchPlayer(searchText : String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.searchPlayer(searchText: searchText)
                }
            }
            return
        }
            
        newSearchString = searchText
        if searchText != "" {
            APIManager.sharedManager.postData(url: APIManager.sharedManager.SEARCH_PLAYER, parameters: ["searchText":searchText,"inviteType" : "PLAYER"]) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    let res = (response?.result?.players)!
                    self.arrPlayer = res.data!
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                } else {
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.arrPlayer.removeAll()
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                }
            }
        }
    }
    
    func searchTeam(searchText : String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.searchTeam(searchText: searchText)
                }
            }
            return
        }
        
        newSearchString = searchText
        if searchText != "" {
            APIManager.sharedManager.postData(url: APIManager.sharedManager.SEARCH_TEAM, parameters: ["searchText":searchText]) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    self.arrTeam = (response?.result?.teams)!
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                } else {
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.arrTeam.removeAll()
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                }
            }
        }
    }
    
    // By Pranay
    func searchLeagueTournament(searchText : String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.searchLeagueTournament(searchText: searchText)
                }
            }
            return
        }
        
        newSearchString = searchText
        if searchText != "" {
            let param : Dictionary<String, Any> = ["filters" : ["search" : searchText],
                         "orderBy" : 1,
                         "page" : 1]
            
            APIManager.sharedManager.postData(url: APIManager.sharedManager.SEARCH_LEAGUE_TOURNAMENT, parameters: param) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    self.arrLeagueTournament = (response?.result?.leagues)!
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                } else {
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.arrLeagueTournament.removeAll()
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                }
            }
        }
    }
    // .
    
    func sendFriendRequest(id : Int,index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendFriendRequest(id: id, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FRIEND_REQUEST, parameters: ["otherUserId":id,"status":1]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrPlayer[index].playerStatus = 1
                    self.tvPlayer.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func cancelfriendRequest(id : Int,index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.cancelfriendRequest(id: id, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CANCEL_FRIEND_REQUEST, parameters: ["playerId":id]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrPlayer[index].playerStatus = 0
                    self.tvPlayer.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func cancelTeamRequest(id : Int,index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.cancelTeamRequest(id: id, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CANCEL_TEAM_REQUEST, parameters: ["teamId":id]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrTeam[index].teamStatus = 0
                    self.tvPlayer.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
}


// MARK: - UITableViewDelegate

extension SearchPlayerVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromPlayer {
            return arrPlayer.count
        }
        else if !isFromPlayer && !isFromTournaments {   //  By Pranay - condition change
            return arrTeam.count
        }
        else if self.isFromTournaments && !self.isFromPlayer {
            return arrLeagueTournament.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.btnAdd.isHidden = false    //  By Pranay
        if isFromPlayer {
            if !(arrPlayer.isEmpty) {
                cell.lblTeamName.text = ""
                cell.lblPlayerName.text = arrPlayer[indexPath.row].displayName
                cell.ivProfile.setImage(imageUrl: arrPlayer[indexPath.row].avatarImage!)
                
                if arrPlayer[indexPath.row].playerStatus == 0 {
                    cell.btnAdd.setTitle("Add Friend", for: .normal)
                    cell.btnAdd.backgroundColor = Colors.theme.returnColor()
                    cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
                }
                else if arrPlayer[indexPath.row].playerStatus == 1 {
                    cell.btnAdd.setTitle("Cancel", for: .normal)
                    cell.btnAdd.backgroundColor = Colors.black.returnColor()
                    cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
                }
                else if arrPlayer[indexPath.row].playerStatus == 2 {
                    cell.btnAdd.setTitle("Added", for: .normal)
                    cell.btnAdd.setTitleColor(Colors.black.returnColor(), for: .normal)
                    cell.btnAdd.backgroundColor = Colors.lightGray.returnColor()
                }
                else if arrPlayer[indexPath.row].playerStatus == 3 {
                    cell.btnAdd.setTitle("Declined", for: .normal)
                    cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
                    cell.btnAdd.backgroundColor = Colors.disableButton.returnColor()
                }
            }
        }
        else if !self.isFromPlayer && !self.isFromTournaments {   //  By Pranay - condition change
            cell.lblTeamName.text = arrTeam[indexPath.row].teamName
            cell.lblPlayerName.text = arrTeam[indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: arrTeam[indexPath.row].teamLogo!)
            
            if arrTeam[indexPath.row].teamStatus == 0 {
                cell.btnAdd.setTitle("Request", for: .normal)
                cell.btnAdd.backgroundColor = Colors.theme.returnColor()
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
            }
            else if arrTeam[indexPath.row].teamStatus == 1 {
                cell.btnAdd.setTitle("Cancel", for: .normal)
                cell.btnAdd.backgroundColor = Colors.black.returnColor()
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
            }
            else if arrTeam[indexPath.row].teamStatus == 2 {
                cell.btnAdd.setTitle("Joined", for: .normal)
                cell.btnAdd.setTitleColor(Colors.black.returnColor(), for: .normal)
                cell.btnAdd.backgroundColor = Colors.lightGray.returnColor()
            }
            else if arrTeam[indexPath.row].teamStatus == 3 {
                cell.btnAdd.setTitle("Declined", for: .normal)
                cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
                cell.btnAdd.backgroundColor = Colors.disableButton.returnColor()
            }
        }   //  By Pranay - new condition
        else if self.isFromTournaments && !self.isFromPlayer {
            //print("Cell - \(indexPath.row + 1)")
            cell.lblTeamName.text = arrLeagueTournament[indexPath.row].leagueName
            cell.lblPlayerName.text = arrLeagueTournament[indexPath.row].gameName
            cell.ivProfile.setImage(imageUrl: arrLeagueTournament[indexPath.row].logo!)
            
            cell.btnAdd.setTitle("View", for: .normal)
            cell.btnAdd.backgroundColor = Colors.theme.returnColor()
            cell.btnAdd.setTitleColor(UIColor.white, for: .normal)
        }
        // .
        cell.index = indexPath.row
        cell.onTapBtn = { index in
            if self.isFromPlayer {
                if self.arrPlayer[index].playerStatus == 0 {
                    self.sendFriendRequest(id: self.arrPlayer[index].id!, index: index)
                }
                else if self.arrPlayer[index].playerStatus == 1 {
                    self.cancelfriendRequest(id: self.arrPlayer[index].id!, index: index)
                }
            }
            else if !self.isFromPlayer && !self.isFromTournaments {
                if self.arrTeam[index].teamStatus == 0 {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "JoinRequestPopupVC") as! JoinRequestPopupVC
                    objVC.onTapSendRequestPopUp = { index in
                        if self.arrTeam[index].teamStatus == 0 {
                            self.arrTeam[index].teamStatus = 1
                        }
                        self.tvPlayer.reloadData()
                    }
                    objVC.index = index
                    //objVC.id = self.arrTeam[index].id
                    objVC.id = self.arrTeam[index].id ?? 0
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
                }
                else if self.arrTeam[index].teamStatus == 1 {
                    //self.cancelTeamRequest(id: self.arrTeam[index].id, index: index)
                    self.cancelTeamRequest(id: self.arrTeam[index].id ?? 0, index: index)
                }
            }
            else if self.isFromTournaments && !self.isFromPlayer {
                ///For view league info.
                self.view!.tusslyTabVC.isFromSerchPlayerTournament = true
                //self.view!.tusslyTabVC.leagueTournamentId = self.arrLeagueTournament[indexPath.row].leagueId!
                self.view!.tusslyTabVC.tournamentDetail = self.arrLeagueTournament[indexPath.row]
                self.view!.tusslyTabVC.isLeagueJoinStatus = (self.arrLeagueTournament[indexPath.row].joinStatus ?? 1) == 1 ? true : false
                self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[5])
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // By Pranay
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFromPlayer {
            self.view.tusslyTabVC.isFromSerchPlayerTournament = true
            //self.view.tusslyTabVC.intIdFromSearch = self.arrPlayer[indexPath.row].id!
            APIManager.sharedManager.playerData = self.arrPlayer[indexPath.row]
            self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[8])
        }
        else if !self.isFromPlayer && !self.isFromTournaments {
            self.view.tusslyTabVC.isFromSerchPlayerTournament = true
            //self.view.tusslyTabVC.intSearchTeamId = self.arrTeam[indexPath.row].id
            self.view.tusslyTabVC.intSearchTeamId = self.arrTeam[indexPath.row].id ?? 0
            self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[7])
        }
        else if self.isFromTournaments && !self.isFromPlayer {
            
        }
    }
    // .
}

// MARK: - UITextFieldDelegate

extension SearchPlayerVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 0 {
            btnSearchAssesory.isSelected = true
        } else {
            btnSearchAssesory.isSelected = false
            newSearchString = ""
            arrPlayer.removeAll()
            arrTeam.removeAll()
            tvPlayer.reloadData()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.timer.invalidate()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
}
