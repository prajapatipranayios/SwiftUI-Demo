//
//  FilterResultcell.swift
//  Tussly
//
//  Created by Auxano on 10/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class FilterResultCell: UICollectionViewCell {

    //MARK: - Control
    @IBOutlet weak var lblRWRL: UILabel!
    @IBOutlet weak var lblRW: UILabel!
    @IBOutlet weak var lblStock: UILabel!
    @IBOutlet weak var viewMain: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    func showAnimation() {
//        lblRWRL.showAnimatedSkeleton()
//        lblRW.showAnimatedSkeleton()
//        lblStock.showAnimatedSkeleton()
//        viewMain.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        lblRWRL.hideSkeleton()
//        lblRW.hideSkeleton()
//        lblStock.hideSkeleton()
//        viewMain.hideSkeleton()
//    }
}
