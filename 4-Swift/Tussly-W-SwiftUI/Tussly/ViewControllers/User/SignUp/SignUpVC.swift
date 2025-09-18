//
//  SignUpVC.swift
//  Tussly
//
//  Created by Auxano on 04/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
//import GoogleSignIn
//import AuthenticationServices


struct Objects {
    var id : Int
    var sectionName : String!
    var sectionImage : String!
    var sectionObjects = [[String: String]]()
}

class SignUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, socialURLDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtUserName : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var txtConfirmPassword : UITextField!
    @IBOutlet weak var txtFirstName : UITextField!
    @IBOutlet weak var txtLastName : UITextField!
    @IBOutlet weak var txtDisplayName : TLTextField!
    @IBOutlet weak var tvGamerTag : UITableView!
    @IBOutlet weak var viewGametag : UIView!
    @IBOutlet weak var btnSignUp : UIButton!
    @IBOutlet weak var heightTvGamerTag : NSLayoutConstraint!
    @IBOutlet weak var lblNote : UILabel!
    @IBOutlet weak var btnSelectGametag : UIButton!
    @IBOutlet weak var lblEmailError : UILabel!
    @IBOutlet weak var lblUserNameError : UILabel!
    @IBOutlet weak var lblPasswordError : UILabel!
    @IBOutlet weak var lblConfirmPswError : UILabel!
    @IBOutlet weak var lblDisplayError : UILabel!
    @IBOutlet weak var viewDisable : UIView!
    
    @IBOutlet weak var topPassword: NSLayoutConstraint!
    @IBOutlet weak var heightPassword: NSLayoutConstraint!
    @IBOutlet weak var topConfirmPass: NSLayoutConstraint!
    @IBOutlet weak var heightConfirmPass: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightViewGamingID: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightViewGameTag: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthSocialLogin: NSLayoutConstraint!
    
    @IBOutlet weak var viewScrollInside: UIView!
    
    
    // MARK: - Variables
    var isValid = true
    var gamerData = [Objects]()
    var arrGetGamerTags = [GamerTag]()
    var selectedIndex = -1
    var selectedID = 0
    var sectionImage = ""
    var userDict = Dictionary<String, Any>()
    var isSocialLogin = false
    var socialId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGamerTags()
        viewDisable.isHidden = true
        btnSelectGametag.setTitle(Messages.selectGamertag, for: .normal)
        let attributedText = NSMutableAttributedString(string: Messages.note, attributes: [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 14.0)])
        attributedText.append(NSMutableAttributedString(string: Messages.allowAddGamerTag, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)]))
        
        // By Pranay
        //lblNote.attributedText = attributedText
        constraintHeightViewGamingID.constant = 0
        constraintHeightViewGameTag.constant = 0
        
        constraintWidthSocialLogin.constant = 10
        // .
        
        btnSignUp.layer.cornerRadius = 15.0
        viewGametag.layer.cornerRadius = 5.0
        viewGametag.layer.borderWidth = 1.0
        viewGametag.layer.borderColor = Colors.border.returnColor().cgColor
        let headerNib = UINib.init(nibName: "CustomHeader", bundle: Bundle.main)
        tvGamerTag.register(headerNib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        tvGamerTag.register(UINib(nibName: "GamerTagCell", bundle: nil), forCellReuseIdentifier: "GamerTagCell")
        tvGamerTag.delegate = self
        tvGamerTag.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvGamerTag.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewScrollInside.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvGamerTag.removeObserver(self, forKeyPath: "contentSize")
    }
    
    // MARK: - UI Methods
    
