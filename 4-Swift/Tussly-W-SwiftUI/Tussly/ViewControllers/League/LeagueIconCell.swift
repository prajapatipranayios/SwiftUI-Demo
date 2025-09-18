//
//  LeagueIconCell.swift
//  - Designed custom League Icon cell to display Logo Image of each League

//  Tussly
//
//  Created by Jaimesh Patel on 09/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView

class LeagueIconCell: UICollectionViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        isSkeletonable = true
//        ivIcon.isSkeletonable = true
//        DispatchQueue.main.async {
//            self.ivIcon.layer.cornerRadius = self.ivIcon.frame.size.width/2
//        }
    }
}
