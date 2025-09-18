//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CharProfileCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var btnChar: UIButton!
    @IBOutlet weak var lblNoOfCharSelect: UILabel!
    
    var onTapProfile: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        DispatchQueue.main.async {
            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height / 2
            self.viewTitle.layer.borderColor = Colors.disable.returnColor().cgColor
            self.viewTitle.layer.borderWidth = 1.5
            self.viewTitle.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: Colors.disable.returnColor(), radius: 0.5, opacity: 0.5, corner: 8)
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapProfile(_ sender: UIButton) {
        if self.onTapProfile != nil {
            self.onTapProfile!(index)
        }
    }
    
}
