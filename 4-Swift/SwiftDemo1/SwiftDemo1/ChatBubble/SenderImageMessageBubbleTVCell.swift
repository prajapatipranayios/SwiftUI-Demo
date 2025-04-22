//
//  SenderMessageBubbleTVCell.swift
//  Tussly
//
//  Created by Auxano on 17/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit

class SenderImageMessageBubbleTVCell: UITableViewCell {

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
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var ivImage: UIImageView! {
        didSet {
            self.ivImage.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var constraintHeightIvImage: NSLayoutConstraint!
    @IBOutlet weak var constraintTopViewMsgToSuper: NSLayoutConstraint!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var ivMsgStatus: UIImageView!
    
    //@IBOutlet weak var lblMsg: UILabel!
    //@IBOutlet weak var lblEdited: UILabel!
    //@IBOutlet weak var constraintTopLblTimeToViewMsg: NSLayoutConstraint!
    
    
    // MARK: - Variable
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 9
        self.viewMsg.backgroundColor = Colors.theme.returnColor()
        
        self.viewDateSection.backgroundColor = .white
        //self.lblEdited.textColor = .white
        self.lblTime.textColor = .white
        //self.lblEdited.isHidden = true
        //self.constraintTopLblTimeToViewMsg.priority = .required
        
        self.ivMsgStatus.image = UIImage(named: "MsgSend")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
}
