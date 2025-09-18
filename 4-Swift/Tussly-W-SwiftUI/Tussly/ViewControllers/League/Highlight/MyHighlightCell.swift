//
//  MyHighlightCell.swift
//  - Designed custom cell for displaying Highlight videos for User logged in

//  Tussly
//
//  Created by Auxano on 23/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MyHighlightCell: UICollectionViewCell {
    
    // MARK: - Controls
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var ivVideo: UIImageView!
    @IBOutlet weak var lblVideoName : UILabel!
    @IBOutlet weak var lblPlayerName: UILabel!
    
//    func showAnimation() {
//        btnDelete.showAnimatedSkeleton()
//        btnPlay.showAnimatedSkeleton()
//        ivVideo.showAnimatedSkeleton()
//        lblVideoName.showAnimatedSkeleton()
//        lblPlayerName.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        btnDelete.hideSkeleton()
//        btnPlay.hideSkeleton()
//        ivVideo.hideSkeleton()
//        lblVideoName.hideSkeleton()
//        lblPlayerName.hideSkeleton()
//    }
}
