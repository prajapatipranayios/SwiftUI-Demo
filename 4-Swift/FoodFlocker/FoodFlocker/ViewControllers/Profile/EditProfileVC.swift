//
//  EditProfileVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 30/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CropViewController
import FloatingPanel

class EditProfileVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    
    @IBOutlet weak var ivUserProfile: UIImageView!
    @IBOutlet weak var viewImageBackground: UIView!

    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    
    @IBOutlet weak var viewTypesContainer: UIView!
    @IBOutlet var btnTypes: [UIButton]!

    @IBOutlet weak var heightTFABN: NSLayoutConstraint! //60
    @IBOutlet weak var topTFABN: NSLayoutConstraint! //24
    
    @IBOutlet weak var tvAboutUs: FFTextView!
    
    @IBOutlet weak var viewAccTypesContainer: UIView!
    @IBOutlet var btnAccTypes: [UIButton]!

    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnVerify: UIButton!
    
    let imagePicker =  UIImagePickerController()
    
    var selectedType: Int = 0
    var selectedAccType: Int = 0

    var isMobileVerify = false
    var updatedMobileNumber = ""
    
    var userRegParams = Dictionary<String, Any>()
    
    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
        
//        viewAbtUsBack.isUserInteractionEnabled = false
        
        btnVerify.isHidden = true
        ivUserProfile.setImage(imageUrl: APIManager.sharedManager.user!.profilePic)
        textFields[0].text = APIManager.sharedManager.user?.name
        textFields[1].text = APIManager.sharedManager.user?.mobileNumber
        textFields[2].text = APIManager.sharedManager.user?.userName
        textFields[3].text = APIManager.sharedManager.user?.website
//        textFields[1].isEnabled = false
        
        tvAboutUs.text = APIManager.sharedManager.user?.aboutMe
        
        view.bringSubviewToFront(tvAboutUs)
        
        if APIManager.sharedManager.user?.userType == "Individual" {
            onTapType(btnTypes[0])
        } else if APIManager.sharedManager.user?.userType == "Business" {
            onTapType(btnTypes[1])
            textFields[4].text = APIManager.sharedManager.user?.ABN
        } else {
            onTapType(btnTypes[2])
        }
        
        if APIManager.sharedManager.user?.accountType == "Public" {
            onTapAccType(btnAccTypes[0])
        } else {
            onTapAccType(btnAccTypes[1])
        }

        DispatchQueue.main.async {
            for i in 0..<self.textFields.count {
                if self.textFields[i].text != "" {
                    self.viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    self.textFields[i].setAttributedTitle(Colors.gray.returnColor())
                }
            }
            
            if self.tvAboutUs.text == "" {
                self.tvAboutUs.updateColor(Colors.lightGray.returnColor())
            } else {
                self.tvAboutUs.updateColor(Colors.gray.returnColor())
            }
        }
        
    }
    
    func setupUI() {
        
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        self.ivUserProfile.layer.cornerRadius = self.ivUserProfile.frame.size.height / 2
        self.viewImageBackground.layer.cornerRadius = self.viewImageBackground.frame.size.height / 2
        
        self.viewImageBackground.layer.masksToBounds = false
        self.viewImageBackground.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        self.viewImageBackground.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.viewImageBackground.layer.shadowOpacity = 0.7
        self.viewImageBackground.layer.shadowRadius = 5.0
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
        }
        
        viewTypesContainer.layer.cornerRadius = viewTypesContainer.frame.size.height / 2
        viewTypesContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewTypesContainer.layer.borderWidth = 1.0
        
        viewAccTypesContainer.layer.cornerRadius = viewAccTypesContainer.frame.size.height / 2
        viewAccTypesContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewAccTypesContainer.layer.borderWidth = 1.0
        
//        viewAbtUsBack.layer.borderWidth = 1.0
//        viewAbtUsBack.layer.cornerRadius = 10.0
        
        for btn in btnTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        for btn in btnAccTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        
//        btnTypes[0].isSelected = true
//        btnTypes[0].backgroundColor = Colors.themeGreen.returnColor()
//        btnTypes[0].setTitleColor(UIColor.white, for: .normal)
//        btnTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
//        viewBack[4].isHidden = true
//        heightTFABN.constant = 0
//        topTFABN.constant = 0
        
