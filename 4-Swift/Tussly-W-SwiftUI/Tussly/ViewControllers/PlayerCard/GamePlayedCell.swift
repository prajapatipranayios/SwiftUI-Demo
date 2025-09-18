//
//  GamePlayedCell.swift
//  Tussly
//
//  Created by Auxano on 17/08/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class GamePlayedCell: UITableViewCell {
    
    // MARK: - Controls
    @IBOutlet weak var btnRemove : UIButton!
    @IBOutlet weak var lblGame : UILabel!
    @IBOutlet weak var ivProfile : UIImageView!
    
    // MARK: - Variables
    var onTapRemove: ((Int)->Void)?
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
        if self.onTapRemove != nil {
            self.onTapRemove!(index)
        }
    }
    
//    func showAnimation() {
//        btnRemove.showAnimatedSkeleton()
//        lblGame.showAnimatedSkeleton()
//        ivProfile.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        btnRemove.hideSkeleton()
//        lblGame.hideSkeleton()
//        ivProfile.hideSkeleton()
//    }
}

