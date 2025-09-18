//
//  DropDownCell.swift
//  Tussly
//
//  Created by Auxano on 17/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var ivLeagueIcon : UIImageView!
    @IBOutlet weak var lblLeagueName: UILabel!
    @IBOutlet weak var lblWeekDay: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ivLeagueIcon.layer.cornerRadius = ivLeagueIcon.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
