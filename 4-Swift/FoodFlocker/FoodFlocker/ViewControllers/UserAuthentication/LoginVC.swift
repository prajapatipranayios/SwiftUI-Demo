//
//  LoginVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 21/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    //Outlets
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    @IBOutlet weak var btnForgotPass: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblUserName : UILabel!

    var userDict = Dictionary<String, Any>()
    
    var userName: String = ""
    var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view in viewBack {
            view.layer.borderColor = Colors.lightGray.returnColor().cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
        }
        btnNext.layer.cornerRadius = 30.0
        
        textFields[0].text = email
        textFields[0].isUserInteractionEnabled = false
        textFields[0].textColor = Colors.lightGray.returnColor()
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                  NSAttributedString.Key.font: Fonts.Medium.returnFont(size: 14.0),
                                  NSAttributedString.Key.foregroundColor: UIColor.black] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: "Forgot Password?", attributes: underlineAttribute)
        btnForgotPass.setAttributedTitle(underlineAttributedString, for: .normal)
        
        let btnPass = UIButton()
        btnPass.setImage(UIImage(named: "HideEye"), for: .normal)
        btnPass.setImage(UIImage(named: "ShowEye"), for: .selected)
        btnPass.addTarget(self, action: #selector(showPassword(btn:)), for: .touchUpInside)
        btnPass.tag = 1
        btnPass.contentHorizontalAlignment = .right
        btnPass.frame = CGRect(x: textFields[1].frame.width - textFields[1].frame.height, y: 0, width: textFields[1].frame.height, height: textFields[1].frame.height)
        textFields[1].rightView = btnPass
        textFields[1].rightViewMode = .always
        
        lblUserName.text = userName
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UI Methods
    
    // Display password to User on tap of Eye button
    @objc func showPassword(btn: UIButton) {
        if btn.tag == 1 {
            btn.isSelected = !btn.isSelected
            textFields[1].isSecureTextEntry = btn.isSelected ? false : true
        }
    }

    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                if textFields[0].text == "" {
                    lblError[0].getEmptyValidationString(textFields[0].placeholder ?? "")
                    value = false
                    //
                    viewBack[0].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[0].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[0].text?.isNumber)! {
                        if !((textFields[0].text?.count)! >= MIN_MOBILE_LENGTH) {
                            lblError[0].setLeftArrow(title: Valid_Mobile)
                            value = false
                            //
                            viewBack[0].layer.borderColor = Colors.red.returnColor().cgColor
                            textFields[0].titleTextColour = Colors.red.returnColor()
                            //
                        } else {
                            lblError[0].text = ""
                            //
                            viewBack[0].layer.borderColor = Colors.gray.returnColor().cgColor
                            textFields[0].titleTextColour = Colors.gray.returnColor()
                            //
                        }
                    }
//                    else {
//                        if !(tfEmail.text?.isValidEmail())! {
//                            lblEmailError.setLeftArrow(title: Valid_Email)
//                            value = false
//                        } else {
//                            lblEmailError.text = ""
//                        }
//                    }
                }
            } else if i == 1 {
                if textFields[1].text == "" {
                    lblError[1].getEmptyValidationString(textFields[1].placeholder ?? "")
                    value = false
                    //
                    viewBack[1].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[1].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[1].text?.count)! >= MIN_PASSWORD_LENGTH {
                        lblError[1].text = ""
                        //
                        viewBack[1].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[1].titleTextColour = Colors.gray.returnColor()
                        //
                    }else {
                        lblError[1].setLeftArrow(title: Valid_Password)
                        value = false
                        //
                        viewBack[1].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[1].titleTextColour = Colors.red.returnColor()
                        //
                    }
                }
            }
        }
        return value
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapForgotPassword(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        if checkValidation(to: 0, from: 2) {
            view.endEditing(true)
//            print(Utilities.getCountryPhoneCode(country: Locale.current.regionCode!))
            userLogIn()
//            performSegue(withIdentifier: "toVerify", sender: nil)
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
    
    // MARK: Webservices
    
    func userLogIn() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userLogIn()
                }
            }
            return
        }
        
        let userName = textFields[0].text!.trimmedString
        let password = textFields[1].text!.trimmedString
        
        userDict = ["email": userName,
                    "password": password,
                    "deviceToken": AppInfo.DeviceId.returnAppInfo(),
                    "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String,
                    "type": userName.isNumber ? "mobileNumber" : "email",
                    "deviceType": AppInfo.Platform.returnAppInfo(),
                    "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!)
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LOGIN, parameters: userDict) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                DispatchQueue.main.async {
                    if response?.result?.isVerified == 0 {
                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                        objVC.isForgotPassword = false
                        objVC.responseOTP = Int((response?.result?.userDetail?.otp)!)!
//                        objVC.userEmail = self.tfEmail.text!.isNumber ? "" : self.tfEmail.text!
                        objVC.mobileNumber = self.textFields[0].text!.isNumber ? self.textFields[0].text! : ""
                        objVC.password = self.textFields[1].text!
                        self.navigationController?.pushViewController(objVC, animated: true)
                    } else {
                        UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                        UserDefaults.standard.synchronize()
//                        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
//                        self.navigationController?.pushViewController(homeVC, animated: true)

                        self.setHomeRootViewController()
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension LoginVC: UITextFieldDelegate {
    
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
        
        if textField == textFields[1] {
            return newString.length <= MAX_PASSWORD_LENGTH
        }else if textField == textFields[0] {
            if (textFields[0].text?.isNumber)! {
                return newString.length <= MAX_MOBILE_LENGTH
            }else {
                return newString.length <= TEXTFIELD_LIMIT
            }
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == textFields[0] {
            textFields[1].becomeFirstResponder()
        }else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
}
