//
//  AddFriendByEmailCell.swift
//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class AddFriendByEmailCell: UITableViewCell ,UITextFieldDelegate {
    // MARK: - Controls
    
    @IBOutlet weak var txtEmailOrPhone : TLTextField!
    @IBOutlet weak var lblEmailOrPhoneError : UILabel!
    
    // MARK: - Variables
    var onTapAddFriendByEmail: ((String,Int)->Void)?
    var onTapRemoveFriend: ((Int)->Void)?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtEmailOrPhone.titleFont = Fonts.Regular.returnFont(size: 5.0)
        txtEmailOrPhone.title.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UI Methods
    func checkValidation() {
        if txtEmailOrPhone.text == "" {
            lblEmailOrPhoneError.getEmptyValidationString(txtEmailOrPhone.placeholder ?? "")
        }else {
            if !(txtEmailOrPhone.text?.isValidEmail())! {
                lblEmailOrPhoneError.setLeftArrow(title: Valid_Email)
            } else {
                lblEmailOrPhoneError.text = ""
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapRemoveFriend(_ sender: UIButton) {
        if self.onTapRemoveFriend != nil {
            self.onTapRemoveFriend!(index)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.onTapAddFriendByEmail != nil {
            self.onTapAddFriendByEmail!(textField.text ?? "",index)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
}
