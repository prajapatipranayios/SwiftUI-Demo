//
//  VerifyVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 21/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ProfileVerifyVC: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var lblMobNo: UILabel!
    @IBOutlet var lblOTP: [UILabel]!
    @IBOutlet weak var txtTemp: UITextField!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblResendCode: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var viewOTP: UIView!
    
    // MARK: - Variables.
    var timer = Timer()
    var timeSeconds = 120
    var responseOTP = 1111
    var mobileNumber = ""
    
    var ontapVerify: (()->Void)?
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.onUiViewClick))
        blurView.addGestureRecognizer(clickGesture)
        blurView.effect =   blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.bringSubviewToFront(viewOTP)
        
        viewOTP.layer.cornerRadius = 20.0
//        let clickGestureView = UITapGestureRecognizer(target: self, action:  #selector(self.onUiViewClick))
//        viewOTP.addGestureRecognizer(clickGestureView)
        lblMobNo.text = "Entered the OTP sent on\n\(Utilities.getCountryPhoneCode(country: Locale.current.regionCode!) + " " + mobileNumber)"
        lblMobNo.textColor = Colors.gray.returnColor()
        btnResend.isUserInteractionEnabled = false
        btnResend.backgroundColor = Colors.inactiveButton.returnColor()
        btnResend.layer.cornerRadius = self.btnResend.frame.height / 2.0
        
        setupUI()
        
        self.resendOtp()
    }
    
    func setupUI() {
        let attributedString = NSMutableAttributedString(string:"Resend Code in \(timeFormatted(totalSeconds: timeSeconds))", attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)])
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: NSRange(location: 15, length: 5))
        attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Semibold.returnFont(size: 14.0), range: NSRange(location: 15, length: 5))

        lblResendCode.attributedText = attributedString
        
        txtTemp.delegate = self
        txtTemp.becomeFirstResponder()
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)

        for lbl in lblOTP {
            lbl.clipsToBounds = true
            lbl.layer.cornerRadius = 5
            
            lbl.layer.borderColor = Colors.gray.returnColor().cgColor
            lbl.layer.borderWidth = 1.0
        }
    }
    
    @objc func onUiViewClick(sender : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
            lblResendCode.isHidden = true
            
            btnResend.backgroundColor = Colors.orange.returnColor()
            btnResend.isUserInteractionEnabled = true
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.RESEND_OTP_MOBILE,
                                          parameters: ["mobileNumber": mobileNumber,
                                                       "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!)]) {
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
                    self.lblResendCode.isHidden = false
                    self.txtTemp.delegate = self
                    self.txtTemp.becomeFirstResponder()
                    self.txtTemp.text = ""
                    self.lblError.text = ""
                    for lbl in self.lblOTP {
                        lbl.text = ""
                    }
                    
                    self.btnResend.isUserInteractionEnabled = false
                    self.btnResend.backgroundColor = Colors.inactiveButton.returnColor()
                    
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
                
            }
        }
        
        if newString.length == 4 {
            if Int(String(newString)) == responseOTP {
                if self.ontapVerify != nil {
                    self.ontapVerify!()
                }
                
                self.dismiss(animated: true, completion: nil)
            } else {
                
                //Invalid OTP
                lblError.text = "You seem to have entered the wrong code"
                for lbl in lblOTP {
                    lbl.layer.borderColor = Colors.red.returnColor().cgColor
                }
//                Utilities.showPopup(title: Valid_OTP, type: .error)
                timer.invalidate()
                lblResendCode.isHidden = true
                
                btnResend.isUserInteractionEnabled = true
                btnResend.backgroundColor = Colors.orange.returnColor()
            }
        }
        
        return newString.length <= 4
    }
}
