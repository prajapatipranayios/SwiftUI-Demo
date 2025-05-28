//
//  LaunchScreenVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 24/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {

    //Outlets
    @IBOutlet weak var ivSplashLogo: UIImageView!

    var module = ""
    var moduleId = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ivSplashLogo.alpha = 0.0
        doAnimation()
        
        if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) {
            APIManager.sharedManager.authToken = UserDefaults.standard.value(forKey: UserDefaultType.accessToken) as! String
            
        }
    }

    // MARK: - UI Methods
    func doAnimation() {
        self.showImage()
    }
    
    func showImage() {
        
        UIView.animate(withDuration: 2.0, animations: {
            self.ivSplashLogo.alpha = 1.0
        }) { (finished) in
            
            if (UserDefaults.standard.value(forKey: UserDefaultType.accessToken) != nil) {
                self.getUserDetails()
            } else {
                let objVC = self.storyboard!.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
                let initNavVC = UINavigationController(rootViewController: objVC)
                initNavVC.interactivePopGestureRecognizer?.isEnabled = false
                initNavVC.navigationBar.isHidden = true
                
                UIApplication.shared.keyWindow?.rootViewController = initNavVC
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
                
//                self.navigationController?.pushViewController(objVC, animated: false)

//                self.view.window!.rootViewController = initNavVC
//                self.view.window!.makeKeyAndVisible()
            }
        }
    }

    // MARK: - Webservices
    
    func getUserDetails() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getUserDetails()
                }
            }
            return
        }
//        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_USER_DETAIL, parameters: nil) { (response: ApiResponse?, error) in
//            self.hideLoading()
            
            DispatchQueue.main.async {
                if response?.status == 1 {
                    
                    APIManager.sharedManager.user = response?.result?.userDetail
                    APIManager.sharedManager.authToken = (response?.result?.accessToken)!
                    APIManager.sharedManager.notificationCount = (response?.result?.notificationCount)!
                    
                    let objVC = self.storyboard!.instantiateViewController(withIdentifier: "FFTabVC") as! FFTabVC
                    if self.moduleId != 0 {
                        objVC.module = self.module
                        objVC.moduleId = self.moduleId
                    }
                    
                    let homeNavVC = UINavigationController(rootViewController: objVC)
                    homeNavVC.interactivePopGestureRecognizer?.isEnabled = false
                    homeNavVC.navigationBar.isHidden = true

                    UIApplication.shared.keyWindow?.rootViewController = homeNavVC
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                } else {
                    let objVC = self.storyboard!.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
                    let initNavVC = UINavigationController(rootViewController: objVC)
                    initNavVC.interactivePopGestureRecognizer?.isEnabled = false
                    initNavVC.navigationBar.isHidden = true
                    
                    UIApplication.shared.keyWindow?.rootViewController = initNavVC
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
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
