//
//  LoginVC.swift
//  Tussly
//

import UIKit
import GoogleSignIn
import WebKit
//import AuthenticationServices

//class LoginVC: UIViewController, UITextFieldDelegate, socialURLDelegate, ASAuthorizationControllerDelegate, UIGestureRecognizerDelegate {
class LoginVC: UIViewController, UITextFieldDelegate, socialURLDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var btnLogin : UIButton!
    @IBOutlet weak var btnRemMe : UIButton!
    @IBOutlet weak var btnGoogle : GIDSignInButton!
    @IBOutlet weak var lblEmailError : UILabel!
    @IBOutlet weak var lblPasswordError : UILabel!
    
    @IBOutlet weak var viewScrollInside: UIView!
    
    
    // MARK: - Variables
    var txtTemp = UITextField()
    var userDict = Dictionary<String, Any>()
    var remMe: Bool = false
    
    var initialVC: (()->InitialVC)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnLogin.layer.cornerRadius = 15.0
        
        if (UserDefaults.standard.value(forKey: UserDefaultType.rememberMe) != nil) && UserDefaults.standard.value(forKey: UserDefaultType.rememberMe)! is Dictionary<String, Any> {
            let credentials = UserDefaults.standard.value(forKey: UserDefaultType.rememberMe)! as! Dictionary<String, Any>
            txtEmail.text = credentials["email"] as? String
            txtPassword.text = credentials["password"] as? String
            onTapRememberMe(btnRemMe)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewScrollInside.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UI Methods
    
//    func configureGoogleSignIn() {
//        //GIDSignIn.sharedInstance.clientID = AppInfo.GoogleClientID.returnAppInfo()
//        //GIDSignIn.sharedInstance?.delegate = self
//        //GIDSignIn.sharedInstance?.presentingViewController = self
//        //GIDSignIn.sharedInstance?.signIn()
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
//            let dic = [
//                "email": user.profile?.email ?? "",
//                "firstName": user.profile?.familyName ?? "",
//                "lastName": user.profile?.givenName ?? "",
//                "deviceId": AppInfo.DeviceId.returnAppInfo(),
//                "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) ?? "",
//                "socialType": "GOOGLE",
//                "socialId": user.userID ?? "",
//                "platform": AppInfo.Platform.returnAppInfo(),
//                "type": "email"
//            ]
//            print(dic)
//            socialLogin(dic: dic)
//        }
//    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                if txtEmail.text == "" {
                    lblEmailError.getEmptyValidationString(txtEmail.placeholder ?? "")
                    value = false
                }
                else {
                    /// 444 -   By Pranay
                    if !(txtEmail.text?.isValidEmail())! {
                        lblEmailError.setLeftArrow(title: Valid_Email)
                        value = false
                    } else {
                        lblEmailError.text = ""
                    }   /// 444 .   */
                    /*/// 444 -   Comment by Pranay.
                    if (txtEmail.text?.isNumber)! {
                        if !((txtEmail.text?.count)! >= MIN_MOBILE_LENGTH) {
                            lblEmailError.setLeftArrow(title: Valid_Mobile)
                            value = false
                        } else {
                            lblEmailError.text = ""
                        }
                    }else {
                        if !(txtEmail.text?.isValidEmail())! {
                            lblEmailError.setLeftArrow(title: Valid_Email)
                            value = false
                        } else {
                            lblEmailError.text = ""
                        }
                    }   /// 444 .   */
                }
            }
            else if i == 1 {
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
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapNavbarButton(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func onTapGoogleSignin(_ sender: UIButton) {
        self.view.endEditing(true)
        //configureGoogleSignIn()
    }
    
    @IBAction func onTapRememberMe(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        remMe = sender.isSelected
    }
    
    @IBAction func onTapLogin(_ sender: UIButton) {
        if checkValidation(to: 0, from: 2) {
            view.endEditing(true)
            print(Utilities.getCountryPhoneCode(country: Locale.current.regionCode!))
            userLogIn()
        }
    }
    
    @IBAction func onTapForgotPassword(_ sender: UIButton) {
        if sender.tag == 0 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
            self.view.rootNavController.pushViewController(objVC, animated: true)
        }
        else if sender.tag == 1 {
            self.navigationController?.popViewController(animated: false)
            self.initialVC!().onTapSignUp(UIButton())
        }
    }
    
    @IBAction func onTapAppleLogin(_ sender: UIButton) {
//        if #available(iOS 13.0, *) {
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName, .email]
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.performRequests()
//        }
//        else {
//            // Fallback on earlier versions
//        }
    }
    
    @IBAction func onTapDiscordTwitchLogin(_ sender: UIButton) {
        let socialLogin = SocialLoginVC()
        socialLogin.delegate = self
        socialLogin.isDiscoredLogin = sender.tag
        self.navigationController?.pushViewController(socialLogin, animated: true)
    }
    
    // MARK: Webservices
    
    func userLogIn() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userLogIn()
                }
            }
            return
        }
        
        let userName = txtEmail.text!
        let password = txtPassword.text!
        
        userDict = [
            "email": userName,
            "password": password,
            "deviceId": AppInfo.DeviceId.returnAppInfo(),
            "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
            "countryCode": Utilities.getCountryPhoneCode(country: Locale.current.regionCode!),
            "type": userName.isNumber ? "mobileNo" : "email",
            "platform": AppInfo.Platform.returnAppInfo(),
            "timeZoneOffSet": (TimeZone.current).offsetFromGMT(),
            "deviceName": UIDevice.modelName,
            "deviceOS": "iOS",
            "osVersion": UIDevice.current.systemVersion
        ]
        // .
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LOGIN, parameters: userDict) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                APIManager.sharedManager.strChatUserId = "\(response?.result?.userDetail?.id ?? 0)"
                DispatchQueue.main.async {
                    if response?.result?.isVerified == 0 {
                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                        objVC.isForgotPassword = false
                        objVC.responseOTP = Int((response?.result?.userDetail?.otp)!)!
                        objVC.userEmail = self.txtEmail.text!.isNumber ? "" : self.txtEmail.text!
                        objVC.mobileNumber = self.txtEmail.text!.isNumber ? self.txtEmail.text! : ""
//                        objVC.password = self.txtPassword.text!
                        self.navigationController?.pushViewController(objVC, animated: true)
                    }
                    else {
                        UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                        
                        if self.remMe {
                            let dictCredentials = ["email": userName, "password": password]
                            UserDefaults.standard.set(dictCredentials, forKey: UserDefaultType.rememberMe)
                        } else {
                            UserDefaults.standard.removeObject(forKey: UserDefaultType.rememberMe)
                        }
                        
                        UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
                        
                        UserDefaults.standard.synchronize()
                        self.view!.tusslyTabVC.selectedIndex = 0
                        appDelegate.isAutoLogin = true
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
            }
            else {
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
    
    /*func socialLogin(dic: [String : Any]) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.socialLogin(dic: dic)
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SOCIAL_LOGIN, parameters: dic) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
//                if self.remMe {
//                    let dictCredentials = ["email": userName, "password": password]
//                    UserDefaults.standard.set(dictCredentials, forKey: UserDefaultType.rememberMe)
//                } else {
//                    UserDefaults.standard.removeObject(forKey: UserDefaultType.rememberMe)
//                }
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    if response?.result?.isVerified == 0 {
                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyVC") as! VerifyVC
                        objVC.isForgotPassword = false
                        objVC.responseOTP = Int((response?.result?.userDetail?.otp)!)!
                        objVC.userEmail = self.txtEmail.text!.isNumber ? "" : self.txtEmail.text!
                        objVC.mobileNumber = self.txtEmail.text!.isNumber ? self.txtEmail.text! : ""
//                        objVC.password = self.txtPassword.text!
                        self.navigationController?.pushViewController(objVC, animated: true)
                    }
                    else {
//                        let appId = ALChatManager.applicationId
//                        let alUser = ALUser()
//                        alUser.applicationId = appId
//                        alUser.userId = "\(APIManager.sharedManager.user?.id ?? 0)"
//                        alUser.displayName = APIManager.sharedManager.user?.displayName
//                        alUser.imageLink = APIManager.sharedManager.user?.avatarImage
//                        ALUserDefaultsHandler.setUserId(alUser.userId)
//                        self.registerUserToApplozic(alUser: alUser)
                        
                        
                        
                        UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                        
                        UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
                        
                        UserDefaults.standard.synchronize()
                        self.view!.tusslyTabVC.selectedIndex = 0
                        appDelegate.isAutoLogin = true
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
            }
            else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    //  */
    
    
    // MARK: UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == txtEmail {
            txtPassword.becomeFirstResponder()
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
    
//    private func registerUserToApplozic(alUser: ALUser) {
//        showLoading()
//        let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
//        alChatManager.connectUser(alUser, completion: { response, error in
//            self.hideLoading()
//            if error == nil {
//                NSLog("[REGISTRATION] Applozic user registration was successful: %@ \(String(describing: response?.isRegisteredSuccessfully()))")
//                self.view!.tusslyTabVC.selectedIndex = 0
//                self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
//            } else {
//                NSLog("[REGISTRATION] Applozic user registration error: %@", error.debugDescription)
//            }
//        })
//    }
    
    //MARK: - ASAuthorizationControllerDelegate
//    @available(iOS 13.0, *)
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
//            let dic = ["email": appleIDCredential.email as Any,
//                       "firstName": appleIDCredential.fullName as Any,
//                       "lastName": "" as Any,
//                        "deviceId": AppInfo.DeviceId.returnAppInfo(),
//                        "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
//                        "socialType": "APPLE",
//                        "socialId": userIdentifier as Any,
//                        "platform": AppInfo.Platform.returnAppInfo(),
//                        "type": "email"
//
//            ]
//            socialLogin(dic: dic)
//        }
//    }
    
//    @available(iOS 13.0, *)
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("Something went wrong")
//    }
}

//// MARK: - GIDSignInUIDelegate
//extension LoginVC {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if(user != nil) {
//            let dic = ["email": user.profile?.email as Any,
//                       "firstName": user.profile?.familyName as Any,
//                       "lastName": user.profile?.givenName as Any,
//                        "deviceId": AppInfo.DeviceId.returnAppInfo(),
//                        "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any,
//                        "socialType": "GOOGLE",
//                        "socialId": user.userID as Any,
//                        "platform": AppInfo.Platform.returnAppInfo(),
//                        "type": "email"
//                        
//            ]
//            socialLogin(dic: dic)
//        }
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//        print("Error: \(error.localizedDescription)")
//    }
//}
