//
//  ImgCVCell.swift
//  - Custom cell to display image only for Bi-Directional Collection View.

//  Tussly
//
//  Created by Jaimesh Patel on 06/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ImgScoreCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var ivCheck: UIImageView!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var ivIconTop: NSLayoutConstraint!
    @IBOutlet weak var lblScoreBottom: NSLayoutConstraint!
    @IBOutlet weak var ivWidthConst: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
