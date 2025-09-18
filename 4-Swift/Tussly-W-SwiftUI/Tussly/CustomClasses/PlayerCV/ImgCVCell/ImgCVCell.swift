//
//  ImgCVCell.swift
//  - Custom cell to display image only for Bi-Directional Collection View.

//  Tussly
//
//  Created by Jaimesh Patel on 06/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ImgCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var withIv : NSLayoutConstraint!
    @IBOutlet weak var ivIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.ivIcon.layer.cornerRadius = self.ivIcon.frame.size.height/2
        }
    }

}
