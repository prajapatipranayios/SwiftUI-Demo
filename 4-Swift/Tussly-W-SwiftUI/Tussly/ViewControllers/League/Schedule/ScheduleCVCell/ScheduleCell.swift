//
//  ScheduleCell.swift
//  - Designed custom cell to display each match schedule

//  Tussly
//
//  Created by Jaimesh Patel on 12/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView

class ScheduleCell: UITableViewCell {

    // MARK: - Controls
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var ivHomeTeam: UIImageView!
    @IBOutlet weak var ivAwayTeam: UIImageView!
    @IBOutlet weak var viewTime: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewTime.layer.cornerRadius = 5.0
        viewTime.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UI Methods
    
//    func showAnimation() {
//        lblTime.showAnimatedSkeleton()
//        lblHomeTeam.showAnimatedSkeleton()
//        lblAwayTeam.showAnimatedSkeleton()
//        ivHomeTeam.showAnimatedSkeleton()
//        ivAwayTeam.showAnimatedSkeleton()
//        viewTime.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblTime.hideSkeleton()
//        lblHomeTeam.hideSkeleton()
//        lblAwayTeam.hideSkeleton()
//        ivHomeTeam.hideSkeleton()
//        ivAwayTeam.hideSkeleton()
//        viewTime.hideSkeleton()
//    }
}
