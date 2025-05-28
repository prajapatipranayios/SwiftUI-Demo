//
//  CompleteRegistrationVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 21/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class CompleteRegistrationVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTypesContainer: UIView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet var btnTypes: [UIButton]!

    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var tfABN: FFTextField!
    @IBOutlet weak var viewWebsiteBack: UIView!
    @IBOutlet weak var tfWebsite: FFTextField!
    @IBOutlet weak var heightTFABN: NSLayoutConstraint! //60
    @IBOutlet weak var topTFABN: NSLayoutConstraint! //24

    @IBOutlet weak var lblABNMessage: UILabel!
    
    @IBOutlet weak var tvAboutUs: FFTextView!
    
    @IBOutlet weak var lblAccType: UILabel!
    @IBOutlet weak var viewAccTypesContainer: UIView!
    @IBOutlet var btnAccTypes: [UIButton]!
    
    @IBOutlet weak var lblTerms: UILabel!

    @IBOutlet weak var btnNext: UIButton!
    
    var userRegParams = Dictionary<String, Any>()
    var userProfileImg: UIImage?
    
    var selectedType: Int = 0
    var selectedAccType: Int = 0
    var otpToVerify: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        tfABN.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tfWebsite.setAttributedPlaceholder(Colors.lightGray.returnColor())
        
        tfABN.delegate = self
        tfWebsite.delegate = self
