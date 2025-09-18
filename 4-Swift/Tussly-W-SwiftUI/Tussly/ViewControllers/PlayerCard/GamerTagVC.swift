//
//  GamerTagVC.swift
//  Tussly
//
//  Created by Auxano on 09/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class GamerTagVC: UIViewController {
    
    // MARK: - Variables.
    var playerTabVC: (()->PlayerCardTabVC)?
    var arrGetGamerTags = [GamerTag]()
    var gamerData = [Objects]()
    var isValid = true
    var selectedIndex = -1
    var selectedID = 0
    var sectionImage = ""
    
    // MARK: - Controls
    @IBOutlet weak var tvGamerTags : UITableView!
    @IBOutlet weak var btnSelectGametag : UIButton!
    @IBOutlet weak var btnSaveGameId : UIButton!
    @IBOutlet weak var viewGametag : UIView!
    @IBOutlet weak var tvGamerTagHeight : NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerNib = UINib.init(nibName: "CustomHeader", bundle: Bundle.main)
        tvGamerTags.register(headerNib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        tvGamerTags.register(UINib(nibName: "GamerTagCell", bundle: nil), forCellReuseIdentifier: "GamerTagCell")
        tvGamerTags.delegate = self
        tvGamerTags.dataSource = self
        
        tvGamerTags.rowHeight = UITableView.automaticDimension
        tvGamerTags.estimatedRowHeight = 250.0
        
        btnSaveGameId.layer.cornerRadius = 15.0
        viewGametag.layer.cornerRadius = 5.0
        viewGametag.layer.borderWidth = 1.0
        viewGametag.layer.borderColor = Colors.border.returnColor().cgColor
        
        btnSaveGameId.isHidden = true
        self.tvGamerTagHeight.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGamerTags()
        tvGamerTags.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvGamerTags.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.tvGamerTags!.observationInfo != nil {
            tvGamerTags.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    // MARK: - UI Methods
    
    func setUI() {
        gamerData.removeAll()
        for i in 0 ..< arrGetGamerTags.count {
            if (arrGetGamerTags[i].userGamerTags?.count ?? 0) > 0 {
                arrGetGamerTags = arrGetGamerTags.map{
                    var mutGamerTag = $0
                    if $0.consoleName == (arrGetGamerTags[i].consoleName)! {
                        mutGamerTag.isSelected = true
                    }
                    return mutGamerTag
                }
                
                var data = [[String:String]]()
                for j in 0 ..< (arrGetGamerTags[i].userGamerTags?.count ?? 0) {
                    let status = arrGetGamerTags[i].userGamerTags?[j].isPublic == 1 ? "Public" : "Private"
                    data.append(["value":arrGetGamerTags[i].userGamerTags?[j].gameTags ?? "" ,"status":status])
                }
                gamerData.append(Objects(id: arrGetGamerTags[i].id,
                                         sectionName: arrGetGamerTags[i].consoleName,
                                         sectionImage: arrGetGamerTags[i].consoleIcon,
                                         sectionObjects: data))
            }
        }
        DispatchQueue.main.async {
            if self.gamerData.count > 0{
                self.btnSaveGameId.isHidden = false
            }
        }
        tvGamerTags.reloadData()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            self.tvGamerTagHeight.constant = tvGamerTags.contentSize.height
            self.updateViewConstraints()
        }
    }
    
    func checkEmptyField(section: Int) -> Bool {
        var value = true
        for i in 0..<gamerData[section].sectionObjects.count {
            if gamerData[section].sectionObjects[i]["value"] == "" {
                value = false
                break
            }
        }
        return value
    }
    
    func checkEmptyGamerTags() {
        for i in 0..<gamerData.count {
            let sectionData = gamerData[i].sectionObjects
            for i in 0..<sectionData.count {
                if sectionData[i]["value"] == "" {
                    isValid = false
                    break
                }
            }
            if !isValid {
                break
            }
        }
    }

    // MARK: - IB Actions
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
    }
    
    @IBAction func onTapSelectGametag(_ sender: UIButton) {
        self.view.endEditing(true)
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.gamerTag = arrGetGamerTags
        objVC.titleTxt = "Select Gaming ID"
        objVC.didSelectItem = { index,isImgPicker in
            if isImgPicker == false {
                self.selectedIndex = index
                self.selectedID = self.arrGetGamerTags[index].id
                self.sectionImage = self.arrGetGamerTags[index].consoleIcon!
                self.btnSelectGametag.setTitle("\(self.arrGetGamerTags[index].consoleName ?? "")", for: .normal)
            } else {}
        }
        objVC.selectedIndex = selectedIndex
        objVC.isImgPicker = false
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddGamerTag(_ sender: UIButton) {
        if selectedIndex != -1 {
            if !gamerData.contains(where: { $0.sectionName == btnSelectGametag.titleLabel?.text}) {
                gamerData.append(Objects(id: selectedID, sectionName: btnSelectGametag.titleLabel?.text,sectionImage: sectionImage, sectionObjects: [["value":"","status":"Public"]]))
                if isValid {
                    self.tvGamerTags.reloadData()
                } else {
                    self.tvGamerTags.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                        self.isValid = true
                        self.tvGamerTags.reloadSections([self.gamerData.count-1], with: .automatic) // Milan
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                            self.isValid = false
                        }
                    }
                }
                
                //self.tvGamerTag.reloadData()
                
                //Jaimesh
                arrGetGamerTags = arrGetGamerTags.map{
                    var mutGamerTag = $0
                    print((btnSelectGametag.titleLabel?.text)!)
                    if $0.consoleName == (btnSelectGametag.titleLabel?.text)! {
                        mutGamerTag.isSelected = true
                    }
                    return mutGamerTag
                }
                //
                
                //DRASHTI
                if gamerData.count > 0 {
                    btnSaveGameId.isHidden = false
                }
                btnSelectGametag.setTitle("Select Gaming ID", for: .normal)
                selectedIndex = -1
            }
        }
