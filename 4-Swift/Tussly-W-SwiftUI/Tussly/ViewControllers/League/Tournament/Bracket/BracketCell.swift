//
//  BracketCell.swift
//  Tussly
//
//  Created by Auxano on 24/09/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class BracketCell: UITableViewCell {

    // MARK: - Controls
    @IBOutlet weak var imgNextPlayer2: UIImageView!
    @IBOutlet weak var imgNextPlayer1: UIImageView!
    @IBOutlet weak var lblNextMatchTime: UILabel!
    @IBOutlet weak var lblNextGame: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewBottomLine: UIView!
    @IBOutlet weak var viewScore: UIView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var lblPlayer1Score: UILabel!
    @IBOutlet weak var lblPlayer2Score: UILabel!
    @IBOutlet weak var lblPlayer1: UILabel!
    @IBOutlet weak var lblPlayer2: UILabel!
    @IBOutlet weak var lblPlayer1TeamNo: UILabel!
    @IBOutlet weak var lblPlayer2TeamNo: UILabel!
    @IBOutlet weak var btnPlayer1Next: UIButton!
    @IBOutlet weak var btnPlayer2Next: UIButton!
    @IBOutlet weak var lblMyGame: UILabel!
    @IBOutlet weak var lblForfeit: UILabel!
    @IBOutlet weak var player1Trailing : NSLayoutConstraint!
    
    var onTapBoxScore: ((Int)->Void)?
    var onTapAwayMatch: ((Int)->Void)?
    var onTapHomeMatch: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewScore.layer.cornerRadius = 4
        viewScore.layer.borderWidth = 1
        viewScore.layer.borderColor = UIColor.lightGray.cgColor
        
        lblMyGame.layer.cornerRadius = 12
        lblMyGame.clipsToBounds = true
        
        imgNextPlayer1.layer.cornerRadius = imgNextPlayer1.frame.size.height / 2
        imgNextPlayer2.layer.cornerRadius = imgNextPlayer2.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapScore(_ sender: UIButton) {
        if self.onTapBoxScore != nil {
            self.onTapBoxScore!(index)
        }
    }
    
    @IBAction func onTapHome(_ sender: UIButton) {
        if self.onTapHomeMatch != nil {
            self.onTapHomeMatch!(index)
        }
    }
    
    @IBAction func onTapAWay(_ sender: UIButton) {
        if self.onTapAwayMatch != nil {
            self.onTapAwayMatch!(index)
        }
    }
    
//    func showAnimation() {
//        imgNextPlayer2.showAnimatedSkeleton()
//        imgNextPlayer1.showAnimatedSkeleton()
//        lblNextMatchTime.showAnimatedSkeleton()
//        lblNextGame.showAnimatedSkeleton()
//        viewTime.showAnimatedSkeleton()
//        viewScore.showAnimatedSkeleton()
//        lblPlayer1Score.showAnimatedSkeleton()
//        lblPlayer2Score.showAnimatedSkeleton()
//        lblPlayer1TeamNo.showAnimatedSkeleton()
//        lblPlayer2TeamNo.showAnimatedSkeleton()
//        btnPlayer1Next.showAnimatedSkeleton()
//        btnPlayer2Next.showAnimatedSkeleton()
//        lblMyGame.showAnimatedSkeleton()
//        lblForfeit.showAnimatedSkeleton()
//    }
//    
//    func hideAnimation() {
//        imgNextPlayer2.hideSkeleton()
//        imgNextPlayer1.hideSkeleton()
//        lblNextMatchTime.hideSkeleton()
//        lblNextGame.hideSkeleton()
//        viewTime.hideSkeleton()
//        viewScore.hideSkeleton()
//        lblPlayer1Score.hideSkeleton()
//        lblPlayer2Score.hideSkeleton()
//        lblPlayer1TeamNo.hideSkeleton()
//        lblPlayer2TeamNo.hideSkeleton()
//        btnPlayer1Next.hideSkeleton()
//        btnPlayer2Next.hideSkeleton()
//        lblMyGame.hideSkeleton()
//        lblForfeit.hideSkeleton()
//    }
}

