//
//  BracketRoundCell.swift
//  Tussly
//
//  Created by Auxano on 24/09/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class BracketRoundCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var lblSelected: UILabel!
    @IBOutlet weak var lblTitle: UILabel!

    var onTapRound: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        DispatchQueue.main.async {
            self.lblSelected.layer.cornerRadius = 3
            self.lblSelected.clipsToBounds = true
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapRound(_ sender: UIButton) {
        if self.onTapRound != nil {
            self.onTapRound!(index)
        }
    }
    
}

