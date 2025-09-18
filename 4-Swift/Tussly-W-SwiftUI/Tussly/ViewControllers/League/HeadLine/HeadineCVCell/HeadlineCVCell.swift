//
//  HeadlineCVCell.swift
//  Tussly
//
//  Created by Jaimesh Patel on 21/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class HeadlineCVCell: UICollectionViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var tvHeadLine : UITableView!
    
    // MARK: - Variables
    
    var headlines: [Headline]?

    // MARK: - UI Methods
    
    func setupHeadlineTbl(headlines: [Headline]? = nil) {
        if headlines != nil {
            self.headlines = headlines
        }
        tvHeadLine.rowHeight = UITableView.automaticDimension
        tvHeadLine.estimatedRowHeight = 250.0
        tvHeadLine.delegate = self
        tvHeadLine.dataSource = self
        DispatchQueue.main.async {
            self.tvHeadLine.reloadData()
        }
    }
}

// MARK: UITableViewDelegate

extension HeadlineCVCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headlines?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeadLineCell", for: indexPath) as! HeadLineCell
        
        if headlines != nil {
//            cell.hideAnimation()
            cell.lblHeadline.attributedText = headlines![indexPath.row].content.htmlToAttributedString
        }else {
            cell.lblHeadline.text = ""
//            cell.showAnimation()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if headlines != nil {
            return UITableView.automaticDimension
        }else {
            return 30.0
        }
        
    }
}
