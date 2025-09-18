//
//  MyTeamCell.swift
//  - It is the design of Collection View cell to display Team information

//  Tussly
//
//  Created by Auxano on 04/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class MyTeamCell: UICollectionViewCell {

    // MARK: - Controls

    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblTeamName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.ivLogo.layer.cornerRadius = self.ivLogo.frame.size.width/2
        }
    }
}
