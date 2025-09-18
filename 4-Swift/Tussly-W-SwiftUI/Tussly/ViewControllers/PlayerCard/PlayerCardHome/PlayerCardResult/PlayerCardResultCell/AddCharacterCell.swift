//
//  AddCharacterCell.swift
//  Tussly
//
//  Created by Auxano on 10/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class AddCharacterCell: UICollectionViewCell {

    //MARK: - Control
    @IBOutlet weak var lblFilterName: UILabel!
    @IBOutlet weak var imgPlus: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgPlus.setImageColor(color: Colors.theme.returnColor())
    }
    
//    func showAnimation() {
//        lblFilterName.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblFilterName.hideSkeleton()
//    }

}
