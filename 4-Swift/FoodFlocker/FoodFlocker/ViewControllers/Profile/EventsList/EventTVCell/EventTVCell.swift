//
//  EventTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 11/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatRatingView

class EventTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var ivEvent: UIImageView!
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblEventDateTime: UILabel!
    @IBOutlet weak var lblEventLocation: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var widthBtnOptions: NSLayoutConstraint!

    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var btnCancelTicket: UIButton!
    @IBOutlet weak var btnConfirmTicket: UIButton!

    @IBOutlet weak var viewRatings: FloatRatingView!
    @IBOutlet weak var widthViewRatings: NSLayoutConstraint!
    
    @IBOutlet weak var btnWriteReview: UIButton!
    
    @IBOutlet weak var btnEvent: UIButton!

    
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
        viewContainer.layer.cornerRadius = 20.0
        viewContainer.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
        ivEvent.layer.cornerRadius = 10.0

    }
    
}
