//
//  SearchPlayerCell.swift
//  Tussly
//
//  Created by Auxano on 26/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddPlayerCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var btnSelection : UIButton!
    
    // MARK: - Variables
    
    var onTapRemovePlayer: ((Int)->Void)?
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
        if self.onTapRemovePlayer != nil {
            self.onTapRemovePlayer!(index)
        }        
    }
}
