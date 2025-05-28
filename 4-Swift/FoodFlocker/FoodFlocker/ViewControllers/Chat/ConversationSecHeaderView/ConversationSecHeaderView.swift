//
//  ConversationSecHeaderView.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 17/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ConversationSecHeaderView: UITableViewHeaderFooterView {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblDate: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewContainer.layer.cornerRadius = viewContainer.frame.size.height / 2
    }

}
