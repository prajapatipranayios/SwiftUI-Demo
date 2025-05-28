//
//  ConversationTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 17/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ConversationTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var ivMedia: UIImageView!
    @IBOutlet weak var ivMediaVideo: UIImageView!
    @IBOutlet weak var btnVideoPlay: UIButton!
    @IBOutlet weak var viewMessage: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