//        if selectedIndex != -1 {
//            if !gamerData.contains(where: { $0.sectionName == btnSelectGametag.titleLabel?.text}) {
//                gamerData.append(Objects(id: selectedID, sectionName: btnSelectGametag.titleLabel?.text, sectionObjects: [["value":"","status":"Public"]]))
//                self.tvGamerTags.reloadData()
//            }
//
//        }
    }
    
    @IBAction func onTapSavePlayerCard( _ sender : UIButton) {
        for i in 0 ..< gamerData.count {
            for j in 0 ..< gamerData[i].sectionObjects.count {
                let indexPath = IndexPath(row: j, section: i)
                let cell = tvGamerTags.cellForRow(at: indexPath) as! GamerTagCell
                cell.txtPlaystation.endEditing(true)
            }
        }
        
        saveGamingID()
    }
    
    // MARK: - Webservices
    func getGamerTags() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGamerTags()
                }
                return
                     }
           }
        
        showLoading()
        /// 232 - By Pranay
        //let params = ["otherUserId": intIdFromSearch]    //   By Pranay - added param
        let params = ["otherUserId": 0]
        /// 232 .
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_GAME_TAGS, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrGetGamerTags = (response?.result?.gameTags)!
                    self.setUI()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func saveGamingID() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.saveGamingID()
                }
                return
                     }
           }
        
        var tag = [[String:Any]]()
        for i in 0 ..< gamerData.count {
            for j in 0 ..< gamerData[i].sectionObjects.count {
                let data = ["gameConsoleId" : gamerData[i].id,
                          "gameTags": gamerData[i].sectionObjects[j]["value"] ?? "",
                          "isPublic" : gamerData[i].sectionObjects[j]["status"] == "Public" ? 1 : 0] as [String : Any]
                tag.append(data as [String : Any])
            }
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.UPDATE_GAMER_TAG, parameters:
        ["gamerTags": tag]
        ) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.getGamerTags()
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - TableView Methods
extension GamerTagVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return gamerData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamerData.count == 0 ? 0 : gamerData[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamerTagCell", for: indexPath) as! GamerTagCell
        cell.index = indexPath.row
        cell.section = indexPath.section
        cell.btnStatus.isSelected = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"] == "Public" ? false : true
        cell.txtPlaystation.placeholder = "Enter \(gamerData[indexPath.section].sectionName.replacingOccurrences(of: "Account", with: "")) Name"
        cell.txtPlaystation.text = gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"]
        cell.lblSwitchStatus.text = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"]
        
        if isValid {
            cell.lblError.text = ""
        } else {
            if gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"] == "" {
                cell.lblError.setLeftArrow(title: "Please enter \(gamerData[indexPath.section].sectionName ?? "") Name")
            } else {
                cell.lblError.text = ""
            }
        }
        
        cell.getPlaystationName = { playStationName,index,section in
            self.gamerData[section].sectionObjects[index]["value"] = playStationName
                        for i in 0..<self.gamerData.count {
                            let sectionData = self.gamerData[i].sectionObjects
                            for i in 0..<sectionData.count {
                                if sectionData[i]["value"] == "" {
                                    self.isValid = false
                                    break
                                } else {
                                    self.isValid = true
                                }
                            }
                            if !self.isValid {
                                self.tvGamerTags.reloadSections([section], with: .automatic)
            //                    self.tvGamerTag.reloadData() - Jaimesh
                                return
                            }
                        }
            //            self.tvGamerTag.reloadData() - Jaimesh
                        self.tvGamerTags.reloadSections([section], with: .automatic)
//                self.gamerData[section].sectionObjects[index]["value"] = playStationName
//                self.checkEmptyGamerTags()
//                if !self.isValid {
//                    self.tvGamerTags.reloadData()
//                    return
//                }
//                self.tvGamerTags.reloadData()
        }
        
        cell.onTapRemovePlaystation = { index, section in
            self.view.endEditing(true)
            self.gamerData[section].sectionObjects.remove(at: index)
            if self.gamerData[section].sectionObjects.count == 0 {
                //Jaimesh
                self.arrGetGamerTags = self.arrGetGamerTags.map{
                    var mutGamerTag = $0
                    if $0.consoleName == self.gamerData[section].sectionName {
                        mutGamerTag.isSelected = false
                    }
                    return mutGamerTag
                }
                //
                self.gamerData.remove(at: section)
            }
            if self.gamerData.count > 0{
                self.btnSaveGameId.isHidden = false
            } else {
                self.btnSaveGameId.isHidden = true
            }
            self.tvGamerTags.reloadData()
//                self.view.endEditing(true)
//                self.gamerData[section].sectionObjects.remove(at: index)
//                if self.gamerData[section].sectionObjects.count == 0 {
//                    self.gamerData.remove(at: section)
//                }
//                self.tvGamerTags.reloadData()
        }
        
        cell.onTapSwitch = { status,index,section in
            self.gamerData[section].sectionObjects[index]["status"] = status
            self.tvGamerTags.reloadSections([section], with: .automatic)
            //self.tvGamerTags.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tvGamerTags {
            if gamerData.count != 0 {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
                headerView.customLabel.text = "\(gamerData[section].sectionName ?? "") Account"
                //headerView.customImage.image = UIImage.init(named: gamerData[section].sectionName + ".png")
                headerView.customImage.setImage(imageUrl: gamerData[section].sectionImage)
                headerView.sectionNumber = section
                headerView.onTapAddAccount = { section in
                    if self.self.checkEmptyField(section: section) {
                        self.isValid = true
                        //self.gamerData[section].sectionObjects.append(["value":"","status":"Public"])
                        self.gamerData[section].sectionObjects.insert(["value":"","status":"Public"], at: 0)
                    } else {
                        self.isValid = false
                    }
                    self.tvGamerTags.reloadSections([section], with: .automatic)
                    //self.tvGamerTags.reloadData()
                }
                return headerView
            }
            return nil
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tvGamerTags {
            if gamerData.count != 0 {
                return 66
            }
            return 0
        }
        return 0
    }
}
