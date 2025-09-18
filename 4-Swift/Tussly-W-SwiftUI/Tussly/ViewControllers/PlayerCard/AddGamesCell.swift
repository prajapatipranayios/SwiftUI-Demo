//
//  AddGamesCell.swift
//  - Designed custom cell to add Games while creating Player Card

//  Tussly
//
//  Created by Auxano on 18/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddGamesCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblGameName : UILabel!
    
    // MARK: - Variables
    
    var onTapRemoveGame: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivLogo.layer.cornerRadius = ivLogo.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapRemoveGames(_ sender: UIButton) {
        if self.onTapRemoveGame != nil {
            self.onTapRemoveGame!(index)
        }
    }

}
