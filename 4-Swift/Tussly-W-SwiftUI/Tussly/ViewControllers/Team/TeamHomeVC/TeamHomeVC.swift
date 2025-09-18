//
//  TeamHomeVC.swift
//  - Displays Team related information which is divided into 3 tabs: 1. Roster, 2. Results & 3. Videos

//  Tussly
//
//  Created by Jaimesh Patel on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamHomeVC: UIViewController {

    // MARK: - Controls
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var viewBottomLine: UIView!
    @IBOutlet weak var contentView: UIView!

    // MARK: - Variables
    var selectedIndex: Int = 0 {
        didSet {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: {
                self.viewBottomLine.frame = CGRect(x: self.btnTabs[self.selectedIndex].frame.origin.x - 15 + 2, y: self.btnTabs[self.selectedIndex].frame.size.height - 1, width: self.selectedIndex == 2 ? self.btnTabs[self.selectedIndex].frame.size.width + 15 : self.btnTabs[self.selectedIndex].frame.size.width, height: self.viewBottomLine.frame.size.height)
            }) { finished in
                
            }
        }
    }
    var teamTabVC: (()->TeamTabVC)?
    var viewControllers: [UIViewController]!
    
    var intIdFromSearch : Int = 0
    
    var tusslyTabVC: (()->TusslyTabVC)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        selectedIndex = 1
        didPressTab(btnTabs[selectedIndex])
        //  By Pranay close this line
        //btnTabs[2].setTitleColor(Colors.border.returnColor(), for: .normal)
    }
    
    // MARK: - UI Methods

    func setupTabbar() {
        let teamRoster = self.storyboard?.instantiateViewController(withIdentifier: "TeamRosterVC") as! TeamRosterVC
        teamRoster.teamData = teamTabVC!().teamDetails
        teamRoster.teamUserRole = teamTabVC!().userRole
        teamRoster.teamTabVC = self.teamTabVC
        teamRoster.tusslyTabVC = self.tusslyTabVC
        
        let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamResultsVC") as! TeamResultsVC
        resultVC.teamDetailData = teamTabVC!().teamDetails
        //resultVC.intIdFromSearch = self.intIdFromSearch
        resultVC.intIdFromSearch = teamTabVC!().intIdFromSearch
        
        let videosVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamVideosVC") as! TeamVideosVC
        videosVC.teamData = teamTabVC!().teamDetails
        //videosVC.intIdFromSearch = self.intIdFromSearch
        videosVC.intIdFromSearch = teamTabVC!().intIdFromSearch
        
        viewControllers = [teamRoster, resultVC, videosVC]
    }
    
    // MARK: - Button Click Events
    @IBAction func didPressTab(_ sender: UIButton) {
        //if sender.tag != 2 {  // By Pranay Close condition
            selectedIndex = sender.tag
            
            let vc: UIViewController = viewControllers[sender.tag]
            addChild(vc)
            vc.view.frame = contentView.bounds
            if contentView.subviews.count > 0 {
                contentView.subviews[0].removeFromSuperview()
            }
            contentView.addSubview(vc.view)
            vc.didMove(toParent: self)
        //}
    }
}
