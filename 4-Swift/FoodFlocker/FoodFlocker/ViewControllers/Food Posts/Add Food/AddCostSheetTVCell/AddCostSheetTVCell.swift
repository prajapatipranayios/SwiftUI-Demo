//
//  AddCostSheetTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class AddCostSheetTVCell: UITableViewCell {

    //Outlets
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!

    var updateCostingSheet: ((String, Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension AddCostSheetTVCell: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 1 {
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }

            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1

            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }

            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2 && newString.length <= MAX_QUANTITY_LENGTH
        } else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            viewBack[textField.tag].layer.borderColor = Colors.lightGray.returnColor().cgColor
            textFields[textField.tag].setAttributedTitle(Colors.lightGray.returnColor())
        }else {
            viewBack[textField.tag].layer.borderColor = Colors.gray.returnColor().cgColor
            textFields[textField.tag].setAttributedTitle(Colors.gray.returnColor())
        }
        
        textField.text = textField.text?.trimmedString
        if updateCostingSheet != nil {
            updateCostingSheet!(textField.text!, textField.tag)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        switch textField.tag {
            case 0:
                textFields[1].becomeFirstResponder()
                break
            default:
                self.contentView.endEditing(true)
                break
        }
        return true
    }
    
}
