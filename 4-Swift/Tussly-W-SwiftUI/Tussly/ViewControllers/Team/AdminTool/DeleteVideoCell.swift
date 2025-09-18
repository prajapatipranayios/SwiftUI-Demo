//
//  DeleteVideoCell.swift
//  Tussly
//
//  Created by Auxano on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class DeleteVideoCell: UITableViewCell {

    @IBOutlet weak var lblCaption : UILabel!
    @IBOutlet weak var imgCaption : UIImageView!
    @IBOutlet weak var imgSelection : UIImageView!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblPlayerName : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
