//
//  MyLeagueCell.swift
//  Tussly
//
//  Created by Auxano on 19/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class MyLeagueCell: UICollectionViewCell {

    @IBOutlet weak var lblTournament : UILabel!
    @IBOutlet weak var lblTournamentName : UILabel!
    @IBOutlet weak var ImgTournament : UIImageView!
    @IBOutlet weak var imgLogo : UIImageView!
    @IBOutlet weak var imgGameLogo : UIImageView!
    @IBOutlet weak var lblTeamName : UILabel!
    @IBOutlet weak var lblMatchDate : UILabel!
    @IBOutlet weak var lblMatchTime : UILabel!
    @IBOutlet weak var viewNextLiveleague: UIView!
    @IBOutlet weak var lblLeagueStatus : UILabel!
    @IBOutlet weak var lblTBD : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.contentView.layer.cornerRadius = 15.0
            self.imgGameLogo.layer.cornerRadius = self.imgGameLogo.frame.size.height/2
            self.ImgTournament.layer.cornerRadius = self.ImgTournament.frame.size.height/2
            self.ImgTournament.clipsToBounds = true
            
            let view = UIView(frame: self.imgLogo.frame)
            let gradient = CAGradientLayer()
            gradient.frame = view.frame
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
            gradient.locations = [0.0, 1.0]
            view.layer.insertSublayer(gradient, at: 0)
            self.imgLogo.addSubview(view)
            self.imgLogo.bringSubviewToFront(view)
        }
    }
}

