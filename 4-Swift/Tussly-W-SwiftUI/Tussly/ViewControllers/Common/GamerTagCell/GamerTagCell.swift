//
//  GamerCell.swift
//  Tussly
//
//  Created by Auxano on 04/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class GamerTagCell: UITableViewCell , UITextFieldDelegate{
    
    // MARK: - Controls
    @IBOutlet weak var txtPlaystation: TLTextField!
    @IBOutlet weak var lblSwitchStatus: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var constraintStatusWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintStatusLeading: NSLayoutConstraint!
    
    
    // MARK: - Variables
    var onTapRemovePlaystation: ((Int,Int)->Void)?
    var getPlaystationName: ((String,Int,Int)->Void)?
    var onTapSwitch: ((String,Int,Int)->Void)?
    var index = 0
    var section = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtPlaystation.titleFont = Fonts.Regular.returnFont(size: 5.0)
        txtPlaystation.title.isHidden = true
        constraintStatusWidth.constant = 0
        constraintStatusLeading.constant = 0
        lblSwitchStatus.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapRemoveName(_ sender: UIButton) {
        if self.onTapRemovePlaystation != nil {
            self.onTapRemovePlaystation!(index,section)
        }
    }
    
    @IBAction func onTapStatus(_ sender: UIButton) {
        if self.onTapSwitch != nil {
            self.onTapSwitch!(sender.isSelected == false ? "Private" : "Public",index,section)
        }
    }
    
    // MARK: UITextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.getPlaystationName != nil {
            self.getPlaystationName!(textField.text ?? "",index,section)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
}
