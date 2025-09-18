//
//  AdminToolsVC.swift
//  - User will be navigated to following screens to update necessary information like Edit Team, Make an Admin, Make a Captain etc.

//  Tussly
//
//  Created by Auxano on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AdminToolsVC: UIViewController {
    
    // MARK: - Controls
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var btnJoin: UIButton!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet var switchHeight: NSLayoutConstraint!
    
    // MARK: - Variables
    var adminToolData = [String]()
    var players = [Player]()
    var teamTabVC: (()->TeamTabVC)?
    var team : Team?
    var isJoin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if teamTabVC!().userRole?.role == "FOUNDER" { //For Founder
            adminToolData = ["Edit Team Page","Make an Admin","Make a Captain","Remove Member","Remove Admin","Remove Captain","Remove Video","Relinquish Ownership","Close Team"]
        } else if teamTabVC!().userRole?.role == "ADMIN" { //For Admin
            adminToolData = ["Edit Team Page","Make an Admin","Make a Captain","Remove Member","Remove Captain","Remove Video"]
        } else { //For Captain
            adminToolData = ["Remove Video","Remove Member"]
        }
            
        for i in btnOptions {
            i.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        }
        setUI()
        getPlayers()
    }
    
    // MARK: - UI Methods
    func setUI() {
        self.isJoin = teamTabVC!().teamDetails?.isRestrictToJoinRequest == 0 ? false : true
        self.btnJoin.isSelected = teamTabVC!().teamDetails?.isRestrictToJoinRequest == 0 ? false : true
        if teamTabVC!().userRole?.role == "FOUNDER" { //For Founder
            btnOptions[9].isHidden = true
            switchHeight.constant = 0
            viewHeader.isHidden = true
        } else if teamTabVC!().userRole?.role == "ADMIN" { //For Admin
            btnOptions[2].setTitle("Make a Captain", for: .normal)
            btnOptions[3].setTitle("Remove Captain", for: .normal)
            for i in 5..<btnOptions.count {
                btnOptions[i].isHidden = true
            }
        } else { //For Captain
            btnOptions[0].setTitle("Remove Video", for: .normal)
            btnOptions[1].setTitle("Remove Member", for: .normal)
            for i in 2..<btnOptions.count {
                btnOptions[i].isHidden = true
            }
        }
        
        // By Pranay
        ////Hide - Admin can restrict joining requests
        switchHeight.constant = 0
        viewHeader.isHidden = true
        //.
        
        // By Pranay Comment loop
        ////Beta 1 - Disable option
        for i in 0..<btnOptions.count {
            if (btnOptions[i].titleLabel?.text == "Edit Team Page") || (btnOptions[i].titleLabel?.text == "Make an Admin")  || (btnOptions[i].titleLabel?.text == "Remove Member")  || (btnOptions[i].titleLabel?.text == "Remove Admin") {
                btnOptions[i].setTitleColor(Colors.black.returnColor() , for: .normal)
            } else {
                btnOptions[i].setTitleColor(Colors.border.returnColor() , for: .normal)
            }
        }   //  */
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        teamTabVC!().selectedIndex = -1
        teamTabVC!().cvTeamTabs.selectedIndex = -1
        teamTabVC!().cvTeamTabs.reloadData()
    }
    
    @IBAction func onTapSwitch(_ sender: UIButton) {
        ////Beta 1 - Disable option
//        let isJoinReq = isJoin ? 1 : 0
//        updateRequest(isJoin: isJoinReq)
    }
        
    @IBAction func onTapAction(_ sender: UIButton) {
        if(btnOptions[sender.tag].currentTitle == "Edit Team Page"){
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "EditTeamVC") as! EditTeamVC
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            objVC.teamData = self.teamTabVC!().teamDetails
            objVC.userRole = self.teamTabVC!().userRole
            self.view.tusslyTabVC.viewControllers[self.view.tusslyTabVC.selectedIndex].pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Make an Admin" { //Make Admin
            ////Beta 1 - Disable option         //  By Pranay uncomment code
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeAdminVC") as! MakeAdminVC
            objVC.makeAdmin = true
            objVC.userRole = self.teamTabVC!().userRole
            objVC.teamData = self.teamTabVC!().teamDetails
            self.navigationController?.pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Make a Captain" { //Make Captain
            ////Beta 1 - Disable option
//            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeAdminVC") as! MakeAdminVC
//            objVC.makeCaptain = true
//            objVC.userRole = self.teamTabVC!().userRole
//            objVC.teamData = self.teamTabVC!().teamDetails
//            self.navigationController?.pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Remove Member" { //Remove Member
            ////Beta 1 - Disable option         //  By Pranay uncomment code
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MakeAdminVC") as! MakeAdminVC
            objVC.deleteMember = true
            objVC.userRole = self.teamTabVC!().userRole
            objVC.teamData = self.teamTabVC!().teamDetails
            self.navigationController?.pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Remove Admin" { //Remove Admin
            ////Beta 1 - Disable option             //  By Pranay uncomment code
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "RemoveAdminVC") as! RemoveAdminVC
            objVC.removeAdmin = true
            objVC.userRole = self.teamTabVC!().userRole
            objVC.teamData = self.teamTabVC!().teamDetails
            objVC.titleString = "Select Admins"
            self.navigationController?.pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Remove Captain" { //Remove Captain
            ////Beta 1 - Disable option
