//
//  ContentCollectionViewCell.swift
//  - Custom cell to display content for Bi-Directional Collection View.
//
//  Created by Kishor on 09/01/2015.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ContentWithBlackBackgroundCell: UICollectionViewCell {
    
    var onTapRedirect: (()->Void)?
    var onTapPlayerDetail: (()->Void)?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var btnPlayerDetail: UIButton!
    @IBOutlet weak var bottomSeprater : UIView!
    @IBOutlet weak var viewDetail : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDetail.layer.cornerRadius = 3.0
        btnPlayerDetail.layer.cornerRadius = 3.0
    }

//    func showAnimation() {
//        contentLabel.showAnimatedSkeleton()
//        viewDetail.showAnimatedSkeleton()
//        btnDetail.showAnimatedSkeleton()
//        btnPlayerDetail.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        contentLabel.hideSkeleton()
//        viewDetail.hideSkeleton()
//        btnDetail.hideSkeleton()
//        btnPlayerDetail.hideSkeleton()
//    }
    
    //MARK: - Button Click Events
    @IBAction func onTapRedirect(_ sender: UIButton) {
        if self.onTapRedirect != nil {
            self.onTapRedirect!()
        }
    }
    
    @IBAction func onTapPlayerDetail(_ sender: UIButton) {
        if self.onTapPlayerDetail != nil {
            self.onTapPlayerDetail!()
        }
    }
}
