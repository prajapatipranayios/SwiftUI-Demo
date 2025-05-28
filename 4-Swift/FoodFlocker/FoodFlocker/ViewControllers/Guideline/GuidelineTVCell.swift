//
//  GuidelineTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class GuidelineTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivGuideline: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
