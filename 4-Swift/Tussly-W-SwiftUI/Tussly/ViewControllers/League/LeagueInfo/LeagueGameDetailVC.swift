//
//  LeagueInfoVC.swift
//  Tussly
//

import UIKit
import WebKit

class LeagueGameDetailVC: UIViewController, UIScrollViewDelegate {

    // MARK: - Variables
    
//    @IBOutlet weak var lblOnlineLan: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)

    }
}
