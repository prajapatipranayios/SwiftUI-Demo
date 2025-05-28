//
//  TagTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class TagTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var ivTag: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ivTag.layer.cornerRadius = ivTag.frame.size.height / 2
        ivTag.layer.borderWidth = 1.0
        ivTag.layer.borderColor = Colors.themeGreen.returnColor().cgColor
    }
}
