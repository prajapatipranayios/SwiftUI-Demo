//
//  SearchCell.swift
//  Tussly
//
//  Created by Auxano on 20/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SocialMediaCell: UITableViewCell {

    // MARK: - Controls
    
    @IBOutlet weak var lblSocialMediaName : UILabel!
    @IBOutlet weak var ivSocialMedia : UIImageView!
    
    var onTapSocialMedia: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.ivSocialMedia.layer.cornerRadius = self.ivSocialMedia.frame.size.height / 2
        }
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
