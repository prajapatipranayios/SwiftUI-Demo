//
//  TeamRosterTVCell.swift
//  - Designed custom cell to display players like Founder, Admin, & Member as well

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamRosterTVCell: UITableViewCell {

    // MARK: - Controls

    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblRole : UILabel!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var btnOption : UIButton!
    @IBOutlet weak var constraintTrailBtnRightToSuperView: NSLayoutConstraint!
    
    
    var onTapBtn: ((Int)->Void)?
    var onTapOptionBtn: ((Int)->Void)?
    var index = 0
     
    override func awakeFromNib() {
        super.awakeFromNib()
        ivProfile.layer.cornerRadius = ivProfile.frame.size.width/2
        
        self.constraintTrailBtnRightToSuperView.priority = .required
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapRightButton(_ sender: UIButton) {
        if self.onTapBtn != nil {
            self.onTapBtn!(index)
        }
    }
    
    @IBAction func btnOptionTap(_ sender: UIButton) {
        if self.onTapOptionBtn != nil {
            self.onTapOptionBtn!(index)
        }
    }
    
//    func showAnimation() {
//        ivProfile.showAnimatedSkeleton()
//        lblName.showAnimatedSkeleton()
//        lblRole.showAnimatedSkeleton()
//        btnRight.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivProfile.hideSkeleton()
//        lblName.hideSkeleton()
//        lblRole.hideSkeleton()
//        btnRight.hideSkeleton()
//    }
}
