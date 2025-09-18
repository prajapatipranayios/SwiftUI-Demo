//
//  VerifyVC.swift
//  Tussly
//

import UIKit

class VerifyVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables.
    var isForgotPassword: Bool = false
    var responseOTP = 1111
    var userEmail = ""
    var mobileNumber = ""
    //    var password = ""
    var timer = Timer()
    var timeSeconds = 120
    
    // MARK: - Controls
    
    @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var lblTwo: UILabel!
    @IBOutlet weak var lblThree: UILabel!
    @IBOutlet weak var lblFour: UILabel!
    @IBOutlet weak var viewOTPOne : UIView!
    @IBOutlet weak var viewOTPTwo : UIView!
    @IBOutlet weak var viewOTPThree : UIView!
    @IBOutlet weak var viewOTPFour : UIView!
    @IBOutlet weak var txtTemp: UITextField!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var btnVerify: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc1: UILabel!
    @IBOutlet weak var lblDesc2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        txtTemp.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblTitle.text = "Enter Code"
        self.lblDesc1.attributedText = "Enter the code we just sent to \(self.userEmail)".setAttributedString(boldString: self.userEmail , fontSize: 16.0)
        self.lblDesc2.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // MARK: - UI Methods
    
    func setUI() {
        /*lblOne.text = "1"
        lblTwo.text = "1"
        lblThree.text = "1"
        lblFour.text = "1"
        txtTemp.text = "1111"   //  */
        
        lblOne.text = ""
        lblTwo.text = ""
        lblThree.text = ""
        lblFour.text = ""
        txtTemp.text = ""
        
        btnVerify.layer.cornerRadius = 15.0
        txtTemp.becomeFirstResponder()
        btnResend.isUserInteractionEnabled = false
        btnResend.setTitleColor(Colors.disable.returnColor(), for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
    }
    
    func setDefaultOTPView() {
        viewOTPOne.backgroundColor = Colors.gray.returnColor()
        viewOTPTwo.backgroundColor = Colors.gray.returnColor()
        viewOTPThree.backgroundColor = Colors.gray.returnColor()
        viewOTPFour.backgroundColor = Colors.gray.returnColor()
    }
    
    func onCustomPopupOk() {
        lblOne.text = ""
        lblTwo.text = ""
        lblThree.text = ""
        lblFour.text = ""
        setDefaultOTPView()
        txtTemp.text = ""
        txtTemp.becomeFirstResponder()
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 1 {
            timer.invalidate()
            btnResend.isUserInteractionEnabled = true
            btnResend.setTitleColor(Colors.black.returnColor(), for: .normal)
        }
    }
    
    func  timeFormatted(totalSeconds: Int) -> String {
        let seconds  = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        _  = totalSeconds / 3600
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapOTP(_ sender: UIButton) {
        txtTemp.becomeFirstResponder()
    }
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapResendOTP(_ sender: UIButton) {
        resendOtp()
    }
    
    @IBAction func onTappedVerify(_ sender: UIButton) {
        view.endEditing(true)
        if (txtTemp.text?.count)! >= 4 {
            if Int(txtTemp.text!) == responseOTP {
                if isForgotPassword {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
                    objVC.userEmail = userEmail
                    objVC.mobileNumber = mobileNumber
                    self.view.rootNavController.pushViewController(objVC, animated: true)
                } else {
                    verifyOTP()
                }
            } else {
                Utilities.showPopup(title: Valid_OTP, type: .error)
            }
        } else {
            Utilities.showPopup(title: Empty_OTP, type: .error)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            lblOne.text = ""
            lblTwo.text = ""
            lblThree.text = ""
            lblFour.text = ""
        }
        setDefaultOTPView()
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let str:String = NSString(format: "%@", newString) as String
        
        print("New string -> \(newString)")
        
        for (index, char) in str.enumerated() {
            if index == 0 {
                lblOne.text = String(char)
                viewOTPOne.backgroundColor = Colors.black.returnColor()
            } else if index == 1 {
                lblTwo.text = String(char)
                viewOTPTwo.backgroundColor = Colors.black.returnColor()
            } else if index == 2 {
                lblThree.text = String(char)
                viewOTPThree.backgroundColor = Colors.black.returnColor()
            } else if index == 3 {
                lblFour.text = String(char)
                viewOTPFour.backgroundColor = Colors.black.returnColor()
            }
            print("Character --->  \(char)")
        }
        return newString.length <= 4
    }
    
    // MARK: Webservices
    
    func verifyOTP() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.verifyOTP()
                }
            }
            return
        }
        
        let dictParms = ["email": userEmail != "" ? userEmail : mobileNumber,
                         "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                         "type": userEmail != "" ? "email" : "mobileNo",
                         "otp": responseOTP,
                         "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
                         "platform": AppInfo.Platform.returnAppInfo(),
                         "deviceId": AppInfo.DeviceId.returnAppInfo(),
                         "sendWelcomeMail": self.isForgotPassword ? 0 : 1] as [String : Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.VERIFY_OTP, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                UserDefaults.standard.synchronize()
                
                //                let appId = ALChatManager.applicationId
                //                let alUser = ALUser()
                //                alUser.applicationId = appId
                //                alUser.userId = "\(APIManager.sharedManager.user?.id ?? 0)"
                //                ALUserDefaultsHandler.setUserId(alUser.userId)
                //                alUser.displayName = APIManager.sharedManager.user?.displayName
                //                alUser.imageLink = APIManager.sharedManager.user?.avatarImage
                //                self.registerUserToApplozic(alUser: alUser)
                
                DispatchQueue.main.async {
                    if appDelegate.isAutoLogin == false {
                        self.view!.tusslyTabVC.selectedIndex = 0
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func resendOtp() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.resendOtp()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.RESENT_OTP, parameters: ["email": userEmail != "" ? userEmail : mobileNumber,"countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                                                                                                 "type": userEmail != "" ? "email" : "mobileNo"]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.responseOTP = Int((response?.result?.otp)!)!
                    self.timeSeconds = 120
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    self.btnResend.isUserInteractionEnabled = false
                    self.btnResend.setTitleColor(Colors.disable.returnColor(), for: .normal)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    // private func registerUserToApplozic(alUser: ALUser) {
    //        showLoading()
    //        let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
    //        alChatManager.connectUser(alUser, completion: { response, error in
    //            self.hideLoading()
    //            if error == nil {
    //                NSLog("[REGISTRATION] Applozic user registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
    //                DispatchQueue.main.async {
    //                    if appDelegate.isAutoLogin == false {
    //                        self.view!.tusslyTabVC.selectedIndex = 0
    //                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
    //                    }
    //                }
    //            } else {
    //                NSLog("[REGISTRATION] Applozic user registration error: %@", error.debugDescription)
    //            }
    //        })
    //   }
}
