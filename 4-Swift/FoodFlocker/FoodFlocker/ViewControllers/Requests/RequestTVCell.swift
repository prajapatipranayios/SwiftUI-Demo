//
//  RequestTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 22/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatRatingView

class RequestTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var ivItem: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReqBy: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnPostDetails: UIButton!
    @IBOutlet weak var lblTime: UILabel!

    @IBOutlet weak var widthBtnConfirm: NSLayoutConstraint!
    
    @IBOutlet weak var viewRatings: FloatRatingView!
    @IBOutlet weak var widthViewRatings: NSLayoutConstraint!
    
    @IBOutlet weak var btnWriteReview: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btnConfirm.layer.cornerRadius = btnConfirm.frame.size.height / 2
        btnReject.layer.cornerRadius = btnReject.frame.size.height / 2

        ivItem.layer.cornerRadius = 5.0
//        ivItem.addShadow(offset: CGSize(width: 3.0, height: 3.0), color: Colors.gray.returnColor(), radius: 10.0, opacity: 0.5)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
