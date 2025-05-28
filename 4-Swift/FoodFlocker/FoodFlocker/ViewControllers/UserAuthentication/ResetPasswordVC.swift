//
//  ResetPasswordVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 22/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!

//    @IBOutlet weak var tfPass: FFTextField!
//    @IBOutlet weak var lblPassError: UILabel!
//    @IBOutlet weak var tfConfirmPass: FFTextField!
//    @IBOutlet weak var lblConfirmPassError: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    // MARK: - Variables.
    var userEmail = ""
    var mobileNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        tfPass.delegate = self
//        tfConfirmPass.delegate = self
        
        for view in viewBack {
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
        }
        btnNext.layer.cornerRadius = 30.0
        
        let btnPass = UIButton()
        btnPass.setImage(UIImage(named: "HideEye"), for: .normal)
        btnPass.setImage(UIImage(named: "ShowEye"), for: .selected)
        btnPass.addTarget(self, action: #selector(showPassword(btn:)), for: .touchUpInside)
        btnPass.tag = 1
        btnPass.contentHorizontalAlignment = .right
        btnPass.frame = CGRect(x: textFields[0].frame.width - textFields[0].frame.height, y: 0, width: textFields[0].frame.height, height: textFields[0].frame.height)
        textFields[0].rightView = btnPass
        textFields[0].rightViewMode = .always
        
        let btnConfirmPass = UIButton()
        btnConfirmPass.setImage(UIImage(named: "HideEye"), for: .normal)
        btnConfirmPass.setImage(UIImage(named: "ShowEye"), for: .selected)
        btnConfirmPass.addTarget(self, action: #selector(showPassword(btn:)), for: .touchUpInside)
        btnConfirmPass.tag = 2
        btnConfirmPass.contentHorizontalAlignment = .right
        btnConfirmPass.frame = CGRect(x: textFields[1].frame.width - textFields[1].frame.height, y: 0, width: textFields[1].frame.height, height: textFields[1].frame.height)
        textFields[1].rightView = btnConfirmPass
        textFields[1].rightViewMode = .always
        
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
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
            btnNext.backgroundColor = Colors.themeGreen.returnColor()
            btnNext.isUserInteractionEnabled = true
        }else {
            btnNext.isUserInteractionEnabled = false
            btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    // MARK: - UI Methods
    
    // Display password to User on tap of Eye button
    @objc func showPassword(btn: UIButton) {
        btn.isSelected = !btn.isSelected

        if btn.tag == 1 {
            textFields[0].isSecureTextEntry = btn.isSelected ? false : true
        } else if btn.tag == 2 {
            textFields[1].isSecureTextEntry = btn.isSelected ? false : true
        }
    }
        
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
//                tfPass.text = tfPass.text?.trimmedString
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[i].text?.count)! >= MIN_PASSWORD_LENGTH {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.gray.returnColor()
                        //
                    }else {
                        lblError[i].setLeftArrow(title: Valid_Password)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }
                }
            } else if i == 1 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[1].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    if textFields[0].text?.trimmedString != textFields[i].text?.trimmedString {
                        lblError[i].setLeftArrow(title: Confirm_Password_Not_Match)
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    } else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.gray.returnColor()
                        //
                    }
                }
            }
        }
        return value
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[3])!, animated: true)
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        if checkValidation(to: 0, from: 2) {
            view.endEditing(true)
            resetPassword()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        lblError[textField.tag].text = ""
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].title.textColor = Colors.themeGreen.returnColor()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= MAX_PASSWORD_LENGTH
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField.tag == 0 {
                textFields[1].becomeFirstResponder()
            }else {
                view.endEditing(true)
            }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if checkValidation(to: textField.tag, from: textField.tag + 1) {
        }
    }

    // MARK: Webservices
    
    func resetPassword() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.resetPassword()
                }
            }
            return
        }
        
        let dictParms = ["email": userEmail != "" ? userEmail : mobileNumber,
                        "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                        "type": userEmail != "" ? "email" : "mobileNumber",
                        "password": (textFields[0].text?.trimmedString)!,
                        "confirmPassword": (textFields[1].text?.trimmedString)!] as [String : Any]

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.RESET_PASSWORD, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
}