//            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "RemoveAdminVC") as! RemoveAdminVC
//            objVC.removeAdmin = false
//            objVC.userRole = self.teamTabVC!().userRole
//            objVC.teamData = self.teamTabVC!().teamDetails
//            objVC.titleString = "Select Captains"
//            self.navigationController?.pushViewController(objVC, animated: true)
        } else if btnOptions[sender.tag].currentTitle == "Remove Video" { //Delete Video
            ////Beta 1 - Disable option
//            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "DeleteVideoVC") as! DeleteVideoVC
//            objVC.teamData = self.teamTabVC!().teamDetails
//            self.navigationController?.pushViewController(objVC, animated: true)
        }  else if btnOptions[sender.tag].currentTitle == "Relinquish Ownership" {
            ////Beta 1 - Disable option
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//            dialog.modalPresentationStyle = .overCurrentContext
//            dialog.modalTransitionStyle = .crossDissolve
//            dialog.titleText = Messages.relinquishOwnership
//            dialog.message = Messages.relinquishOwnershipMessage
//            dialog.tapOK = {
//                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
//                objVC.didSelectItem = { selectedFriend in
//                    let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//                    dialog.modalPresentationStyle = .overCurrentContext
//                    dialog.modalTransitionStyle = .crossDissolve
//                    dialog.titleText = Messages.confirmNewFounder
//                    dialog.message = "Do you want to make '\(selectedFriend[0].displayName ?? "")' the new founder of this team? By doing this you will become just a player and have the ability to leave the team."
//                    dialog.highlightString = selectedFriend[0].displayName ?? ""
//                    dialog.tapOK = {
//                        self.changeRole(playerId: selectedFriend[0].id!)
//                    }
//                    dialog.btnYesText = Messages.confirm
//                    dialog.btnNoText = Messages.cancel
//                    self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//                }
//                objVC.titleString = Messages.newFounderSelection
//                objVC.buttontitle = Messages.makeNewFounder
//                objVC.placeHolderString = Messages.searchForPlayers
//                objVC.arrFriendsList = self.players
//                objVC.isFromFounder = true
//                objVC.modalPresentationStyle = .overCurrentContext
//                objVC.modalTransitionStyle = .crossDissolve
//                self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
//            }
//            dialog.btnYesText = Messages.assignNewFounder
//            dialog.btnNoText = Messages.cancel
//            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        } else if btnOptions[sender.tag].currentTitle == "Close Team" {
            ////Beta 1 - Disable option
//            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//            dialog.modalPresentationStyle = .overCurrentContext
//            dialog.modalTransitionStyle = .crossDissolve
//            dialog.titleText = Messages.closeTeam
//            dialog.message = Messages.sureWantToClose
//            dialog.tapOK = {
//                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
//                dialog.modalPresentationStyle = .overCurrentContext
//                dialog.modalTransitionStyle = .crossDissolve
//                dialog.titleText = Messages.alert
//                dialog.message = Messages.closeTeamMessage
//                dialog.highlightString = Messages.noFurtherLeagueAllow
//                dialog.tapOK = {
//                    self.closeTeam()
//                }
//                dialog.btnYesText = Messages.confirm
//                dialog.btnNoText = Messages.cancel
//                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//            }
//            dialog.btnYesText = Messages.closeTeam
//            dialog.btnNoText = Messages.cancel
//            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Webservices
    func getPlayers() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayers()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_MEMBER, parameters: ["teamId":teamTabVC!().teamDetails?.id as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.players = (response?.result?.teamMembers)!
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func updateRequest(isJoin : Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayers()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_MEMBER, parameters: ["teamId":teamTabVC!().teamDetails?.id as Any, "isRestrictToJoinRequest" : isJoin]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.isJoin = !self.isJoin
                    self.btnJoin.isSelected = self.team?.isRestrictToJoinRequest == 0 ? false : true
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func changeRole(playerId : Int) { // For Make Founder
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changeRole(playerId: playerId)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_TEAM_ROLE, parameters: ["teamId":teamTabVC!().teamDetails?.id as Any,"playerId":playerId,"roleId":4]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.teamTabVC!().selectedIndex = -1
                    self.teamTabVC!().cvTeamTabs.selectedIndex = -1
                    self.teamTabVC!().reloadTab()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func closeTeam() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.closeTeam()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CLOSE_TEAM, parameters: ["teamId":teamTabVC!().teamDetails?.id as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.view.tusslyTabVC.selectedIndex = 0
                    self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
