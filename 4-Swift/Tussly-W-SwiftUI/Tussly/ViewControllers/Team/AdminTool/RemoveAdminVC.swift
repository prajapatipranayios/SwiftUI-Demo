//
//  RemoveAdmin.swift
//  - User can able to remove Admin from this screen.

//  Tussly
//
//  Created by Auxano on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class RemoveAdminVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    // MARK: - Controls
    
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var tvAdmin : UITableView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var btnMakeAdmin: UIButton!
    @IBOutlet weak var lblTitle : UILabel!

    // MARK: - Variables

    var players = [Player]()
    var tempArray: [Player]?
    var selectedPlayers = [Player]()
    
    var removeAdmin = false
    var titleString = ""
    
    var teamData: Team?
    var userRole: UserRole?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvAdmin.delegate = self
        self.tvAdmin.dataSource = self
        self.tvAdmin.reloadData()
        setupUI()
        getPlayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        btnMakeAdmin.isEnabled = false
        btnMakeAdmin.backgroundColor = Colors.themeDisable.returnColor()
        txtSearch.placeholder = removeAdmin ? Messages.searchAdmin : Messages.searchCaptain
        tvAdmin.rowHeight = UITableView.automaticDimension
        tvAdmin.estimatedRowHeight = 100.0
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        lblTitle.text = titleString
        txtSearch.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.btnMakeAdmin.layer.cornerRadius = self.btnMakeAdmin.frame.size.height/2
        }
    }
    
    func searchContent(string: String) {
        if string != "" {
            tempArray = players.filter({ (data) -> Bool in
                return ("\(data.displayName ?? "")").lowercased().contains(string.lowercased())
            })
            tvAdmin.reloadData()
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapMakeAdmin(_ sender: UIButton) {
        if selectedPlayers.count > 0 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = self.removeAdmin ? Messages.removeAdmin : Messages.removeCaptain
            /// By Pranay - change remove admin message
            dialog.message = self.removeAdmin ? "Do you want to remove '\(selectedPlayers[0].displayName ?? "")' as an admin for this team?" : "Do you want to remove '\(selectedPlayers[0].displayName ?? "")' from the position of a captain of this team?"
            dialog.highlightString = selectedPlayers[0].displayName ?? ""
            dialog.tapOK = {
                self.deleteMember(playerId: self.selectedPlayers[0].id!, roleId: self.selectedPlayers[0].role!)
            }
            dialog.btnYesText = Messages.remove
            dialog.btnNoText = Messages.cancel
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        txtSearch.text = ""
        tempArray = players
        tvAdmin.reloadData()
    }
    
    // MARK: - Webservices
    
    func getPlayer() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayer()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_MEMBER, parameters: ["teamId":teamData?.id as Any]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.players = (response?.result?.teamMembers)!
                    let foundItems = self.players.filter { $0.role == (self.removeAdmin ? 3 : 2) }
                    self.players = foundItems
                    self.tempArray = self.players
                    
                    if self.players.count > 0 {
                        self.txtSearch.isUserInteractionEnabled = true
                    }
                    self.tvAdmin.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.tempArray = [Player]()
                    self.tvAdmin.reloadData()
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func deleteMember(playerId : Int,roleId : Int) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.deleteMember(playerId: playerId, roleId: roleId)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_MEMBER, parameters: ["teamId":teamData?.id as Any,"playerId":playerId,"roleId":roleId]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.selectedPlayers.removeAll()
                    let member = (response?.result?.teamMember)!
                    if member.id == nil {
                        let mainIndex = self.players.firstIndex(where: {$0.id == playerId})
                        if mainIndex != nil {
                            self.players.remove(at: mainIndex!)
                            self.txtSearch.text = ""
                            self.tempArray = self.players
                        }
                    } else {
                        let mainIndex = self.players.firstIndex(where: {$0.id == playerId})
                        if mainIndex != nil {
                            self.players[mainIndex!] = member
                        }
                        let mainIndex1 = self.tempArray!.firstIndex(where: {$0.id == playerId})
                        if mainIndex1 != nil {
                            self.tempArray![mainIndex1!] = member
                        }
                    }
                    self.btnMakeAdmin.isEnabled = false
                    self.btnMakeAdmin.backgroundColor = Colors.themeDisable.returnColor()
                    self.showLoading()
                    self.getPlayer()
                    //self.tvAdmin.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RemoveAdminVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray?.count ?? 1    //0     default 10 to 0 - By Pranay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MakeAdminCell", for: indexPath) as! MakeAdminCell
        
        if tempArray != nil {
//            cell.hideAnimation()
            cell.lblName.text = tempArray![indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: tempArray![indexPath.row].avatarImage!)
            cell.lblRole.text = Utilities.getRoleName(roleId: tempArray![indexPath.row].role ?? 0)
            cell.viewDisable.isHidden = true
            cell.index = indexPath.row
            cell.onTapAdminCell = { index in
                self.selectedPlayers.removeAll()
                self.selectedPlayers.append(self.tempArray![index])
                self.tvAdmin.reloadData()
                self.btnMakeAdmin.isEnabled = true
                self.btnMakeAdmin.backgroundColor = Colors.theme.returnColor()
            }
            cell.btnSelect.isSelected = false
            if selectedPlayers.count > 0 {
                let mainIndex = selectedPlayers.firstIndex(where: {$0.id == tempArray![indexPath.row].id})
                if mainIndex != nil {
                    cell.btnSelect.isSelected = true
                }
            }
        } else {
//            cell.showAnimation()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - UITextFieldDelegate
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
            tempArray = players
            tvAdmin.reloadData()
        }
        if newString.length > 2 {
            searchContent(string: newString as String)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
}

