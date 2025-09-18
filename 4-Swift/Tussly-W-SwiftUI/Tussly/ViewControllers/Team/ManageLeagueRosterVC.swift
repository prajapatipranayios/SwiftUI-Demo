//
//  ManageLeagueRosterVC.swift
//  - Manage League Rosters for particular League. Rights will only be with Team Captain & Owner only.

//  Tussly
//
//  Created by Jaimesh Patel on 30/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ManageLeagueRosterVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvStarters: UITableView!
    @IBOutlet weak var tvSubstitute: UITableView!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var btnMove: UIButton!
    @IBOutlet weak var viewAssistantBtns: UIView!
    @IBOutlet weak var btnMakeAssistant: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!
    @IBOutlet weak var ivGameLogo: UIImageView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var viewGameSelection : UIView!

    // MARK: - Variables

    var starters = [Player]()
    var substitutes = [Player]()
    var players = [Player]()
    var getAllGameData = [Game]()
    var selectedGame = [Game]()
        
    var selectedStarters = [Player]()
    var selectedSubstitutes = [Player]()

    var selectedPlayer: Player?

    var isVCAvailable: Bool = false
    
    var teamTabVC: (()->TeamTabVC)?
    
    var swapPlayersArray = [[String: Any]]()
    
    var leagueConsolId = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()

        tvStarters.register(UINib(nibName: "PlayerTVCell", bundle: nil), forCellReuseIdentifier: "PlayerTVCell")
        tvSubstitute.register(UINib(nibName: "PlayerTVCell", bundle: nil), forCellReuseIdentifier: "PlayerTVCell")

        tvStarters.estimatedRowHeight = 50.0
        tvStarters.rowHeight = UITableView.automaticDimension
        tvSubstitute.estimatedRowHeight = 50.0
        tvSubstitute.rowHeight = UITableView.automaticDimension
        
        DispatchQueue.main.async {
            self.ivGameLogo.layer.cornerRadius = self.ivGameLogo.frame.size.width/2
        }
        
        getGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tvStarters.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvSubstitute.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.tvStarters!.observationInfo != nil {
           tvStarters.removeObserver(self, forKeyPath: "contentSize")
        }
        if self.tvSubstitute!.observationInfo != nil {
           tvSubstitute.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        heightViewContainer.constant = tvStarters.contentSize.height >= tvSubstitute.contentSize.height ? tvStarters.contentSize.height + 30 : tvSubstitute.contentSize.height + 30
        print("Starter: \(tvStarters.contentSize.height)")
        print("Substitute: \(tvStarters.contentSize.height)")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if(keyPath == "contentSize"){
            updateViewConstraints()
        }
    }
    
    func setupUI() {
        let attributedText = NSMutableAttributedString(string: Messages.note, attributes: [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 14.0)])
        attributedText.append(NSMutableAttributedString(string: "Lorem ipsum dolor sit amen, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et.", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)]))
        lblNote.attributedText = attributedText
        btnOptions.layer.cornerRadius = btnOptions.frame.size.height / 2
        btnOptions.clipsToBounds = true
        btnMove.layer.cornerRadius = btnMove.frame.size.height / 2
        btnMove.clipsToBounds = true
        btnMakeAssistant.layer.cornerRadius = btnMakeAssistant.frame.size.height / 2
        btnMakeAssistant.clipsToBounds = true
        btnCancel.layer.cornerRadius = btnCancel.frame.size.height / 2
        btnCancel.clipsToBounds = true
        
        viewAssistantBtns.isHidden = true
        btnMove.isHidden = false
        
        btnMove.isEnabled = false
    }
    
    func setupAPIResponse() {
        starters = players.filter{
            $0.isStarter == 1
        }
        substitutes = players.filter{
            $0.isStarter == 0
        }
        
        let vc = players.filter{ $0.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue }
        isVCAvailable = vc.count != 0
        
        if starters.count > 0 {
            tvStarters.dataSource = self
            tvStarters.delegate = self
            tvStarters.reloadData()
        }
        
        if substitutes.count > 0 {
            tvSubstitute.dataSource = self
            tvSubstitute.delegate = self
            tvSubstitute.reloadData()
        }
    }
    
    func clearSelection() {
        self.selectedStarters.removeAll()
        self.selectedSubstitutes.removeAll()
        self.starters = self.starters.map{
            var mutStarter = $0
            if $0.isSelected == true {
                mutStarter.isSelected = false
            }
            return mutStarter
        }
        self.tvStarters.reloadData()
        self.substitutes = self.substitutes.map{
            var mutSubstitute = $0
            if $0.isSelected == true {
                mutSubstitute.isSelected = false
            }
            return mutSubstitute
        }
        self.tvSubstitute.reloadData()
        self.players = self.players.map{
            var mutPlayer = $0
            if $0.isSelected == true {
                mutPlayer.isSelected = false
            }
            return mutPlayer
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        teamTabVC!().selectedIndex = -1
        teamTabVC!().cvTeamTabs.selectedIndex = -1
        teamTabVC!().cvTeamTabs.reloadData()
    }
    
    @IBAction func onTapGame(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectItem = { arrSelected in
            DispatchQueue.main.async {
                self.selectedGame = arrSelected
                self.leagueConsolId = arrSelected[0].leagueConsole![0].id!
                self.getLeagueRosters(consoleId: arrSelected[0].leagueConsole![0].id!)
            }
        }
        objVC.arrGameList = getAllGameData
        objVC.arrSelected = selectedGame
        objVC.isSingleSelection = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func moveTapped(_ sender: Any) {
        if starters.first(where: {$0.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue}) != nil || substitutes.first(where: {$0.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue}) != nil {
           // Vice Captain is available
            if starters.count == self.selectedGame[0].teamSize && selectedStarters.count != selectedSubstitutes.count {
                Utilities.showPopup(title: Messages.selectEqualAmount, type: .error)
            } else if selectedSubstitutes.count + (starters.count - selectedStarters.count) > self.selectedGame[0].teamSize! {
                Utilities.showPopup(title: "Maximum \(self.selectedGame[0].teamSize ?? 0) Players required.", type: .error)
//            }
//
//            if selectedStarters.count != selectedSubstitutes.count {
//                Utilities.showPopup(title: "Please select equal amount of Players for swapping", type: .error)
            } else {
                selectedStarters.removeAll()
                selectedSubstitutes.removeAll()
                print(swapPlayersArray)
                swapPlayersArray.removeAll()
                self.players = self.players.map{
                    var mutPlayer = $0
                    if $0.isSelected == true {
                        mutPlayer.isStarter = mutPlayer.isStarter == 0 ? 1 : 0
                        mutPlayer.isSelected = false
                    }
                    swapPlayersArray.append(["userId": mutPlayer.id!, "isStarter": mutPlayer.isStarter!, "role": mutPlayer.role!])
                    return mutPlayer
                }
                
                swapLeaguePlayers(matchId: self.players[0].matchId!, swapPlayers: swapPlayersArray, completionBlock: { status in
                    if status == 1 {
                        self.starters = self.players.filter{
                            $0.isStarter == 1
                        }
                        self.substitutes = self.players.filter{
                            $0.isStarter == 0
                        }
                        DispatchQueue.main.async {
                            self.tvStarters.reloadData()
                            self.tvSubstitute.reloadData()
                            self.btnMove.isEnabled = false
                        }
                    }
                })
            }
        } else {
           // Vice Captain is not available
            clearSelection()
            
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.addAssistantcaptain
            dialog.message = Messages.firstAddCaptainToLeague
            dialog.tapOK = {
                self.btnMove.isHidden = true
                self.viewAssistantBtns.isHidden = false
            }
            dialog.btnYesText = Messages.add
            dialog.btnNoText = Messages.cancel
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func makeCaptainTapped(_ sender: Any) {
        if selectedPlayer != nil {
            if selectedPlayer!.role == PlayerRole.CAPTAIN.rawValue {
                Utilities.showPopup(title: Messages.selectPlayerAlreadyCaptain, type: .error)
            } else if selectedPlayer!.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue {
                Utilities.showPopup(title: Messages.selectPlayerAlreadyViceCaptain, type: .error)
            } else {
                //
                let player = self.players.filter{
                    $0.id == selectedPlayer?.id
                }
                var rolePlayer: PlayerRole
                if btnMakeAssistant.titleLabel?.text == "Change Captain" {
                    //Change Captain
                    rolePlayer = PlayerRole.CAPTAIN
                } else {
                    //Change Assistant Captain
                    rolePlayer = PlayerRole.ASSISTENT_CAPTAIN
                }
                changeLeaguePlayerRole(player: player[0], role: rolePlayer.rawValue) { (player) in
                    self.players = self.players.map{
                        var mutPlayer = $0
                        if $0.id != player.id {
                            if $0.role == rolePlayer.rawValue {
                                mutPlayer.role = PlayerRole.MEMBER.rawValue
                            }
                            return mutPlayer
                        } else {
                            return player
                        }
                    }
                    
                    self.starters = self.players.filter{
                        $0.isStarter == 1
                    }
                    self.substitutes = self.players.filter{
                        $0.isStarter == 0
                    }
                    self.isVCAvailable = true
                    
                    self.viewAssistantBtns.isHidden = true
                    self.btnMove.isHidden = false
                    self.btnMove.isEnabled = false
                    
                    self.selectedPlayer = nil
                    self.tvStarters.reloadData()
                    self.tvSubstitute.reloadData()
                }
            }
        } else {
            Utilities.showPopup(title: Messages.selectPlayerMakeAssistantCaptain, type: .error)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        viewAssistantBtns.isHidden = true
        btnMove.isHidden = false
        selectedPlayer = nil
        tvStarters.reloadData()
        tvSubstitute.reloadData()
        btnMove.isEnabled = false
    }
    
    @IBAction func optionsTapped(_ sender: Any) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = "Select Option"
        objVC.didSelectItem = { index,isImagePicker in
            switch index {
                case 0: // Manage Starting Line Up
                    break
                case 1: // Add Substitute
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSubstituteVC") as! AddSubstituteVC
                    //objVC.teamId = self.teamTabVC!().teamDetails!.id
                objVC.teamId = self.teamTabVC!().teamDetails!.id ?? 0
                    objVC.isFromTeam = true
                    objVC.leagueConsoleId = self.leagueConsolId
                    self.navigationController?.pushViewController(objVC, animated: true)
                    break
                case 2: //Change Captain
                    self.btnMove.isHidden = true
                    self.viewAssistantBtns.isHidden = false
                    self.clearSelection()
                    self.btnMakeAssistant.setTitle("Change Captain", for: .normal)
                    break
                case 3: //Change Assistant Captain
                    self.btnMove.isHidden = true
                    self.viewAssistantBtns.isHidden = false
                    self.clearSelection()
                    self.btnMakeAssistant.setTitle("Change Assistant Captain", for: .normal)
                default:
                    break
            }
        }
        objVC.selectedIndex = -1
        objVC.option = ["Manage Starting Line Up",
                        "Add Substitute",
                        "Change Captain",
                        "\(isVCAvailable ? "Change" : "Add") Assistant Captain"]
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    
    func getGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGame()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_GAME, parameters: ["teamId":teamTabVC!().teamDetails!.id]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.viewGameSelection.isHidden = false
//                    self.getAllGameData = (response?.result?.teamGames)!
//                    self.selectedGame = [self.getAllGameData[0]]
//                    self.getLeagueRosters(consoleId: self.getAllGameData[0].leagueConsole![0].id!)
//                    self.leagueConsolId = self.getAllGameData[0].leagueConsole![0].id!
//                    self.lblTeamName.text = self.getAllGameData[0].gameName!
//                    self.ivGameLogo.setImage(imageUrl: self.getAllGameData[0].gameImage)
                }
            } else {
                DispatchQueue.main.async {
                    self.viewGameSelection.isHidden = true
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func changeLeaguePlayerRole(player: Player, role: Int, completion: ((Player)->Void)?) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changeLeaguePlayerRole(player: player, role: role, completion: completion)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["matchId": player.matchId!,
                      "userId": player.id!,
                      "role": role,
                      "teamId": teamTabVC!().teamDetails!.id] as [String: Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_LEAGUE_PLAYER_ROLE, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1  {
                var playerRole = player
                playerRole.role = role
                DispatchQueue.main.async {
                    completion!(playerRole)
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getLeagueRosters(consoleId : Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLeagueRosters(consoleId: consoleId)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["leagueId": consoleId,
                      "teamId": teamTabVC!().teamDetails!.id]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_ROSTER, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                self.players.removeAll()
                self.players = (response?.result?.leagueRoster)!
                DispatchQueue.main.async {
                    self.setupAPIResponse()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    func swapLeaguePlayers(matchId: Int, swapPlayers: [[String: Any]], completionBlock: @escaping (Int)->()) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.swapLeaguePlayers(matchId: matchId, swapPlayers: swapPlayers, completionBlock: completionBlock)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        var param = ["matchId": matchId,
                     "teamId": teamTabVC!().teamDetails!.id] as [String: Any]
        
        param.updateValue(swapPlayers, forKey: "players")
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SWAP_LEAGUE_PLAYERS, parameters: param) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            completionBlock((response?.status)!)
            if response?.status != 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension ManageLeagueRosterVC: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 11 {
            return starters.count
        } else {
            return substitutes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTVCell", for: indexPath) as! PlayerTVCell
        var player: Player
        if tableView.tag == 11 {
            player = starters[indexPath.row]
        } else {
            player = substitutes[indexPath.row]
        }
        cell.lblPlayerName.text = player.displayName
        
        cell.ivPlayer.setImage(imageUrl: player.avatarImage!)
        
        cell.widthIvCaptain.constant = player.role == PlayerRole.CAPTAIN.rawValue || player.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue ? 20.0 : 0
        
        cell.ivCaptain.image = UIImage(named: player.role == PlayerRole.CAPTAIN.rawValue ? "Captain" : player.role == PlayerRole.ASSISTENT_CAPTAIN.rawValue ? "AssistantCaptain" : "")
        
        
        if btnMove.isHidden == true {
            cell.ivCheck.image = UIImage(named: player.id == selectedPlayer?.id ? "Select" : "Uncheck")
        } else {
            cell.ivCheck.image = UIImage(named: player.isSelected != nil && player.isSelected! ? "Select" : "Uncheck")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if btnMove.isHidden == true {
            if tableView.tag == 11 {
                selectedPlayer = starters[indexPath.row]
            } else {
                selectedPlayer = substitutes[indexPath.row]
            }
            tvStarters.reloadData()
            tvSubstitute.reloadData()
        } else {
            var player: Player
            if tableView.tag == 11 {
                starters[indexPath.row].isSelected = starters[indexPath.row].isSelected == nil ? true : !starters[indexPath.row].isSelected!
                player = starters[indexPath.row]
                if player.isSelected == false {
                    selectedStarters.removeAll{$0.id == player.id}
                } else {
                    selectedStarters.append(player)
                }
            } else {
                substitutes[indexPath.row].isSelected = substitutes[indexPath.row].isSelected == nil ? true : !substitutes[indexPath.row].isSelected!
                player = substitutes[indexPath.row]
                if player.isSelected == false {
                    selectedSubstitutes.removeAll{$0.id == player.id}
                } else {
                    selectedSubstitutes.append(player)
                }
            }

            self.players = self.players.map{
                var mutPlayer = $0
                if $0.id == player.id {
                    mutPlayer.isSelected = mutPlayer.isSelected == nil ? true : !mutPlayer.isSelected!
                }
                return mutPlayer
            }

            btnMove.isEnabled = selectedSubstitutes.count == 0 && selectedStarters.count == 0 ? false : true

            tableView.reloadRows(at: [indexPath], with: .automatic)
            print(selectedStarters.count)
        }
    }
}
