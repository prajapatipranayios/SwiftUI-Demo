//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CharNameCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewMain: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.viewMain.layer.borderColor = Colors.disable.returnColor().cgColor
            self.viewMain.layer.borderWidth = 1.5
            self.viewMain.cornerWithShadow(offset: CGSize(width: 0.0, height: 2.0), color: Colors.disable.returnColor(), radius: 1.0, opacity: 0.5, corner: self.viewMain.frame.size.height/2)
        }
    }
    
}
