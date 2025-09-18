//
//  ResultSecHeaderView.swift
//  - Custom section header view for Team Results Tableview.

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultSecHeaderView: UITableViewHeaderFooterView {

    // MARK: - Controls
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var ivLeague: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblWL: UILabel!
    @IBOutlet weak var lblStandings: UILabel!
    @IBOutlet weak var lblPlayoffs: UILabel!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var lblTotalWL: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var btnDetail: UIButton!

    // MARK: - Variables
    var openResultDetails: ((Int)->Void)?
    var onTapDetail: (()->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDetail.layer.cornerRadius = 3.0
        ivLeague.layer.cornerRadius = ivLeague.frame.size.width / 2
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapResultDetail(_ sender: UIButton) {
        if openResultDetails != nil {
            openResultDetails!(index)
        }
    }
    
    @IBAction func openDetail(_ sender: UIButton) {
        if onTapDetail != nil {
            onTapDetail!()
        }
    }
    
//    func showAnimation() {
//        ivArrow.showAnimatedSkeleton()
//        lblDate.showAnimatedSkeleton()
//        lblName.showAnimatedSkeleton()
//        lblWL.showAnimatedSkeleton()
//        lblStandings.showAnimatedSkeleton()
//        lblPlayoffs.showAnimatedSkeleton()
//        ivLeague.showAnimatedSkeleton()
//        lblTotalWL.showAnimatedSkeleton()
//        lblNote.showAnimatedSkeleton()
//        btnDetail.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        ivArrow.hideSkeleton()
//        lblDate.hideSkeleton()
//        lblName.hideSkeleton()
//        lblWL.hideSkeleton()
//        lblStandings.hideSkeleton()
//        lblPlayoffs.hideSkeleton()
//        ivLeague.hideSkeleton()
//        lblTotalWL.hideSkeleton()
//        lblNote.hideSkeleton()
//        btnDetail.hideSkeleton()
//    }
    
}
