//
//  CharCountTVCell.swift
//  Tussly
//
//  Created by MAcBook on 20/06/23.
//  Copyright © 2023 Auxano. All rights reserved.
//

import UIKit

class CharCountTVCell: UITableViewCell {

    @IBOutlet weak var imgCharacter: UIImageView!
    @IBOutlet weak var viewCharName: UIView!
    @IBOutlet weak var lblCharName: UILabel!
    @IBOutlet weak var lblCharLimit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgCharacter.layer.cornerRadius = imgCharacter.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
