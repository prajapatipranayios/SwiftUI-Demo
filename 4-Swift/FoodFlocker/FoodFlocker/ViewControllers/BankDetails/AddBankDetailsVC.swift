//
//  AddBankDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/05/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class AddBankDetailsVC: UIViewController {

    //Outlets
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var btnAdd: UIButton!
    
    var bankDetails: BankDetail?
    var updateFrame: ((CGFloat)->Void)?
    var removePanel: ((BankDetail)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
        
        if bankDetails != nil {
//            textFields[0].text = bankDetails?.bank_account.number
            textFields[1].text = bankDetails?.bank_account.bsb
            textFields[2].text = bankDetails?.bank_account.name
            
            btnAdd.setTitle("Update", for: .normal)
        }
    }
    
    func setupUI() {
        for view in viewBack {
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
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
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    if (textFields[i].text?.isNumber)! {
//                        if !((textFields[i].text?.count)! >= MIN_BANK_ACC_NO_LENGTH) {
//                            lblError[i].setLeftArrow(title: Valid_Bank_Acc_No)
//                            value = false
//                            //
//                            viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
//                            textFields[i].titleTextColour = Colors.red.returnColor()
//                            //
//                        }
//                        else {
                            lblError[i].text = ""
                            //
                            viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                            textFields[i].setAttributedTitle(Colors.gray.returnColor())
                            //
//                        }
                    }else {
                        lblError[i].setLeftArrow(title: Valid_Bank_Acc_No)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                    }
                }
            } else if i == 1 {
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
                }
            } else if i == 2 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[i].text?.count)! >= MIN_USERNAME_LENGTH {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    } else {
                        lblError[i].text = Valid_Name
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }
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
    
    // MARK: - Button Click Events

    @IBAction func onTapAdd(_ sender: UIButton) {
        if checkValidation(to: 0, from: 3) {
            self.submitBankDetails()
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

    // MARK: - Webservices

    func submitBankDetails() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.submitBankDetails()
                }
            }
            return
        }
        
        let dictParams = ["name": textFields[2].text!,
                          "bsb": textFields[1].text!,
                          "number": textFields[0].text!] as [String: Any]
        
        let url = bankDetails != nil ? APIManager.sharedManager.UPDATE_BANK_DETAIL : APIManager.sharedManager.ADD_BANK_DETAIL
        
        showLoading()
        APIManager.sharedManager.postData(url: url, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.removePanel != nil {
                        self.removePanel!((response?.result?.userBankAccountDetail)!)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension AddBankDetailsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblError[textField.tag].text = ""
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == textFields[0] {
            return newString.length <= MAX_BANK_ACC_NO_LENGTH
        }else if textField == textFields[2] {
            return newString.length <= MAX_USERNAME_LENGTH
        }else if textField == textFields[1] {
            return newString.length <= MAX_MOBILE_LENGTH
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
