//
//  AddSubstituteVC.swift
//  - Designed screen to add substitute players

//  Tussly
//
//  Created by Jaimesh Patel on 30/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddSubstituteVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var tvAddSubTeam : UITableView!
    @IBOutlet weak var tvAddSubDisplay : UITableView!
    @IBOutlet weak var tvAddFriendByEmail : UITableView!
    @IBOutlet weak var viewAddSubDisplay : UIView!
    @IBOutlet weak var viewAddEmail: UIView!
    @IBOutlet weak var heightTvAddSubTeam : NSLayoutConstraint!
    @IBOutlet weak var heightTvAddSubDisplay : NSLayoutConstraint!
    @IBOutlet weak var heightTvAddFriendByEmail : NSLayoutConstraint!
    @IBOutlet weak var viewFriendContainer: UIView!
    @IBOutlet weak var btnAddFriends : UIButton!
    @IBOutlet weak var btnAddPlayers : UIButton!
    @IBOutlet weak var btnAddByEmail : UIButton!
    
    // MARK: - Variables
    
    var leagueConsoleId = -1
    var teamId = -1
    var addFriendData = [Player]()
    var addPlayerData = [PlayerData]()
    var addFriendByEmailData = [String]()
    var substitutePlayers = [Player]()
    var dicSub = Dictionary<String, Any>()
    var isValid = true
    var isFromTeam = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSubstitutes()
        DispatchQueue.main.async {
            self.btnAddByEmail.layer.cornerRadius = self.btnAddByEmail.frame.size.height / 2
            self.btnAddFriends.layer.cornerRadius = self.btnAddFriends.frame.size.height / 2
            self.btnAddPlayers.layer.cornerRadius = self.btnAddPlayers.frame.size.height / 2
            self.viewFriendContainer.addDashedBorder()
            self.viewAddSubDisplay.addDashedBorder()
            self.viewAddEmail.addDashedBorder()
        }
        tvAddSubTeam.delegate = self
        tvAddSubTeam.dataSource = self
        tvAddSubDisplay.delegate = self
        tvAddSubDisplay.dataSource = self
        tvAddFriendByEmail.delegate = self
        tvAddFriendByEmail.dataSource = self
        
        tvAddSubTeam.rowHeight = UITableView.automaticDimension
        tvAddSubTeam.estimatedRowHeight = 250.0
        tvAddSubDisplay.rowHeight = UITableView.automaticDimension
        tvAddSubDisplay.estimatedRowHeight = 250.0
        tvAddFriendByEmail.rowHeight = UITableView.automaticDimension
        tvAddFriendByEmail.estimatedRowHeight = 250.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvAddSubTeam.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddSubDisplay.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddFriendByEmail.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvAddSubTeam.removeObserver(self, forKeyPath: "contentSize")
        tvAddSubDisplay.removeObserver(self, forKeyPath: "contentSize")
        tvAddFriendByEmail.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func updateViewConstraints() {
        heightTvAddFriendByEmail.constant = tvAddFriendByEmail.contentSize.height
        heightTvAddSubTeam.constant = tvAddSubTeam.contentSize.height
        heightTvAddSubDisplay.constant = tvAddSubDisplay.contentSize.height
        heightTvAddFriendByEmail.constant = tvAddFriendByEmail.contentSize.height
        super.updateViewConstraints()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTvAddSubTeam.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    // MARK: - UI Methods
    
    func checkValidation() -> Bool {
        var value = true
        for i in 0..<addFriendByEmailData.count {
            if addFriendByEmailData[i] == "" {
                value = false
                break
            }else {
                if (addFriendByEmailData[i].isNumber) {
                    if !((addFriendByEmailData[i].count) >= MIN_MOBILE_LENGTH) {
                        value = false
                        break
                    }
                }else {
                    if !(addFriendByEmailData[i].isValidEmail()) {
                        value = false
                        break
                    }
                }
            }
        }
        
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapAddSubTeam(_ sender : UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
        objVC.didSelectItem = { selectedFriend in
            self.addFriendData = selectedFriend
            self.tvAddSubTeam.reloadData()
        }
        objVC.titleString = "Add Substitute"
        objVC.buttontitle = "Add"
        objVC.placeHolderString = "Search player from your team"
        objVC.arrFriendsList = substitutePlayers
        objVC.arrSelected = addFriendData
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddSubDisplay(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlayerVC") as! AddPlayerVC
        objVC.didSelectOtherPlayer = { selectedPlayer in
            self.addPlayerData = selectedPlayer
            self.tvAddSubDisplay.reloadData()
        }
        objVC.titleString = "Add Substitute"
        objVC.isFromTeam = isFromTeam
        objVC.teamId = teamId
        objVC.arrOtherSelected = addPlayerData
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddUserByEmail(_ sender : UIButton) {
        if checkValidation() {
            tvAddFriendByEmail.reloadData()
            isValid = true
            //addFriendByEmailData.append("")
            addFriendByEmailData.insert("", at: 0)
        }else {
            isValid = false
        }
        
        tvAddFriendByEmail.reloadData()
    }
    
    @IBAction func onTapSubstitutes(_ sender: UIButton) {
        if checkValidation() {
            isValid = true
            tvAddFriendByEmail.reloadData()
            addSubstitutes()
        }else {
            isValid = false
            tvAddFriendByEmail.reloadData()
        }
    }
    
    // MARK: Webservices

    func getSubstitutes() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getSubstitutes()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_SUBSTITUTES_PLAYER, parameters: ["leagueId": leagueConsoleId,
        "teamId": teamId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.substitutePlayers = (response?.result?.substitutePlayers)!
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func addSubstitutes() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addSubstitutes()
                }
            }
            return
        }
        
        if addFriendData.count == 0 && addPlayerData.count == 0 && addFriendByEmailData.count == 0 {
            return
        }
        
        var alreadyExistPlayer = [[String: Any]]()
        for i in 0..<addFriendData.count {
            alreadyExistPlayer.append(["userId": addFriendData[i].id!])
        }

        for i in 0..<addPlayerData.count {
            alreadyExistPlayer.append(["userId": addPlayerData[i].id!])
        }
        
        var invitedNotExMembers = [[String: Any]]()
        for i in 0..<addFriendByEmailData.count {
            invitedNotExMembers.append(["receiverEmail": addFriendByEmailData[i]])
        }

        dicSub = ["leagueId": leagueConsoleId,
                    "teamId": teamId,
                    "alreadyExistPlayer": alreadyExistPlayer,
                    "invitedNotExMembers": invitedNotExMembers
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ADD_SUBSTITUTES, parameters: dicSub) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension AddSubstituteVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvAddSubTeam {
            return addFriendData.count
        } else if tableView == tvAddSubDisplay {
            return addPlayerData.count
        } else {
            return addFriendByEmailData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvAddSubTeam {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addFriendData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addFriendData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddSubTeam
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddSubTeam {
                    self.addFriendData.remove(at: index)
                    self.tvAddSubTeam.reloadData()
                } else {
                    self.addPlayerData.remove(at: index)
                    self.tvAddSubDisplay.reloadData()
                }
            }
            return cell
        } else if tableView == tvAddSubDisplay {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addPlayerData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addPlayerData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddSubDisplay
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddSubTeam {
                    self.addFriendData.remove(at: index)
                    self.tvAddSubTeam.reloadData()
                } else {
                    self.addPlayerData.remove(at: index)
                    self.tvAddSubDisplay.reloadData()
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendByEmailCell", for: indexPath) as! AddFriendByEmailCell
            cell.txtEmailOrPhone.text = addFriendByEmailData[indexPath.row]
            cell.index = indexPath.row
            
            if !isValid {
                cell.checkValidation()
            }else {
                cell.lblEmailOrPhoneError.text = ""
            }
            
            cell.onTapAddFriendByEmail = { emailOrPhone,index in
                self.addFriendByEmailData[index] = emailOrPhone
                if self.checkValidation() {
                    self.tvAddFriendByEmail.reloadData()
                    self.isValid = true
                }else {
                    self.isValid = false
                    self.tvAddFriendByEmail.reloadData()
                }
            }
            
            cell.onTapRemoveFriend = { index in
                self.view.endEditing(true)
                self.addFriendByEmailData.remove(at: index)
                self.tvAddFriendByEmail.reloadData()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