//        btnAccTypes[0].backgroundColor = Colors.themeGreen.returnColor()
//        btnAccTypes[0].setTitleColor(UIColor.white, for: .normal)
//        btnAccTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height / 2
        btnUpdate.isUserInteractionEnabled = true
        btnUpdate.backgroundColor = Colors.orange.returnColor()
    }
    
    // MARK: - UI Methods
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        var value = true
        for tf in textFields {
            if tf.text?.trimmedString == "" {
                
                if tf != textFields[3] {
                    if selectedType != 1 {
                        if tf != textFields[4] {
                            value = false
                            break
                        }
                    }else {
                        value = false
                        break
                    }
                }
            }
        }
        
        if value == true {
            btnUpdate.backgroundColor = Colors.orange.returnColor()
            btnUpdate.isUserInteractionEnabled = true
        }else {
            btnUpdate.isUserInteractionEnabled = false
            btnUpdate.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[i].text?.count)! >= MIN_USERNAME_LENGTH {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    } else {
                        lblError[i].text = Valid_Name
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }
                }
            }
            else if i == 1 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    if (textFields[i].text?.isNumber)! {
                        if !((textFields[i].text?.count)! >= MIN_MOBILE_LENGTH) {
                            lblError[i].setLeftArrow(title: Valid_Mobile)
                            value = false
                            //
                            viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                            textFields[i].titleTextColour = Colors.red.returnColor()
                            //
                        }
                        else {
                            lblError[i].text = ""
                            //
                            viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                            textFields[i].setAttributedTitle(Colors.gray.returnColor())
                            //
                        }
                    }
                }
            } else if i == 2 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if (textFields[i].text?.count)! >= MIN_USERNAME_LENGTH {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }else {
                        lblError[i].text = Valid_Name
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }
                }
            } else if i == 3 { //ABN
                if textFields[i].text == "" {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.lightGray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.lightGray.returnColor())
                    //
                }else {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                }
            } else if i == 4 { //ABN
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    if ((textFields[i].text?.count)! < ABN_LENGTH) {
                        lblError[i].text = Valid_ABN
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            }
        }
        
        return value
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            openGallary()
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func uploadProfilePic(_ sender: UIButton) {
        if fpcOptions == nil {
            fpcOptions = FloatingPanelController()
            fpcOptions.delegate = self
            fpcOptions.surfaceView.cornerRadius = 20.0
            fpcOptions.isRemovalInteractionEnabled = true
            imagePicker.delegate = self
            
            blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
            blurEffect.setValue(2, forKeyPath: "blurRadius")
            blurView.effect = blurEffect
            blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.view.addSubview(blurView)
            blurView.isHidden = true
        }
        
        let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionVC") as? ChooseOptionVC
        chooseOptionVC?.openMediaPicker = { option in
            self.fpcOptions.removePanelFromParent(animated: false)
            self.blurView.isHidden = true

            if option == 0 {
                //"Take Photo/Video"
                self.openCamera()
            } else {
                //"Choose Photo/Video"
                self.openGallary()
            }
        }
        
        chooseOptionVC?.chooseProfile = true
        fpcOptions.set(contentViewController: chooseOptionVC)
        fpcOptions.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
    }

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
        
        btnUpdate.isUserInteractionEnabled = sender.tag != 1 ? true : (textFields[4].text == "" ? true : false)
        btnUpdate.backgroundColor = sender.tag != 1 ? Colors.orange.returnColor() : (textFields[4].text != "" ? Colors.orange.returnColor() : Colors.inactiveButton.returnColor())
        viewBack[4].layer.borderColor = sender.tag != 1 ? Colors.lightGray.returnColor().cgColor : (textFields[4].text != "" ? Colors.gray.returnColor().cgColor : Colors.lightGray.returnColor().cgColor)
        textFields[4].setAttributedTitle(sender.tag != 1 ? Colors.lightGray.returnColor() : (textFields[4].text != "" ? Colors.gray.returnColor() : Colors.lightGray.returnColor()))
        
        viewBack[4].isHidden = sender.tag != 1 ? true : false
        heightTFABN.constant = sender.tag != 1 ? 0 : 60
        topTFABN.constant = sender.tag != 1 ? 0 : 24
        lblError[4].text = sender.tag != 1 ? "" : lblError[4].text
        textFields[4].title.isHidden = sender.tag != 1 ? true : false // Placeholder Label
        tvAboutUs.hint = sender.tag == 0 ? "About Me" : "About Us"

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
    
    @IBAction func onTapVerify(_ sender: UIButton) {
        view.endEditing(true)
        
        let profileVefiryVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVerifyVC") as! ProfileVerifyVC
        profileVefiryVC.mobileNumber = self.textFields[1].text!
        profileVefiryVC.ontapVerify = {
            self.isMobileVerify = true
            self.btnVerify.isHidden = true
        }
        profileVefiryVC.modalPresentationStyle = .overCurrentContext
        profileVefiryVC.modalTransitionStyle = .crossDissolve

        self.present(profileVefiryVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapUpdate(_ sender: UIButton) {
        view.endEditing(true)
        var valid = false
        if selectedType == 1 {
            valid = checkValidation(to: 0, from: 5)
        } else {
            valid = checkValidation(to: 0, from: 4)
        }
        
        if valid {
            
            if textFields[1].text != APIManager.sharedManager.user?.mobileNumber && !isMobileVerify {
                let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
                confirmPopup.titleString = "Hey,wait!"
                confirmPopup.subTitleString = "Mobile number will not be changed unless you get it verified."
                confirmPopup.yesString = "Verify Mobile No."
                confirmPopup.noString = "ignore"
                confirmPopup.tapYes = {
                    let profileVefiryVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVerifyVC") as! ProfileVerifyVC
                    profileVefiryVC.mobileNumber = self.textFields[1].text!
                    profileVefiryVC.ontapVerify = {
                        self.isMobileVerify = true
                        self.btnVerify.isHidden = true
                    }
                    profileVefiryVC.modalPresentationStyle = .overCurrentContext
                    profileVefiryVC.modalTransitionStyle = .crossDissolve

                    self.present(profileVefiryVC, animated: true, completion: nil)
//                    self.navigationController?.pushViewController(profileVefiryVC, animated: true)
                }
                confirmPopup.tapNo = {
                    self.userRegParams.updateValue(self.textFields[0].text!, forKey: "name")
                    self.userRegParams.updateValue(self.textFields[2].text!, forKey: "userName")
                    self.userRegParams.updateValue(self.textFields[3].text!, forKey: "website")
                    self.userRegParams.updateValue(self.textFields[4].text!, forKey: "ABN")
                    self.userRegParams.updateValue(self.tvAboutUs.text!, forKey: "aboutMe")
                    self.userRegParams.updateValue(self.btnTypes[self.selectedType].titleLabel!.text!, forKey: "userType")
                    self.userRegParams.updateValue(self.btnAccTypes[self.selectedAccType].titleLabel!.text!, forKey: "accountType")
                    self.userRegParams.updateValue(APIManager.sharedManager.user?.mobileNumber ?? "", forKey: "mobileNumber")
                    self.userRegParams.updateValue(APIManager.sharedManager.user?.countryCode ?? "", forKey: "countryCode")
                    self.updateProfile()
                }
                confirmPopup.modalPresentationStyle = .overCurrentContext
                confirmPopup.modalTransitionStyle = .crossDissolve
                
                self.present(confirmPopup, animated: true, completion: nil)
            }else {
                userRegParams.updateValue(textFields[0].text!, forKey: "name")
                userRegParams.updateValue(textFields[2].text!, forKey: "userName")
                userRegParams.updateValue(textFields[1].text!, forKey: "mobileNumber")
                userRegParams.updateValue(Utilities.getCountryPhoneCode(country: Locale.current.regionCode!), forKey: "countryCode")
                userRegParams.updateValue(textFields[3].text!, forKey: "website")
                userRegParams.updateValue(textFields[4].text!, forKey: "ABN")
                userRegParams.updateValue(tvAboutUs.text!, forKey: "aboutMe")
                userRegParams.updateValue(btnTypes[selectedType].titleLabel!.text!, forKey: "userType")
                userRegParams.updateValue(btnAccTypes[selectedAccType].titleLabel!.text!, forKey: "accountType")
                
                updateProfile()
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
    
    // MARK: Webservices
    func updateProfile() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.updateProfile()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.EDIT_PROFILE, parameters: userRegParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.user = response?.result?.userDetail
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadProfilePic() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadProfilePic()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.UPLOAD_PROFILE, fileName: "profilePic", image: self.ivUserProfile.image, movieDataURL: nil, params: nil) { (status, response, message) in
            self.hideLoading()
            if status {
                if response != nil {
                    APIManager.sharedManager.user?.profilePic = response!["profilePic"] as! String
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
}

extension EditProfileVC: UITextViewDelegate {

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

extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblError[textField.tag].text = ""
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == textFields[0] {
            return newString.length <= MAX_USERNAME_LENGTH
        }else if textField == textFields[2] {
            return newString.length <= MAX_USERNAME_LENGTH
        }else if textField == textFields[4] {
            if (string == " ") {
                return false
            }
            
            return newString.length <= ABN_LENGTH
        }else if textField == textFields[1] {
            if String(newString) != APIManager.sharedManager.user?.mobileNumber {
                btnVerify.isHidden = false
                isMobileVerify = false
            }else {
                btnVerify.isHidden = true
                isMobileVerify = true
            }
            
            return newString.length <= MAX_MOBILE_LENGTH
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == textFields[0] {
            textFields[1].becomeFirstResponder()
        } else if textField == textFields[1] {
            textFields[2].becomeFirstResponder()
        } else if textField == textFields[2] {
            textFields[3].becomeFirstResponder()
        }else if textField == textFields[3] {
            if selectedType == 1 {
                textFields[4].becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
        } else if textField == textFields[4] {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.ivUserProfile.image = image
            self.uploadProfilePic()
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        
        dismiss(animated: true) {
            let cropViewController = CropViewController(image: image)
            cropViewController.toolbarPosition = .top
            cropViewController.resetButtonHidden = true
            cropViewController.rotateButtonsHidden = true
            cropViewController.aspectRatioPickerButtonHidden = true
            cropViewController.aspectRatioPreset = .presetSquare
            cropViewController.aspectRatioLockEnabled = true

            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}
