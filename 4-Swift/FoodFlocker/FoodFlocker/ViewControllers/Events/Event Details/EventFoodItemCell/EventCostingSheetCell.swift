//
//  CostingSheetCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventCostingSheetCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblIngr: UILabel!
    @IBOutlet weak var lblCost: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
