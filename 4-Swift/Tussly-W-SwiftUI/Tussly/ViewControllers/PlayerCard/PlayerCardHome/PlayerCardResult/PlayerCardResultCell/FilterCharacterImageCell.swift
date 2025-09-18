//
//  FilterCharacterImageCell.swift
//  Tussly
//
//  Created by Auxano on 10/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class FilterCharacterImageCell: UICollectionViewCell {
    
    //MARK: - Variables
    var onTapRemove: (()->Void)?

    //MARK: - Outlets
    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var imgWidthConst: NSLayoutConstraint!
    @IBOutlet weak var imgHeightConst: NSLayoutConstraint!
    @IBOutlet weak var btnRemove: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    func showAnimation() {
//        imgCharacter.showAnimatedSkeleton()
//        btnRemove.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        imgCharacter.hideSkeleton()
//        btnRemove.hideSkeleton()
//    }
    
    //MARK: - Button Click Events
    @IBAction func onTapRemove(_ sender: UIButton) {
        if self.onTapRemove != nil {
            self.onTapRemove!()
        }
    }

}
