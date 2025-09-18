//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultUsersCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var ivPlayer: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.ivPlayer.layer.cornerRadius = self.ivPlayer.frame.size.width/2
            self.ivPlayer.clipsToBounds = true
        }
    }
    
//    func showAnimation() {
//        lblPlayerName.showAnimatedSkeleton()
//        ivPlayer.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblPlayerName.hideSkeleton()
//        ivPlayer.hideSkeleton()
//    }

}
