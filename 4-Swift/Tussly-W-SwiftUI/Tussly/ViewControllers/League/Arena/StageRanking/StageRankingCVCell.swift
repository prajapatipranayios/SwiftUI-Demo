//
//  StageRankingCVCell.swift
//  Tussly
//
//  Created by Auxano on 02/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class StageRankingCVCell: UITableViewCell {
    
    // MARK: - Controls
    //Outlets
    @IBOutlet weak var lblStageName: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var viewContaianer: UIView!
    @IBOutlet weak var imgCheck : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContaianer.layer.cornerRadius = 8
        viewContaianer.layer.borderWidth = 1.5
        viewContaianer.layer.borderColor = Colors.disable.returnColor().cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
