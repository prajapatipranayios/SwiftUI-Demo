//
//  LeagueInfoVC.swift
//  Tussly
//
//  Created by Auxano on 27/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
//import ShipBookSDK

class LeagueInfoVC: UIViewController {

    // MARK: - Variables
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var isLeagueJoinStatus : Bool = true
    var tournamentInviteLink : String = ""
    var leagueRegistrationStatus : Int? = 1
    var leagueMatchStatus : Int? = 0
    var discordLink : String? = ""
    var btnTitle: [String] = ["Overview",
                              "Match Details",
                              "Rules & Regulations",
                              "Contact",
                              "Btn-5",
                              "Btn-6",
                              "Btn-7",
                              "Btn-8"]
    var isCheckIn: Bool = false
//    fileprivate let log = ShipBook.getLogger(LeagueInfoVC.self)
    var timeSeconds = 0
    var timer = Timer()
    var isBtnTap: Bool = false
    
    // MARK: - Outlets
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet weak var btnRegisterForTournament: UIButton!
    @IBOutlet weak var lblTournamentInfo: UILabel!
    @IBOutlet weak var btnDiscord: UIButton!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var btnCheckIn: UIButton!
    @IBOutlet weak var constraintTopOverview: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for btn in btnOptions
        {
            btn.addShadow(offset: CGSize(width: 0, height: 0), color: Colors.shadow.returnColor(), radius: 5.0, opacity: 0.7)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: 0),animate: true)
        // By Pranay
        
        self.btnCheckIn.layer.cornerRadius = self.btnCheckIn.frame.height / 2
        self.btnCheckIn.isHidden = true
        
        self.btnRegisterForTournament.layer.cornerRadius = self.btnRegisterForTournament.frame.height / 2
        self.btnRegisterForTournament.isHidden = true
        
        self.btnDiscord.layer.cornerRadius = self.btnDiscord.frame.height / 2
        
        self.lblTournamentInfo.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        
        self.btnDiscord.isUserInteractionEnabled = false
        self.btnDiscord.backgroundColor = Colors.disableButton.returnColor()
        if self.discordLink != "" {
            if Utilities.verifyUrl(urlString: self.discordLink) {
                self.btnDiscord.isUserInteractionEnabled = true
                self.btnDiscord.backgroundColor = Colors.discordBtn.returnColor()
            }
        }
        
        self.constraintTopOverview.priority = .defaultLow
        
        if !isLeagueJoinStatus {
            //self.constraintTopOverview.priority = .defaultLow
            self.btnCheckIn.isHidden = true
            self.btnRegisterForTournament.isHidden = false
            if self.leagueRegistrationStatus! == 1 && self.leagueMatchStatus! == 0 {
                btnRegisterForTournament.isUserInteractionEnabled = true
                //btnRegisterForTournament.backgroundColor = Colors.disableButton.returnColor()
            } else {
                btnRegisterForTournament.isUserInteractionEnabled = false
                btnRegisterForTournament.backgroundColor = Colors.disableButton.returnColor()
            }
        }
        else {
            self.constraintTopOverview.priority = .required
            
            self.btnRegisterForTournament.isHidden = true
            
            if self.leagueTabVC!().getLeagueMatches?.match?.league?.isCheckInEnable ?? "" == "Yes" {
                self.btnCheckIn.isHidden = false
                
                self.btnCheckIn.setTitle("Check In", for: .normal)
                self.isCheckIn = false
                
                timeSeconds = (self.leagueTabVC!().getLeagueMatches?.checkInRemainingTime ?? 0) / 1000
                
                if self.timeSeconds > 0 {
                    
                    self.btnCheckIn.backgroundColor = Colors.disableButton.returnColor()
                    self.btnCheckIn.isEnabled = false
                    self.btnCheckIn.titleLabel?.textColor = UIColor.white
                    
                    //self.timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    self.timer = Timer.scheduledTimer(timeInterval: 01.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    
                    /*if (timeSeconds - 600) > 0 {
                     //lblGameCountDown.attributedText = timeFormatted(seconds: timeSeconds).setAttributedString(boldString: "Game Time Countdown:", fontSize: 13.0)
                     self.timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                     }
                     else {
                     self.btnCheckIn.backgroundColor = Colors.green.returnColor()
                     self.btnCheckIn.isEnabled = true
                     self.btnCheckIn.titleLabel?.textColor = UIColor.white
                     }
                     /// */
                }
                else {
                    self.btnCheckIn.backgroundColor = Colors.green.returnColor()
                    self.btnCheckIn.isEnabled = true
                    self.btnCheckIn.titleLabel?.textColor = UIColor.white
                    
                    let isCheckIn: Bool = (self.leagueTabVC!().getLeagueMatches?.isPlayerCheckIn ?? 0) == 1 ? true : false
                    
                    if isCheckIn {
                        self.isCheckIn = true
                        self.btnCheckIn.setTitle("Check Out", for: .normal)
                        self.btnCheckIn.backgroundColor = Colors.theme.returnColor()
                    }
                    else {
                        self.isCheckIn = false
                        self.btnCheckIn.setTitle("Check In", for: .normal)
                        self.btnCheckIn.backgroundColor = Colors.green.returnColor()
                    }
                }
            }
            else {
                self.btnCheckIn.isHidden = true
            }
            
            if (self.leagueTabVC!().getLeagueMatches?.leagueMatchStatus ?? 0 == 5) || (self.leagueTabVC!().getLeagueMatches?.leagueMatchStatus ?? 0 == 6) {
                self.btnCheckIn.backgroundColor = Colors.disableButton.returnColor()
                self.btnCheckIn.isEnabled = false
                self.btnCheckIn.titleLabel?.textColor = UIColor.white
            }
        }
        
        print(scrlView.contentSize.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func callTimer()
    {
        timeSeconds -= 1
        if timeSeconds < 0 {
            timer.invalidate()
            self.btnCheckIn.isEnabled = true
            self.btnCheckIn.backgroundColor = Colors.theme.returnColor()
            self.btnCheckIn.backgroundColor = Colors.green.returnColor()
        }
        else {
            //self.btnCheckIn.isEnabled = true
            //self.btnCheckIn.backgroundColor = Colors.theme.returnColor()
        }
    }
    
    func setContentSize() {
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onClickOptions(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let biographyVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueBiographyVC") as! LeagueBiographyVC
            biographyVC.isBio = true
            biographyVC.strTitle = "Overview"
            biographyVC.stringContent = "\(self.leagueTabVC!().getLeagueMatches?.frontEndBaseUrl ?? "")mobile-overview/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
            //mobile-overview/:leagueSlug
            //APIManager.sharedManager.content?.biographyLink ?? ""
            biographyVC.leagueInfoVC = {
                return self
            }
            self.navigationController?.pushViewController(biographyVC, animated: true)
        case 1:
            let biographyVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueBiographyVC") as! LeagueBiographyVC
            biographyVC.isBio = true
            biographyVC.strTitle = "Match Details"
            biographyVC.stringContent = "\(self.leagueTabVC!().getLeagueMatches?.frontEndBaseUrl ?? "")mobile-matchdetails/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
            //mobile-matchdetails/:leagueSlug
            biographyVC.leagueInfoVC = {
                return self
            }
            self.navigationController?.pushViewController(biographyVC, animated: true)
        case 2:
            let biographyVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueBiographyVC") as! LeagueBiographyVC
            biographyVC.isBio = true
            biographyVC.strTitle = "Rules & Regulations"
            biographyVC.stringContent = "\(self.leagueTabVC!().getLeagueMatches?.frontEndBaseUrl ?? "")mobile-rules/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
            ///mobile-rules/:leagueSlug
            biographyVC.leagueInfoVC = {
                return self
            }
            self.navigationController?.pushViewController(biographyVC, animated: true)
        case 3:
            let biographyVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueBiographyVC") as! LeagueBiographyVC
            biographyVC.isBio = true
            biographyVC.strTitle = "Contact"
            biographyVC.stringContent = "\(self.leagueTabVC!().getLeagueMatches?.frontEndBaseUrl ?? "")mobile-contact/\(APIManager.sharedManager.match?.league?.leagueSlug ?? "")"
            ///mobile-contact/:leagueSlug
            biographyVC.leagueInfoVC = {
                return self
            }
            self.navigationController?.pushViewController(biographyVC, animated: true)
        case 4:
            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueSpecificationVC") as! LeagueSpecificationVC
            self.navigationController?.pushViewController(specificationVC, animated: true)
        case 5:
            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueMatchDetailVC") as! LeagueMatchDetailVC
            self.navigationController?.pushViewController(specificationVC, animated: true)
        case 6:
            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueRulesVC") as! LeagueRulesVC
            self.navigationController?.pushViewController(specificationVC, animated: true)
        case 7:
            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueHostGuideVC") as! LeagueHostGuideVC
            self.navigationController?.pushViewController(specificationVC, animated: true)
        default:
            break
        }
    }
    
//    @IBAction func onClickOptions(_ sender: UIButton) {
//        switch sender.tag {
//        case 0:
//            let biographyVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueBiographyVC") as! LeagueBiographyVC
//            biographyVC.isBio = true
//            biographyVC.leagueInfoVC = {
//                return self
//            }
//            self.navigationController?.pushViewController(biographyVC, animated: true)
//        case 1:
//            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueContactVC") as! LeagueContactVC
//            self.navigationController?.pushViewController(specificationVC, animated: true)
//        case 2:
//            let gameDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueGamingIdVC") as! LeagueGamingIdVC
//            self.navigationController?.pushViewController(gameDetailsVC, animated: true)
//        case 3:
//            let gameDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueSocialMediaVC") as! LeagueSocialMediaVC
//            self.navigationController?.pushViewController(gameDetailsVC, animated: true)
//        case 4:
//            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueSpecificationVC") as! LeagueSpecificationVC
//            self.navigationController?.pushViewController(specificationVC, animated: true)
//        case 5:
//            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueMatchDetailVC") as! LeagueMatchDetailVC
//            self.navigationController?.pushViewController(specificationVC, animated: true)
//        case 6:
//            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueRulesVC") as! LeagueRulesVC
//            self.navigationController?.pushViewController(specificationVC, animated: true)
//        case 7:
//            let specificationVC = self.storyboard?.instantiateViewController(withIdentifier: "LeagueHostGuideVC") as! LeagueHostGuideVC
//            self.navigationController?.pushViewController(specificationVC, animated: true)
//        default:
//            break
//        }
//    }
    
    // By Pranay
    @IBAction func btnRegisterForTournamentTap(_ sender: UIButton) {
        var msg : String = ""
        if self.leagueRegistrationStatus! == 1 && self.leagueMatchStatus! == 0 {
            msg = Messages.registrationPageYourBrowserForTournament
        } else {    //if self.leagueRegistrationStatus == 13 {
            msg = Messages.registrationClose
        }
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.registerForTournament
        dialog.message = msg
        dialog.tapOK = {
            if self.leagueRegistrationStatus == 1 && self.leagueMatchStatus == 0 {
                //guard let url = URL(string: self.tournamentInviteLink) else {
                //    return
                //}
                //UIApplication.shared.open(url)
                self.getCrossLoginToken()
            }
        }
        dialog.btnYesText = Messages.ok
        if self.leagueRegistrationStatus == 1 && self.leagueMatchStatus == 0 {
            dialog.btnNoText = Messages.cancel
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func btnDiscordTap(_ sender: UIButton) {
        guard let url = URL(string: self.discordLink ?? "") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnCheckInTap(_ sender: UIButton) {
        if !self.isBtnTap {
            self.isBtnTap = true
            if self.isCheckIn {
                let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
                dialog.modalPresentationStyle = .overCurrentContext
                dialog.modalTransitionStyle = .crossDissolve
                dialog.titleText = "Check Out"
                dialog.message = "Are you sure you want to check out?"
                dialog.tapOK = {
                    print("Check Out button clicked -- API call...")
                    
                    self.checkInOut(currStatus: 0)
                }
                dialog.tapCancel = {
                    self.isBtnTap = false
                }
                dialog.btnYesText = Messages.ok
                dialog.btnNoText = Messages.cancel
                
                self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
            }
            else {
                print("Check In button clicked -- API call...")
                //self.view!.tusslyTabVC.showLoading()
                self.checkInOut(currStatus: 1)
            }
        }
    }
    
    
    
    // MARK: - API call
    
    func checkInOut(currStatus: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.checkInOut(currStatus: currStatus)
                }
            }
            return
        }
        
//        self.log.i("CHECK_IN api call. - \(APIManager.sharedManager.user?.userName ?? "")")
        self.view!.tusslyTabVC.showLoading()
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHECK_IN, parameters: ["leagueId" : self.leagueTabVC!().tournamentDetail?.id ?? 0, "status" : currStatus]) { (response: ApiResponse?, error) in
            
            DispatchQueue.main.async {
                self.view!.tusslyTabVC.hideLoading()
                if response?.status == 1 {
//                    self.log.i("CHECK_IN api call success. - \(APIManager.sharedManager.user?.userName ?? "")")
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    if currStatus == 1 {
                        self.btnCheckIn.setTitle("Check Out", for: .normal)
                        self.btnCheckIn.backgroundColor = Colors.theme.returnColor()
                        self.isCheckIn = true
                        self.leagueTabVC!().getLeagueMatches?.isPlayerCheckIn = 1
                    }
                    else {
                        self.btnCheckIn.setTitle("Check In", for: .normal)
                        self.btnCheckIn.backgroundColor = Colors.green.returnColor()
                        self.isCheckIn = false
                        self.leagueTabVC!().getLeagueMatches?.isPlayerCheckIn = 0
                    }
                }
                else {
//                    self.log.e("CHECK_IN api call fail. - \(APIManager.sharedManager.user?.userName ?? "")")
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
                self.isBtnTap = false
            }
        }
    }
    
    func getCrossLoginToken()
    {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getCrossLoginToken()
                }
                return
            }
        }
        
        let param = ["type": "tournament-register",
                     "leagueId": self.leagueTabVC!().tournamentDetail?.id ?? 0
        ] as [String: Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CROSS_PLATFORM_TOKEN, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                self.hideLoading()
                if response?.status == 1 {
                    guard let url = URL(string: response?.result?.crossLoginUrl ?? "") else {
                        return
                    }
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
