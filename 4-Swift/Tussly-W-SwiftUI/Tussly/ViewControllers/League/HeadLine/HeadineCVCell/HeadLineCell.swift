//
//  HeadLineCell.swift
//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import SkeletonView

class HeadLineCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var lblHeadline : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - UI Methods
    
//    func showAnimation() {
//        lblHeadline.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblHeadline.hideSkeleton()
//    }
}
