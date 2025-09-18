//
//  AddSubstituteVC.swift
//  - Invite members like Friends, Players to Team. It's one of available Tabs within Team Module.

//  Tussly
//
//  Created by Jaimesh Patel on 30/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class InviteMembersVC: UIViewController {

    // MARK: - Controls
    
    @IBOutlet weak var tvAddFriends: UITableView!
    @IBOutlet weak var tvAddPlayers: UITableView!
    @IBOutlet weak var tvAddFriendByEmail: UITableView!
    
    @IBOutlet weak var viewAddSubTeam: UIView!
    @IBOutlet weak var viewAddSubDisplay: UIView!
    @IBOutlet weak var viewAddEmail: UIView!
    @IBOutlet weak var viewShareByLink: UIView!
    
    @IBOutlet weak var heightTVAddFriends : NSLayoutConstraint!
    @IBOutlet weak var heightTVAddPlayers : NSLayoutConstraint!
    @IBOutlet weak var heightTVAddFriendByEmail : NSLayoutConstraint!
    @IBOutlet weak var heightViewAddEmail: NSLayoutConstraint!
    @IBOutlet weak var topViewAddEmail: NSLayoutConstraint!
    @IBOutlet weak var heightViewAddSubDisplay: NSLayoutConstraint!
    @IBOutlet weak var topViewAddSubDisplay: NSLayoutConstraint!
    
    @IBOutlet weak var btnAddFriends : UIButton!
    @IBOutlet weak var btnInvite : UIButton!
    @IBOutlet weak var btnAddPlayers : UIButton!
    @IBOutlet weak var btnAddByEmail : UIButton!
    @IBOutlet weak var btnCopy : UIButton!
    @IBOutlet weak var lblPendingFriend : UILabel!
    @IBOutlet weak var lblPendingPlayer : UILabel!
    @IBOutlet weak var lblPendingByEmail : UILabel!
    @IBOutlet weak var lblCopy : UILabel!
    
    // MARK: - Variables
    
    var addFriendData = [Player]()
    var addPlayerData = [PlayerData]()
    var addFriendByEmailData = [String]()
    var friends = [Player]()
    var dicTeamInvite = Dictionary<String, Any>()
    var isValid = true
    var teamTabVC: (()->TeamTabVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getFriend()   //  Comment by Pranay.
        DispatchQueue.main.async {
            self.lblCopy.text = self.teamTabVC!().teamDetails!.inviteUrl ?? ""
            
//            self.addFriendContainer.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMinXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.bottomLeft])
            self.btnAddFriends.layer.cornerRadius = self.btnAddFriends.frame.size.height / 2
            self.btnAddPlayers.layer.cornerRadius = self.btnAddPlayers.frame.size.height / 2
            self.btnAddByEmail.layer.cornerRadius = self.btnAddByEmail.frame.size.height / 2
            self.btnInvite.layer.cornerRadius = 12.0
            self.btnCopy.layer.cornerRadius = self.btnCopy.frame.size.height / 2
            self.viewAddSubTeam.addDashedBorder()
            self.viewAddSubDisplay.addDashedBorder()
            self.viewAddEmail.addDashedBorder()
            self.viewShareByLink.addDashedBorder()
        }
        tvAddFriends.delegate = self
        tvAddFriends.dataSource = self
        tvAddPlayers.delegate = self
        tvAddPlayers.dataSource = self
        tvAddFriendByEmail.delegate = self
        tvAddFriendByEmail.dataSource = self
        
        tvAddFriends.rowHeight = UITableView.automaticDimension
        tvAddFriends.estimatedRowHeight = 250.0
        tvAddPlayers.rowHeight = UITableView.automaticDimension
        tvAddPlayers.estimatedRowHeight = 250.0
        tvAddFriendByEmail.rowHeight = UITableView.automaticDimension
        tvAddFriendByEmail.estimatedRowHeight = 250.0
        
        viewAddEmail.isHidden = true
        heightViewAddEmail.constant = 0
        topViewAddEmail.constant = 0
        viewAddSubDisplay.isHidden = true
        heightViewAddSubDisplay.constant = 0
        topViewAddSubDisplay.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvAddFriends.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddPlayers.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddFriendByEmail.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //lblPendingFriend.text = "Pending Invitations"
        
        self.addFriendData.removeAll()
        self.tvAddFriends.reloadData()
        getFriend()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvAddFriends.removeObserver(self, forKeyPath: "contentSize")
        tvAddPlayers.removeObserver(self, forKeyPath: "contentSize")
        tvAddFriendByEmail.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func updateViewConstraints() {
        heightTVAddFriendByEmail.constant = tvAddFriendByEmail.contentSize.height
        heightTVAddFriends.constant = tvAddFriends.contentSize.height
        heightTVAddPlayers.constant = tvAddPlayers.contentSize.height
        heightTVAddFriendByEmail.constant = tvAddFriendByEmail.contentSize.height
        super.updateViewConstraints()
    }
    
    // MARK: - UI Methods

    @IBAction func btnCopyTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.teamTabVC!().teamDetails!.inviteUrl ?? ""
            Utilities.showPopup(title: "Team link copied.", type: .success)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVAddFriends.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
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
        teamTabVC!().selectedIndex = -1
        teamTabVC!().cvTeamTabs.selectedIndex = -1
        teamTabVC!().cvTeamTabs.reloadData()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onTapAddFriends(_ sender : UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
        objVC.didSelectItem = { selectedFriend in
            self.addFriendData = selectedFriend
//            if(self.addFriendData.count > 0){
//                self.lblPendingFriend.text = "Pending Invitations"
//            } else {
//                self.lblPendingFriend.text = ""
//            }
            self.tvAddFriends.reloadData()
        }
        objVC.titleString = "Add Friends"
        objVC.buttontitle = "Add"
        objVC.arrFriendsList = friends
        objVC.arrSelected = addFriendData
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddPlayers(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlayerVC") as! AddPlayerVC
        objVC.didSelectOtherPlayer = { selectedPlayer in
            self.addPlayerData = selectedPlayer
            self.tvAddPlayers.reloadData()
        }
        objVC.titleButton = "Invite"
        objVC.titleString = "Search Players"
        objVC.isFromTeam = true
        //objVC.teamId = teamTabVC!().teamDetails!.id
        objVC.teamId = teamTabVC!().teamDetails!.id ?? 0
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
    
    @IBAction func onTapInviteFriends(_ sender: UIButton) {
        if checkValidation() {
            isValid = true
            tvAddFriendByEmail.reloadData()
            inviteMember()
        }else {
            isValid = false
            tvAddFriendByEmail.reloadData()
        }
    }
    
    @IBAction func onTapShareFriends(_ sender: UIButton) {
        UIPasteboard.general.string = "Hello "
        Utilities.showPopup(title: "Copy to clipboard", type: .success)
//        let text = Messages.inviteMemberDiscription
//        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//
//        if UIDevice.current.userInterfaceIdiom == .phone
//        {
//            self.present(activityViewController, animated: true, completion: nil)
//        }
//        else
//        {
//            let popover = activityViewController.popoverPresentationController
//            popover?.sourceView = btnCopy
//            popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)
//
//            present(activityViewController, animated: true)
//        }
    }
    
    @IBAction func ontapInviteMember(_ sender: UIButton) {
        inviteMember()
    }

    // MARK: - Webservices
    
    func getFriend() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFriend()
                }
            }
            return
        }
        
        showLoading()
        let param = ["type" : "invitation",
                     "teamId" : teamTabVC!().teamDetails?.id ?? 0] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIENDS, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.friends = (response?.result?.friends)!
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func inviteMember() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.inviteMember()
                }
            }
            return
        }
        
        var alreadyExistPlayer = [[String: Any]]()
        for i in 0..<addFriendData.count {
            alreadyExistPlayer.append(["userId": addFriendData[i].id!,"status":1])
        }

        for i in 0..<addPlayerData.count {
            alreadyExistPlayer.append(["userId": addPlayerData[i].id!,"status":1])
        }
        
        var invitedNotExMembers = [[String: Any]]()
        for i in 0..<addFriendByEmailData.count {
            invitedNotExMembers.append(["receiverEmail": addFriendByEmailData[i]])
        }
        
        if alreadyExistPlayer.count != 0 || invitedNotExMembers.count != 0 {
            dicTeamInvite = [
                "teamId": teamTabVC!().teamDetails!.id as Any,
                        "teamMembers": alreadyExistPlayer,
                        "teamMemberInvites": invitedNotExMembers
            ]

            showLoading()
            APIManager.sharedManager.postData(url: APIManager.sharedManager.INVITE_TEAM_MEMBER, parameters: dicTeamInvite) { (response: ApiResponse?, error) in
                self.hideLoading()
                if response?.status == 1 {
                    DispatchQueue.main.async {
                        Utilities.showPopup(title: response?.message ?? "", type: .success)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension InviteMembersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvAddFriends {
            return addFriendData.count
        } else if tableView == tvAddPlayers {
            return addPlayerData.count
        } else {
            return addFriendByEmailData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvAddFriends {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addFriendData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addFriendData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddFriends
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddFriends {
                    self.addFriendData.remove(at: index)
                    //self.inviteMember()     //  Comment by Pranay
                    // By Pranay
                    self.tvAddFriends.reloadData()
                    //.
                }
//                else {
//                    self.addPlayerData.remove(at: index)
//                    self.tvAddPlayers.reloadData()
//                }
            }
            return cell
        } else if tableView == tvAddPlayers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addPlayerData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addPlayerData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddPlayers
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddPlayers {
                    self.addPlayerData.remove(at: index)
                    //self.inviteMember()     //  Comment by Pranay
                    // By Pranay
                    self.tvAddPlayers.reloadData()
                    //.
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
                    self.isValid = true
                    self.inviteMember()
                }else {
                    self.isValid = false
                    self.tvAddFriendByEmail.reloadData()
                }
            }
            
            cell.onTapRemoveFriend = { index in
                self.view.endEditing(true)
                self.addFriendByEmailData.remove(at: index)
                //self.inviteMember()   //  Comment by Pranay
                // By Pranay
                self.tvAddFriendByEmail.reloadData()
                //.
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
