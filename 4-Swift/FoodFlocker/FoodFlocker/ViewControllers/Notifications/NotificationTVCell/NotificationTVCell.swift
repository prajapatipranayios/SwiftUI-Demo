//
//  NotificationTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class NotificationTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivNotif: UIImageView!
    @IBOutlet weak var lblNotif: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var seprater: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ivNotif.layer.cornerRadius = ivNotif.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
