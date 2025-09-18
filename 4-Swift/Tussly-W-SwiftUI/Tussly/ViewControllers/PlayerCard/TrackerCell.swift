//
//  TrackerCell.swift
//  Tussly
//
//  Created by Auxano on 18/08/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class TrackerCell: UITableViewCell {
    
    // MARK: - Controls
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var viewMain : UIView!
    
    // MARK: - Variables
    var onTapRemove: ((Int)->Void)?
    var onTapEdit: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivProfile.layer.cornerRadius = ivProfile.frame.size.width/2
        viewMain.layer.borderWidth = 1.0
        viewMain.layer.cornerRadius = 10
        viewMain.layer.borderColor = Colors.border.returnColor().cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Click Events

    @IBAction func onTapRemove(_ sender: UIButton) {
        if self.onTapRemove != nil {
            self.onTapRemove!(index)
        }
    }
    
    @IBAction func onTapEdit(_ sender: UIButton) {
        if self.onTapEdit != nil {
            self.onTapEdit!(index)
        }
    }
}


