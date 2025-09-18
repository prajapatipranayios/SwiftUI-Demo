//
//  SelectGamertagCellDelegate.swift
//  - Custom cell to allow user to select Gamer Tag from available.

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//


import UIKit

class SelectGamertagCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var btnGameName: UIButton!
    @IBOutlet weak var viewBottom: UIView!
    
    // MARK: - Variables
    var onTapGamerCell: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnGameName.layer.cornerRadius = 15.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func didPressTitle(_ sender: UIButton) {
        if self.onTapGamerCell != nil {
            self.onTapGamerCell!(index)
        }
    }
}
