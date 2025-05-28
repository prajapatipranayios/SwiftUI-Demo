//
//  AddMediaCVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 12/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class AddMediaCVCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var ivMedia: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnVideoIndicator: UIButton!

    override func layoutSubviews() {
        super.layoutSubviews()
        ivMedia.layer.cornerRadius = 10.0
        ivMedia.clipsToBounds = true
    }
}
