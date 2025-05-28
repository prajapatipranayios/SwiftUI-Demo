//
//  AddNewCardVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 28/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CCValidator


class AddNewCardVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    
    @IBOutlet weak var btnAdd: UIButton!
    
    var cardType = ""
    
    var updateFrame: ((CGFloat)->Void)?
    var removePanel: ((Card)->Void)?
    
    var showError: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    func setupUI() {
        for view in viewBack {
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
        btnAdd.layer.cornerRadius = btnAdd.frame.size.height / 2
        
        btnAdd.isUserInteractionEnabled = false
        btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        var value = true
        for tf in textFields {
            if tf.text?.trimmedString == "" {
                value = false
                break
            }
        }
        
        if value == true {
            btnAdd.backgroundColor = Colors.orange.returnColor()
            btnAdd.isUserInteractionEnabled = true
        }else {
            btnAdd.isUserInteractionEnabled = false
            btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                if textFields[0].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if !(CCValidator.validate(creditCardNumber: textFields[i].text!)) {
                        lblError[i].setLeftArrow(title: Valid_Card_Number)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            }else if i == 1 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if textFields[i].text!.count < 5 {
                        lblError[i].setLeftArrow(title: Valid_Card_ExpiryDate)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            }else if i == 2 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if textFields[i].text!.count < 3 {
                        lblError[i].setLeftArrow(title: Valid_Card_CVV)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            }else if i == 3 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            }
        }
        
        if updateFrame != nil {
            self.dismiss(animated: false) {
                self.updateFrame!(self.viewContent.frame.height)
            }
        }
        
        return value
    }
    
    @IBAction func textFieldDidChanges(_ textField: UITextField) {
        if textField == textFields[0] {
            textField.text = textField.text?.grouping(every: 4, with: " ")
        }else if textField == textFields[1] {
            textField.text = textField.text?.grouping(every: 2, with: "/")
        }
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapAdd(_ sender: UIButton) {
        if checkValidation(to: 0, from: 4) {
            self.submitCardDetails()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Web services
    
    func submitCardDetails() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.submitCardDetails()
                }
            }
            return
        }
        
        let dictParams: Dictionary<String, Any> = [
            "cardNumber" : textFields[0].text!,
            "expiryMonth": textFields[1].text!.split(separator: "/")[0],
            "expiryYear": textFields[1].text!.split(separator: "/")[1],
            "cvc": textFields[2].text!,
            "name": textFields[3].text!,
            "addressLine1": "42 Sevenoaks St",
            "addressCity": "Lathlain",
            "addressCountry": "Australia"
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ADD_CARD, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.removePanel != nil {
                        self.removePanel!((response?.result?.userCardData)!)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
}

extension AddNewCardVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblError[textField.tag].text = ""
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField != textFields[3] {
            if (string == " ") {
                return false
            }
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == textFields[0] {
            switch CCValidator.typeCheckingPrefixOnly(creditCardNumber: newString as String).rawValue {
                case 0:
                    cardType = "American Express"
                case 1:
                    cardType = "Dankort"
                case 2:
                    cardType = "Diners Club"
                case 3:
                    cardType = "Discover"
                case 4:
                    cardType = "JCB"
                case 5:
                    cardType = "Maestro"
                case 6:
                    cardType = "MasterCard"
                case 7:
                    cardType = "UnionPay"
                case 8:
                    cardType = "Visa Electron"
                case 9:
                    cardType = "Visa"
                case 10:
                    cardType = ""
                default:
                    cardType = ""
            }
                        
            return newString.length <= 23
        }else if textField == textFields[1] {
            if newString.length == 1 {
                return newString.intValue <= 1
            }else if newString.length == 2 {
                return newString.intValue <= 12 && newString.intValue != 0
            }else if newString.length == 5 {
                let date = Date()
                return (newString.length <= 5) &&
                    (Int((newString as String).suffix(2)) ?? 0 >= Int(date.year) ?? 0) &&
                    (Int((newString as String).suffix(2)) ?? 0 == Int(date.year) ?? 0 ? (Int((newString as String).prefix(2)) ?? 0 >= Int(date.month) ?? 0) : true)
            }
            
            return newString.length <= 5
        }else if textField == textFields[2] {
            return newString.length <= 4
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == textFields[0] {
            textFields[1].becomeFirstResponder()
        } else if textField == textFields[1] {
            textFields[2].becomeFirstResponder()
        } else if textField == textFields[2] {
            textFields[3].becomeFirstResponder()
        } else if textField == textFields[3] {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
}
