//
//  PlayerTVCell.swift
//  - Designed custom cell to display Player Info within Manage Roster screen

//  Tussly
//
//  Created by Jaimesh Patel on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class PlayerTVCell: UITableViewCell {
    
    // MARK: - Controls
    
    @IBOutlet weak var ivCheck: UIImageView!
    @IBOutlet weak var ivPlayer: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var ivCaptain: UIImageView!
    @IBOutlet weak var widthIvCaptain: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.ivPlayer.layer.cornerRadius = self.ivPlayer.frame.size.height / 2
            self.ivPlayer.clipsToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
