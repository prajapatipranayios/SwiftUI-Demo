//
//  MenuItemTVCell.swift
//  - Custom cell to display options available within Side Menu.

//  Tussly
//
//  Created by Jaimesh Patel on 26/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MenuItemTVCell: UITableViewCell {

    // MARK: - Controls
    
    @IBOutlet weak var lblMenuItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
