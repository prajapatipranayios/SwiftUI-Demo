//
//  ScheduleCVCell.swift
//  - Designed custom Collection View cell for displaying Schedule of each week

//  Tussly
//
//  Created by Jaimesh Patel on 21/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView

class ScheduleCVCell: UICollectionViewCell {
    // MARK: - Controls

    @IBOutlet weak var tvSchedule: UITableView!
    
    // MARK: - Variables

    var scheduleData: [Schedule]?
    
    // MARK: - UI Methods

    func setupScheduleTbl(scheduleData: [Schedule]? = nil) {
        if scheduleData != nil {
            self.scheduleData = scheduleData
        }
        tvSchedule.delegate = self
        tvSchedule.dataSource = self
//        self.contentView.isSkeletonable = true
        tvSchedule.rowHeight = UITableView.automaticDimension
        tvSchedule.estimatedRowHeight = 40.0
        tvSchedule.reloadData()
    }
}

// MARK: - UITableView Data Source/Delegate

extension ScheduleCVCell: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleData?.count ?? 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        if scheduleData != nil {
            let schedule = scheduleData![indexPath.row]
//            cell.hideAnimation()
            cell.lblTime.text = schedule.matchTime
            cell.ivHomeTeam.setImage(imageUrl: schedule.homeTeamLogoImage ?? "")
            cell.lblHomeTeam.text = schedule.homeTeamName
            cell.ivAwayTeam.setImage(imageUrl: schedule.awayTeamLogoImage ?? "")
            cell.lblAwayTeam.text = schedule.awayTeamName
            cell.ivHomeTeam.layer.cornerRadius = cell.ivHomeTeam.frame.size.width/2
            cell.ivAwayTeam.layer.cornerRadius = cell.ivAwayTeam.frame.size.width/2
        } else {
//            cell.showAnimation()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
