//
//  SearchCell.swift
//  Tussly
//
//  Created by Auxano on 20/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class LeagueScheduleCell: UITableViewCell {

    // MARK: - Controls
    
    @IBOutlet weak var lblDay : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    
    var onTapSocialMedia: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapSocialMedia(_ sender: UIButton) {
        if self.onTapSocialMedia != nil {
            self.onTapSocialMedia!(index)
        }
    }
}