//        tvAboutUs.delegate = self
//        placeholderTVLabel = UILabel()
//        placeholderTVLabel.text = "About Me"
//        placeholderTVLabel.font = Fonts.Regular.returnFont(size: 16.0)
//        placeholderTVLabel.sizeToFit()
//        tvAboutUs.addSubview(placeholderTVLabel)
//        placeholderTVLabel.frame.origin = CGPoint(x: 5, y: (tvAboutUs.font?.pointSize)! / 2)
//        placeholderTVLabel.textColor = UIColor.lightGray
//        placeholderTVLabel.isHidden = !tvAboutUs.text.isEmpty
        tvAboutUs.updateColor(Colors.lightGray.returnColor())
        
        btnNext.isUserInteractionEnabled = true
        btnNext.backgroundColor = Colors.themeGreen.returnColor()
        tfABN.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
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
        
        if textField.text?.last == " " {
            textField.text?.removeLast()
        }else {
            if textField.text?.count == 3 || textField.text?.count == 7 || textField.text?.count == 11 {
                let tmpText: NSMutableString = NSMutableString(string: textField.text!)
                tmpText.insert(" ", at: textField.text!.count - 1)
                textField.text = tmpText as String
            }
        }
    }
    
    func setupUI() {
        let attributedType = NSMutableAttributedString(string: lblType.text!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
        attributedType.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: lblType.text!.trimmedString.count))
        attributedType.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: lblType.text!.trimmedString.count - 1, length: 1))

        self.lblType.attributedText = attributedType
        
        let attributedAccType = NSMutableAttributedString(string: lblAccType.text!, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 16.0)])
        attributedAccType.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: lblAccType.text!.trimmedString.count))
        attributedAccType.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: lblAccType.text!.trimmedString.count - 1, length: 1))

        self.lblAccType.attributedText = attributedAccType
        
        viewTypesContainer.layer.cornerRadius = viewTypesContainer.frame.size.height / 2
        viewTypesContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewTypesContainer.layer.borderWidth = 1.0
        
        viewAccTypesContainer.layer.cornerRadius = viewAccTypesContainer.frame.size.height / 2
        viewAccTypesContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewAccTypesContainer.layer.borderWidth = 1.0

        viewBack.layer.borderColor = Colors.lightGray.returnColor().cgColor
        viewBack.layer.borderWidth = 1.0
        viewBack.layer.cornerRadius = 30.0
        
        viewWebsiteBack.layer.borderColor = Colors.lightGray.returnColor().cgColor
        viewWebsiteBack.layer.borderWidth = 1.0
        viewWebsiteBack.layer.cornerRadius = 30.0
        
        for btn in btnTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        for btn in btnAccTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        
        btnTypes[0].isSelected = true
        btnTypes[0].backgroundColor = Colors.themeGreen.returnColor()
        btnTypes[0].setTitleColor(UIColor.white, for: .normal)
        btnTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
        viewBack.isHidden = true
        heightTFABN.constant = 0
        topTFABN.constant = 0
        
        btnAccTypes[0].backgroundColor = Colors.themeGreen.returnColor()
        btnAccTypes[0].setTitleColor(UIColor.white, for: .normal)
        btnAccTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
        let main_string = lblTerms.text
        let privacyPolicyRange = (main_string! as NSString).range(of: "Privacy Policy")
        let termsAndConditionRange = (main_string! as NSString).range(of: "Terms of Use")
        let attributedString = NSMutableAttributedString(string:main_string!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: termsAndConditionRange)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.themeGreen.returnColor(), range: privacyPolicyRange)
        lblTerms.attributedText = attributedString
        
        self.lblTerms.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.lblTerms.addGestureRecognizer(tapgesture)
        
        btnNext.layer.cornerRadius = 30.0
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.lblTerms.text else { return }
        let privacyPolicyRange = (text as NSString).range(of: "Privacy Policy")
        let termsAndConditionRange = (text as NSString).range(of: "Terms of Use")
        let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagalPolicyVC") as! LeagalPolicyVC
        if gesture.didTapAttributedTextInLabel(label: self.lblTerms, inRange: termsAndConditionRange) {
            termsVC.selectedTabIndex = 0
        }else if gesture.didTapAttributedTextInLabel(label: self.lblTerms, inRange: privacyPolicyRange) {
            termsVC.selectedTabIndex = 1
        }
        self.navigationController?.pushViewController(termsVC, animated: true)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapType(_ sender: UIButton) {
        view.endEditing(true)
        
        selectedType = sender.tag
        for btn in btnTypes {
            if btn.tag == sender.tag {
                btn.backgroundColor = Colors.themeGreen.returnColor()
                btn.setTitleColor(UIColor.white, for: .normal)
                btn.titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
                btn.isSelected = true
            } else {
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(Colors.lightGray.returnColor() , for: .normal)
                btn.titleLabel?.font = Fonts.Regular.returnFont(size: 14.0)
                btn.isSelected = false
            }
        }
        
        btnNext.isUserInteractionEnabled = sender.tag != 1 ? true : (tfABN.text != "" ? true : false)
        btnNext.backgroundColor = sender.tag != 1 ? Colors.themeGreen.returnColor() : (tfABN.text != "" ? Colors.themeGreen.returnColor() : Colors.inactiveButton.returnColor())
        viewBack.layer.borderColor = sender.tag != 1 ? Colors.lightGray.returnColor().cgColor : (tfABN.text != "" ? Colors.gray.returnColor().cgColor : Colors.lightGray.returnColor().cgColor)
        tfABN.setAttributedTitle(sender.tag != 1 ? Colors.lightGray.returnColor() : (tfABN.text != "" ? Colors.gray.returnColor() : Colors.lightGray.returnColor()))
        
        viewBack.isHidden = sender.tag != 1 ? true : false
        heightTFABN.constant = sender.tag != 1 ? 0 : 60
        topTFABN.constant = sender.tag != 1 ? 0 : 24
        lblABNMessage.text = sender.tag != 1 ? "" : lblABNMessage.text
        tfABN.title.isHidden = sender.tag != 1 ? true : false // Placeholder Label
        tvAboutUs.hint = sender.tag == 0 ? "About Me" : "About Us"
//        placeholderTVLabel.text = sender.tag == 0 ? "About Me" : "About Us"
    }
    
    @IBAction func onTapAccType(_ sender: UIButton) {
        view.endEditing(true)
        
        selectedAccType = sender.tag
        for btn in btnAccTypes {
            if btn.tag == sender.tag {
                btn.backgroundColor = Colors.themeGreen.returnColor()
                btn.setTitleColor(UIColor.white, for: .normal)
                btn.titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
            } else {
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(Colors.lightGray.returnColor() , for: .normal)
                btn.titleLabel?.font = Fonts.Regular.returnFont(size: 14.0)
            }
        }
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        if selectedType == 1 {
            tfABN.text = tfABN.text?.trimmedString
            if tfABN.text == "" {
                lblABNMessage.getEmptyValidationString(tfABN.placeholder ?? "")
                //
                viewBack.layer.borderColor = Colors.red.returnColor().cgColor
                tfABN.titleTextColour = Colors.red.returnColor()
                //
                return
            } else {
                if ((tfABN.text?.count)! < ABN_LENGTH) {
                    lblABNMessage.setLeftArrow(title: Valid_ABN)
                    //
                    viewBack.layer.borderColor = Colors.red.returnColor().cgColor
                    tfABN.titleTextColour = Colors.red.returnColor()
                    //
                    return
                }else {
                    lblABNMessage.text = ""
                    //
                    viewBack.layer.borderColor = Colors.gray.returnColor().cgColor
                    tfABN.titleTextColour = Colors.gray.returnColor()
                    //
                }
            }
        }
        userRegParams.updateValue(tfABN.text!, forKey: "ABN")
        userRegParams.updateValue(tfWebsite.text!, forKey: "website")
        userRegParams.updateValue(tvAboutUs.text!, forKey: "aboutMe")
        userRegParams.updateValue(btnTypes[selectedType].titleLabel!.text!, forKey: "userType")
        userRegParams.updateValue(btnAccTypes[selectedAccType].titleLabel!.text!, forKey: "accountType")

        userSignUp()
    }
        
    // MARK: Webservices
    
    func userSignUp() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userSignUp()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.SIGNUP, fileName: "profilePic", image: userProfileImg!, movieDataURL: nil, params: userRegParams) { (status, response, message) in
            self.hideLoading()
            if status {
                self.otpToVerify = Int(response!["otp"] as! String)!
                DispatchQueue.main.async {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                    objVC.isForgotPassword = false
                    objVC.responseOTP = self.otpToVerify
                    objVC.mobileNumber = self.userRegParams["mobileNumber"] as! String
                    self.navigationController?.pushViewController(objVC, animated: true)
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
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

extension CompleteRegistrationVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        tvAboutUs.updateColor(Colors.themeGreen.returnColor())
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString

        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmedString
        
        if textView.text == "" {
            tvAboutUs.updateColor(Colors.lightGray.returnColor())
        } else {
            tvAboutUs.updateColor(Colors.gray.returnColor())
        }
    }

    func textViewDidChange(_ textView: UITextView) {
//        placeholderTVLabel.isHidden = !textView.text.isEmpty
    }
}

extension CompleteRegistrationVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfABN {
            lblABNMessage.text = ""
            viewBack.layer.borderColor = Colors.themeGreen.returnColor().cgColor
            tfABN.setAttributedTitle(Colors.themeGreen.returnColor())
        }else {
            viewWebsiteBack.layer.borderColor = Colors.themeGreen.returnColor().cgColor
            tfWebsite.setAttributedTitle(Colors.themeGreen.returnColor())
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        
       let currentString: NSString = textField.text! as NSString
       let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            
        if textField == tfABN {
            return newString.length <= ABN_LENGTH
        }
        
        return newString.length <= TEXTFIELD_LIMIT
        
   }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        
        if textField == tfABN {
            if textField.text == "" {
                
                lblABNMessage.getEmptyValidationString(tfABN.placeholder ?? "")
                //
                viewBack.layer.borderColor = Colors.red.returnColor().cgColor
                tfABN.titleTextColour = Colors.red.returnColor()
                
            } else {
                
                if ((tfABN.text?.count)! < ABN_LENGTH) {
                    lblABNMessage.setLeftArrow(title: Valid_ABN)
                    //
                    viewBack.layer.borderColor = Colors.red.returnColor().cgColor
                    tfABN.titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblABNMessage.text = ""
                    //
                    viewBack.layer.borderColor = Colors.gray.returnColor().cgColor
                    tfABN.titleTextColour = Colors.gray.returnColor()
                    //
                }
            }
        }else {
            
            if textField.text == "" {
                
                viewWebsiteBack.layer.borderColor = Colors.lightGray.returnColor().cgColor
                tfWebsite.setAttributedTitle(Colors.lightGray.returnColor())
            } else {
                
                viewWebsiteBack.layer.borderColor = Colors.gray.returnColor().cgColor
                tfWebsite.setAttributedTitle(Colors.gray.returnColor())
            }
        }
        
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
