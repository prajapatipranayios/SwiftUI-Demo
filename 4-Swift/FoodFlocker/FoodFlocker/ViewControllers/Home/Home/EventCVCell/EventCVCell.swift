//
//  PostCVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventCVCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivEvent: UIImageView!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblEventDateTime: UILabel!
    @IBOutlet weak var lblLocation: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewContainer.layer.cornerRadius = 10.0
        viewContainer.addShadow(offset: CGSize(width: 0, height: -3.0), color: Colors.gray.returnColor(), radius: 2.0, opacity: 0.25)
        ivEvent.layer.cornerRadius = 10.0
    }
}
