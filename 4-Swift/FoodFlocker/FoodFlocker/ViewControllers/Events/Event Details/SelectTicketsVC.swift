//
//  SelectTicketsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 08/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class SelectTicketsVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblRemainingTickets: UILabel!
    @IBOutlet weak var lblTicketsCount: UILabel!
    
    @IBOutlet weak var btnInc: UIButton!
    @IBOutlet weak var btnDec: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    
    var eventDetails: PostEventDetail?
    
    var removePanel:((Int)->Void)?
    
    var ticketsCount: Int = 0
    var isComeForCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        if self.eventDetails?.isLimitedTicket == 0 {
            self.lblRemainingTickets.isHidden = true
        }
        
        lblRemainingTickets.text = isComeForCancel ? "\((eventDetails?.tickets)!)" + " Remaining" : "\((eventDetails?.totalAvailbleTicket)!)" + " Remaining"
        
        lblTicketsCount.text = "\(ticketsCount)"
        
        let decImage = UIImage(named: "Dec")?.withRenderingMode(.alwaysTemplate)
        btnDec.setBackgroundImage(decImage, for: .normal)
        btnDec.tintColor = Colors.inactiveButton.returnColor()
        let incImage = UIImage(named: "Inc")?.withRenderingMode(.alwaysTemplate)
        btnInc.setBackgroundImage(incImage, for: .normal)
        btnInc.tintColor = Colors.themeGreen.returnColor()
        
        btnInc.isEnabled = isComeForCancel ? ((eventDetails?.tickets)! != 0 ) : (self.eventDetails?.isLimitedTicket == 0 ? true : (eventDetails?.totalAvailbleTicket)! != 0)
        btnDec.isEnabled = false
        btnProceed.isEnabled = false
        btnProceed.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    func setupUI() {
        btnProceed.layer.cornerRadius = btnProceed.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
    
    @IBAction func updateQty(_ sender: UIButton) {
        
        if sender.tag == 0 {
            ticketsCount -= 1
            btnDec.isEnabled = ticketsCount != 0
            btnDec.tintColor = btnDec.isEnabled ? Colors.themeGreen.returnColor() : Colors.inactiveButton.returnColor()
            btnInc.isEnabled = true
            btnInc.tintColor = btnInc.isEnabled ? Colors.themeGreen.returnColor() : Colors.inactiveButton.returnColor()
        } else {
            ticketsCount += 1
            btnInc.isEnabled = isComeForCancel ? eventDetails!.tickets! > ticketsCount : (self.eventDetails?.isLimitedTicket == 0 ? true : eventDetails!.totalAvailbleTicket! > ticketsCount)
            btnInc.tintColor = btnInc.isEnabled ? Colors.themeGreen.returnColor() : Colors.inactiveButton.returnColor()
            
            btnDec.isEnabled = true
            btnDec.tintColor = btnDec.isEnabled ? Colors.themeGreen.returnColor() : Colors.inactiveButton.returnColor()
        }
        
        btnProceed.isEnabled = ticketsCount == 0 ? false : true
        btnProceed.backgroundColor = ticketsCount == 0 ? Colors.inactiveButton.returnColor() : Colors.orange.returnColor()
        lblRemainingTickets.text = isComeForCancel ? "\((eventDetails?.tickets)! - ticketsCount)" + " Remaining" : "\((eventDetails?.totalAvailbleTicket)! - ticketsCount)" + " Remaining"
        
        lblTicketsCount.text = "\(ticketsCount)"
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
        isComeForCancel ? cancelTickets() : confirmTickets()
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

    func confirmTickets() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.confirmTickets()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id, "tickets": ticketsCount] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CONFIRM_EVENT_TICKETS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    if self.removePanel != nil {
                        self.removePanel!(self.ticketsCount)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    func cancelTickets() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.confirmTickets()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id, "tickets": ticketsCount] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CANCEL_EVENT_TICKETS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    if self.removePanel != nil {
                        self.removePanel!(self.ticketsCount)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}
