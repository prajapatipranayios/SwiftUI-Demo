//
//  ChangePasswordVC.swift
//  Tussly
//
//  Created by Auxano on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
    // MARK: - Controls
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var btnUpdatePassword: UIButton!
    @IBOutlet weak var lblCurrentPswError : UILabel!
    @IBOutlet weak var lblNewPswError : UILabel!
    @IBOutlet weak var lblConfirmNewPswError : UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdatePassword.layer.cornerRadius = 15.0
    }
    
    // MARK: - UI Methods
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                txtCurrentPassword.text = txtCurrentPassword.text?.trimmingCharacters(in: .whitespaces)
                if txtCurrentPassword.text == "" {
                    lblCurrentPswError.getEmptyValidationString(txtCurrentPassword.placeholder ?? "")
                    value = false
                }else {
                    if (txtCurrentPassword.text?.count)! >= MIN_PASSWORD_LENGTH {
                        lblCurrentPswError.text = ""
                    }else {
                        lblCurrentPswError.setLeftArrow(title: Valid_Password)
                        value = false
                    }
                }
            } else if i == 1 {
                txtNewPassword.text = txtNewPassword.text?.trimmingCharacters(in: .whitespaces)
                if txtNewPassword.text == "" {
                    lblNewPswError.getEmptyValidationString(txtNewPassword.placeholder ?? "")
                    value = false
                }else {
                    if (txtNewPassword.text?.count)! >= MIN_PASSWORD_LENGTH {
                        lblNewPswError.text = ""
                    }else {
                        lblNewPswError.setLeftArrow(title: Valid_Password)
                        value = false
                    }
                }
            }else if i == 2 {
                txtConfirmPassword.text = txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces)
                if txtConfirmPassword.text == "" {
                    lblConfirmNewPswError.getEmptyValidationString(txtConfirmPassword.placeholder ?? "")
                    value = false
                }else {
                    if (txtConfirmPassword.text?.count)! >= MIN_PASSWORD_LENGTH {
                        if txtNewPassword.text?.trimmedString != txtConfirmPassword.text {
                            lblConfirmNewPswError.setLeftArrow(title: Confirm_Password_Not_Match)
                            value = false
                        }else {
                            lblConfirmNewPswError.text = ""
                        }
                    }else {
                        lblConfirmNewPswError.setLeftArrow(title: Valid_Password)
                        value = false
                    }
                    
                }
            }
        }
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapUpdatePassword(_ sender: UIButton) {
        if checkValidation(to: 0, from: 3) {
            view.endEditing(true)
            changePassword()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
            if textField == txtCurrentPassword {
                txtNewPassword.becomeFirstResponder()
            } else if textField == txtNewPassword {
                txtConfirmPassword.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == txtCurrentPassword {
            return newString.length <= MAX_PASSWORD_LENGTH
        }else if textField == txtNewPassword {
            return newString.length <= MAX_PASSWORD_LENGTH
        }else if textField == txtConfirmPassword {
            return newString.length <= MAX_PASSWORD_LENGTH
        }else {
            return true
        }
    }
    
    // MARK: - Webservices
    
    func changePassword() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changePassword()
                }
            }
            return
        }
        
        showLoading()
        let params = ["oldPassword": (txtCurrentPassword.text?.trimmedString)!,
                      "newPassword": (txtNewPassword.text?.trimmedString)!,
                      "confirmPassword": (txtConfirmPassword.text?.trimmedString)!]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_PASSWORD, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
//                    var param = UserDefaults.standard.value(forKey: UserDefaultType.logInParameters)! as! Dictionary<String, Any>
//                    param.updateValue((self.txtNewPassword.text?.trimmedString)!, forKey: "password")
//                    UserDefaults.standard.set(param, forKey: UserDefaultType.logInParameters)
//                    UserDefaults.standard.synchronize()
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
