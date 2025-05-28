//
//  ContactUsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 11/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        getAboutUs()
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Webservices

    func getAboutUs() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getAboutUs()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ABOUT_US, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.lblEmail.text = response?.result?.aboutUs?.email
                    self.lblPhone.text = response?.result?.aboutUs?.mobileNumber
                    self.lblAddress.text = response?.result?.aboutUs?.address
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
