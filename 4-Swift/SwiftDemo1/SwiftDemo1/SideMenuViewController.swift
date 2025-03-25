//
//  SideMenuViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import Foundation
import UIKit

class SideMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add buttons or table view to handle navigation
    }

    @IBAction func menuItemTapped(_ sender: UIButton) {
        // Handle navigation based on the button tapped
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "DestinationViewController")

        // Present or push the destination view controller
        if let navigationController = self.parent as? UINavigationController {
            navigationController.pushViewController(destinationVC, animated: true)
        } else {
            self.present(destinationVC, animated: true, completion: nil)
        }

        // Hide the side menu
        if let mainVC = self.parent as? ViewController {
            //mainVC.toggleSideMenu(self)
        }
    }
}
