//
//  FriendListCell.swift
//  Tussly
//
//  Created by Auxano on 14/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class FriendListCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var btnSelection : UIButton!
    @IBOutlet weak var lblName : UILabel!
    
    // MARK: - Variables
    
    var onTapGameCell: ((Int)->Void)?
    var onTapFriendCell: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapSelection(_ sender: UIButton) {
        if self.onTapFriendCell != nil {
            self.onTapFriendCell!(index)
        }
        
        if self.onTapGameCell != nil {
            self.onTapGameCell!(index)
        }
    }
}
