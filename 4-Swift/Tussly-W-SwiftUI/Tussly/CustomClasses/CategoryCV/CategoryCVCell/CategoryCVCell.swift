//
//  CategoryCVCell.swift
//  - Custom CollectionView Cell which contains relevant Category Name & Image.
//
//  Created by Jaimesh Patel on 6/6/18.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CategoryCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var ivCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewAnimation : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

//    func showAnimation() {
//        viewAnimation.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        viewAnimation.hideSkeleton()
//    }
    
}
