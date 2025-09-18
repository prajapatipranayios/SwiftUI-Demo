//
//  LeagueGamingIdCell.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class LeagueGamingIdCell: UITableViewCell {
    
    // MARK: - Variable

    // MARK: - Controls
    
    @IBOutlet weak var lblGameName : UILabel!
    @IBOutlet weak var lblGameId : UILabel!
    @IBOutlet weak var imgGame : UIImageView!
    @IBOutlet weak var imgStatus : UIImageView!
    @IBOutlet weak var btnSelect : UIButton!
    @IBOutlet weak var imgGameLeadingConst : NSLayoutConstraint!
        
    // MARK: - UI Method
    /*func showAnimation() {
        lblGameName.showAnimatedSkeleton()
        lblGameId.showAnimatedSkeleton()
        imgGame.showAnimatedSkeleton()
        btnSelect.showAnimatedSkeleton()
        imgStatus.showAnimatedSkeleton()
    }   //  */
    
    /*func hideAnimation() {
        lblGameName.hideSkeleton()
        lblGameId.hideSkeleton()
        imgGame.hideSkeleton()
        btnSelect.hideSkeleton()
        imgStatus.hideSkeleton()
    }   //  */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgGame.layer.cornerRadius = imgGame.frame.size.height / 2
    }
}
