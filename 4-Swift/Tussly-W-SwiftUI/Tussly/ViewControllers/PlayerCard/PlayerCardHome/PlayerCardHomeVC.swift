//
//  TeamHomeVC.swift
//  - Displays Team related information which is divided into 3 tabs: 1. Roster, 2. Results & 3. Videos

//  Tussly
//
//  Created by Jaimesh Patel on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class PlayerCardHomeVC: UIViewController {

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

    var playerTabVC: (()->PlayerCardTabVC)?
    
    var viewControllers: [UIViewController]!
    
    // 231 - By Pranay
    var intIdFromSearch : Int = 0
    // 231 .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
        selectedIndex = 0
        didPressTab(btnTabs[selectedIndex])
        //  By Pranay close this line
        //btnTabs[1].setTitleColor(Colors.border.returnColor(), for: .normal)
    }
    
    // MARK: - UI Methods

    func setupTabbar() {
        let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerCardResultsVC") as! PlayerCardResultsVC
        //resultVC.teamDetailData = playerTabVC!().teamDetails
        resultVC.intIdFromSearch = self.intIdFromSearch
        
        let videosVC = self.storyboard?.instantiateViewController(withIdentifier: "TeamVideosVC") as! TeamVideosVC
        videosVC.isComeFromPlayercard = true
        videosVC.intIdFromSearch = self.intIdFromSearch
        //videosVC.teamData = playerTabVC!().teamDetails
        
        viewControllers = [resultVC, videosVC]
    }
    
    // MARK: - Button Click Events
    
    @IBAction func didPressTab(_ sender: UIButton) {
        //remove below condition to enable videos tab
        //if sender.tag != 1  { // By Pranay Close condition
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
