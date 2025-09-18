//
//  TLDropDown.swift
//  - Custom Dropdown to allow user to select league.
//  Tussly
//
//  Created by Auxano on 17/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TLDropDown: UIView {
    // MARK: - Controls
    
    @IBOutlet weak var tblDropdown : UITableView!
    @IBOutlet weak var imgType : UIImageView!
    
    // MARK: - Variables
    
    var leagues = [League]()
    var didSelectLeague: ((Int)->Void)?
    var closeDropDown: (()->Void)?
    var type = String()
    var isScroll = false
    /// 331 - By Pranay
    var arrTotalTeams = [Team]()
    /// 331  .
    
    // MARK: - UI Methods
    
    func setUpCustomeDropDown(leagueData : [League]) {
        imgType.image = UIImage(named: type)
        leagues = leagueData
        tblDropdown.delegate = self
        tblDropdown.dataSource = self
        
        if isScroll == false {
            tblDropdown.isScrollEnabled = false
        } else {
            tblDropdown.isScrollEnabled = true
        }
        
        tblDropdown.register(UINib(nibName: "DropDownCell", bundle: nil), forCellReuseIdentifier: "DropDownCell")
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapTab(_ sender: UIButton) {
        if self.closeDropDown != nil {
            self.removeFromSuperview()
            self.closeDropDown!()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TLDropDown: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return leagues.count
        return type == "TeamsActive" ? arrTotalTeams.count : leagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        cell.selectionStyle = .none
        if self.type == "TeamsActive" {
            cell.ivLeagueIcon.setImage(imageUrl: arrTotalTeams[indexPath.item].teamLogo ?? "")
            cell.lblLeagueName.text = arrTotalTeams[indexPath.item].teamName ?? ""
            //cell.lblWeekDay.text = leagues[indexPath.row].weekDays
            cell.lblWeekDay.text = ""
        } else {
            if leagues[indexPath.item].profileImage == "" {
                cell.ivLeagueIcon.setImage(imageUrl: leagues[indexPath.item].gameImage ?? "")
            } else {
                cell.ivLeagueIcon.setImage(imageUrl: leagues[indexPath.item].profileImage ?? "")
            }
            cell.lblLeagueName.text = leagues[indexPath.item].abbrevation ?? ""
            cell.lblWeekDay.text = leagues[indexPath.row].weekDays
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.didSelectLeague != nil {
            self.removeFromSuperview()
            self.didSelectLeague!(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
