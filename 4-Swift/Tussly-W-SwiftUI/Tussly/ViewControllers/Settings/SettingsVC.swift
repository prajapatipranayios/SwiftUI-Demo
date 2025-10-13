//
//  SettingsVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 04/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CropViewController
import CometChatSDK
import SwiftUI


class SettingsVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    @IBOutlet weak var ivCamera: UIImageView!
    @IBOutlet weak var txtDisplayName : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtUserName : UITextField!
    @IBOutlet weak var txtFirstName : UITextField!
    @IBOutlet weak var txtLastName : UITextField!
    @IBOutlet weak var txtGender : UITextField!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var btnSave : UIButton!
    @IBOutlet weak var heightBtnSave : NSLayoutConstraint!
    @IBOutlet weak var topBtnSave : NSLayoutConstraint!
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblDote : UILabel!
    @IBOutlet weak var lblDisplayNameError : UILabel!
    @IBOutlet weak var lblEmailError : UILabel!
    @IBOutlet weak var lblUserNameError : UILabel!
    @IBOutlet weak var lblFirstNameError : UILabel!
    @IBOutlet weak var lblLastNameError : UILabel!
    @IBOutlet weak var lblGenderError : UILabel!
    @IBOutlet weak var btnLayer : UIButton!
    @IBOutlet weak var viewDisable: UIView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var txtGenderDisable: TLTextField!
    
    @IBOutlet weak var viewScrollInside: UIView!
    
    
    // MARK: - Variables
    
    var isTABPressed: ((Bool, Int?)->Void)?
    var saveSettingData: (()->Void)?
    var selectedGender: Gender?
    let imagePickerController =  UIImagePickerController()
    var isLogOutTap = false
    
    var isAlreadyValidated: Bool = false
    
    var tusslyTabVC: (()->TusslyTabVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tusslyTabVC!().logoLeadingConstant = 16
        tusslyTabVC!().reloadTopBar()
//        txtGenderDisable.isHideBottomLine = true
//        imagePickerController.delegate = self
//        imagePickerController.modalPresentationStyle = .overFullScreen
//        DispatchQueue.main.async {
//            self.ivCamera.layer.cornerRadius = self.ivCamera.frame.size.width/2
//            self.ivCamera.layer.shadowColor = UIColor.black.cgColor
//            self.ivCamera.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
//            self.ivCamera.layer.shadowOpacity = 0.2
//            self.ivCamera.layer.shadowRadius = 5.0
//            self.ivCamera.layer.masksToBounds = false
//            
//            self.btnSave.layer.cornerRadius = 15.0
//            self.ivLogo.layer.cornerRadius = self.ivLogo.frame.size.width / 2
//            self.ivLogo.layer.masksToBounds = true
//            self.btnLayer.layer.borderWidth = 5.0
//            self.btnLayer.layer.cornerRadius = self.btnLayer.frame.size.width / 2
//            self.btnLayer.layer.borderColor = Colors.lightGray.returnColor().cgColor
//            self.btnLayer.layer.masksToBounds = true
//        }
        
        let hostingController = UIHostingController(rootView: SettingsView())
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        scrlView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
//
//        if isAlreadyValidated {
//            isAlreadyValidated = false
//            return
//        }
//
//        heightBtnSave.constant = 0
//        topBtnSave.constant = 0
//        btnSave.isHidden = true
//        self.lblDisplayNameError.text = ""
//        self.lblFirstNameError.text = ""
//        self.lblLastNameError.text = ""
//        isLogOutTap = false
//        isTABPressed = { status, leagueIndex in
//            if status {
//                if self.isLogOutTap == false {
//                    if (APIManager.sharedManager.user != nil) {
//                        if self.txtDisplayName.text != APIManager.sharedManager.user?.displayName || self.txtFirstName.text != APIManager.sharedManager.user?.firstName || self.txtLastName.text != APIManager.sharedManager.user?.lastName || self.txtGender.text != APIManager.sharedManager.user?.genderText || self.genderString(type: self.selectedGender != nil ? self.selectedGender!.rawValue : -1) != APIManager.sharedManager.user?.gender {
//
//                            self.view!.tusslyTabVC.settingsUpdated = true// Jaimesh
//                            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "SaveProfileDialog") as! SaveProfileDialog
//                            dialog.modalPresentationStyle = .overCurrentContext
//                            dialog.modalTransitionStyle = .crossDissolve
//
//                            dialog.tapSave = {
//                                if self.checkValidation(to: 0, from: 4) {
//                                    self.view.endEditing(true)
//                                    self.updateUserProfile(isSaveChange: true, leagueIndex: leagueIndex!)
//                                } else {
//                                    self.isAlreadyValidated = true //Jaimesh
//                                    self.view!.tusslyTabVC.settingsUpdated = false// Jaimesh
//                                    self.view.tusslyTabVC.selectedIndex = 8
//                                    self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[self.view.tusslyTabVC.selectedIndex])
//                                }
//                            }
//
//                            dialog.tapNotSave = {
//                                DispatchQueue.main.async {
//                                    self.view!.tusslyTabVC.settingsUpdated = false// Jaimesh
//                                    print(self.view.tusslyTabVC.selectedIndex)
//                                    if leagueIndex != -1 {
//                                        self.view!.tusslyTabVC.customeView?.didSelectLeague!(leagueIndex!)
//                                    } else {
//                                        self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[self.view.tusslyTabVC.selectedIndex])
//                                    }
//                                }
//
//                                self.txtDisplayName.text = APIManager.sharedManager.user?.displayName
//                                self.txtFirstName.text = APIManager.sharedManager.user?.firstName
//                                self.txtLastName.text = APIManager.sharedManager.user?.lastName
//                                self.txtGender.text = APIManager.sharedManager.user?.genderText
//                                switch APIManager.sharedManager.user?.gender {
//                                case "MALE":
//                                    self.onTapGender(self.buttons[0])
//                                    break
//                                case "FEMALE":
//                                    self.onTapGender(self.buttons[1])
//                                    break
//                                case "OTHER":
//                                    self.onTapGender(self.buttons[2])
//                                    self.viewDisable.isHidden = true
//                                    self.txtGenderDisable.isHidden = true
//                                    self.txtGender.isHidden = false
//                                    break
//                                case "PREFER NOT TO SAY":
//                                    self.onTapGender(self.buttons[3])
//                                    break
//                                default:
//                                    //self.onTapGender(self.buttons[3])
//                                    break
//                                }
//                            }
//
//                            dialog.tapCancel = {
//                                self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[8])
//                            }
//
//                            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
//                        } else {
//
//                        }
//                    }
//                }
//            }
//        }
//
//        for i in 0..<buttons.count {
//            buttons[i].isSelected = false
//        }
//
//        selectedGender = nil
//        self.viewDisable.isHidden = false
//        self.txtGenderDisable.isHidden = false
//        txtGender.isHidden = true
//        if APIManager.sharedManager.user != nil {
//            if APIManager.sharedManager.user!.mobileNo == "" {
//                txtEmail.placeholder = "Email Address"
//            } else {
//                txtEmail.placeholder = "Phone Number"
//            }
//            ivLogo.setImage(imageUrl: APIManager.sharedManager.user!.avatarImage)
//            txtDisplayName.text = APIManager.sharedManager.user?.displayName
//            txtEmail.text = APIManager.sharedManager.user?.email == "" ? APIManager.sharedManager.user?.mobileNo : APIManager.sharedManager.user?.email
//            txtEmail.isEnabled = false
//            txtUserName.isEnabled = false
//            txtUserName.text = APIManager.sharedManager.user?.userName
//            txtFirstName.text = APIManager.sharedManager.user?.firstName
//            txtLastName.text = APIManager.sharedManager.user?.lastName
//
//            switch APIManager.sharedManager.user?.gender {
//                case "MALE":
//                    onTapGender(buttons[0])
//                    break
//                case "FEMALE":
//                    onTapGender(buttons[1])
//                    break
//                case "OTHER":
//                    onTapGender(buttons[2])
//                    self.viewDisable.isHidden = true
//                    self.txtGenderDisable.isHidden = true
//                    txtGender.isHidden = false
//                    txtGender.text = APIManager.sharedManager.user?.genderText
//                    break
//                case "PREFER NOT TO SAY":
//                    onTapGender(buttons[3])
//                    break
//                default:
//                    break
//            }
//        } else {
//            ivLogo.image = UIImage.init(named: "Default")
//            txtDisplayName.text = ""
//            txtEmail.text = ""
//            txtEmail.isEnabled = false
//            txtUserName.isEnabled = false
//            txtUserName.text = ""
//            txtFirstName.text = ""
//            txtLastName.text = ""
//            txtGender.text = ""
//        }
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
//        tapGesture.cancelsTouchesInView = false
//        tapGesture.delegate = self
//        self.viewScrollInside.addGestureRecognizer(tapGesture)
//    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func valueUpdate() {
        if self.txtDisplayName.text != APIManager.sharedManager.user?.displayName || self.txtFirstName.text != APIManager.sharedManager.user?.firstName || self.txtLastName.text != APIManager.sharedManager.user?.lastName || self.txtGender.text != APIManager.sharedManager.user?.genderText || self.genderString(type: self.selectedGender != nil ? self.selectedGender!.rawValue : -1) != APIManager.sharedManager.user?.gender {
            heightBtnSave.constant = 50
            topBtnSave.constant = 20
            btnSave.isHidden = false
        } else {
            heightBtnSave.constant = 0
            topBtnSave.constant = 0
            btnSave.isHidden = true
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                txtDisplayName.text = txtDisplayName.text?.trimmingCharacters(in: .whitespaces)
                if txtDisplayName.text == "" {
                    lblDisplayNameError.getEmptyValidationString(txtDisplayName.placeholder ?? "")
                    value = false
                }else {
                    lblDisplayNameError.text = ""
                }
            } else if i == 1 {
                if genderString(type: selectedGender!.rawValue) == "OTHER" {
                    txtGender.text = txtGender.text?.trimmingCharacters(in: .whitespaces)
                    if txtGender.text == "" {
                        lblGenderError.setLeftArrow(title: Empty_Gender)
                        value = false
                    }else {
                        lblGenderError.text = ""
                    }
                } else {
                    lblGenderError.text = ""
                }
            }
        }
        return value
    }
    
    func genderString(type: Int) -> String {
        if type == 0 {
            return "MALE"
        } else if type == 1 {
            return "FEMALE"
        } else if type == 2 {
            return "OTHER"
        } else if type == 3 {
            return "PREFER NOT TO SAY"
        } else {
            return ""
        }
    }
    
    func openCamera() {
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapGender(_ sender: UIButton) {
        lblGenderError.text = ""
        buttons[sender.tag].isSelected = true
        selectedGender = Gender(rawValue: sender.tag)!
        for i in 0..<buttons.count {
            if sender.tag != i {
                buttons[i].isSelected = false
            }
        }
        if sender.tag == 2 {
            self.viewDisable.isHidden = true
            self.txtGenderDisable.isHidden = true
            txtGender.isHidden = false
            txtGender.text = APIManager.sharedManager.user?.genderText
        } else {
            self.viewDisable.isHidden = false
            self.txtGenderDisable.isHidden = false
            txtGender.isHidden = true
            txtGender.text = ""
        }
        valueUpdate()
    }
    
    @IBAction func onTapCamera(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = Messages.uploadProfilePhoto
        objVC.option = ["Camera","Gallery"]
        objVC.didSelectItem = {index,isImgPicker in
            switch index {
            case 0:
                self.openCamera()
            case 1:
                self.openGallary()
            default:
                break
            }
        }
        objVC.isImgPicker = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.view.rootNavController.pushViewController(objVC, animated: true)
    }
    
    @IBAction func logout(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.logout
        dialog.message = Messages.sureWantToLogout
        dialog.btnYesText = Messages.yes
        dialog.btnNoText = Messages.no
        dialog.tapOK = {
            self.isLogOutTap = true
            //self.userLogout()
            //self.cometChatLogout()
            self.cometChatUnregisterPushToken()
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        if self.checkValidation(to: 0, from: 4) {
            view.endEditing(true)
            updateUserProfile(isSaveChange: false)
        }
    }
    
    func cometChatUnregisterPushToken() {
        CometChatNotifications.unregisterPushToken { success in
            print("unregisterPushToken: \(success)")
            self.cometChatLogout()
        } onError: { error in
            print("unregisterPushToken: \(error.errorCode) \(error.errorDescription)")
            self.cometChatLogout()
        }
    }
    
    func cometChatLogout(count: Int = 1)  {
        print("Logout tapped...")
        if CometChat.getLoggedInUser() != nil {
            CometChat.logout { Response in
                print("CometChat Logout successful.")
                self.userLogout()
            } onError: { (error) in
                print("CometChat Logout failed with error: " + error.errorDescription);
                let temp = count + 1
                if temp < 3 {
                    self.cometChatLogout(count: temp)
                }
                else {
                    Utilities.showPopup(title: "Chat service is temporarily unavailable.", type: .error)
                    self.userLogout()
                }
            }
        }
        else {
            self.userLogout()
        }
    }
    
    @IBAction func btnDeleteAccount(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.DeleteAccount
        dialog.message = Messages.ConfirmAccountDelete
        dialog.btnYesText = Messages.yes
        dialog.btnNoText = Messages.no
        dialog.tapOK = {
            self.isLogOutTap = true
            //self.userLogout()
            self.userAccountDelete()
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    
    func updateUserProfile(isSaveChange: Bool, leagueIndex: Int = -1) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.updateUserProfile(isSaveChange: isSaveChange)
                }
            }
            return
        }
        
        showLoading()
        let params = ["displayName": (txtDisplayName.text?.trimmedString)!,
                      "firstName": (txtFirstName.text?.trimmedString)!,
                      "lastName": (txtLastName.text?.trimmedString)!,
                      "gender": genderString(type: selectedGender!.rawValue),
                      "genderText": (txtGender.text?.trimmedString)!
            ] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.EDIT_PROFILE, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.user = response?.result?.userDetail
                    self.topBtnSave.constant = 0
                    self.heightBtnSave.constant = 0
                    self.btnSave.isHidden = true
                    if isSaveChange {
                        self.view!.tusslyTabVC.settingsUpdated = false// Jaimesh
                        if leagueIndex != -1 {
                            self.view!.tusslyTabVC.customeView?.didSelectLeague!(leagueIndex)
                        } else {
                            self.view!.tusslyTabVC.didPressTab(self.view.tusslyTabVC.buttons[self.view.tusslyTabVC.selectedIndex])
                        }
                    }
                    Utilities.showPopup(title: "Profile edited successfully", type: .success)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func userLogout() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userLogout()
                }
            }
            return
        }
        
        showLoading()
        
        let param = [
            "deviceId": AppInfo.DeviceId.returnAppInfo()
        ] as [String: Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LOGOUT, parameters: param) { (response: ApiResponse?, error) in
            if ((response?.status) != nil) {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                self.hideLoading()
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
            APIManager.sharedManager.user = nil
            APIManager.sharedManager.authToken = ""
            UserDefaults.standard.removeObject(forKey: UserDefaultType.accessToken)
            UserDefaults.standard.synchronize()
            // By Pranay
            //APIManager.sharedManager.intNotificationCount = 0
            UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
            self.tusslyTabVC!().notificationCount()
            self.tusslyTabVC!().chatNotificationCount()
            // .
            DispatchQueue.main.async {
                appDelegate.isAutoLogin = false
                self.view.tusslyTabVC.selectedIndex = 0
                self.view!.tusslyTabVC.leagueConsoleId = -1
                self.view!.tusslyTabVC.logoLeadingConstant = 16
                self.hideLoading()
                appDelegate.isAutoLogin = false
                self.view.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: false)
            }
        }
    }
    
    func userAccountDelete() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userAccountDelete()
                }
            }
            return
        }
        
        showLoading()
        
        let param = [
            "deviceId": AppInfo.DeviceId.returnAppInfo()
        ] as [String: Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_ACCOUNT, parameters: param) { (response: ApiResponse?, error) in
        
            if ((response?.status) != nil) {
                if response?.status == 1 {
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    
                    APIManager.sharedManager.user = nil
                    APIManager.sharedManager.authToken = ""
                    UserDefaults.standard.removeObject(forKey: UserDefaultType.accessToken)
                    UserDefaults.standard.synchronize()
                    // By Pranay
                    //APIManager.sharedManager.intNotificationCount = 0
                    UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
                    self.tusslyTabVC!().notificationCount()
                    // .
                    DispatchQueue.main.async {
                        appDelegate.isAutoLogin = false
                        self.view.tusslyTabVC.selectedIndex = 0
                        self.view!.tusslyTabVC.leagueConsoleId = -1
                        self.view!.tusslyTabVC.logoLeadingConstant = 16
                        self.hideLoading()
                        self.view.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: false)
                    }
                }
                else {
                    self.hideLoading()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
            else {
                self.hideLoading()
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadImage(type : String,image: UIImage) {
        showLoading()
        APIManager.sharedManager.uploadImage(url: APIManager.sharedManager.UPLOAD_IMAGE, fileName: "image", image: image, type: type, id: APIManager.sharedManager.user!.id) { (success, response, message) in
            self.hideLoading()
            if success {
                APIManager.sharedManager.user?.avatarImage = response!["filePath"] as! String
                print(response!["filePath"] as Any)
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
    
}

extension SettingsVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        self.dismiss(animated: true) {
            let cropViewController = CropViewController(image: image)
            cropViewController.toolbarPosition = .top
            cropViewController.resetButtonHidden = true
            cropViewController.rotateButtonsHidden = true
            cropViewController.aspectRatioPickerButtonHidden = true
            cropViewController.delegate = self
            let navController = UINavigationController(rootViewController: cropViewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.ivLogo.image = image
            self.uploadImage(type: "AvatarImage", image: image)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension SettingsVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if textField == txtGender {
            return newString.length <= 15
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
            valueUpdate()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == txtDisplayName {
            txtFirstName.becomeFirstResponder()
        } else if textField == txtFirstName {
            txtLastName.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}
