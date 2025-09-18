//
//  TeamPlayerCell.swift
//  Tussly
//
//  Created by Auxano on 03/12/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class TeamPlayerCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblRWRL: UILabel!
    @IBOutlet weak var lblWL: UILabel!
    @IBOutlet weak var lblS: UILabel!
    @IBOutlet weak var lblLabel1: UILabel!
    @IBOutlet weak var lblLabel2: UILabel!
    @IBOutlet weak var lblLabel3: UILabel!
    @IBOutlet weak var lblLabel4: UILabel!
    @IBOutlet weak var viewHeader: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.height / 2
        }
    }
}
