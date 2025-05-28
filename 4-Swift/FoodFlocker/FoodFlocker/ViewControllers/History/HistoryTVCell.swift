//
//  HistoryTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class HistoryTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivHistory: UIImageView!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDuration: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ivHistory.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
