//
//  AddVideoCell.swift
//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import SDWebImage

class AddVideoCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var lblCaption : UILabel!
    @IBOutlet weak var imgCaption : UIImageView!
    @IBOutlet weak var imgPlay : UIImageView!
    
    // MARK: - Variables
    
    var onTapEdit: ((Int)->Void)?
    var onTapRemove: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgPlay.layer.cornerRadius = imgPlay.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapEdit(_ sender : UIButton) {
        if self.onTapEdit != nil {
            self.onTapEdit!(index)
        }
    }
    
    @IBAction func ontRemove(_ sender : UIButton) {
        if self.onTapRemove != nil {
            self.onTapRemove!(index)
        }
    }

}
