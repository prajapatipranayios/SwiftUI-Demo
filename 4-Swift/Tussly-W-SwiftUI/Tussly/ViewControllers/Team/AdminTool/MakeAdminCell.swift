//
//  MakeAdminCell.swift
//  - This Cell is used to display Player Information along with his/her Role

//  Tussly
//
//  Created by Auxano on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MakeAdminCell: UITableViewCell {
    
    // MARK: - Controls
    @IBOutlet weak var btnSelect : UIButton!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblRole : UILabel!
    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var viewDisable: UIView!
    
    // MARK: - Variables
    var onTapAdminCell: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivProfile.layer.cornerRadius = ivProfile.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Button Click Events

    @IBAction func onTapSelection(_ sender: UIButton) {
        if self.onTapAdminCell != nil {
            self.onTapAdminCell!(index)
        }
    }
    
//    func showAnimation() {
//        lblName.showAnimatedSkeleton()
//        lblRole.showAnimatedSkeleton()
//        ivProfile.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblName.hideSkeleton()
//        lblRole.hideSkeleton()
//        ivProfile.hideSkeleton()
//    }
}
