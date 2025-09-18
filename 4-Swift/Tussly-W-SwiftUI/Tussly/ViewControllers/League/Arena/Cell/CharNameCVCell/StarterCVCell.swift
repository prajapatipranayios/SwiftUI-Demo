//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class StarterCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBanned: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    
    var onTapProfile: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        DispatchQueue.main.async {
            self.viewTitle.layer.cornerRadius = 8
            self.viewTitle.layer.borderColor = Colors.border.returnColor().cgColor
            self.viewTitle.layer.borderWidth = 1
        }
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapProfile(_ sender: UIButton) {
        if self.onTapProfile != nil {
            self.onTapProfile!(index)
        }
    }
    
}
