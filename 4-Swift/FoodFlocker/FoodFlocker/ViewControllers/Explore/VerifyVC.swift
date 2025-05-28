//
//  VerifyVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 21/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class VerifyVC: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var lblMobNo: UILabel!
    @IBOutlet var lblOTP: [UILabel]!
    @IBOutlet weak var txtTemp: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblResendCode: UILabel!
    @IBOutlet weak var lblError: UILabel!

    // MARK: - Variables.
    var isForgotPassword: Bool = false
    var timer = Timer()
    var timeSeconds = 120
    var responseOTP = 1111
    var mobileNumber = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        lblMobNo.text = Utilities.getCountryPhoneCode(country: Locale.current.regionCode!) + " " + mobileNumber
        
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        txtTemp.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func setupUI() {
        let attributedString = NSMutableAttributedString(string:"Resend Code in \(timeFormatted(totalSeconds: timeSeconds))", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: NSRange(location: 15, length: 5))
        attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Semibold.returnFont(size: 14.0), range: NSRange(location: 15, length: 5))

        lblResendCode.attributedText = attributedString
            
            
        btnNext.layer.cornerRadius = 30.0
        btnResend.isHidden = true
        txtTemp.delegate = self
        txtTemp.becomeFirstResponder()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)

        for lbl in lblOTP {
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = 5
            
            lbl.layer.borderColor = Colors.gray.returnColor().cgColor
            lbl.layer.borderWidth = 1.0
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        print(textField.text!)
        if textField.text?.trimmedString.count == 4 {
            btnNext.backgroundColor = Colors.themeGreen.returnColor()
            btnNext.isUserInteractionEnabled = true
        } else {
            btnNext.isUserInteractionEnabled = false
            btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    // Call Timer
    @objc func callTimer()
    {
        timeSeconds -= 1
        
        let attributedString = NSMutableAttributedString(string:"Resend Code in \(timeFormatted(totalSeconds: timeSeconds))", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: NSRange(location: 15, length: 5))
        attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Semibold.returnFont(size: 14.0), range: NSRange(location: 15, length: 5))

        lblResendCode.attributedText = attributedString
        
        if timeSeconds < 1 {
            timer.invalidate()
            btnResend.isHidden = false
            lblResendCode.isHidden = true
        }
    }
    
    // Time Formating
    func  timeFormatted(totalSeconds: Int) -> String {
        let seconds  = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        _  = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        if isForgotPassword {
            self.navigationController?.popViewController(animated: true)
        }else {
            DispatchQueue.main.async {
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
            }
        }
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        view.endEditing(true)
        if (txtTemp.text?.count)! >= 4 {
            if Int(txtTemp.text!) == responseOTP {
                lblError.text = ""
                if isForgotPassword {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
//                    objVC.userEmail = userEmail
                    objVC.mobileNumber = mobileNumber
                    self.navigationController!.pushViewController(objVC, animated: true)
                } else {
                    verifyOTP()
                }
            } else {
                //Invalid OTP
                lblError.text = "You seem to have entered the wrong code"
                for lbl in lblOTP {
                    lbl.layer.borderColor = Colors.red.returnColor().cgColor
                }
//                Utilities.showPopup(title: Valid_OTP, type: .error)
                timer.invalidate()
                btnResend.isHidden = false
                lblResendCode.isHidden = true
            }
        } else {
            Utilities.showPopup(title: Empty_OTP, type: .error)
        }
    }
    
    @IBAction func onTapResendOTP(_ sender: UIButton) {
        resendOtp()
    }
    
    // Open Keyboard
    @IBAction func onTapOTP(_ sender: UIButton) {
        txtTemp.becomeFirstResponder()
    }
    
    func setDefaultOTPView() {
        for lbl in lblOTP {
            lbl.layer.borderColor = Colors.gray.returnColor().cgColor
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
    
    func verifyOTP() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.verifyOTP()
                }
            }
            return
        }
        
        let dictParms = ["email": mobileNumber,//userEmail != "" ? userEmail : mobileNumber,
                         "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                         "type": "mobileNumber",//userEmail != "" ? "email" : "mobileNumber",
                         "otp": responseOTP,
                         "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String,
                         "deviceType": AppInfo.Platform.returnAppInfo(),
                         "deviceToken": AppInfo.DeviceId.returnAppInfo()] as [String : Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.VERIFY_OTP, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                UserDefaults.standard.synchronize()
                
                DispatchQueue.main.async {
                    let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
                    let homeNavVC = UINavigationController(rootViewController: mainTabVC)
                    homeNavVC.isNavigationBarHidden = true
                    UIApplication.shared.windows.first?.rootViewController = homeNavVC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
//                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func resendOtp() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.resendOtp()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.RESEND_OTP,
                                          parameters: ["email": mobileNumber,//userEmail != "" ? userEmail : mobileNumber,
                                                       "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                                                       "type": "mobileNumber" /*userEmail != "" ? "email" : "mobileNo"*/]) {
                                                        (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.responseOTP = Int((response?.result?.otp)!)!
                    self.timeSeconds = 120
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    
                    let attributedString = NSMutableAttributedString(string:"Resend Code in \(self.timeFormatted(totalSeconds: self.timeSeconds))", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)])
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: NSRange(location: 15, length: 5))

                    self.lblResendCode.attributedText = attributedString
                    self.btnResend.isHidden = true
                    self.lblResendCode.isHidden = false
                    self.txtTemp.delegate = self
                    self.txtTemp.becomeFirstResponder()
                    self.txtTemp.text = ""
                    self.lblError.text = ""
                    for lbl in self.lblOTP {
                        lbl.text = ""
                    }
                    self.setDefaultOTPView()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        lblError.text = ""

        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let str:String = NSString(format: "%@", newString) as String
        
        if newString.length <= 4 {
            if string == "" {
                for lbl in lblOTP {
                    lbl.text = ""
                }
            }
            
            setDefaultOTPView()
            for (index, char) in str.enumerated() {
                lblOTP[index].text = String(char)
                lblOTP[index].layer.borderColor = Colors.themeGreen.returnColor().cgColor
                

    //            if index == 0 {
    //                lblOne.text = String(char)
    //                viewOTPOne.backgroundColor = Colors.black.returnColor()
    //            } else if index == 1 {
    //                lblTwo.text = String(char)
    //                viewOTPTwo.backgroundColor = Colors.black.returnColor()
    //            } else if index == 2 {
    //                lblThree.text = String(char)
    //                viewOTPThree.backgroundColor = Colors.black.returnColor()
    //            } else if index == 3 {
    //                lblFour.text = String(char)
    //                viewOTPFour.backgroundColor = Colors.black.returnColor()
    //            }
            }
        }
        return newString.length <= 4
    }
}
