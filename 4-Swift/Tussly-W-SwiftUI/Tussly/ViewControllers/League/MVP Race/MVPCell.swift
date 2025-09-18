//
//  MVPCell.swift
//  - Designed custom cell for displaying MVP Progress

//  Tussly
//
//  Created by Auxano on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MVPCell: UITableViewCell {
    
    @IBOutlet weak var lblPlayerName : UILabel!
    @IBOutlet weak var lblProgress : UILabel!
    @IBOutlet weak var viewProgress : UIView!
    @IBOutlet weak var widthProgressView : NSLayoutConstraint!
    @IBOutlet weak var viewContainer : UIView!
    @IBOutlet weak var ivAvtar : UIImageView!
    @IBOutlet weak var ivTeamLogo : UIImageView!

    var scaleFactor: CGFloat = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        ivAvtar.layer.cornerRadius = ivAvtar.frame.width/2
        ivTeamLogo.layer.cornerRadius = ivTeamLogo.frame.width/2
        // Configure the view for the selected state
    }

    /*func showAnimation() {
        lblPlayerName.showAnimatedSkeleton()
        lblProgress.showAnimatedSkeleton()
        viewProgress.showAnimatedSkeleton()
//        viewContainer.showAnimatedSkeleton()
        
        ivAvtar.showAnimatedSkeleton()
        ivTeamLogo.showAnimatedSkeleton()
    }   //  */
    
    /*func hideAnimation() {
        lblPlayerName.hideSkeleton()
        lblProgress.hideSkeleton()
        viewProgress.hideSkeleton()
//        viewContainer.hideSkeleton()
        
        ivAvtar.hideSkeleton()
        ivTeamLogo.hideSkeleton()
    }   //  */
    
}
