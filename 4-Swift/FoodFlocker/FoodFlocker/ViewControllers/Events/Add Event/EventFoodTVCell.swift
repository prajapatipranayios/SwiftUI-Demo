//
//  EventFoodTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 26/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventFoodTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblFoodItem: UILabel!
    @IBOutlet weak var btnEdit: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
