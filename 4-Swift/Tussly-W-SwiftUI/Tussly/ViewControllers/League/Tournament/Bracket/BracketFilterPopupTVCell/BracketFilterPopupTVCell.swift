//
//  BracketFilterPopupTVCell.swift
//  Tussly
//
//  Created by MAcBook on 11/07/22.
//  Copyright © 2022 Auxano. All rights reserved.
//

import UIKit

class BracketFilterPopupTVCell: UITableViewCell {

    @IBOutlet weak var lblFilterPool: UILabel!
    @IBOutlet weak var lblMyPool: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblMyPool.clipsToBounds = true
        lblFilterPool.clipsToBounds = true
        lblMyPool.layer.cornerRadius = 10
        lblFilterPool.layer.cornerRadius = 10
        lblFilterPool.layer.borderWidth = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
