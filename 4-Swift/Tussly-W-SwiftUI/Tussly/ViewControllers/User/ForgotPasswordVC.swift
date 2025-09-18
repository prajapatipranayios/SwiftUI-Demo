//
//  ForgotPasswordVC.swift
//  Tussly
//
//  Created by Kishor on 07/10/19.
//  Copyright © 2019 Kishor. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var btnSend : UIButton!
    @IBOutlet weak var lblEmailError : UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    // MARK: - Variables.
    
    var otpToVerify: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblDesc.text = "Enter your email address and we will send you a code to reset your password."
    }
    
    // MARK: - UI Methods
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespaces)
                if txtEmail.text == "" {
                    lblEmailError.getEmptyValidationString(txtEmail.placeholder ?? "")
                    value = false
                }else {
                    /// 444 -   By Pranay
                    if !(txtEmail.text?.isValidEmail())! {
                        lblEmailError.setLeftArrow(title: Valid_Email)
                        value = false
                    } else {
                        lblEmailError.text = ""
                    }   /// 444 .   */
                    /*/// 444 -   Comment by Pranay.
                    if (txtEmail.text?.isNumber)! {
                        if !((txtEmail.text?.count)! >= MIN_MOBILE_LENGTH) {
                            lblEmailError.setLeftArrow(title: Valid_Mobile)
                            value = false
                        } else {
                            lblEmailError.text = ""
                        }
                    }else {
                        if !(txtEmail.text?.isValidEmail())! {
                            lblEmailError.setLeftArrow(title: Valid_Email)
                            value = false
                        } else {
                            lblEmailError.text = ""
                        }
                    }   /// 444 .   */
                }
            }
        }
        
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.view.rootNavController.popViewController(animated: true)
    }
    
    @IBAction func onTapSend(_ sender: UIButton) {
        if checkValidation(to: 0, from: 1) {
            view.endEditing(true)
            callForgotPasswordAPI()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == txtEmail {
            if (txtEmail.text?.isNumber)! {
                return newString.length <= MAX_MOBILE_LENGTH
            }else {
                return true
            }
        }else {
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmail.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkValidation(to: 0, from: 1) {
        }
    }
    
    // MARK: Webservices
    
    func callForgotPasswordAPI() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.callForgotPasswordAPI()
                }
            }
            return
        }
        
        let userName = txtEmail.text!
        
        let dictParms = ["email": userName,
                        "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                        "type": userName.isNumber ? "mobileNo" : "email"]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FORGOT_PASSWORD, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.otpToVerify = (response?.result?.otp)!
                DispatchQueue.main.async {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                    objVC.isForgotPassword = true
                    objVC.responseOTP = Int(self.otpToVerify)!
                    objVC.userEmail = userName.isNumber ? "" : userName
                    objVC.mobileNumber = userName.isNumber ? userName : ""
                    self.view.rootNavController.pushViewController(objVC, animated: true)
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
