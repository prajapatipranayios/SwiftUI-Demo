//
//  FollowRequestCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class FollowRequestCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnUser: UIButton!

    @IBOutlet weak var widthBtnFollow: NSLayoutConstraint!
    
    @IBOutlet weak var widthBtnApprove: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        btnApprove.layer.cornerRadius = btnApprove.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
