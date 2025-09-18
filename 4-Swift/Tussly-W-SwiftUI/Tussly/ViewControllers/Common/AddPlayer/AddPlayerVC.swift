//
//  AddPlayerVC.swift
//  Tussly
//
//  Created by Auxano on 26/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddPlayerVC: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Controls
    @IBOutlet weak var tvPlayer : UITableView!
    @IBOutlet weak var tvSelectedPlayer : UITableView!
    @IBOutlet weak var heightTvselectedPlayer : NSLayoutConstraint!
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSub : UIView!
    @IBOutlet weak var btnAdd : UIButton!
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var viewBottom : UIView!
    @IBOutlet weak var btnSearchAssesory : UIButton!
    @IBOutlet weak var viewSelectedContainer : UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Variables
    var titleButton = ""
    var didSelectItem: (([Player])->Void)?
    var didSelectOtherPlayer: (([PlayerData])->Void)?
    var timer = Timer()
    var newSearchString = ""
    var arrPlayer = [PlayerData]()
    var arrSelected = [Player]()
    var arrOtherSelected = [PlayerData]()
    var arrTemp = [PlayerData]()
    var isFromTeam = false
    var teamId = -1
    var titleString = ""
    var hasMore = -1
    var pageNumber = 1
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleString
        DispatchQueue.main.async {
            self.btnAdd.layer.cornerRadius = 15
        }
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewMain)
        
        viewSub.layer.cornerRadius = 15.0
        viewSelectedContainer.layer.cornerRadius = 10.0
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        
        btnAdd.setTitle(titleButton, for: .normal)
        viewBottom.addShadow(offset: CGSize(width: 0, height: -5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
        tvPlayer.rowHeight = UITableView.automaticDimension
        tvPlayer.estimatedRowHeight = 100.0
        tvPlayer.reloadData()
        submitButtonUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvSelectedPlayer.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewMain.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvSelectedPlayer.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                if isFromTeam {
                    if arrOtherSelected.count > 3 {
                        self.heightTvselectedPlayer.constant = 214
                    } else {
                        self.heightTvselectedPlayer.constant = newsize.height == 0 ? 0 : newsize.height + 54
                    }
                } else {
                    if arrSelected.count > 3 {
                        self.heightTvselectedPlayer.constant = 214
                    } else {
                        self.heightTvselectedPlayer.constant = newsize.height == 0 ? 0 : newsize.height + 54
                    }
                }
                self.updateViewConstraints()
            }
        }
    }
    
    // MARK: - UI Methods
    
    @objc func update () {
        if txtSearch.text != ""{
            if txtSearch.text!.count > 0 {
                if newSearchString != txtSearch.text {
                    searchPlayer(searchText: txtSearch.text!)
                }
            }
        } else {
            newSearchString = ""
            arrPlayer.removeAll()
            arrTemp.removeAll()
            tvPlayer.reloadData()
        }
    }
    
    func submitButtonUI() {
        if isFromTeam {
            if arrOtherSelected.count > 0 {
                btnAdd.isEnabled = true
                btnAdd.backgroundColor = Colors.theme.returnColor()
            } else {
                btnAdd.isEnabled = false
                btnAdd.backgroundColor = Colors.themeDisable.returnColor()
            }
        } else {
            if arrSelected.count > 0 {
                btnAdd.isEnabled = true
                btnAdd.backgroundColor = Colors.theme.returnColor()
            } else {
                btnAdd.isEnabled = false
                btnAdd.backgroundColor = Colors.themeDisable.returnColor()
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapAdd(_ sender: UIButton) {
        if isFromTeam {
            if self.didSelectOtherPlayer != nil {
                self.didSelectOtherPlayer!(arrOtherSelected)
            }
        } else {
            if self.didSelectItem != nil {
                self.didSelectItem!(arrSelected)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapClear(_ sender: UIButton) {
        sender.isSelected = false
        newSearchString = ""
        txtSearch.text = ""
        arrPlayer.removeAll()
        arrTemp.removeAll()
        tvPlayer.reloadData()
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
        var param = [String : Any]()
        if isFromTeam {
            param = ["searchText":searchText,"inviteType" : "PLAYER","teamId":teamId, "page": pageNumber]
        } else {
            param = ["searchText":searchText,"inviteType" : "FRIEND", "page": pageNumber]
        }
        if searchText != "" {
            
            APIManager.sharedManager.postData(url: APIManager.sharedManager.SEARCH_PLAYER, parameters: param) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    let res = (response?.result?.players)!
                    self.arrPlayer = res.data!
                    self.arrTemp = res.data!
                    if self.isFromTeam {
                        for i in 0 ..< self.arrOtherSelected.count {
                            let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.arrOtherSelected[i].id})
                            if mainIndex != nil {
                                self.arrPlayer.remove(at: mainIndex!)
                            }
                        }
                    } else {
                        for i in 0 ..< self.arrSelected.count {
                            let mainIndex = self.arrPlayer.firstIndex(where: {$0.id == self.arrSelected[i].id})
                            if mainIndex != nil {
                                self.arrPlayer.remove(at: mainIndex!)
                            }
                        }
                    }
                    
                    if (self.arrPlayer.count) > 0 {
                        self.pageNumber += 1
                        self.hasMore = 1
                    } else {
                        self.hasMore = -1
                    }
                    DispatchQueue.main.async {
                        self.tvPlayer.reloadData()
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension AddPlayerVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvPlayer {
            return arrPlayer.count
        } else {
            return isFromTeam ? arrOtherSelected.count : arrSelected.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvPlayer {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPlayerCell", for: indexPath) as! AddPlayerCell
            cell.btnSelection.isHidden = false
            cell.lblName.text = arrPlayer[indexPath.row].displayName
            cell.imgProfile.setImage(imageUrl: arrPlayer[indexPath.row].avatarImage!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPlayerCell", for: indexPath) as! AddPlayerCell
            cell.btnSelection.isHidden = false
            cell.btnSelection.isUserInteractionEnabled = false
//            cell.onTapRemovePlayer = { index in
//                let results = self.arrTemp.filter { $0.id == self.arrSelected[index].id }
//                if results.count > 0 {
//                    self.arrPlayer.append(results[0])
//                    self.tvPlayer.reloadData()
//                }
//                self.arrSelected.remove(at: index)
//                self.tvSelectedPlayer.reloadData()
//
//                if self.arrSelected.count > 0 {
//                    self.btnAdd.isEnabled = true
//                    self.btnAdd.backgroundColor = Colors.theme.returnColor()
//                } else {
//                    self.btnAdd.isEnabled = false
//                    self.btnAdd.backgroundColor = Colors.themeDisable.returnColor()
//                }
//            }
            cell.index = indexPath.row
            cell.lblName.text = isFromTeam ? arrOtherSelected[indexPath.row].displayName : arrSelected[indexPath.row].displayName
            cell.imgProfile.setImage(imageUrl: isFromTeam ? arrOtherSelected[indexPath.row].avatarImage! :  arrSelected[indexPath.row].avatarImage!)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromTeam {
            if tableView == tvPlayer {
                arrOtherSelected.append(arrPlayer[indexPath.row])
                arrPlayer.remove(at: indexPath.row)
                tvSelectedPlayer.reloadData()
                tvPlayer.reloadData()
            } else {
                let results = self.arrTemp.filter { $0.id == self.arrOtherSelected[indexPath.row].id }
                if results.count > 0 {
                    self.arrPlayer.append(results[0])
                    self.tvPlayer.reloadData()
                }
                self.arrOtherSelected.remove(at: indexPath.row)
                self.tvSelectedPlayer.reloadData()
            }
        }  else {
            if tableView == tvPlayer {
                let results = arrSelected.filter { $0.id == arrPlayer[indexPath.row].id }
                if results.count == 0 {
                    arrPlayer.append(arrPlayer[indexPath.row])
                    tvSelectedPlayer.reloadData()
                    arrPlayer.remove(at: indexPath.row)
                    tvPlayer.reloadData()
                    tvSelectedPlayer.scrollToRow(at: NSIndexPath(row: arrSelected.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
                }
            } else {
                let results = self.arrTemp.filter { $0.id == self.arrSelected[indexPath.row].id }
                if results.count > 0 {
                    self.arrPlayer.append(results[0])
                    self.tvPlayer.reloadData()
                }
                self.arrSelected.remove(at: indexPath.row)
                self.tvSelectedPlayer.reloadData()
            }
        }
        submitButtonUI()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == (self.arrPlayer.count) - 1) {
            if self.hasMore == 1 {
                self.searchPlayer(searchText: txtSearch.text ?? "")
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddPlayerVC : UITextFieldDelegate {
    
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
            arrTemp.removeAll()
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
