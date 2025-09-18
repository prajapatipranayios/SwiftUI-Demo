//
//  ResultCVCell.swift
//  - Designed custom cell for Result Details screen for League Module

//  Tussly
//
//  Created by Jaimesh Patel on 21/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultCVCell: UICollectionViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var tvResult : UITableView!

    // MARK: - Variables
    
    var openResultDetails: ((Int)->Void)?
    var result: [Result]?

    // MARK: - UI Methods
    
    func setupResultTbl(resultData:[Result]? = nil) {
        if resultData != nil {
            self.result = resultData
        }
        tvResult.delegate = self
        tvResult.dataSource = self
        tvResult.reloadData()
    }
}

// MARK: UITableViewDelegate

extension ResultCVCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        if result != nil {
//            cell.hideAnimation()
            cell.ivHomeTeamLogo.setImage(imageUrl: result![indexPath.row].homeTeamLogoImage ?? "")
            cell.lblHomeTeamName.text = result![indexPath.row].homeTeamName
            cell.ivAwayTeamLogo.setImage(imageUrl: result![indexPath.row].awayTeamLogoImage ?? "")
            cell.lblAwayTeamName.text = result![indexPath.row].awayTeamName
            cell.lblScore.text = "\(result![indexPath.row].homeTeamRoundWin ?? 0) \("-") \(result![indexPath.row].tiedRound ?? 0) \("-") \(result![indexPath.row].awayTeamRoundWin ?? 0)"
            cell.ivHomeTeamLogo.layer.cornerRadius = cell.ivHomeTeamLogo.frame.size.width/2
            cell.ivAwayTeamLogo.layer.cornerRadius = cell.ivAwayTeamLogo.frame.size.width/2
        }else {
//            cell.showAnimation()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if openResultDetails != nil {
            openResultDetails!(indexPath.row)
        }
    }
}
