//
//  ChatTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ChatTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblMsgCount: UILabel!
    @IBOutlet weak var lblDuration: UILabel!

    @IBOutlet weak var viewPhoto: UIView!
    @IBOutlet weak var ivPhotoVideo: UIImageView!
    @IBOutlet weak var lblPhotoVideo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ivProfile.layer.cornerRadius = ivProfile.frame.size.height / 2
        lblMsgCount.layer.cornerRadius = lblMsgCount.frame.size.height / 2
        lblMsgCount.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
