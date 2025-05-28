//
//  SettingTVCell.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class SettingTVCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var swNotif: UISwitch!
    @IBOutlet weak var ivArrow: UIImageView!
    @IBOutlet weak var viewSep: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ivArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        viewSep.backgroundColor = Colors.lightGray.returnColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // Change notitfication status ON and OFF
    @IBAction func onChangeSwith(_ sender: UISwitch) {
        if sender.isOn {
            UIApplication.shared.registerForRemoteNotifications()
            UserDefaults.standard.set(true, forKey: UserDefaultType.notification)
        }else {
            UIApplication.shared.unregisterForRemoteNotifications()
            UserDefaults.standard.set(false, forKey: UserDefaultType.notification)
        }
    }
}
