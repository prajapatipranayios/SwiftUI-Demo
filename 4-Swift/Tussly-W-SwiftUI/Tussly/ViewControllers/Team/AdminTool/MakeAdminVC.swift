//
//  MakeAdminVC.swift
//  - User can able to make Admin from this screen.

//  Tussly
//
//  Created by Auxano on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MakeAdminVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var tvAdmin : UITableView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var btnMakeAdmin: UIButton!
    
    // MARK: - Variables
    var arrPlayer = [Player]()
    var tempArray: [Player]?
    var arrSelected = [Player]()
    
    var makeAdmin = false
    var makeCaptain = false
    var deleteMember = false
    
    var teamData: Team?
    var userRole: UserRole?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvAdmin.delegate = self
        self.tvAdmin.dataSource = self
        self.tvAdmin.reloadData()
        txtSearch.isEnabled = false
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
        tvAdmin.rowHeight = UITableView.automaticDimension
        tvAdmin.estimatedRowHeight = 100.0
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        DispatchQueue.main.async {
            self.btnMakeAdmin.layer.cornerRadius = self.btnMakeAdmin.frame.size.height/2
            self.btnMakeAdmin.setTitle(self.makeAdmin ? Messages.makeAdmin : self.makeCaptain ? Messages.makeCaptain : Messages.remove, for: .normal)
        }
        self.tvAdmin.delegate = self
        self.tvAdmin.dataSource = self
    }
    
    func searchContent(string: String) {
        if string != "" {
            tempArray = arrPlayer.filter({ (data) -> Bool in
                return "\(data.displayName!)".lowercased().contains(string.lowercased())
            })
            tvAdmin.reloadData()
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapMakeAdmin(_ sender: UIButton) {
        if arrSelected.count > 0 {
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = self.makeAdmin ? Messages.adminSelection : self.makeCaptain ? Messages.captainSelection : Messages.removeMembers
            dialog.message = self.makeAdmin ? "Do you want to make '\(arrSelected[0].displayName ?? "")' an Admin of this team?" : self.makeCaptain ? "Do you want to make '\(arrSelected[0].displayName ?? "")', a Captain of this team?" : "Do you want to remove '\(arrSelected[0].displayName ?? "")' from this team?"
            dialog.highlightString = arrSelected[0].displayName ?? ""
            dialog.tapOK = {
                if self.deleteMember {
                    self.deleteMember(playerId: self.arrSelected[0].id!,roleId: self.arrSelected[0].role!)
                } else {
                    self.changeRole(playerId: self.arrSelected[0].id!)
                }
            }
            dialog.btnYesText = self.makeAdmin ? Messages.makeAdmin : self.makeCaptain ? Messages.makeCaptain : Messages.remove
            dialog.btnNoText = Messages.cancel
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        txtSearch.text = ""
        tempArray = arrPlayer
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
        
        //showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TEAM_MEMBER, parameters: ["teamId":teamData?.id as Any]) { (response: ApiResponse?, error) in
            //self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrPlayer.removeAll()
                    self.tempArray?.removeAll()
//                    if self.deleteMember {
//                        self.arrPlayer = (response?.result?.teamMembers)!
//                        let foundItems = self.arrPlayer.filter { $0.role == 1 }
//                        self.arrPlayer = foundItems
//                        self.tempArray = self.arrPlayer
//                    } else {
//                        self.arrPlayer = (response?.result?.teamMembers)!
//                        self.tempArray = self.arrPlayer
//                    }
                    self.arrPlayer = (response?.result?.teamMembers)!
                    if self.arrPlayer.count > 0 {
                        self.txtSearch.isEnabled = true
                    }
                    self.tempArray = self.arrPlayer
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
    
    func changeRole(playerId : Int) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changeRole(playerId: playerId)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_TEAM_ROLE, parameters: ["teamId":teamData?.id as Any,"playerId":playerId,"roleId":self.makeAdmin ? 3 : 2]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrSelected.removeAll()
                    let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == playerId})
                    if mainIndex != nil {
                        self.arrPlayer[mainIndex!].role = self.makeAdmin ? 3 : 2
                    }
                    let mainIndex1 = self.tempArray!.firstIndex(where: {$0.id == playerId})
                    if mainIndex1 != nil {
                        self.tempArray![mainIndex1!].role = self.makeAdmin ? 3 : 2
                    }
                    self.btnMakeAdmin.isEnabled = false
                    self.btnMakeAdmin.backgroundColor = Colors.themeDisable.returnColor()
                    self.tvAdmin.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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
                    self.arrSelected.removeAll()
                    let member = (response?.result?.teamMember)!
                    if member.id == nil {
                        let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == playerId})
                        if mainIndex != nil {
                            self.arrPlayer.remove(at: mainIndex!)
                            self.txtSearch.text = ""
                            self.tempArray = self.arrPlayer
                        }
                    } else {
                        let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == playerId})
                        if mainIndex != nil {
                            self.arrPlayer[mainIndex!] = member
                        }
                        let mainIndex1 = self.tempArray!.firstIndex(where: {$0.id == playerId})
                        if mainIndex1 != nil {
                            self.tempArray![mainIndex1!] = member
                        }
                    }
                    self.tvAdmin.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MakeAdminVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArray?.count ?? SKELETON_ROWHEADER_COUNT
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MakeAdminCell", for: indexPath) as! MakeAdminCell
        if tempArray != nil {
//            cell.hideAnimation()
            cell.lblName.text = tempArray?[indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: tempArray?[indexPath.row].avatarImage ?? "")
            cell.lblRole.text = Utilities.getRoleName(roleId: tempArray?[indexPath.row].role ?? 0)
            cell.viewDisable.isHidden = true
            if deleteMember == false {
                if (tempArray?[indexPath.row].role ?? 0 >= (self.makeAdmin ? 3 : 2)) {
                    cell.viewDisable.isHidden = false
                    cell.btnSelect.isHidden = true
                } else {
                    cell.viewDisable.isHidden = true
                    cell.btnSelect.isHidden = false
                }
            } else {
                if (tempArray?[indexPath.row].role ?? 0 > 1) {
                    cell.viewDisable.isHidden = false
                    cell.btnSelect.isHidden = true
                } else {
                    cell.viewDisable.isHidden = true
                    cell.btnSelect.isHidden = false
                }
            }
            cell.index = indexPath.row
            cell.onTapAdminCell = { index in
                self.arrSelected.removeAll()
                self.arrSelected.append((self.tempArray?[index])!)
                self.tvAdmin.reloadData()
                self.btnMakeAdmin.isEnabled = true
                self.btnMakeAdmin.backgroundColor = Colors.theme.returnColor()
            }
            cell.btnSelect.isSelected = false
            if arrSelected.count > 0 {
                let mainIndex = arrSelected.firstIndex(where: {$0.id == tempArray?[indexPath.row].id})
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
}

// MARK: - UITextFieldDelegate

extension MakeAdminVC : UITextFieldDelegate {
    
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
            tempArray = arrPlayer
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
