//
//  ResetPasswordVC.swift
//  Tussly
//
//  Created by Auxano on 01/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController,UITextFieldDelegate {
    // MARK: - Controls
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var lblPasswordError : UILabel!
    @IBOutlet weak var lblConfirmPswError : UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    // MARK: - Variables.
    
    var userEmail = ""
    var mobileNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnReset.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblDesc.text = "Create a new password for your account."
    }
    
    // MARK: - UI Methods
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                txtNewPassword.text = txtNewPassword.text?.trimmingCharacters(in: .whitespaces)
                if txtNewPassword.text == "" {
                    lblPasswordError.getEmptyValidationString(txtNewPassword.placeholder ?? "")
                    value = false
                }else {
                    if (txtNewPassword.text?.count)! >= MIN_PASSWORD_LENGTH {
                        lblPasswordError.text = ""
                    }else {
                        lblPasswordError.setLeftArrow(title: Valid_Password)
                        value = false
                    }
                }
            } else if i == 1 {
                if txtConfirmPassword.text == "" {
                    lblConfirmPswError.getEmptyValidationString(txtConfirmPassword.placeholder ?? "")
                    value = false
                } else {
                    if txtNewPassword.text?.trimmedString != txtConfirmPassword.text?.trimmedString {
                        lblConfirmPswError.setLeftArrow(title: Confirm_Password_Not_Match)
                        value = false
                    } else {
                        lblConfirmPswError.text = ""
                    }
                }
            }
        }
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.view.rootNavController.popViewController(animated: true)
    }
    
    @IBAction func onTapResetPassword(_ sender: UIButton) {
        if checkValidation(to: 0, from: 2) {
            view.endEditing(true)
            resetPassword()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
            if textField == txtNewPassword {
                txtConfirmPassword.becomeFirstResponder()
            }else {
                view.endEditing(true)
            }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }

    // MARK: Webservices
    
    func resetPassword() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.resetPassword()
                }
            }
            return
        }
        
        let dictParms = ["email": userEmail != "" ? userEmail : mobileNumber,
                        "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                        "type": userEmail != "" ? "email" : "mobileNo",
                        "password": (txtNewPassword.text?.trimmedString)!,
                        "confirmPassword": (txtConfirmPassword.text?.trimmedString)!] as [String : Any]

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.RESET_PASSWORD, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.view.rootNavController.popToRootViewController(animated: true)
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
