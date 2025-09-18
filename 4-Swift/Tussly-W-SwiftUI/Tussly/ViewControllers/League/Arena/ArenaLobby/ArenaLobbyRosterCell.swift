//
//  ArenaLobbyRosterCell.swift
//  Tussly
//
//  Created by Jaimesh Patel on 19/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ArenaLobbyRosterCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var ivBg: UIImageView!
    @IBOutlet weak var ivPlayer: UIImageView!
    @IBOutlet weak var ivCaptainCap: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.ivPlayer.layer.cornerRadius = self.ivPlayer.frame.size.width/2
        }
        
    }
    
}