//    func configureGoogleSignIn() {
//        //GIDSignIn.sharedInstance.clientID = AppInfo.GoogleClientID.returnAppInfo()
//        //GIDSignIn.sharedInstance.delegate = self
//        //GIDSignIn.sharedInstance.presentingViewController = self
//        //GIDSignIn.sharedInstance.signIn()
//        
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: AppInfo.GoogleClientID.returnAppInfo())
//        GIDSignIn.sharedInstance.configuration = config
//     
//        //Start the sign flow
//        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result,error in
//            guard error == nil else {
//                print("Error: \(error!.localizedDescription)")
//                return
//            }
//            
//            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
//                return
//            }
//            //let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
//            
//            txtPassword.text = ""
//            txtConfirmPassword.text = ""
//            isSocialLogin = true
//            topPassword.constant = 0
//            heightPassword.constant = 0
//            topConfirmPass.constant = 0
//            heightConfirmPass.constant = 0
//            txtPassword.isHidden = true
//            txtConfirmPassword.isHidden = true
//            lblPasswordError.text = ""
//            lblConfirmPswError.text = ""
//            
//            txtEmail.text = ""
//            txtEmail.text = user.profile?.email
//            txtEmail.isUserInteractionEnabled = false
//            txtUserName.text = user.profile?.name
//            txtFirstName.text = user.profile?.familyName
//            txtLastName.text = user.profile?.givenName
//            socialId = user.userID ?? ""
//        }
//    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespaces)
                if txtEmail.text == "" {
                    lblEmailError.getEmptyValidationString(txtEmail.placeholder ?? "")
                    value = false
                }
                else {
                    if !(txtEmail.text?.isValidEmail())! {
                        lblEmailError.setLeftArrow(title: Valid_Email)
                        value = false
                    } else {
                        lblEmailError.text = ""
                    }
                }
            } else if i == 1 {
                txtUserName.text = txtUserName.text?.trimmingCharacters(in: .whitespaces)
                if txtUserName.text == "" {
                    lblUserNameError.getEmptyValidationString(txtUserName.placeholder ?? "")
                    value = false
                }
                else {
                    if (txtUserName.text?.count)! >= MIN_USERNAME_LENGTH {
                        lblUserNameError.text = ""
                    }
                    else {
                        lblUserNameError.getValidationString(txtUserName.placeholder ?? "")
                        value = false
                    }
                }
            }
            else if i == 2 {
                txtDisplayName.text = txtDisplayName.text?.trimmingCharacters(in: .whitespaces)
                if txtDisplayName.text == "" {
                    lblDisplayError.getEmptyValidationString(txtDisplayName.placeholder ?? "")
                    value = false
                }
                else {
                    lblDisplayError.text = ""
                }
            }
            else if i == 3 {
                if isSocialLogin {
                    value = true
                }
                else {
                    txtPassword.text = txtPassword.text?.trimmingCharacters(in: .whitespaces)
                    if txtPassword.text == "" {
                        lblPasswordError.getEmptyValidationString(txtPassword.placeholder ?? "")
                        value = false
                    }
                    else {
                        if (txtPassword.text?.count)! >= MIN_PASSWORD_LENGTH {
                            lblPasswordError.text = ""
                        }
                        else {
                            lblPasswordError.setLeftArrow(title: Valid_Password)
                            value = false
                        }
                    }
                }
            }
            else if i == 4 {
                if isSocialLogin {
                    value = true
                }
                else {
                    if txtConfirmPassword.text == "" {
                        lblConfirmPswError.getEmptyValidationString(txtConfirmPassword.placeholder ?? "")
                        value = false
                    }
                    else {
                        if txtPassword.text == txtConfirmPassword.text {
                            lblConfirmPswError.text = ""
                        }
                        else {
                            lblConfirmPswError.setLeftArrow(title: Confirm_Password_Not_Match)
                            value = false
                        }
                    }
                }
            }
        }
        
        return value
    }
    
    func checkEmptyField(section: Int) -> Bool {
        var value = true
        for i in 0..<gamerData[section].sectionObjects.count {
            if gamerData[section].sectionObjects[i]["value"] == "" {
                value = false
                break
            }
        }
        return value
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTvGamerTag.constant = newsize.height
                self.updateViewConstraints()
                
            }
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapGoogleSignin(_ sender: UIButton) {
        self.view.endEditing(true)
        //configureGoogleSignIn()
    }
    
    @IBAction func onTapUseSameForDisplayName(_ sender: UIButton) {
        if txtUserName.text != "" {
            lblUserNameError.text = ""
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                self.txtDisplayName.isHideBottomLine = true
                txtDisplayName.text = txtUserName.text
                txtDisplayName.isEnabled = false
                viewDisable.isHidden = false
            } else {
                self.txtDisplayName.isHideBottomLine = false
                txtDisplayName.text = ""
                txtDisplayName.isEnabled = true
                viewDisable.isHidden = true
            }
            if txtDisplayName.text == "" {
                lblDisplayError.getEmptyValidationString(txtDisplayName.placeholder ?? "")
            } else {
                lblDisplayError.text = ""
            }
        } else {
            lblUserNameError.getEmptyValidationString(txtUserName.placeholder ?? "")
        }
    }
    
    @IBAction func onTapSignUp(_ sender: UIButton) {
        view.endEditing(true)
        
        let valid = checkValidation(to: 0, from: 5)
        
        isValid = valid
        
        for i in 0..<gamerData.count {
            let sectionData = gamerData[i].sectionObjects
            for i in 0..<sectionData.count {
                if sectionData[i]["value"] == "" {
                    isValid = false
                    break
                }
            }
            if !isValid {
                break
            }
        }
        
        if !isValid {
            tvGamerTag.reloadData()
            return
        }
        tvGamerTag.reloadData()
        
        userSignUp()
        
        //self.configureGoogleSignIn()
        
        //self.appleLogin()
    }
    
    @IBAction func onTapSelectGametag(_ sender: UIButton) {
        ////Beta 1 - disable option
        ///Remove comment to enable button.
        self.view.endEditing(true)
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.gamerTag = arrGetGamerTags
        objVC.titleTxt = Messages.selectGamertag
        objVC.didSelectItem = { index,isImgPicker in
            self.selectedIndex = index
            self.selectedID = self.arrGetGamerTags[index].id
            self.sectionImage = self.arrGetGamerTags[index].consoleIcon!
            self.btnSelectGametag.setTitle("\(self.arrGetGamerTags[index].consoleName ?? "")", for: .normal)
        }
        objVC.selectedIndex = selectedIndex
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAppleLogin(_ sender: UIButton) {
       
    }
    
//    func appleLogin() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//    }
    
    @IBAction func onTapDiscordTwitchLogin(_ sender: UIButton) {
        let socialLogin = SocialLoginVC()
        socialLogin.isDiscoredLogin = sender.tag
        socialLogin.delegate = self
        self.navigationController?.pushViewController(socialLogin, animated: true)
    }
    
    @IBAction func onTapAddGamerTag(_ sender: UIButton) {
        if selectedIndex != -1 {
            if !gamerData.contains(where: { $0.sectionName == btnSelectGametag.titleLabel?.text}) {
                gamerData.append(Objects(id: selectedID, sectionName: btnSelectGametag.titleLabel?.text, sectionImage: sectionImage , sectionObjects: [["value":"","status":"Public"]]))
                if isValid {
                    self.tvGamerTag.reloadData()
                } else {
                    self.tvGamerTag.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                        self.isValid = true
                        self.tvGamerTag.reloadSections([self.gamerData.count-1], with: .automatic) // Milan
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                            self.isValid = false
                        }
                        
                    }
                }
                //self.tvGamerTag.reloadData()
                
                //Jaimesh
                arrGetGamerTags = arrGetGamerTags.map{
                    var mutGamerTag = $0
                    print((btnSelectGametag.titleLabel?.text)!)
                    if $0.consoleName == (btnSelectGametag.titleLabel?.text)! {
                        mutGamerTag.isSelected = true
                    }
                    return mutGamerTag
                }
                
                btnSelectGametag.setTitle(Messages.selectGamertag, for: .normal)
                selectedIndex = -1
            }
        }
    }
    
    // MARK: UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField == txtUserName && viewDisable.isHidden == false {
            txtDisplayName.text = newString as String
        }
        
        if textField == txtPassword {
            return newString.length <= MAX_PASSWORD_LENGTH
        }else if textField == txtEmail {
            if (txtEmail.text?.isNumber)! {
                return newString.length <= MAX_MOBILE_LENGTH
            }else {
                return true
            }
        }else {
            return true
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
        if textField == txtEmail {
            txtUserName.becomeFirstResponder()
        } else if textField == txtUserName {
            if viewDisable.isHidden {
                txtDisplayName.becomeFirstResponder()
            } else {
                txtPassword.becomeFirstResponder()
            }
        } else if textField == txtDisplayName {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtConfirmPassword.becomeFirstResponder()
        } else if textField == txtConfirmPassword {
            txtFirstName.becomeFirstResponder()
        } else if textField == txtFirstName {
            txtLastName.becomeFirstResponder()
        } else if textField == txtLastName {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return gamerData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamerData.count == 0 ? 0 : gamerData[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GamerTagCell", for: indexPath) as! GamerTagCell
        cell.index = indexPath.row
        cell.section = indexPath.section
        cell.btnStatus.isSelected = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"] == "Public" ? false : true
        cell.txtPlaystation.placeholder = "Enter \(gamerData[indexPath.section].sectionName.replacingOccurrences(of: "Account", with: "")) Name"
        cell.txtPlaystation.text = gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"]
        cell.lblSwitchStatus.text = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"]
        
        if isValid {
            cell.lblError.text = ""
        } else {
            if gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"] == "" {
                cell.lblError.setLeftArrow(title: "Please enter \(gamerData[indexPath.section].sectionName ?? "") Name")
            } else {
                cell.lblError.text = ""
            }
        }
        
        cell.getPlaystationName = { playStationName,index,section in
            self.gamerData[section].sectionObjects[index]["value"] = playStationName
            for i in 0..<self.gamerData.count {
                let sectionData = self.gamerData[i].sectionObjects
                for i in 0..<sectionData.count {
                    if sectionData[i]["value"] == "" {
                        self.isValid = false
                        break
                    } else {
                        self.isValid = true
                    }
                }
                if !self.isValid {
                    self.tvGamerTag.reloadSections([section], with: .automatic)
                    return
                }
            }
            self.tvGamerTag.reloadSections([section], with: .automatic)
        }
        
        cell.onTapRemovePlaystation = { index, section in
            self.view.endEditing(true)
            self.gamerData[section].sectionObjects.remove(at: index)
            if self.gamerData[section].sectionObjects.count == 0 {
                self.arrGetGamerTags = self.arrGetGamerTags.map{
                    var mutGamerTag = $0
                    if $0.consoleName == self.gamerData[section].sectionName {
                        mutGamerTag.isSelected = false
                    }
                    return mutGamerTag
                }
                self.gamerData.remove(at: section)
            }
            self.tvGamerTag.reloadData()
        }
        
        cell.onTapSwitch = { status,index,section in
            self.gamerData[section].sectionObjects[index]["status"] = status
            self.tvGamerTag.reloadSections([section], with: .automatic)
            //self.tvGamerTag.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if gamerData.count != 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
            headerView.customLabel.text = "\(gamerData[section].sectionName ?? "") Account"
            
            headerView.customImage.setImage(imageUrl: gamerData[section].sectionImage)
            headerView.sectionNumber = section
            headerView.onTapAddAccount = { section in
                if self.checkEmptyField(section: section) {
                    self.isValid = true
                    //Jaimesh
                    
                    self.gamerData[section].sectionObjects.insert(["value":"","status":"Public"], at: 0)
                    //
                } else {
                    self.isValid = false
                }
                self.tvGamerTag.reloadSections([section], with: .automatic)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if gamerData.count != 0 {
            return 66
        }
        return 0
    }
    
    // MARK: Webservices
    
    func userSignUp() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userSignUp()
                }
            }
            return
        }
        
        var selectedTag = [[String: Any]]()
        for i in 0..<gamerData.count {
            let id = gamerData[i].id
            let numberOfTags = gamerData[i].sectionObjects
            for j in 0..<numberOfTags.count {
                selectedTag.append(["gameConsoleId":id,"gameTags":numberOfTags[j]["value"]!,"isPublic":numberOfTags[j]["status"] == "Public" ? 1 : 0])
            }
        }
        
        userDict = ["email": txtEmail.text!,
                    "type": txtEmail.text!.isNumber ? "mobileNo" : "email",
                    "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                    "userName": txtUserName.text!,
                    "password" : txtPassword.text!,
                    "confirmPassword" : txtConfirmPassword.text!,
                    "firstName" : txtFirstName.text!,
                    "lastName" : txtLastName.text!,
                    "displayName" : txtDisplayName.text!,
                    "fcmToken" : UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
                    "deviceId" : AppInfo.DeviceId.returnAppInfo(),
                    "platform" : AppInfo.Platform.returnAppInfo(),
                    "gamerTags": selectedTag,
                    "socialType": isSocialLogin ? "GOOGLE" : "",
                    "socialId": isSocialLogin ? socialId : "",
                    "timeZoneOffSet": (TimeZone.current).offsetFromGMT()
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SIGNUP, parameters: userDict) { (response: ApiResponse?, error) in
            //self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    /*/// 442 - By Pranay - Comment below code by pranay to by pass otp verification.
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                    objVC.isForgotPassword = false
                    objVC.responseOTP = Int((response?.result?.otp)!)!
                    objVC.userEmail = self.txtEmail.text!.isNumber ? "" : self.txtEmail.text!
                    objVC.mobileNumber = self.txtEmail.text!.isNumber ? self.txtEmail.text! : ""
//                    objVC.password = self.txtPassword.text!
                    self.navigationController?.pushViewController(objVC, animated: true)
                    /// 442 .   */
                    /// 443 - By Pranay - added by pranay
                    self.verifyOTP()
                    /// 443 .
                }
            } else {
                self.hideLoading()  //  - By Pranay
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getToken(token: String) {
        APIManager.sharedManager.authToken = token
        UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
        UserDefaults.standard.synchronize()
        getUserDetails()
    }
    
    func getUserDetails() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getUserDetails()
                }
            }
            return
        }
        showLoading()
        // By Pranay
        let param = [
            "timeZoneOffSet" : (TimeZone.current).offsetFromGMT(),
            "deviceId": AppInfo.DeviceId.returnAppInfo(),
            "deviceName": UIDevice.modelName,
            "deviceOS": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ]
        // .
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_USER_DETAIL, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                DispatchQueue.main.async {
                    self.view!.tusslyTabVC.selectedIndex = 0
                    self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getGamerTags() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGamerTags()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMER_TAGS, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.arrGetGamerTags = (response?.result?.gameTags)!
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func verifyOTP() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.verifyOTP()
                }
            }
            return
        }
        
        let dictParms = ["email": txtEmail.text!,
                         "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
                         "type": txtEmail.text!.isNumber ? "mobileNo" : "email",
                         "otp": 1111,
                         "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
                         "platform": AppInfo.Platform.returnAppInfo(),
                         "deviceId": AppInfo.DeviceId.returnAppInfo(),
                         "sendWelcomeMail": 1] as [String : Any]
        //showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.VERIFY_OTP, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                APIManager.sharedManager.strChatUserId = "\(response?.result?.userDetail?.id ?? 0)"
                UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    if appDelegate.isAutoLogin == false {
                        self.view!.tusslyTabVC.selectedIndex = 0
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            }
            else {
                self.hideLoading()
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - GIDSignInUIDelegate
//extension SignUpVC {
//    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if(user != nil) {
//            txtPassword.text = ""
//            txtConfirmPassword.text = ""
//            isSocialLogin = true
//            topPassword.constant = 0
//            heightPassword.constant = 0
//            topConfirmPass.constant = 0
//            heightConfirmPass.constant = 0
//            txtPassword.isHidden = true
//            txtConfirmPassword.isHidden = true
//            lblPasswordError.text = ""
//            lblConfirmPswError.text = ""
//            
//            txtEmail.text = ""
//            txtEmail.text = user.profile?.email
//            txtEmail.isUserInteractionEnabled = false
//            txtUserName.text = user.profile?.name
//            txtFirstName.text = user.profile?.familyName
//            txtLastName.text = user.profile?.givenName
//            socialId = user.userID ?? ""
//        }
//    }
//    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        print("Error: \(error.localizedDescription)")
//    }
//}

//extension SignUpVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let userIdentifier = credential.user
//            let fullName = credential.fullName
//            let email = credential.email
//
//            print("✅ Apple Sign In Success")
//            print("User ID: \(userIdentifier)")
//            print("Email: \(email ?? "Not available")")
//            print("Name: \((fullName?.givenName ?? "") + " " + (fullName?.familyName ?? ""))")
//            
//            // You can now save userIdentifier securely for future login
//            
//            txtPassword.text = ""
//            txtConfirmPassword.text = ""
//            isSocialLogin = true
//            topPassword.constant = 0
//            heightPassword.constant = 0
//            topConfirmPass.constant = 0
//            heightConfirmPass.constant = 0
//            txtPassword.isHidden = true
//            txtConfirmPassword.isHidden = true
//            lblPasswordError.text = ""
//            lblConfirmPswError.text = ""
//            
//            txtEmail.text = ""
//            txtEmail.text = email ?? ""
//            txtEmail.isUserInteractionEnabled = false
//            txtUserName.text = "\(fullName?.givenName ?? "")\(fullName?.familyName ?? "")"
//            txtFirstName.text = fullName?.givenName ?? ""
//            txtLastName.text = fullName?.familyName ?? ""
//            socialId = userIdentifier
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("❌ Apple Sign-In failed: \(error.localizedDescription)")
//    }
//
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//}
