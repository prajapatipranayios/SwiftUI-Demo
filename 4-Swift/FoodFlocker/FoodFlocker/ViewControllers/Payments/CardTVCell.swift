//
//  CardTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 28/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class CardTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivCardType: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var ivCardDefault: UIImageView!

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
        if btnDelete != nil {
            viewContainer.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
        }
    }

}
