//
//  AddFriendCell.swift
//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var imgLogo : UIImageView!
    @IBOutlet weak var lblFriendName : UILabel!
    
    // MARK: - Variables
    var onTapRemoveFriend: ((Int,UITableView)->Void)?
    var index = 0
    var strTblName : UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imgLogo.layer.cornerRadius = imgLogo.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapRemoveFriend(_ sender: UIButton) {
        if self.onTapRemoveFriend != nil {
            self.onTapRemoveFriend!(index,strTblName)
        }
    }
}
