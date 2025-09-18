//
//  FriendListVC.swift
//  Tussly
//
//  Created by Auxano on 14/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class FriendListVC: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Controls
    
    @IBOutlet weak var tvFriend : UITableView!
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSub : UIView!
    @IBOutlet weak var btnAddFriend : UIButton!
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var viewBottom : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    
    // MARK: - Variables
    var isForGame = false
    var didSelectGame: (()->Void)?
    var arrGameList = [Game]()
    var tempGameArray = [Game]()
    var arrSelectedGame = [Int]()
    var didSelectItem: (([Player])->Void)?
    var arrFriendsList = [Player]()
    var tempArray = [Player]()
    var arrSelected = [Player]()
    var titleString = ""
    var buttontitle = ""
    var isFromFounder = false
    var placeHolderString = Messages.searchByDisplayName
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleString
        btnAddFriend.setTitle(buttontitle, for: .normal)
        txtSearch.placeholder = placeHolderString
        DispatchQueue.main.async {
            self.btnAddFriend.layer.cornerRadius = 15
        }
        if arrSelected.count > 0 {
            btnAddFriend.isEnabled = true
            btnAddFriend.backgroundColor = Colors.theme.returnColor()
        }
        else {
            btnAddFriend.isEnabled = false
            btnAddFriend.backgroundColor = Colors.themeDisable.returnColor()
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
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        
        viewBottom.addShadow(offset: CGSize(width: 0, height: -5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
        
        //arrSelectedGame = Array(Set(arrSelectedGame))
        
        tempArray = arrFriendsList
        tempGameArray = arrGameList
        tvFriend.rowHeight = UITableView.automaticDimension
        tvFriend.estimatedRowHeight = 100.0
        tvFriend.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewMain.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Methods
    
    func searchContent(string: String) {
        if string != "" {
            if isForGame {
                tempGameArray = arrGameList.filter({ (data) -> Bool in
                    return ("\(data.gameName ?? "")").lowercased().contains(string.lowercased())
                })
            } else {
                tempArray = arrFriendsList.filter({ (data) -> Bool in
                    return ("\(data.displayName ?? "")").lowercased().contains(string.lowercased())
                })
            }
            tvFriend.reloadData()
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapAddFriend(_ sender: UIButton) {
        if self.isForGame {
            self.saveGame()
        } else {
            self.dismiss(animated: true) {
                if self.didSelectItem != nil {
                    self.didSelectItem!(self.arrSelected)
                }
            }
        }
    }
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    func saveGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.saveGame()
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SAVE_PLAYER_GAME, parameters: ["games" : arrSelectedGame]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        if self.didSelectGame != nil {
                            self.didSelectGame!()
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension FriendListVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isForGame ? tempGameArray.count : tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        cell.lblName.text = isForGame ? tempGameArray[indexPath.row].gameName : tempArray[indexPath.row].displayName
        cell.imgProfile.setImage(imageUrl: isForGame ? tempGameArray[indexPath.row].gameLogo ?? "" : tempArray[indexPath.row].avatarImage ?? "")
        cell.index = indexPath.row
        
        if isForGame {
            self.addButtonUI()
        }
        
        if isForGame {
            cell.onTapGameCell = { index in
                if self.arrSelectedGame.count > 0 {
                    if self.arrSelectedGame.contains(self.tempGameArray[indexPath.row].id!) {
                        self.arrSelectedGame.remove(at: self.arrSelectedGame.firstIndex(of: self.tempGameArray[index].id!)!)
                    }
                    else {
                        self.arrSelectedGame.append(self.tempGameArray[index].id!)
                    }
                }
                else {
                    self.arrSelectedGame.append(self.tempGameArray[index].id!)
                }
                self.tvFriend.reloadData()
                self.addButtonUI()
            }
            cell.btnSelection.isSelected = false
            if arrSelectedGame.count > 0 {
                if arrSelectedGame.contains(tempGameArray[indexPath.row].id!) {
                    cell.btnSelection.isSelected = true
                }
            }
        }
        else {
            cell.onTapFriendCell = { index in
                if self.isFromFounder {
                    self.arrSelected.removeAll()
                    self.arrSelected.append(self.tempArray[index])
                }
                else {
                    if self.arrSelected.count > 0 {
                        let mainIndex = self.arrSelected.firstIndex(where: {$0.id == self.tempArray[index].id})
                        if mainIndex != nil {
                            self.arrSelected.remove(at: mainIndex!)
                        }
                        else {
                            self.arrSelected.append(self.tempArray[index])
                        }
                    }
                    else {
                        self.arrSelected.append(self.tempArray[index])
                    }
                }
                self.tvFriend.reloadData()
                if self.arrSelected.count > 0 {
                    self.btnAddFriend.isEnabled = true
                    self.btnAddFriend.backgroundColor = Colors.theme.returnColor()
                }
                else {
                    self.btnAddFriend.isEnabled = false
                    self.btnAddFriend.backgroundColor = Colors.themeDisable.returnColor()
                }
            }
            cell.btnSelection.isSelected = false
            if arrSelected.count > 0 {
                let mainIndex = arrSelected.firstIndex(where: {$0.id == tempArray[indexPath.row].id})
                if mainIndex != nil {
                    cell.btnSelection.isSelected = true
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func addButtonUI() {
        if self.arrSelectedGame.count > 0 {
            self.btnAddFriend.isEnabled = true
            self.btnAddFriend.backgroundColor = Colors.theme.returnColor()
        }
        else {
            self.btnAddFriend.isEnabled = false
            self.btnAddFriend.backgroundColor = Colors.themeDisable.returnColor()
        }
    }
}

// MARK: - UITextFieldDelegate Delegate

extension FriendListVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length > 2 {
            searchContent(string: newString as String)
        }
        else {
            if isForGame {
                tempGameArray = arrGameList
            }
            else {
                tempArray = arrFriendsList
            }
            tvFriend.reloadData()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
}
