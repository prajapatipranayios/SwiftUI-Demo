//
//  MenuHeaderView.swift
//  - This is a part of Sidemenu which contains User Profile Img & User name.

//  Tussly
//
//  Created by Jaimesh Patel on 26/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MenuHeaderView: UIView {

    //Outlets
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblUserName: UILabel!


    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.ivUser.layer.cornerRadius = self.ivUser.frame.height / 2
            self.ivUser.layer.masksToBounds = true
            
            self.viewShadow.layer.cornerRadius = self.viewShadow.frame.height / 2
            self.viewShadow.layer.masksToBounds = false
            self.viewShadow.layer.shadowColor = Colors.black.returnColor().cgColor
            self.viewShadow.layer.shadowOffset = CGSize.zero
            self.viewShadow.layer.shadowOpacity = 0.4
            self.viewShadow.layer.shadowRadius = 3.0
        }
        
    }
}
