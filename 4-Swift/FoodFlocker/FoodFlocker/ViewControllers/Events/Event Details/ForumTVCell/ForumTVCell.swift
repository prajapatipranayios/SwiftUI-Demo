//
//  ForumTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ForumTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewReply: UIView!
    
    @IBOutlet weak var tfReply: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
//        ivUser.layer.borderWidth = 1.0
//        ivUser.layer.borderColor = UIColor.white.cgColor
//        ivUser.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
        
        viewReply.layer.cornerRadius = viewReply.frame.height / 2
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
