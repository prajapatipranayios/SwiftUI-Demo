//
//  LeagueGamingIdVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class LeagueGamingIdVC: UIViewController {
    
    // MARK: - Controls

    @IBOutlet weak var tvGamingId : UITableView!
    @IBOutlet weak var viewSearchContainer : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    
    // MARK: - Variables
    var expandedIndex = -1
    var tempArray = [CaptainDetail]()
    var arrCaptainGamingId = [CaptainDetail]()
    var totalCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewSearchContainer.layer.cornerRadius = 20.0
        viewSearchContainer.layer.borderWidth = 1.0
        viewSearchContainer.layer.borderColor = Colors.border.returnColor().cgColor
        
        tempArray = APIManager.sharedManager.leagueInfo?.captainGameIds ?? []
        arrCaptainGamingId = APIManager.sharedManager.leagueInfo?.captainGameIds ?? []
        
        let headerNib = UINib.init(nibName: "LeagueGamingIdCell", bundle: Bundle.main)
        tvGamingId.register(headerNib, forHeaderFooterViewReuseIdentifier: "LeagueGamingIdCell")
        tvGamingId.register(UINib(nibName: "LeagueGamingIdCell", bundle: nil), forCellReuseIdentifier: "LeagueGamingIdCell")
        tvGamingId.reloadData()
    }
    
    // MARK: - UI Methods
    func searchContent(string: String) {
        if string != "" {
            arrCaptainGamingId = tempArray.filter({ (data) -> Bool in
                return ("\(data.teamName ?? "")").lowercased().contains(string.lowercased())
            })
            tvGamingId.reloadData()
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - TableView Methods
extension LeagueGamingIdVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (expandedIndex != -1 ? (arrCaptainGamingId.count + (arrCaptainGamingId[expandedIndex].userGameTags?.count ?? 0)) : arrCaptainGamingId.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeagueGamingIdCell", for: indexPath) as! LeagueGamingIdCell
        var idCount = 0
        var currentCount = 0
        if expandedIndex != -1 {
            totalCount = arrCaptainGamingId[expandedIndex].userGameTags?.count ?? 0
            idCount = arrCaptainGamingId[expandedIndex].userGameTags?.count ?? 0
            idCount = expandedIndex + idCount + 1
        }
        if(expandedIndex != -1 && (indexPath.section > expandedIndex && indexPath.section < idCount)){
            cell.imgGameLeadingConst.constant = 80
            cell.btnSelect.isHidden = true
            cell.lblGameId.isHidden = false
            cell.imgStatus.isHidden = false
            let arr = arrCaptainGamingId[expandedIndex].userGameTags
            cell.lblGameId.text = arr?[currentCount].consoleName
            cell.imgGame.setImage(imageUrl: arr?[currentCount].consoleIcon ?? "")
            cell.imgStatus.image = UIImage(named: "Captain")
            cell.lblGameName.text = arr?[currentCount].gameTags
            currentCount += 1
        } else if(expandedIndex != -1 && indexPath.section == expandedIndex) {
            cell.imgGameLeadingConst.constant = 32
            cell.imgStatus.isHidden = true
            cell.btnSelect.isHidden = false
            cell.lblGameId.isHidden = true
            cell.btnSelect.setImage(UIImage(named: "Arrow_more"), for: .normal)
            cell.lblGameName.text = arrCaptainGamingId[indexPath.section].teamName
            cell.imgGame.setImage(imageUrl: arrCaptainGamingId[indexPath.section].teamLogo ?? "")
        } else {
            var subData = 0
            if expandedIndex != -1 {
                subData = arrCaptainGamingId[expandedIndex].userGameTags?.count ?? 0
            }
            cell.imgGameLeadingConst.constant = 32
            cell.btnSelect.isHidden = false
            cell.lblGameId.isHidden = true
            cell.imgStatus.isHidden = true
            cell.btnSelect.setImage(UIImage(named: "Arrow_down"), for: .normal)
            cell.lblGameName.text = (expandedIndex != -1 && indexPath.section > expandedIndex) ? arrCaptainGamingId[indexPath.section - subData].teamName : arrCaptainGamingId[indexPath.section].teamName
            cell.imgGame.setImage(imageUrl: (expandedIndex != -1 && indexPath.section > expandedIndex) ? arrCaptainGamingId[indexPath.section - subData].teamLogo ?? "" : arrCaptainGamingId[indexPath.section].teamLogo ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndex == -1 {
                expandedIndex = indexPath.section
        }else {
            if indexPath.section == expandedIndex {
                expandedIndex = -1
            }else {
                if expandedIndex < indexPath.section {
                    expandedIndex = indexPath.section - totalCount
                } else {
                    expandedIndex = indexPath.section
                }
            }
        }
        tvGamingId.reloadData()
    }

}

// MARK: - UITextFieldDelegate Delegate

extension LeagueGamingIdVC : UITextFieldDelegate {
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
                arrCaptainGamingId = tempArray
                tvGamingId.reloadData()
            }
            return true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
}

