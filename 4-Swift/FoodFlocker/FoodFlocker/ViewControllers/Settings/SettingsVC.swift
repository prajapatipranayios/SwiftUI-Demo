//
//  SettingsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel

class SettingsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tvSettings: UITableView!
    
    let options = ["Notifications",
                    "History",
                    "Manage Payment",
                    "Bank Details",
                    "Change Password",
                    "Frequently Asked Questions",
                    "Legal Policy",
                    "Need Help? Contact Us",
                    "Rate App",
                    "Share App",
                    "Logout"]
    
    var fpcOptions: FloatingPanelController?
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    func setupUI() {
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Webservices

    func userLogout() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.userLogout()
                }
            }
            return
        }
                        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.USER_LOGOUT, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    UserDefaults.standard.removeObject(forKey: UserDefaultType.accessToken)
                    UserDefaults.standard.synchronize()
                    
                    let objVC = self.storyboard!.instantiateViewController(withIdentifier: "InitialVC") as! InitialVC
                    let initNavVC = UINavigationController(rootViewController: objVC)
                    initNavVC.interactivePopGestureRecognizer?.isEnabled = false
                    initNavVC.navigationBar.isHidden = true
                    
                    UIApplication.shared.keyWindow?.rootViewController = initNavVC
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
        
        cell.lblOption.text = options[indexPath.row]
        
        cell.swNotif.isHidden = indexPath.row == 0 ? false : true
        cell.ivArrow.isHidden = indexPath.row != 0 && indexPath.row <= 7 ? false : true
        
        if indexPath.row == 0 {
            cell.swNotif.isOn = UserDefaults.standard.bool(forKey: UserDefaultType.notification) ? true : false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 1: //History
                let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "HistoryVC") as? HistoryVC
                self.navigationController?.pushViewController(historyVC!, animated: true)
                break
            case 2: //Manage Payment
                let paymentVC = self.storyboard?.instantiateViewController(withIdentifier: "ManagePaymentsVC") as? ManagePaymentsVC
                self.navigationController?.pushViewController(paymentVC!, animated: true)
                break
            case 3: //Bank Details
                let bankVC = self.storyboard?.instantiateViewController(withIdentifier: "BankDetailsVC") as? BankDetailsVC
                self.navigationController?.pushViewController(bankVC!, animated: true)
                break
            case 4: //Change Password
                let changePassVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
                self.navigationController?.pushViewController(changePassVC!, animated: true)
                break
            case 5: //Frequently Asked Questions
                let faqVC = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as? FAQVC
                self.navigationController?.pushViewController(faqVC!, animated: true)
                break
            case 6: //Legal Policy
                let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagalPolicyVC") as! LeagalPolicyVC
                self.navigationController?.pushViewController(termsVC, animated: true)
                break
            case 7: //Contact Us
                let contactUsVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                self.navigationController?.pushViewController(contactUsVC, animated: true)
                break
            case 8: //Rate App
                break
            case 9: //Share App
                let text = "https://foodflockerapp.page.link/eNh4"
                let shareAll = [text] as [Any]
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true) {
                    
                }
                break
            case 10: //Logout
                if fpcOptions == nil {
                    fpcOptions = FloatingPanelController()
                    fpcOptions?.delegate = self
                    fpcOptions?.surfaceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    fpcOptions?.surfaceView.cornerRadius = 20.0
                    fpcOptions?.isRemovalInteractionEnabled = true
                    
                    blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
                    blurEffect.setValue(2, forKeyPath: "blurRadius")
                    blurView.effect = blurEffect
                    blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    self.view.addSubview(blurView)
                    blurView.isHidden = true
                }
                let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionVC") as? ChooseOptionVC
                chooseOptionVC?.isLogout = true
                chooseOptionVC?.removePanel = { selectedIndex in
                    self.fpcOptions?.removePanelFromParent(animated: false)
                    self.blurView.isHidden = true
                    if selectedIndex == 1 {
                        self.userLogout()
                    }
                }
                fpcOptions?.set(contentViewController: chooseOptionVC)
                fpcOptions?.addPanel(toParent: self, animated: true)
                blurView.isHidden = false

                break
            default:
                break
        }
    }
    
}

extension SettingsVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}
