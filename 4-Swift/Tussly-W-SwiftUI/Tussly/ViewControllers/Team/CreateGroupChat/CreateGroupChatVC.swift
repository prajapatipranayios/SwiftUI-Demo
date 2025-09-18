//
//  CreateGroupChatVC.swift

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CreateGroupChatVC: UIViewController {

    // MARK: - Controls
    
    
    // MARK: - Variables
    var teamTabVC: (()->TeamTabVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        teamTabVC!().selectedIndex = -1
        teamTabVC!().cvTeamTabs.selectedIndex = -1
        teamTabVC!().cvTeamTabs.reloadData()
    }
    
}
