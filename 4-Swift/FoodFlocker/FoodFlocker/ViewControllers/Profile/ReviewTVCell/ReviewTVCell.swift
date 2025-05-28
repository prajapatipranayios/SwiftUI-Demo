//
//  ReviewTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 09/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatRatingView

class ReviewTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewRatings: FloatRatingView!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var widthBtnFollow: NSLayoutConstraint!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let decImage = UIImage(named: "StarFilled")?.withRenderingMode(.alwaysTemplate)
        viewRatings.fullImage = decImage
        viewRatings.tintColor = Colors.yellowStar.returnColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewContainer.layer.cornerRadius = 20.0
        viewContainer.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height / 2

    }
}
