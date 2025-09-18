//
//  ArenaInfoDataCell.swift
//  Tussly
//
//  Created by Auxano on 22/10/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class ArenaInfoDataCell: UITableViewCell {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblOverview: UILabel!
    @IBOutlet weak var imgInfo: UIImageView!
    @IBOutlet weak var viewOverview: UIView!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
