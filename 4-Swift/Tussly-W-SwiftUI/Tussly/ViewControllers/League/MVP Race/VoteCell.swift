//
//  VoteCell.swift
//  - Designed custom cell for Vote screen

//  Tussly
//
//  Created by Auxano on 23/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class VoteCell: UITableViewCell {
    // MARK: - Controls

    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var btnSelection : UIButton!
    @IBOutlet weak var lblName : UILabel!
    
    // MARK: - Variables

    var onTapVoteCell: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivProfile.layer.cornerRadius = ivProfile.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapSelection(_ sender: UIButton) {
        if self.onTapVoteCell != nil {
            self.onTapVoteCell!(index)
        }
    }
}
