//
//  LeagueInfoVC.swift
//  Tussly
//
//  Created by Auxano on 27/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import WebKit


class LeagueSpecificationVC: UIViewController, UIScrollViewDelegate {

    // MARK: - Variables
    var isOnline = false
    
    // MARK: - Outlets
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblRegion: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTimezone: UILabel!
    @IBOutlet weak var lblPlatform: UILabel!
    @IBOutlet weak var lblOnlineLan: UILabel!
    @IBOutlet weak var lblPVP: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblHostSystem: UILabel!
    @IBOutlet weak var lblScheduleSystem: UILabel!
    
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    @IBOutlet weak var lblForfitTime: UILabel!
    @IBOutlet weak var lblPlayoffTeam: UILabel!
    @IBOutlet weak var lblPlayoffFormat: UILabel!
    
    @IBOutlet weak var viewFormat : UIView!
    @IBOutlet weak var viewBasics: UIScrollView!
    @IBOutlet weak var viewBasicsLine: UIView!
    @IBOutlet weak var viewFormatLine: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewFormat.isHidden = true
        viewFormatLine.isHidden = true
        
        lblStartDate.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.startDate
        lblEndDate.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.registrationEndDate
        lblRegion.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.regionName
        lblCity.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.city
        lblCountry.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.country
        lblAddress.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.address
        lblTimezone.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.timezoneName
        lblPlatform.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.platforms
        lblOnlineLan.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.onlineType
        lblPVP.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.PVPSize
        lblCategory.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.category
        lblHostSystem.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.hostSystem
        lblScheduleSystem.text = APIManager.sharedManager.leagueInfo?.specification?.basic?.schedulingSystem
        
        lblDivision.text = APIManager.sharedManager.leagueInfo?.specification?.format?.divisions
        lblTeam.text = APIManager.sharedManager.leagueInfo?.specification?.format?.totalTeams
        lblForfitTime.text = APIManager.sharedManager.leagueInfo?.specification?.format?.forfietedTime
        lblPlayoffTeam.text = "\(APIManager.sharedManager.leagueInfo?.specification?.format?.teamsInPlayoffs ?? 0)"
        lblPlayoffFormat.text = APIManager.sharedManager.leagueInfo?.specification?.format?.playOffFormats
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func basicsTapped(_ sender: UIButton) {
        viewBasics.isHidden = false
        viewFormat.isHidden = true
        viewBasicsLine.isHidden = false
        viewFormatLine.isHidden = true
    }
    
    @IBAction func formatTapped(_ sender: UIButton) {
        viewBasics.isHidden = true
        viewFormat.isHidden = false
        viewBasicsLine.isHidden = true
        viewFormatLine.isHidden = false
    }
}
