//
//  PlayerCVCell.swift
//  - Custom cell to display Player Name & Image for Bi-Directional Collection View.
//
//  Created by Jaimesh Patel on 11/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ReportScoreCVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    
    var onTapStock: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapProfile(_ sender: UIButton) {
        if self.onTapStock != nil {
            self.onTapStock!(index)
        }
    }
    
}
