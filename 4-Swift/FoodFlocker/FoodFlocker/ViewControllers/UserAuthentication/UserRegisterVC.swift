//
//  UserRegisterVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 21/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CropViewController

class UserRegisterVC: UIViewController {

    //Outlets
    @IBOutlet weak var ivUserProfile: UIImageView!
    @IBOutlet weak var ivAddProfile: UIImageView!
    
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewImageBackground: UIView!
    
    var email: String = ""
    var mobileNo: String = ""
    let imagePicker =  UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        textFields[0].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[1].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[2].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[3].setAttributedPlaceholder(Colors.lightGray.returnColor())

        DispatchQueue.main.async {
            self.ivUserProfile.layer.cornerRadius = self.ivUserProfile.frame.size.height / 2
            self.viewImageBackground.layer.cornerRadius = self.viewImageBackground.frame.size.height / 2
            
            self.viewImageBackground.layer.masksToBounds = false
            self.viewImageBackground.layer.shadowColor = Colors.lightGray.returnColor().cgColor
            self.viewImageBackground.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.viewImageBackground.layer.shadowOpacity = 0.7
            self.viewImageBackground.layer.shadowRadius = 5.0
        }
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
        }
        btnNext.layer.cornerRadius = 30.0
        
        viewBack[1].layer.borderColor = Colors.gray.returnColor().cgColor
        textFields[1].setAttributedTitle(Colors.gray.returnColor())

        if email != "" {
//            tfEmail.text = email
        } else if mobileNo != "" {
            textFields[1].text = mobileNo
        }
        
        let btnPass = UIButton()
        btnPass.setImage(UIImage(named: "HideEye"), for: .normal)
        btnPass.setImage(UIImage(named: "ShowEye"), for: .selected)
        btnPass.addTarget(self, action: #selector(showPassword(btn:)), for: .touchUpInside)
        btnPass.tag = 1
        btnPass.contentHorizontalAlignment = .right
        btnPass.frame = CGRect(x: textFields[3].frame.width - textFields[3].frame.height, y: 0, width: textFields[3].frame.height, height: textFields[3].frame.height)
        textFields[3].rightView = btnPass
        textFields[3].rightViewMode = .always
        
        btnNext.isUserInteractionEnabled = false
        btnNext.backgroundColor = Colors.inactiveButton.returnColor()
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    // MARK: - UI Methods
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
    
    // Display password to User on tap of Eye button
    @objc func showPassword(btn: UIButton) {
        if btn.tag == 1 {
            btn.isSelected = !btn.isSelected
            textFields[3].isSecureTextEntry = btn.isSelected ? false : true
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
                    }else {
                        lblError[i].text = Valid_Name
//                            .getValidationString(textFields[i].placeholder ?? "")
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }
                    //
                }
            }
//            else if i == 1 {
//                tfEmail.text = tfEmail.text?.trimmingCharacters(in: .whitespaces)
//                if tfEmail.text == "" {
//                    lblEmailError.getEmptyValidationString(tfEmail.placeholder ?? "")
//                    value = false
//                } else {
//                    if !(tfEmail.text?.isValidEmail())! {
//                        lblEmailError.setLeftArrow(title: Valid_Email)
//                        value = false
//                    } else {
//                        lblEmailError.text = ""
//                    }
//                }
//            }
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
                
            } else if i == 3 {
                
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
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
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
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Choose Photo", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openGallary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        view.endEditing(true)
        let valid = checkValidation(to: 0, from: 4)

        if valid {
            //profilePic
            let userDict = [
                        "deviceToken" : AppInfo.DeviceId.returnAppInfo(),
                        "fcmToken" : UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String,
                        "name": textFields[0].text!,
                        "userName": textFields[2].text!,
//                        "email": tfEmail.text!,
                        "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                        "mobileNumber": textFields[1].text!,
                        "userType": "",
                        "accountType": "",
                        "ABN": "",
                        "deviceType": "Ios",
                        "password": textFields[3].text!,
                        "aboutMe": ""
            ]
            performSegue(withIdentifier: "toCompleteRegistration", sender: userDict)
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is CompleteRegistrationVC {
            let destVC = segue.destination as! CompleteRegistrationVC
            destVC.userRegParams = sender as! [String : Any]
            destVC.userProfileImg = self.ivUserProfile.image
        }
    }
}

extension UserRegisterVC: UITextFieldDelegate {
    
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
        }else if textField == textFields[3] {
            if (string == " ") {
                return false
            }
            
            return newString.length <= MAX_PASSWORD_LENGTH
        }else if textField == textFields[1] {
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
//        } else if textField == tfEmail {
//            tfMobNo.becomeFirstResponder()
        } else if textField == textFields[1] {
            textFields[2].becomeFirstResponder()
        } else if textField == textFields[2] {
            textFields[3].becomeFirstResponder()
        } else if textField == textFields[3] {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
}

extension UserRegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.ivUserProfile.image = image
            self.ivAddProfile.image = UIImage(named: "edit_icon")
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
//            let navController = UINavigationController(rootViewController: cropViewController)
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
