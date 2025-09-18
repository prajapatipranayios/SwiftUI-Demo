//
//  LeagueContactVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import WebKit


class LeagueContactVC: UIViewController {

    // MARK: - Controls
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var lblWebsite: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblEmail.text = APIManager.sharedManager.leagueInfo?.contactInformation?.email
        lblMobile.text = APIManager.sharedManager.leagueInfo?.contactInformation?.phoneNumber
        lblWebsite.text = APIManager.sharedManager.leagueInfo?.contactInformation?.website
        //lblChannel.text = APIManager.sharedManager.leagueInfo?.contactInformation?.channels[0].type
    }

    // MARK: - UI Methods
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}

