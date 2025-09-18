//
//  SearchCell.swift
//  Tussly
//
//  Created by Auxano on 20/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    // MARK: - Controls
    
    @IBOutlet weak var btnAdd : UIButton!
    @IBOutlet weak var lblPlayerName : UILabel!
    @IBOutlet weak var lblTeamName : UILabel!
    @IBOutlet weak var ivProfile : UIImageView!
    
    var onTapBtn: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.height / 2
            self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.height / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapAdd(_ sender: UIButton) {
        if self.onTapBtn != nil {
            self.onTapBtn!(index)
        }
    }
}
