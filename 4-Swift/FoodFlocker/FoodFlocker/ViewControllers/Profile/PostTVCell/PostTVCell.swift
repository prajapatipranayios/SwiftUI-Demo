//
//  PostTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 09/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class PostTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var ivPost: UIImageView!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblPostDesc: UILabel!
    @IBOutlet weak var lblPostDateTime: UILabel!
    @IBOutlet weak var lblPostCategory: UILabel!
    @IBOutlet weak var lblPostType: UILabel!

    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var lblExpirydate: UILabel!

    @IBOutlet weak var btnPost: UIButton!

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
        ivPost.layer.cornerRadius = 10.0
        btnPrice.layer.cornerRadius = 5.0

    }
}
