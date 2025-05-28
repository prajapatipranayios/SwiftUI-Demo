//
//  EnterEmailVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 20/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EnterEmailVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var tfEmail: FFTextField!
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBack.layer.borderColor = Colors.lightGray.returnColor().cgColor
        viewBack.layer.borderWidth = 1.0
        viewBack.layer.cornerRadius = 30.0
        btnNext.layer.cornerRadius = 30.0
        
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        tfEmail.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        print(textField.text!)
        if textField.text?.trimmedString != "" {
            btnNext.backgroundColor = Colors.themeGreen.returnColor()
            btnNext.isUserInteractionEnabled = true
        } else {
            btnNext.isUserInteractionEnabled = false
            btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    // MARK: - UI Methods
//    func checkNextButtonValue() {
//        if tfEmail.text != "" {
//            btnNext.isUserInteractionEnabled = true
//            btnNext.backgroundColor = Colors.themeGreen.returnColor()
//        }else {
//            btnNext.isUserInteractionEnabled = false
//            btnNext.backgroundColor = Colors.inactiveButton.returnColor()
//        }
//    }
    
    func checkValidation() -> Bool {
        var value = true
        tfEmail.text = tfEmail.text?.trimmingCharacters(in: .whitespaces)
        if tfEmail.text == "" {
            lblEmailError.getEmptyValidationString(tfEmail.placeholder ?? "")
            value = false
            //
            viewBack.layer.borderColor = Colors.red.returnColor().cgColor
            tfEmail.titleTextColour = Colors.red.returnColor()
            //
        }else {
            if (tfEmail.text?.isNumber)! {
                if !((tfEmail.text?.count)! >= MIN_MOBILE_LENGTH) {
                    lblEmailError.setLeftArrow(title: Valid_Mobile)
                    value = false
                    //
                    viewBack.layer.borderColor = Colors.red.returnColor().cgColor
                    tfEmail.titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    lblEmailError.text = ""
                    //
                    viewBack.layer.borderColor = Colors.gray.returnColor().cgColor
                    tfEmail.titleTextColour = Colors.gray.returnColor()
                    //
                }
            }
//            else {
//                if !(tfEmail.text?.isValidEmail())! {
//                    lblEmailError.setLeftArrow(title: Valid_Email)
//                    value = false
//                    //
//                    viewBack.layer.borderColor = Colors.red.returnColor().cgColor
//                    tfEmail.titleTextColour = Colors.red.returnColor()
//                    //
//                } else {
//                    lblEmailError.text = ""
//                    //
//                    viewBack.layer.borderColor = Colors.themeGreen.returnColor().cgColor
//                    tfEmail.titleTextColour = Colors.themeGreen.returnColor()
//                    //
//                }
//            }
        }
        
        return value
    }
    
    // MARK: Webservices
    
    func checkEmailOrMobileNo() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.checkEmailOrMobileNo()
                }
            }
            return
        }
        
        let userName = tfEmail.text!.trimmedString
        
        let userDict = ["email": userName,
                        "type": userName.isNumber ? "mobileNumber" : "email",
                        "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!)
            ] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHECK_EMAIL_MOBILE, parameters: userDict) { (response: ApiResponse?, error) in
            self.hideLoading()
            if (response?.status)! == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.user = response?.result?.userDetail
                    let userLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    userLoginVC.userName = APIManager.sharedManager.user!.name
                    userLoginVC.email = self.tfEmail.text!
                    self.navigationController?.pushViewController(userLoginVC, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let userRegVC = self.storyboard?.instantiateViewController(withIdentifier: "UserRegisterVC") as! UserRegisterVC
                    if userName.isNumber {
                        userRegVC.mobileNo = userName
                    } else {
                        userRegVC.email = userName
                    }
                    self.navigationController?.pushViewController(userRegVC, animated: true)
                }
//                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapNext(_ sender: UIButton) {
        if checkValidation() {
            view.endEditing(true)
            checkEmailOrMobileNo()
//            performSegue(withIdentifier: "toLogin", sender: nil)
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

}

extension EnterEmailVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblEmailError.text = ""
        viewBack.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        tfEmail.title.textColor = Colors.themeGreen.returnColor()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == tfEmail {
            if (tfEmail.text?.isNumber)! {
                return newString.length <= MAX_MOBILE_LENGTH
            }else {
                return newString.length <= TEXTFIELD_LIMIT
            }
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfEmail.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkValidation() {
            
        }
    }
}
