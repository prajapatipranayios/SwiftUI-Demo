//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class PlayerCVCenterCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var viewCellBg: UIView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var ivPlayer: UIImageView!
    @IBOutlet weak var horizontalSeperater : UIView!
    @IBOutlet weak var bottomSeprater : UIView!
    @IBOutlet weak var widthIVPlayer : NSLayoutConstraint!
    @IBOutlet weak var trailIVPlayer : NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivPlayer.layer.masksToBounds = false
        ivPlayer.clipsToBounds = true
    }
    
    /*func showAnimation() {
        lblPlayerName.showAnimatedSkeleton()
        ivPlayer.showAnimatedSkeleton()
    }
    
    func hideAnimation() {
        lblPlayerName.hideSkeleton()
        ivPlayer.hideSkeleton()
    }   //  */

}
