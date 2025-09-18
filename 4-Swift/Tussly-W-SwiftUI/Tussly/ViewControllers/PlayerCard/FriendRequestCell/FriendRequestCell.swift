//
//  NotificationsCell.swift
//  - To display information related to notification on table.

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import SwipeCellKit

class FriendRequestCell: SwipeTableViewCell {

    // MARK: - Variables
    var didPressNext: ((Int)->Void)?
    var onTapAccept: ((Int)->Void)?
    var onTapReject: ((Int)->Void)?
    var index = 0
    
    // MARK: - Controls

    @IBOutlet weak var ivNotification: UIImageView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var heightAcceptView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnAccept.layer.cornerRadius = self.btnAccept.frame.height / 2
        self.btnDecline.layer.cornerRadius = self.btnDecline.frame.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.ivNotification.layer.cornerRadius = self.ivNotification.frame.height / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func showAnimation() {
//        ivNotification.showAnimatedSkeleton()
//        btnAccept.showAnimatedSkeleton()
//        btnDecline.showAnimatedSkeleton()
//        lblTitle.showAnimatedSkeleton()
//        lblTime.showAnimatedSkeleton()
//        lblDiscription.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivNotification.hideSkeleton()
//        btnAccept.hideSkeleton()
//        btnDecline.hideSkeleton()
//        lblTitle.hideSkeleton()
//        lblTime.hideSkeleton()
//        lblDiscription.hideSkeleton()
//    }
    
    // MARK: - Button Click Events
    @IBAction func onTapAccept(_ sender: UIButton) {
        if onTapAccept != nil {
            onTapAccept!(index)
        }
    }
    
    @IBAction func onTapReject(_ sender: UIButton) {
        if onTapReject != nil {
            onTapReject!(index)
        }
    }
}
