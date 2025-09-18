//
//  ResultCVCell.swift
//  - Designed custom cell for Result Details screen for League Module

//  Tussly
//
//  Created by Jaimesh Patel on 21/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var ivHomeTeamLogo : UIImageView!
    @IBOutlet weak var ivAwayTeamLogo : UIImageView!
    @IBOutlet weak var ivDetailNext : UIImageView!
    @IBOutlet weak var lblHomeTeamName : UILabel!
    @IBOutlet weak var lblAwayTeamName : UILabel!
    @IBOutlet weak var lblScore : UILabel!
    
    // MARK: - Variables
    var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UI Methods
    
//    func showAnimation() {
//        ivHomeTeamLogo.showAnimatedSkeleton()
//        ivAwayTeamLogo.showAnimatedSkeleton()
//        lblHomeTeamName.showAnimatedSkeleton()
//        lblAwayTeamName.showAnimatedSkeleton()
//        lblScore.showAnimatedSkeleton()
//        ivDetailNext.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivHomeTeamLogo.hideSkeleton()
//        ivAwayTeamLogo.hideSkeleton()
//        lblHomeTeamName.hideSkeleton()
//        lblAwayTeamName.hideSkeleton()
//        lblScore.hideSkeleton()
//        ivDetailNext.hideSkeleton()
//    }
}
