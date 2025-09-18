//
//  TeamVideoCell.swift
//  - To display list of Videos to User within Team Module.

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamVideoCell: UITableViewCell {

    // MARK: - Controls

    @IBOutlet weak var ivVideo: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var ivSelection : UIImageView!

    @IBOutlet weak var viewBtnContainer: UIView!
    @IBOutlet weak var heightViewBtnContainer: NSLayoutConstraint!
    @IBOutlet weak var topLblUserName: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    // By Pranay
    @IBOutlet weak var btnVideo: UIButton!
    var onVideoImgTap: ((Int)->Void)?
    //.

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func showAnimation() {
//        ivVideo.showAnimatedSkeleton()
//        lblDuration.showAnimatedSkeleton()
//        lblTitle.showAnimatedSkeleton()
//        lblUserName.showAnimatedSkeleton()
//        lblTime.showAnimatedSkeleton()
//        lblViews.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivVideo.hideSkeleton()
//        lblDuration.hideSkeleton()
//        lblTitle.hideSkeleton()
//        lblUserName.hideSkeleton()
//        lblTime.hideSkeleton()
//        lblViews.hideSkeleton()
//    }
    
    // By Pranay
    @IBAction func btnVideoTap(_ sender: UIButton) {
        if self.onVideoImgTap != nil {
            self.onVideoImgTap!(sender.tag)
        }
    }
    //.
}
