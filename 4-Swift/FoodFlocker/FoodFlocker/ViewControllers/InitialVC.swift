//
//  ViewController.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 20/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class InitialVC: UIViewController {

    //Outlets
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnGoogle: GIDSignInButton!
    @IBOutlet weak var btnFacebook: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
    }

    // MARK: - UI Methods
    func setupUI() {
        btnEmail.layer.cornerRadius = btnEmail.frame.size.height / 2
        btnGoogle.layer.cornerRadius = btnGoogle.frame.size.height / 2
        btnFacebook.layer.cornerRadius = btnFacebook.frame.size.height / 2
        
        btnEmail.layer.borderWidth = 2.0
        btnEmail.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        btnEmail.setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
        
        btnGoogle.layer.masksToBounds = false
        btnGoogle.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        btnGoogle.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnGoogle.layer.shadowOpacity = 0.7
        btnGoogle.layer.shadowRadius = 5.0
        
//        btnFacebook.layer.masksToBounds = false
//        btnFacebook.layer.shadowColor = UIColor.black.cgColor
//        btnFacebook.layer.shadowOffset = CGSize(width: 3, height: 3)
//        btnFacebook.layer.shadowOpacity = 0.7
//        btnFacebook.layer.shadowRadius = 5.0

    }
        
    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance().clientID = AppInfo.GoogleClientID.returnAppInfo()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }

    // MARK: - Button Click Events
    @IBAction func onTapLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "toEnterEmail", sender: nil)
    }
    
    @IBAction func onTapGoogleSignin(_ sender: UIButton) {
        self.view.endEditing(true)
        configureGoogleSignIn()
    }
    
    @IBAction func onTapFacebookSignin(_ sender: UIButton) {
        self.view.endEditing(true)
//        self.showLoading()
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (loginResult, error) in
            
            // if we have an error display it and abort
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // make sure we have a result, otherwise abort
            guard let result = loginResult else { return }
            
            //if cancelled nothing todo
            if result.isCancelled { return }
            else {
                //login successfull, now request the fields we like to have in this case first name and last name
                GraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, picture.type(large)"]).start() {
                    (connection, result, error) in
                    //if we have an error display it and abort
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    //parse the fields out of the result
                    
                    if
                        let fields = result as? [String:Any],
                        let firstName = fields["first_name"] as? String,
                        let lastName = fields["last_name"] as? String,
                        let id = fields["id"] as? String
                    {
                        print("firstName -> \(firstName)")
                        print("lastName -> \(lastName)")
                        
                        let dictPicture = fields["picture"] as? Dictionary<String, AnyObject>
                        let dic = ["name": firstName + " " + lastName,
                                   "userName": firstName + " " + lastName,
                                   "pictureUrl": dictPicture?["data"]!["url"] as! String,
                                   "socialType": "Facebook",
                                   "socialId": id,
                                   "deviceType": AppInfo.Platform.returnAppInfo(),
                                   "deviceToken": AppInfo.DeviceId.returnAppInfo(),
                                   "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String
                        ] as [String: Any]
                        print(dic)
                        self.socialLogin(dic: dic)
                    }
                }
            }
        }
    }
    
    // MARK: Webservices
    func socialLogin(dic: [String : Any]) {
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SOCIAL_LOGIN, parameters: dic) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                APIManager.sharedManager.user = response?.result?.userDetail
                APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                DispatchQueue.main.async {
                    UserDefaults.standard.set(APIManager.sharedManager.authToken, forKey: UserDefaultType.accessToken)
                    UserDefaults.standard.synchronize()
                    
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
                    let homeNavVC = UINavigationController(rootViewController: homeVC)
                    homeNavVC.navigationBar.isHidden = true
                    UIApplication.shared.windows.first?.rootViewController = homeNavVC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension InitialVC: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(user != nil) {
            let dic = ["name": user.profile.givenName! + " " + user.profile.familyName!,
                       "userName": user.profile.name!,
                       "pictureUrl": user.profile.imageURL(withDimension: UInt(1024)).absoluteString,
                       "socialType": "Google",
                       "socialId": user.userID!,
                       "deviceType": AppInfo.Platform.returnAppInfo(),
                       "deviceToken": AppInfo.DeviceId.returnAppInfo(),
                       "fcmToken": UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as! String
            ]
            
            socialLogin(dic: dic)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Error: \(error.localizedDescription)")
    }
    
}
