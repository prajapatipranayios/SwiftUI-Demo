//
//  ForumSecHeaderView.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ForumSecHeaderView: UITableViewHeaderFooterView {
    
    //Outlets
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
    }


}
