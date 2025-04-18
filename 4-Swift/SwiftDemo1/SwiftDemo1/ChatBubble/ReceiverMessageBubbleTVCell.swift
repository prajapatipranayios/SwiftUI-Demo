//
//  ReceiverMessageBubbleTVCell.swift
//  Tussly
//
//  Created by Auxano on 17/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit

class ReceiverMessageBubbleTVCell: UITableViewCell {

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
                                                        borderColor: .black.withAlphaComponent(0.6))
        }
    }
    @IBOutlet weak var lblDateSection: UILabel!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var constraintTopViewMsgToSuper: NSLayoutConstraint!
    @IBOutlet weak var lblEdited: UILabel!
    @IBOutlet weak var constTopMsg: NSLayoutConstraint!
    @IBOutlet weak var constTopMsgToUser: NSLayoutConstraint!
    @IBOutlet weak var constraintTopLblTimeToViewMsg: NSLayoutConstraint!
    
    
    // MARK: - Variable
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMsg.layer.cornerRadius = 5
        //self.viewMsg.backgroundColor = .lightGray
        self.viewMsg.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        self.lblUserName.textColor = .white
        self.lblUserName.isHidden = true
        self.constTopMsg.priority = .required
        
        self.lblMsg.textColor = .white
        self.lblEdited.textColor = .white
        self.lblEdited.isHidden = true
        self.constraintTopLblTimeToViewMsg.priority = .required
        
        self.lblTime.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
