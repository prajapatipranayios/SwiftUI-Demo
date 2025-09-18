//
//  ContentCollectionViewCell.swift
//  - Custom cell to display content for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 09/01/2015.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bottomSeprater : UIView!
    @IBOutlet weak var horizontalSeprater : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    func showAnimation() {
//        contentLabel.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        contentLabel.hideSkeleton()
//    }
}
