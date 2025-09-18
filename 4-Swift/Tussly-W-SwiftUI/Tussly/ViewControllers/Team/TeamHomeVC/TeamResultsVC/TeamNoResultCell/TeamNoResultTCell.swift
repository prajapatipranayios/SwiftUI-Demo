//
//  TeamNoResultTCell.swift
//  Tussly
//
//  Created by Auxano on 01/12/22.
//  Copyright © 2022 Auxano. All rights reserved.
//

import UIKit

class TeamNoResultTCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnDetails: UIButton!
    
    @IBOutlet var lblWLDetails: UILabel!
    @IBOutlet var lblTeamLifeTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblWLDetails.layer.cornerRadius = 3.0
        self.lblWLDetails.layer.masksToBounds = true
        
        self.lblTitle.font = Fonts.Regular.returnFont(size: 13.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
