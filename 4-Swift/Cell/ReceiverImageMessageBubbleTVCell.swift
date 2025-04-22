//
//  ReceiverMessageBubbleTVCell.swift
//  Tussly
//
//  Created by Auxano on 17/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit

class ReceiverImageMessageBubbleTVCell: UITableViewCell {

    // MARK: - Outlet
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewDateSection: UIView! {
        didSet {
            self.viewDateSection.clipsToBounds = true
            self.viewDateSection.backgroundColor = .white
            self.viewDateSection.roundCornersWithShadow(cornerRadius: 9.0,
                                                        shadowColor: .clear,
                                                        shadowOffset: .zero,
                                                        shadowOpacity: 0,
                                                        shadowRadius: 0,
                                                        borderWidth: 1.0,
                                                        borderColor: UIColor(hexString: "#C8C8C8", alpha: 1.0))
        }
    }
    @IBOutlet weak var lblDateSection: UILabel! {
        didSet {
            //self.lblDateSection.textColor = .darkGray
            self.lblDateSection.textColor = UIColor(hexString: "#696969", alpha: 1.0)
        }
    }
    @IBOutlet weak var ivUserAvatar: UIImageView! {
        didSet {
            self.ivUserAvatar.layer.cornerRadius = self.ivUserAvatar.frame.width / 2
        }
    }
    @IBOutlet weak var lblUserName: UILabel! {
        didSet {
            self.lblUserName.textColor = Colors.theme.returnColor()
        }
    }
    @IBOutlet weak var constraintTopLblUserNameToSuper: NSLayoutConstraint!
    @IBOutlet weak var constraintTopLblUserNameToViewDateSection: NSLayoutConstraint!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var ivImage: UIImageView! {
        didSet {
            self.ivImage.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var constraintHeightIvImage: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var constraintTopViewMsgToSuper: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingViewMsgToSuper: NSLayoutConstraint!
    //@IBOutlet weak var constTopMsgToUser: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewMsgToViewDateSection: NSLayoutConstraint!
    
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblEdited: UILabel!
    @IBOutlet weak var constTopMsg: NSLayoutConstraint!
    @IBOutlet weak var constraintTopLblTimeToViewMsg: NSLayoutConstraint!
    
    
    // MARK: - Variable
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 5
        //self.viewMsg.backgroundColor = .lightGray
        self.viewMsg.backgroundColor = UIColor(hexString: "#696969", alpha: 1.0)
        
        //self.lblUserName.textColor = Colors.theme.returnColor()
        self.lblUserName.isHidden = true
        //self.constTopMsg.priority = .required
        
        self.lblMsg.textColor = .white
        self.lblEdited.textColor = .white
        self.lblEdited.isHidden = true
        //self.constraintTopLblTimeToViewMsg.priority = .required
        
        self.lblTime.textColor = .white
        
        /// Default settings for one to one chat
        // Default 1000(required) for one to one chat
        // Change to 250(low) for group chat
        self.ivUserAvatar.isHidden = true
        self.lblUserName.isHidden = true
        //self.constraintTopLblUserNameToSuper.priority = .defaultLow
        self.constraintTopViewMsgToViewDateSection.priority = .required
        self.constraintLeadingViewMsgToSuper.priority = .required
        
        DispatchQueue.main.async {
            self.constraintHeightIvImage.constant = self.contentView.frame.width * 0.65
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
