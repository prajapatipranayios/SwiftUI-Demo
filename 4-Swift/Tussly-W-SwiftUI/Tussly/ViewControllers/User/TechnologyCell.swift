//
//  TechnologyCell.swift
//  Tussly
//
//  Created by Auxano on 18/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class TechnologyCell: UICollectionViewCell {

    //Outlets
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgTech: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.contentView.layer.cornerRadius = 15.0
            self.imgTech.layer.cornerRadius = 15.0
        }
    }
}
