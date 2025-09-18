//
//  SelectGameCell.swift
//  - Designed custom cell for Select Game option

//  Tussly
//
//  Created by Auxano on 18/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SelectGameCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var btnSelection : UIButton!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var ivLogo : UIImageView!
    
    // MARK: - Variables
    
    var onTapGameCell: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivLogo.layer.cornerRadius = ivLogo.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapSelection(_ sender: UIButton) {
        if self.onTapGameCell != nil {
            self.onTapGameCell!(index)
        }
    }

}
