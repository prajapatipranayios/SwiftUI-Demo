//
//  AddTrackerNetworkVC.swift
//  Tussly
//
//  Created by Auxano on 18/08/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class AddTrackerNetworkVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var tvGame : UITableView!
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSub : UIView!
    @IBOutlet weak var btnAdd : UIButton!
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var txtURL : UITextField!
    @IBOutlet weak var txtTitle : UITextField!
    @IBOutlet weak var viewBottom : UIView!
    @IBOutlet weak var lblUrlError: UILabel!
    @IBOutlet weak var lblTitleError: UILabel!
    
    // MARK: - Variables
    var didSelectGame: (() -> Void)?
    var arrGameList = [Game]()
    var tempGameArray = [Game]()
    var arrSelectedGame = [Game]()
    var isEditedId = 0
    var editData = [String:Any]()
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.btnAdd.layer.cornerRadius = 15
        }
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
        
        btnAdd.isEnabled = false
        if isEditedId != 0 {
            for i in 0 ..< arrGameList.count {
                if arrGameList[i].id == isEditedId {
                    arrSelectedGame.append(arrGameList[i])
                    txtURL.text = editData["url"] as? String
                    txtTitle.text = editData["title"] as? String
                    btnAdd.isEnabled = true
                }
            }
        }
        
        viewBottom.addShadow(offset: CGSize(width: 0, height: -5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
        tempGameArray = arrGameList
        tvGame.reloadData()
    }
    
    // MARK: - UI Methods
    
    func searchContent(string: String) {
        if string != "" {
            tempGameArray = arrGameList.filter({ (data) -> Bool in
                return ("\(data.gameName ?? "")").lowercased().contains(string.lowercased())
            })
            tvGame.reloadData()
        }
    }
    
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapAdd(_ sender: UIButton) {
        var isValid = false
        if txtURL.text == "" {
            lblUrlError.text = "Please enter Tracker Network URL"
        } else {
            let url = txtURL.text
            if canOpenURL(url) {
                lblUrlError.text = ""
                isValid = true
            } else {
                lblUrlError.text = "Please enter valid Tracker Network URL"
            }
        }
        
        if txtTitle.text == "" {
            lblTitleError.text = "Please enter Tracker Network Title"
        } else {
            lblTitleError.text = ""
        }
                
        if txtURL.text != "" && txtTitle.text != "" && isValid {
            showLoading()
            var param = [String:Any]()
            param =
                isEditedId == 0 ? ["title" : txtTitle.text ?? "",
                                  "trackerNetworkUrl" : txtURL.text ?? "",
                                  "gameId" : arrSelectedGame[0].id!] :
                ["title" : txtTitle.text ?? "",
                "trackerNetworkUrl" : txtURL.text ?? "",
                "gameId" : arrSelectedGame[0].id!, "id" : isEditedId]
            APIManager.sharedManager.postData(url: APIManager.sharedManager.ADD_EDIT_TRACKER_NETWORK, parameters: param) { (response: ApiResponse?, error) in
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
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension AddTrackerNetworkVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempGameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        cell.lblName.text = tempGameArray[indexPath.row].gameName
        cell.imgProfile.setImage(imageUrl: tempGameArray[indexPath.row].gameImage )
        cell.index = indexPath.row
    
        cell.onTapGameCell = { index in
            self.arrSelectedGame.removeAll()
            self.arrSelectedGame.append(self.tempGameArray[index])
            self.tvGame.reloadData()
        }
        
        if arrSelectedGame.count > 0 {
            if arrSelectedGame[0].id == tempGameArray[indexPath.row].id {
                cell.btnSelection.setImage(UIImage(named: "Select"), for: .normal)
            } else {
                cell.btnSelection.setImage(UIImage(named: ""), for: .normal)
            }
            btnAdd.isEnabled = true
            btnAdd.backgroundColor = Colors.theme.returnColor()
        } else {
            btnAdd.isEnabled = false
            btnAdd.backgroundColor = Colors.themeDisable.returnColor()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

// MARK: - UITextFieldDelegate Delegate

extension AddTrackerNetworkVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtSearch {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length > 2 {
                searchContent(string: newString as String)
            } else {
                tempGameArray = arrGameList
                tvGame.reloadData()
            }
            return true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
}

